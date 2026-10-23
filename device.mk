#
# Copyright (C) 2012 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

DEVICE_PATH := device/xiaomi/aries

# Internal storage is not removable.  Without this MediaProvider calls a FAT
# ioctl on the ext4 mount and crashes in a loop.
PRODUCT_CHARACTERISTICS := nosdcard

PRODUCT_PACKAGES += \
    lights.msm8960

# Init scripts and vold configuration.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/ramdisk/init.qcom.rc:root/init.qcom.rc \
    $(DEVICE_PATH)/rootdir/ramdisk/ueventd.qcom.rc:root/ueventd.qcom.rc \
    $(DEVICE_PATH)/rootdir/vold.fstab:system/etc/vold.fstab

# USB gadget setup: no UsbDeviceManager in 2.3, the script writes the sysfs.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/usb-gadget.sh:system/etc/usb-gadget.sh

# APN list; the version must match the framework one or it is dropped.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/apns-conf.xml:system/etc/apns-conf.xml

# Hardware features.
PRODUCT_COPY_FILES += \
    frameworks/base/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
    frameworks/base/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
    frameworks/base/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/base/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/base/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/base/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/base/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/base/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/base/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/base/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/base/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/base/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/base/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=320 \
    ro.opengles.version=131072 \
    dalvik.vm.heapsize=128m \
    wifi.interface=wlan0
