
#import "cocos2d.h"
#import "Common.h"

// HelloWorldLayer
@interface GameLayer: CCLayer <GameLayerDelegate>
{
    CCSprite *back;
    
    CCLabelBMFont *level;
    CCLabelBMFont *scores;
    CCLabelBMFont *bestResult;
    CCMenuItemImage *playAgainBtn;
    
    NSInteger currentLevel;
    NSInteger currentScore;
    NSInteger currentAmountOfMice;
    
    BOOL ready;
} 

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;
- (void) gameOver;
- (void) increaseLevel;
- (void) increaseScore;
- (void) addMouse;
- (void) playAgain;

- (void) pause;
- (void) unpause;

@end
