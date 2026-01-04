TWEAK_NAME = CODMMod Angus

CODMMod_FILES = Tweak.x
CODMMod_CFLAGS = -fobjc-arc
CODMMod_LDFLAGS = -Wl,-rpath,@executable_path/Frameworks

Angus_FILES = Angus.x
Angus_CFLAGS = -fobjc-arc
Angus_LDFLAGS = -Wl,-rpath,@executable_path/Frameworks

include $(THEOS_MAKE_PATH)/tweak.mk
