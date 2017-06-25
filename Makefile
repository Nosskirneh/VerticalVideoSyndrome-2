include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VerticalVideoSyndrome10
VerticalVideoSyndrome10_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Camera"
