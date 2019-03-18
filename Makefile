include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WiFiCarrier
WiFiCarrier_FILES = Tweak.xm
WiFiCarrier_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
