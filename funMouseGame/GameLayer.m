
#import "GameLayer.h"
#import "MenuLayer.h"
#import "GameConfig.h"
#import "SimpleAudioEngine.h"
#import "Apsalar.h"
#import "Settings.h"

// HelloWorldLayer implementation
@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    //add menu layer
    MenuLayer *menu = [MenuLayer node];
    menu.gameLayerDelegate = layer;
    [scene addChild: menu];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance

- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if((self=[super init])) 
    {
        NSString *isIPadPostfix = (IsIPad ? @"HD" : @"");
        //load background
        back = [CCSprite spriteWithFile: [NSString stringWithFormat: @"back%@.png", isIPadPostfix]];
        back.position = GameCenterPos;
        
        [self addChild: back];
        
        //load mice
        
        level = [CCLabelBMFont labelWithString: @"level: 1" fntFile: [NSString stringWithFormat: @"gameFont%@.fnt", isIPadPostfix]];
        level.position = ccp(GameWidth * 0.02f, GameHeight * 0.90f); 
        level.anchorPoint = ccp(0.0f, 1.0f);
        [self addChild: level];
        
        scores = [CCLabelBMFont labelWithString: @"mice: 0" fntFile: [NSString stringWithFormat: @"gameFont%@.fnt", isIPadPostfix]];
        scores.position = ccp(GameWidth * 0.02f, GameHeight * 0.97f);
        scores.anchorPoint = ccp(0.0f, 1.0f);
        [self addChild: scores];
        
        NSString *btnName = [NSString stringWithFormat: @"playAgainBtn"];
        
        playAgainBtn = [CCMenuItemImage itemFromNormalImage: [NSString stringWithFormat: @"%@%@.png", btnName, isIPadPostfix]
                                              selectedImage: [NSString stringWithFormat: @"%@On%@.png", btnName, isIPadPostfix]
                                                     target: self
                                                   selector: @selector(playAgain)
                       ];
        
        CCMenu *playAgainMenu = [CCMenu menuWithItems: playAgainBtn, nil];
        playAgainMenu.position = ccp(0.0f, 0.0f);
        playAgainBtn.position = ccp(-GameCenterX, GameCenterY);
        [self addChild: playAgainMenu z: 1];
        
        //best result layer
        bestResult = [CCLabelBMFont labelWithString: [NSString stringWithFormat: @"Best: %i", [Settings sharedSettings].maxScore] 
                                            fntFile: [NSString stringWithFormat: @"gameFont%@.fnt", isIPadPostfix]
                     ];
        bestResult.position = ccp(GameWidth / 2.0f, -100);
        bestResult.color = ccc3(0, 0, 0);

        [self addChild: bestResult z: zBestResult];
        
        [self gameOver];
        
        //enable input
        self.isTouchEnabled = YES;
        
        //play background sound
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"back.mp3" loop: YES];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect: @"mouse0.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect: @"mouse1.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect: @"mouse2.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect: @"btnTap.mp3"];
        
        [[SimpleAudioEngine sharedEngine] setEffectsVolume: 0.7f];
        
        
        [self scheduleUpdate];
	}
	return self;
}

- (void) update: (ccTime) dt
{
    return;
}

- (void) gameOver
{
    [playAgainBtn runAction:
                            [CCMoveTo actionWithDuration: 0.3f
                                                position: ccp(GameCenterX, GameCenterY)
                            ]
    ];
    
    NSInteger bestResultEver = [Settings sharedSettings].maxScore;
    if(currentScore > bestResultEver)
    {
        //check for a new record and save if any
        [Settings sharedSettings].maxScore = currentScore;
        [[Settings sharedSettings] save];
    }
    
    bestResult.string = [NSString stringWithFormat: @"Best: %i", [Settings sharedSettings].maxScore];
    
    [bestResult runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp(GameWidth / 2.0f, GameHeight * 0.35f)]
    ];
    
    for(CCNode *node in [self children])
    {
        if(node.tag == kMouseTag)
        {
            [node stopAllActions];
            [node runAction:
                            [CCRepeatForever actionWithAction:
                                                        [CCSequence actions:
                                                                            [CCScaleTo actionWithDuration: 0.3f scale: 1.06f],
                                                                            [CCScaleTo actionWithDuration: 0.6 scale: 0.95f],
                                                                            nil
                                                        ]
                            ]
            ];
        }
    }
    
    ready = NO;
    //enable chartboost
    CanDisplayChartBoost = YES;
    //request more interstitial
    [[NSNotificationCenter defaultCenter] postNotificationName: kRequestMoreInterstitialKey object: nil];
}

