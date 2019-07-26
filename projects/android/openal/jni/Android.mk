LOCAL_PATH := $(call my-dir)


########################################################################################################
include $(CLEAR_VARS)

LOCAL_MODULE     := openal
LOCAL_ARM_MODE   := arm
LOCAL_C_INCLUDES := $(LOCAL_PATH)							\
					$(LOCAL_PATH)/include 					\
					$(LOCAL_PATH)/Alc 						\
					$(LOCAL_PATH)/OpenAL32 					\
					$(LOCAL_PATH)/OpenAL32/Include

LOCAL_SRC_FILES  := \
            Alc/ALc.c \
            Alc/alcConfig.c \
            Alc/alcRing.c \
            Alc/ALu.c \
            Alc/ambdec.c \
            Alc/bformatdec.c \
            Alc/bs2b.c \
            Alc/bsinc.c \
            Alc/helpers.c \
            Alc/hrtf.c \
            Alc/mixer.c \
            Alc/mixer_c.c \
            Alc/panning.c \
            Alc/uhjfilter.c \
            \
            Alc/effects/autowah.c \
            Alc/effects/chorus.c \
            Alc/effects/compressor.c \
            Alc/effects/dedicated.c \
            Alc/effects/distortion.c \
            Alc/effects/echo.c \
            Alc/effects/equalizer.c \
            Alc/effects/flanger.c \
            Alc/effects/modulator.c \
            Alc/effects/null.c \
            Alc/effects/reverb.c \
            \
            Alc/backends/base.c \
            Alc/backends/loopback.c \
            Alc/backends/null.c \
            Alc/backends/opensl.c \
            Alc/backends/wave.c \
            \
            OpenAL32/alAuxEffectSlot.c \
            OpenAL32/alBuffer.c \
            OpenAL32/alEffect.c \
            OpenAL32/alError.c \
            OpenAL32/alExtension.c \
            OpenAL32/alFilter.c \
            OpenAL32/alListener.c \
            OpenAL32/alSource.c \
            OpenAL32/alState.c \
            OpenAL32/alThunk.c \
            OpenAL32/sample_cvt.c \
            \
            common/almalloc.c \
            common/alhelpers.c \
            common/atomic.c \
            common/rwlock.c \
            common/threads.c \
            common/uintmap.c \

LOCAL_CFLAGS     := -DAL_BUILD_LIBRARY \
                    -DAL_ALEXT_PROTOTYPES \
					-DANDROID \
                    -DHAVE_GCC_VISIBILITY \
                    -O3 \
                    -ffast-math \
					-fpic \
					-ffunction-sections \
					-funwind-tables \
					-fstack-protector \
					-fno-short-enums \
					-mfloat-abi=softfp \
                    -std=c99 \

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
LOCAL_CFLAGS	+= -mfpu=neon 
LOCAL_ARM_NEON := true
else

endif
					             
LOCAL_LDLIBS     := -lOpenSLES -llog

include $(BUILD_STATIC_LIBRARY)

