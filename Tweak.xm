#import "Tweak.h"

static BOOL hasFullyLoaded = NO;

// Original values from SBTelephonyManager
static NSString *originalName = @"";
static id subscriptionContext = nil;

// User settings
static BOOL enabled;
static NSString *customCarrier;

%hook SBTelephonyManager
-(void)operatorNameChanged:(id)arg1 name:(id)arg2 {
	subscriptionContext = arg1;
	originalName = arg2;

	if (!enabled || !hasFullyLoaded) {
		%orig;
		return;
	}

	SBWiFiManager *manager = [%c(SBWiFiManager) sharedInstance];
	NSString *networkName = [manager currentNetworkName];

	if ([networkName length] > 0) {
		%orig(arg1, networkName);
	} else if ([customCarrier length] > 0) {
		%orig(arg1, customCarrier);
	} else {
		%orig;
	}

}
%end

%hook SBWiFiManager
-(void)_updateCurrentNetwork {
	%orig;

	if (enabled) {
		forceUpdate();
	}
}
%end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
	%orig;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
		hasFullyLoaded = YES;
		forceUpdate();
	});
}
%end

static void forceUpdate() {
	if (!hasFullyLoaded || subscriptionContext == nil) return;

	SBTelephonyManager *manager = [%c(SBTelephonyManager) sharedTelephonyManager];
	[manager operatorNameChanged:subscriptionContext name:originalName];
}

// ===== PREFERENCE HANDLING ===== //

static void loadPrefs() {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.wificarrier.plist"];

  if (prefs) {
    enabled = ( [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES );
    customCarrier = ( [prefs objectForKey:@"customCarrier"] ? [[prefs objectForKey:@"customCarrier"] stringValue] : nil );
  }

}

static void refreshPrefs() {
  loadPrefs();
  forceUpdate();
}

static void initPrefs() {
  // Copy the default preferences file when the actual preference file doesn't exist
  NSString *path = @"/User/Library/Preferences/com.noisyflake.wificarrier.plist";
  NSString *pathDefault = @"/Library/PreferenceBundles/WiFiCarrier.bundle/defaults.plist";
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:path]) {
    [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
  }
}

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshPrefs, CFSTR("com.noisyflake.wificarrier/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  initPrefs();
  loadPrefs();
}
