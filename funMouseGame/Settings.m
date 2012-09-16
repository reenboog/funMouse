
#import "Settings.h"
#import "GameConfig.h"

@implementation Settings

Settings *sharedSettings    = nil;

@synthesize maxScore;

+ (Settings *) sharedSettings
{
    if(!sharedSettings)
    {
        sharedSettings = [[Settings alloc] init];
    }
    
    return sharedSettings;
}

- (id) init
{
    if((self = [super init]))
    {
        //
    }
    
    return self;
}

- (void) dealloc
{
    [self save];
    [super dealloc];
}

#pragma mark -
#pragma mark load/save

- (void) load
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *maxScoreData = [defaults objectForKey: kMaxScoreKey];
    if(maxScoreData)
    {
        self.maxScore = [maxScoreData integerValue];
    }
    else
    {
        self.maxScore = 0;
    }
}

- (void) save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject: [NSNumber numberWithInteger: self.maxScore] forKey: kMaxScoreKey];
    
    [defaults synchronize];
}


@end
