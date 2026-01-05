TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DeviceReset

DeviceReset_FILES = Tweak.x
DeviceReset_CFLAGS = -fobjc-arc
DeviceReset_LDFLAGS = -Wl,-segalign,0x4000

include $(THEOS_MAKE_PATH)/tweak.mk
