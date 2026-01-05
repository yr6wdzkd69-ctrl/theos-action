export ARCHS = arm64
export TARGET = iphone:clang:latest:15.0

INSTALL_TARGET_PROCESSES = ShadowTrackerExtra

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CODMMod

CODMMod_FILES = Tweak.x
CODMMod_CFLAGS = -fobjc-arc
CODMMod_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
