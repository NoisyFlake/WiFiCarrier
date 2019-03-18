#import "Tweak.h"

%hook SBTelephonyManager
-(void)_setOperatorName:(id)arg1 inSubscriptionContext:(id)arg2 {
  SBWiFiManager *manager = [%c(SBWiFiManager) sharedInstance];
  NSString *networkName = [manager currentNetworkName];

  if ([networkName length] > 0) {
    %orig(networkName, arg2);
  } else {
    %orig;
  }
}
%end

