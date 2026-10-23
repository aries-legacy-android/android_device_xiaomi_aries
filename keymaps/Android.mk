# aries key layouts and character maps.
#
# qwerty.kl is the fallback layout used for devices without their own .kl, and
# qwerty.kcm is compiled to qwerty.kcm.bin by the host kcm tool.  The other
# files must match the input device names reported by the kernel.

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := qwerty.kcm
include $(BUILD_KEY_CHAR_MAP)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := qwerty2.kcm
include $(BUILD_KEY_CHAR_MAP)

file := $(TARGET_OUT_KEYLAYOUT)/qwerty.kl
ALL_PREBUILT += $(file)
$(file): $(LOCAL_PATH)/qwerty.kl | $(ACP)
	$(transform-prebuilt-to-target)

file := $(TARGET_OUT_KEYLAYOUT)/AVRCP.kl
ALL_PREBUILT += $(file)
$(file): $(LOCAL_PATH)/AVRCP.kl | $(ACP)
	$(transform-prebuilt-to-target)

file := $(TARGET_OUT_KEYLAYOUT)/gpio-keys.kl
ALL_PREBUILT += $(file)
$(file): $(LOCAL_PATH)/gpio-keys.kl | $(ACP)
	$(transform-prebuilt-to-target)

file := $(TARGET_OUT_KEYLAYOUT)/apq8064-tabla-snd-card_Button_Jack.kl
ALL_PREBUILT += $(file)
$(file): $(LOCAL_PATH)/apq8064-tabla-snd-card_Button_Jack.kl | $(ACP)
	$(transform-prebuilt-to-target)
