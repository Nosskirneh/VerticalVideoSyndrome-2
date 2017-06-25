include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VerticalVideoSyndrome2
VerticalVideoSyndrome2_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Camera"
