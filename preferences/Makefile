include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WiFiCarrier
WiFiCarrier_FILES = $(wildcard *.m)
WiFiCarrier_INSTALL_PATH = /Library/PreferenceBundles
WiFiCarrier_FRAMEWORKS = CoreGraphics UIKit
WiFiCarrier_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WiFiCarrier.plist$(ECHO_END)
