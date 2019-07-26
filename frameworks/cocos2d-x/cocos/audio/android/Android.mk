LOCAL_PATH := $(call my-dir)

#New AudioEngine
include $(CLEAR_VARS)

LOCAL_MODULE := audio

LOCAL_MODULE_FILENAME := libaudio

LOCAL_SRC_FILES := AudioEngine-inl.cpp \
				   ../AudioEngine.cpp \
				   AudioCache.cpp \
				   AudioDecoder.cpp \
				   AudioDecoderManager.cpp \
				   AudioDecoderMp3.cpp \
				   AudioDecoderOgg.cpp \
				   AudioPlayer.cpp \
				   utils/Utils.cpp

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../include \
                    $(LOCAL_PATH)/../.. \
                    $(LOCAL_PATH)/../../platform/android \
                    $(LOCAL_PATH)/../../../external/android-specific \
                    $(LOCAL_PATH)/../../../external/android-specific/tremolo \
					$(LOCAL_PATH)/../../../external/android-specific/openal/include \
					$(LOCAL_PATH)/../../../external/android-specific/libmpg123/include
					
LOCAL_LDLIBS     := -llog
LOCAL_STATIC_LIBRARIES += libmpg123_static ext_vorbisidec libopenal_static

include $(BUILD_STATIC_LIBRARY)

#SimpleAudioEngine
include $(CLEAR_VARS)

LOCAL_MODULE := ccds

LOCAL_MODULE_FILENAME := libccds

LOCAL_SRC_FILES := cddSimpleAudioEngine.cpp \
                   ccdandroidUtils.cpp \
                   jni/cddandroidAndroidJavaEngine.cpp

LOCAL_STATIC_LIBRARIES := audio
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../include \
                    $(LOCAL_PATH)/../.. \
                    $(LOCAL_PATH)/../../platform/android

include $(BUILD_STATIC_LIBRARY)

$(call import-module,android-specific/tremolo)
$(call import-module,android-specific/mpg123/prebuilt)
$(call import-module,android-specific/openal/prebuilt)

