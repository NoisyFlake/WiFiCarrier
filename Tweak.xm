#import "Tweak.h"

static BOOL hasFullyLoaded = NO;

static NSString *originalName = nil;
static id subscriptionContext = nil;

%hook SBTelephonyManager
-(void)operatorNameChanged:(id)arg1 name:(id)arg2 {
	subscriptionContext = arg1;
	originalName = arg2;

	if (!hasFullyLoaded) {
		%orig;
		return;
	}

	SBWiFiManager *manager = [%c(SBWiFiManager) sharedInstance];
	NSString *networkName = [manager currentNetworkName];

	if ([networkName length] > 0) {
		%orig(arg1, networkName);
	} else {
		%orig;
	}

}
%end

%hook SBWiFiManager
-(void)_updateCurrentNetwork {
	%orig;
	forceUpdate();
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
	if (!hasFullyLoaded || subscriptionContext == nil || originalName == nil) return;

	SBTelephonyManager *manager = [%c(SBTelephonyManager) sharedTelephonyManager];
	[manager operatorNameChanged:subscriptionContext name:originalName];
}
