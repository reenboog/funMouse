
#import "cocos2d.h"
#import "Common.h"

@interface MenuLayer: CCLayer
{
    CCMenu *menu;
    CCMenuItemImage *pauseBtn;
    CCMenuItemImage *infoBtn;
    CCMenuItemImage *helpBtn;
    CCMenuItemImage *resetBtn;
    
    CCSprite *help;
    
    CCLayerColor *shadow;
    
    id<GameLayerDelegate> gameLayerDelegate;
}

@property (nonatomic, assign) id<GameLayerDelegate> gameLayerDelegate;

- (void) pause;
- (void) showInfo;
- (void) reset;
- (void) help;

@end
