LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libopenal_static
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libopenal.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include
LOCAL_EXPORT_LDLIBS := -lOpenSLES
include $(PREBUILT_STATIC_LIBRARY)
