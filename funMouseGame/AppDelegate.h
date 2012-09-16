
#import <UIKit/UIKit.h>
#import "PushNotificationManager.h"
#import <RevMobAds/RevMobAds.h>

@class RootViewController;

@interface AppDelegate: NSObject <UIApplicationDelegate, PushNotificationDelegate, ChartBoostDelegate, RevMobAdsDelegate> 
{
	UIWindow			*window;
	RootViewController	*viewController;
    UINavigationController *navigationController;
    
    PushNotificationManager *pushManager;
}

- (void) requestMoreApps: (NSNotification *) notification;
- (void) requestMoreInterstitial: (NSNotification *) notification;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) PushNotificationManager *pushManager;
@property (nonatomic, retain) UINavigationController *navigationController;

@end
