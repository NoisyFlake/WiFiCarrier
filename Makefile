ARCHS = arm64 arm64e
FINALPACKAGE=1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WiFiCarrier
WiFiCarrier_FILES = Tweak.xm
WiFiCarrier_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