- (void) increaseLevel
{
    currentLevel++;
    level.string = [NSString stringWithFormat: @"level: %i", currentLevel];
    
    NSInteger currentMouse = 1;
    for(CCNode *node in [self children])
    {
        if(node.tag == kMouseTag)
        {
            currentMouse++;
            NSInteger mouseY = (IsIPad ? 150 : 80);
            NSInteger multiplier;
            
            if(currentMouse % 2 == 0)
            {
                multiplier = -1;
            }
            
            node.position = ccp(GameCenterX + multiplier * random() % (int)GameCenterX, -mouseY);
            
            float time = 3 + (CCRANDOM_MINUS1_1() * (random() % 3));
            if(IsIPad)
            {
                time *= 2;
            }
            
            [node runAction:
                            [CCSequence actions:
                                            [CCMoveTo actionWithDuration: time
                                                                position: ccp(GameCenterX, GameHeight + mouseY)
                                            ],
                                            [CCCallFunc actionWithTarget: self selector: @selector(gameOver)],
                                            nil
                            ]
            ];
        }
    }
    
    //add one more mouse
    [self addMouse];
    currentAmountOfMice = currentLevel;
}

- (void) checkForNewLevel
{
    if(currentAmountOfMice <= 0)
    {
        [self increaseLevel];
    }
}

- (void) increaseScore
{
    currentScore++;
    scores.string = [NSString stringWithFormat: @"mice: %i", currentScore];
}

- (void) addMouse
{
    NSString *isIPadPostfix = (IsIPad ? @"HD" : @"");
    
    NSInteger mouseIndex = random() % 3;
    NSString *mouseFileName = [NSString stringWithFormat: @"mouse%i%@.png", mouseIndex, isIPadPostfix];
    
    NSInteger mouseY = (IsIPad ? 150 : 80);
    
    CCSprite *mouse = [CCSprite spriteWithFile: mouseFileName];
    NSInteger multiplier = 1;
    if(currentLevel % 2 == 0)
    {
        multiplier = -1;
    }
    
    mouse.position = ccp(GameCenterX + multiplier * random() % (int)GameCenterX, -mouseY);
    mouse.tag = kMouseTag;
    
    [self addChild: mouse];
    
    float time = 3 + (CCRANDOM_MINUS1_1() * (random() % 3));
    [mouse runAction:
                    [CCSequence actions:
                                        [CCMoveTo actionWithDuration: time
                                                            position: ccp(GameCenterX, GameHeight + mouseY - random() % 200)
                                        ],
                                        [CCCallFunc actionWithTarget: self selector: @selector(gameOver)],
                                        nil
                    ]
    ];
}

- (void) playAgain
{
    //play btn sound
    [[SimpleAudioEngine sharedEngine] playEffect: @"btnTap.mp3"];
    
    [playAgainBtn runAction:
                            [CCMoveTo actionWithDuration: 0.2f
                                                position: ccp(-GameCenterX, GameCenterY)
                            ]
    ];
    
    [bestResult runAction:
                            [CCMoveTo actionWithDuration: 0.2f
                                                position: ccp(GameCenterX, -100)
                            ]
    ];
    
    currentLevel = 1;
    currentScore = 0;

    currentAmountOfMice = currentLevel;
    
    //remove all the mice
    NSMutableArray *ar = [NSMutableArray array];
    for(NSInteger i = 0; i < self.children.count; ++i)
    {
        CCNode *node = [self.children objectAtIndex: i];
        if(node.tag == kMouseTag)
        {
            //[node stopAllActions];
            //[self removeChild: node cleanup: YES];
            [ar addObject: node];
        }
    }
    
    for(CCNode *node in ar)
    {
        [node removeFromParentAndCleanup: YES];
    }
    
    level.string = [NSString stringWithFormat: @"level: %i", currentLevel];
    scores.string = [NSString stringWithFormat: @"mice: %i", currentScore];
    
    [self addMouse];
    
    ready = YES;
    //disable chartboost;
    CanDisplayChartBoost = NO;
    
    //notify apsalar system about this event
    [Apsalar eventWithArgs: @"tryAgain",
                            @"lastLevel", [NSNumber numberWithInt: currentLevel],
                            @"lastScore", [NSNumber numberWithInt: currentScore], 
                            nil
    ];
}

#pragma mark -
#pragma mark touches

- (void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority: 0 swallowsTouches: YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!ready)
    {
        return;
    }
    
    CGPoint location = [touch locationInView: [touch view]];    
    location = [[CCDirector sharedDirector] convertToGL: location];
    NSInteger mouseY = (IsIPad ? 150 : 80);

    for(CCNode *node in [self children])
    {
        if(node.tag == kMouseTag && node.position.y > 0.05 * GameHeight) 
        {
            if(CGRectContainsPoint(node.boundingBox, location))
            {
                float time = (node.position.y / GameHeight) * 0.4;
                
                [node stopAllActions];
                [node runAction:
                                [CCSequence actions:
                                                    [CCMoveTo actionWithDuration: time position: ccp(GameCenterX, -mouseY)],
                                                    [CCCallFunc actionWithTarget: self selector: @selector(checkForNewLevel)],
                                                    nil
                                ]
                ];
                
                [self increaseScore];
                currentAmountOfMice--;
                
                //play mouse sound
                NSInteger mouseIndex = random() % 3;
                [[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"mouse%i.mp3", mouseIndex]];
                //don't check other mice with this touch
                return;
            }
        }
    }
}

- (void) pause
{
    [self onExit];
}

- (void) unpause
{
    [self onEnter];
}

@end
