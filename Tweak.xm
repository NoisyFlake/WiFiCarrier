#import "Tweak.h"

static NSString *originalName = nil;
static id subscriptionContext = nil;

%hook SBTelephonyManager

-(void)operatorNameChanged:(id)arg1 name:(id)arg2 {
	subscriptionContext = arg1;
	originalName = arg2;

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

	if (subscriptionContext != nil && originalName != nil) {
		SBTelephonyManager *manager = [%c(SBTelephonyManager) sharedTelephonyManager];
		[manager operatorNameChanged:subscriptionContext name:originalName];
	}

}
%end
