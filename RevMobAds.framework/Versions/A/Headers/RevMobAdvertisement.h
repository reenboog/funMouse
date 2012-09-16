#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RevMobAdvertisement <NSObject>

@required

- (void)fetchServerDataForAppID:(NSString *)appID;

- (void)update:(NSDictionary *)dict;

@optional

- (void)show;

- (BOOL)isLoaded;

@end