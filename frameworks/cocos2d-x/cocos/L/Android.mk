LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := cocosL_static
LOCAL_ARM_MODE := arm

LOCAL_MODULE_FILENAME := libcocosL

LOCAL_SRC_FILES := \
HPatch/patch.cpp \
aeskeys.cpp \
AntiAliasedScene.cpp \
BufferReader.cpp \
FileManager.cpp \
FileReader.cpp \
LUtils.cpp \
TMXLayer.cpp \
TMXObject.cpp \
TMXObjectGroup.cpp \
TMXTiledMap.cpp \
TMXTileSet.cpp

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH) \
			$(LOCAL_PATH)/..

LOCAL_C_INCLUDES := $(LOCAL_PATH) \
			$(LOCAL_PATH)/..

LOCAL_STATIC_LIBRARIES := cc_core

include $(BUILD_STATIC_LIBRARY)
