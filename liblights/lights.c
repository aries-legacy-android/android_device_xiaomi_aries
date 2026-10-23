/*
 * Copyright (C) 2008 The Android Open Source Project
 * Copyright (C) 2012 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Lights HAL for Xiaomi Mi 2 (aries): backlight, RGB notification LED and
 * flashlight.  The LEDs have no hardware blink, so only brightness is written.
 */

#define LOG_TAG "lights"

#include <cutils/log.h>

#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <hardware/lights.h>

/* The 2.3 header has no flashlight id; CM based frameworks use this name. */
#ifndef LIGHT_ID_FLASHLIGHT
#define LIGHT_ID_FLASHLIGHT "flashlight"
#endif

static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;
static struct light_state_t g_notification;
static struct light_state_t g_battery;

static char const* const LCD_FILE
        = "/sys/class/leds/lcd-backlight/brightness";
static char const* const RED_LED_FILE
        = "/sys/class/leds/red/brightness";
static char const* const GREEN_LED_FILE
        = "/sys/class/leds/green/brightness";
static char const* const BLUE_LED_FILE
        = "/sys/class/leds/blue/brightness";
static char const* const FLASHLIGHT_FILE
        = "/sys/class/leds/flashlight/brightness";

static int write_int(char const* path, int value)
{
    char buffer[16];
    int fd, len, ret = 0;

    fd = open(path, O_WRONLY);
    if (fd < 0) {
        LOGE("open %s failed: %s\n", path, strerror(errno));
        return -errno;
    }

    len = snprintf(buffer, sizeof(buffer), "%d\n", value);
    if (write(fd, buffer, len) != len) {
        ret = -errno;
        LOGE("write %s failed: %s\n", path, strerror(errno));
    }
    close(fd);

    return ret;
}

static int is_lit(struct light_state_t const* state)
{
    return (state->color & 0x00ffffff) != 0;
}

static int rgb_to_brightness(struct light_state_t const* state)
{
    int color = state->color & 0x00ffffff;
    return ((77 * ((color >> 16) & 0x00ff))
            + (150 * ((color >> 8) & 0x00ff))
            + (29 * (color & 0x00ff))) >> 8;
}

static int set_light_backlight(struct light_device_t* dev,
        struct light_state_t const* state)
{
    int err;

    pthread_mutex_lock(&g_lock);
    err = write_int(LCD_FILE, rgb_to_brightness(state));
    pthread_mutex_unlock(&g_lock);

    return err;
}

static int set_speaker_light_locked(struct light_state_t const* state)
{
    int err, ret = 0;

    err = write_int(RED_LED_FILE, (state->color >> 16) & 0xff);
    if (err)
        ret = err;
    err = write_int(GREEN_LED_FILE, (state->color >> 8) & 0xff);
    if (err)
        ret = err;
    err = write_int(BLUE_LED_FILE, state->color & 0xff);
    if (err)
        ret = err;

    return ret;
}

static int update_speaker_light_locked(void)
{
    if (is_lit(&g_battery))
        return set_speaker_light_locked(&g_battery);
    return set_speaker_light_locked(&g_notification);
}

static int set_light_battery(struct light_device_t* dev,
        struct light_state_t const* state)
{
    int err;

    pthread_mutex_lock(&g_lock);
    g_battery = *state;
    err = update_speaker_light_locked();
    pthread_mutex_unlock(&g_lock);

    return err;
}

static int set_light_notifications(struct light_device_t* dev,
        struct light_state_t const* state)
{
    int err;

    pthread_mutex_lock(&g_lock);
    g_notification = *state;
    err = update_speaker_light_locked();
    pthread_mutex_unlock(&g_lock);

    return err;
}

/* No separate attention LED; notification pulses are not implemented. */
static int set_light_attention(struct light_device_t* dev,
        struct light_state_t const* state)
{
    return 0;
}

/* No keyboard backlight or button backlight on this device. */
static int set_light_keyboard(struct light_device_t* dev,
        struct light_state_t const* state)
{
    return 0;
}

static int set_light_buttons(struct light_device_t* dev,
        struct light_state_t const* state)
{
    return 0;
}

static int set_light_flashlight(struct light_device_t* dev,
        struct light_state_t const* state)
{
    int err;

    pthread_mutex_lock(&g_lock);
    err = write_int(FLASHLIGHT_FILE, is_lit(state) ? 255 : 0);
    pthread_mutex_unlock(&g_lock);

    return err;
}

static int close_lights(struct light_device_t* dev)
{
    free(dev);
    return 0;
}

static int open_lights(const struct hw_module_t* module, char const* name,
        struct hw_device_t** device)
{
    int (*set_light)(struct light_device_t* dev,
            struct light_state_t const* state);
    struct light_device_t* dev;

    if (!strcmp(LIGHT_ID_BACKLIGHT, name)) {
        set_light = set_light_backlight;
    } else if (!strcmp(LIGHT_ID_KEYBOARD, name)) {
        set_light = set_light_keyboard;
    } else if (!strcmp(LIGHT_ID_BUTTONS, name)) {
        set_light = set_light_buttons;
    } else if (!strcmp(LIGHT_ID_BATTERY, name)) {
        set_light = set_light_battery;
    } else if (!strcmp(LIGHT_ID_NOTIFICATIONS, name)) {
        set_light = set_light_notifications;
    } else if (!strcmp(LIGHT_ID_ATTENTION, name)) {
        set_light = set_light_attention;
    } else if (!strcmp(LIGHT_ID_FLASHLIGHT, name)) {
        set_light = set_light_flashlight;
    } else {
        return -EINVAL;
    }

    dev = malloc(sizeof(*dev));
    if (!dev)
        return -ENOMEM;
    memset(dev, 0, sizeof(*dev));

    dev->common.tag = HARDWARE_DEVICE_TAG;
    dev->common.version = 0;
    dev->common.module = (struct hw_module_t*)module;
    dev->common.close = (int (*)(struct hw_device_t*))close_lights;
    dev->set_light = set_light;

    *device = (struct hw_device_t*)dev;
    return 0;
}

static struct hw_module_methods_t lights_module_methods = {
    .open = open_lights,
};

const struct hw_module_t HAL_MODULE_INFO_SYM = {
    .tag = HARDWARE_MODULE_TAG,
    .version_major = 1,
    .version_minor = 0,
    .id = LIGHTS_HARDWARE_MODULE_ID,
    .name = "Xiaomi Mi 2 (aries) lights",
    .author = "aries-legacy-android",
    .methods = &lights_module_methods,
};
