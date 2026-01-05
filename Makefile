TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StoreShieldFinal

StoreShieldFinal_FILES = Tweak.x SecurityBypass.x Angus.x
StoreShieldFinal_CFLAGS = -fobjc-arc
StoreShieldFinal_FRAMEWORKS = UIKit Foundation Security

include $(THEOS_MAKE_PATH)/tweak.mk
