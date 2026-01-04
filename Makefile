DEBUG = 0
FINALPACKAGE = 1
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CODMMod Angus

CODMMod_FILES = Tweak.x
CODMMod_CFLAGS = -fobjc-arc

Angus_FILES = Angus.x
Angus_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
