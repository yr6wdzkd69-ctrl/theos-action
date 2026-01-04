ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CODMMod

CoreAppSetting_FILES = Tweak.x Angus.x SecurityBypass.x
CoreAppSetting_CFLAGS = -fobjc-arc
CoreAppSetting_LDFLAGS = -Wl,-rpath,@executable_path/Frameworks -dynamiclib

include $(THEOS_MAKE_PATH)/tweak.mk
