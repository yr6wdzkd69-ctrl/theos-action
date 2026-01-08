TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CoDScopeBot

CoDScopeBot_FILES = Tweak.x
CoDScopeBot_FRAMEWORKS = UIKit
CoDScopeBot_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
