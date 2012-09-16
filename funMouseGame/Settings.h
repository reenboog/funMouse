
#import <Foundation/Foundation.h>

@interface Settings: NSObject
{
    NSInteger maxScore;
}

+ (Settings *) sharedSettings;

- (void) load;
- (void) save;

@property (nonatomic, assign) NSInteger maxScore;

@end