//
//  PushNotificationManager.m
//

#import "PushNotificationManager.h"
#import "HtmlWebViewController.h"
#import "JSON.h"

#define kServicePushNotificationUrl @"https://cp.pushwoosh.com/json/1.1/registerDevice"
#define kServiceHtmlContentFormatUrl @"https://cp.pushwoosh.com/content/%@"

@implementation PushNotificationManager

@synthesize appCode, appName, navController, lastPushDict, delegate;

- (id) initWithApplicationCode:(NSString *)_appCode appName:(NSString *)_appName{
	if(self = [super init]) {
		self.appCode = _appCode;
		self.appName = _appName;
	}
	
	return self;
}

- (id) initWithApplicationCode:(NSString *)_appCode navController:(UIViewController *) _navController appName:(NSString *)_appName{
	if (self = [super init]) {
		self.appCode = _appCode;
		self.navController = _navController;
		self.appName = _appName;
	}
	
	return self;
}

- (void) closeAction {
	[navController dismissModalViewControllerAnimated:YES];
}

- (void) showPushPage:(NSString *)pageId {
	NSString *url = [NSString stringWithFormat:kServiceHtmlContentFormatUrl, pageId];
	HtmlWebViewController *vc = [[HtmlWebViewController alloc] initWithURLString:url];
	
	// Create the navigation controller and present it modally.
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
	vc.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(closeAction)] autorelease];

	[navController presentModalViewController:navigationController animated:YES];
	
	[navigationController release];
	[vc release];
}

- (void) sendDevTokenToServer:(NSString *)deviceID {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString * appLocale = @"en";
	NSLocale * locale = (NSLocale *)CFLocaleCopyCurrent();
	NSString * localeId = [locale localeIdentifier];
	
	if([localeId length] > 2)
		localeId = [localeId stringByReplacingCharactersInRange:NSMakeRange(2, [localeId length]-2) withString:@""];
	
	[locale release]; locale = nil;
	
	appLocale = localeId;
	
	NSArray * languagesArr = (NSArray *) CFLocaleCopyPreferredLanguages();	
	if([languagesArr count] > 0)
	{
		NSString * value = [languagesArr objectAtIndex:0];
		
		if([value length] > 2)
			value = [value stringByReplacingCharactersInRange:NSMakeRange(2, [value length]-2) withString:@""];
		
		appLocale = value;
	}
	
	[languagesArr release]; languagesArr = nil;

	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:appCode forKey:@"application"];
	[dict setObject:[NSNumber numberWithInt:1] forKey:@"device_type"];
	[dict setObject:deviceID forKey:@"device_id"];
	[dict setObject:appLocale forKey:@"language"];
	
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	[request setObject:dict forKey:@"request"];
	
	SBJSON *json = [[SBJSON alloc] init];
	
	//create JSON data 
	NSError *error = nil;
	NSString *jsonRequestData = [json stringWithObject:request allowScalar:YES error:&error];
	
	if (error) {
		NSLog(@"Send Data Error: %@", error);
		return;
	}
	
	NSLog(@"Sending request: %@", jsonRequestData);
	NSLog(@"Opening url: %@", kServicePushNotificationUrl);
	
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kServicePushNotificationUrl]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setHTTPBody:[jsonRequestData dataUsingEncoding:NSUTF8StringEncoding]];
	
	//Send data to server
	NSURLResponse *response = nil;
	NSData * responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	[urlRequest release]; urlRequest = nil;
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSLog(@"Response string: %@", responseString);
	[responseString release]; responseString = nil;
	
	NSLog(@"Error: %@", error);
	NSLog(@"Registered for push notifications: %@", deviceID);
	
	[pool release]; pool = nil;
}

- (void) handlePushRegistration:(NSData *)devToken {
	NSMutableString *deviceID = [NSMutableString stringWithString:[devToken description]];
	
	//Remove <, >, and spaces
	[deviceID replaceOccurrencesOfString:@"<" withString:@"" options:1 range:NSMakeRange(0, [deviceID length])];
	[deviceID replaceOccurrencesOfString:@">" withString:@"" options:1 range:NSMakeRange(0, [deviceID length])];
	[deviceID replaceOccurrencesOfString:@" " withString:@"" options:1 range:NSMakeRange(0, [deviceID length])];
	
	[[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"PWPushUserId"];
	
	[self performSelectorInBackground:@selector(sendDevTokenToServer:) withObject:deviceID];
}

- (NSString *) getPushToken {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"PWPushUserId"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != 1)
		return;

	NSString *htmlPageId = [lastPushDict objectForKey:@"h"];
	if(htmlPageId) {
		[self showPushPage:htmlPageId];
	}
	
	[delegate onPushAccepted:self];
}

- (BOOL) handlePushReceived:(NSDictionary *)userInfo {
	BOOL isPushOnStart = NO;
	NSDictionary *pushDict = [userInfo objectForKey:@"aps"];
	if(!pushDict) {
		//try as launchOptions dictionary
		userInfo = [userInfo objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		pushDict = [userInfo objectForKey:@"aps"];
		isPushOnStart = YES;
	}
	
	if (!pushDict)
		return NO;
	
	self.lastPushDict = userInfo;
	
	//check if the app is really running
	if([[UIApplication sharedApplication] respondsToSelector:@selector(applicationState)] && [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
		isPushOnStart = YES;
	}
	
	if([delegate respondsToSelector:@selector(onPushReceived: onStart:)] ) {
		[delegate onPushReceived:self onStart:isPushOnStart];
		return YES;
	}

	NSString *alertMsg = [pushDict objectForKey:@"alert"];
//	NSString *badge = [pushDict objectForKey:@"badge"];
//	NSString *sound = [pushDict objectForKey:@"sound"];
	NSString *htmlPageId = [userInfo objectForKey:@"h"];
//	NSString *customData = [userInfo objectForKey:@"u"];
	
	//the app is running, display alert only
	if(!isPushOnStart) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.appName message:alertMsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return YES;
	}
	
	if(htmlPageId) {
		[self showPushPage:htmlPageId];
	}
	
	[delegate onPushAccepted:self];
	return YES;
}

- (NSDictionary *) getApnPayload {
	return [self.lastPushDict objectForKey:@"aps"];
}

- (NSString *) getCustomPushData {
	return [self.lastPushDict objectForKey:@"u"];
}

- (void) dealloc {
	self.delegate = nil;
	self.appCode = nil;
	self.navController = nil;
	
	[super dealloc];
}

@end
