
#import "cocos2d.h"
#import "ChartBoost.h"
#import "Apsalar.h"

#import "Settings.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "GameLayer.h"
#import "RootViewController.h"

@implementation AppDelegate

@synthesize window;
@synthesize pushManager;
@synthesize navigationController;

- (void)dealloc {
	[[CCDirector sharedDirector] end];
    [navigationController release];
    [pushManager release];
	[window release];
	[super dealloc];
}

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    return YES;
//}
//
//- (void) applicationDidFinishLaunching:(UIApplication*)application
//{
	// Init the window
    //load settings
    [[Settings sharedSettings] load];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //apply global constants according to the device type
    IsIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if(IsIPad)
    {
        GameWidth         = kScreenWidthHD;
        GameHeight        = kScreenHeightHD;
        GameCenterX       = GameWidth / 2.0f;
        GameCenterY       = GameHeight / 2.0f;
    }
    
    GameCenterPos   = ccp(GameCenterX, GameCenterY);
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS: NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
    self.navigationController = [[UINavigationController alloc] init];
    self.navigationController.navigationBarHidden = YES;

    window.rootViewController = navigationController;
	//[window addSubview: viewController.view];
    
    [self.navigationController pushViewController: viewController animated: NO];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [GameLayer scene]];
    
    [Apsalar startSession: @"McAppTeam" withKey: @"yrGJruOl"];
    
    //enable push woosh manager
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                                (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)
    ];
    
    //initialize push manager instance
    pushManager = [[PushNotificationManager alloc] initWithApplicationCode:@"4ed5f46ddba033.67399018" navController:self.navigationController appName:@"funMouseGame"];
	pushManager.delegate = self;
	[pushManager handlePushReceived: launchOptions];
    
    //subscrive for reuesting more ads
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(requestMoreApps:)
                                                 name: kRequestMoreAppsNotificationKey
                                               object: nil
    ];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(requestMoreInterstitial:)
                                                 name: kRequestMoreInterstitialKey
                                               object: nil
    ];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
    
    ChartBoost *cb = [ChartBoost sharedChartBoost];
    cb.delegate = self;
    
    cb.appId = @"4ebc202bcb60156707000000";
    cb.appSignature = @"6df8afe29fb3ffb3bf7a26ecc02748e9883e7cb2";
    
    // Notify an install
    [cb install];
    
    // Load interstitial
    [cb loadInterstitial];
    
    //[cb loadMoreApps];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    //save settings
    [[Settings sharedSettings] save];
    //remove app from notification center for chartboost
    [[NSNotificationCenter defaultCenter] removeObserver: self name: kRequestMoreAppsNotificationKey object: nil];

	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}



#pragma mark -
#pragma mark push notifications

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    [pushManager handlePushRegistration:devToken];
    
    //you might want to send it to your backend if you use remote integration
    NSString *token = [pushManager getPushToken];
    NSLog(@"Push token: %@", token);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error registering for push notifications. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [pushManager handlePushReceived:userInfo];
}

- (void) onPushAccepted:(PushNotificationManager *)manager 
{
    //Handle Push Notification here
    NSString *pushExtraData = [manager getCustomPushData];
	if(pushExtraData) 
    {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Push Extra Data"
                                                        message: pushExtraData
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel" 
                                              otherButtonTitles: @"OK", nil
                             ];
		[alert show];
		[alert release];
	}
}

#pragma mark -
#pragma mark chartboost

- (BOOL)shouldDisplayInterstitial: (UIView *) interstitialView
{
    return CanDisplayChartBoost;
}

- (BOOL)shouldDisplayMoreApps:(UIView *)moreAppsView
{
    return CanDisplayChartBoost;
}

- (void) requestMoreApps: (NSNotification *) notification
{
    [[ChartBoost sharedChartBoost] loadMoreApps];
}

- (void) requestMoreInterstitial: (NSNotification *) notification
{
    [[ChartBoost sharedChartBoost] loadInterstitial];
}

@end
