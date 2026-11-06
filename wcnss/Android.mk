LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := wcnss_trigger.c
LOCAL_MODULE := wcnss_trigger
LOCAL_MODULE_TAGS := optional

include $(BUILD_EXECUTABLE)
