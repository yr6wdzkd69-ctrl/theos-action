# دعم معالج A13 (arm64e)
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AntiReport
AntiReport_FILES = Tweak.x
AntiReport_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk
