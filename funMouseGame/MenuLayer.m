
#import "MenuLayer.h"
#import "GameConfig.h"

@implementation MenuLayer

@synthesize gameLayerDelegate;

- (id) init
{
    if((self = [super init])) 
    {
        shadow = [CCLayerColor layerWithColor: ccc4(0, 0, 0, 255)];
        [shadow setOpacity: 0];

        [self addChild: shadow];
        
        NSString *isIPadPostfix = (IsIPad ? @"HD" : @"");
        NSString *btnName = @"pauseBtn";
        
        pauseBtn = [CCMenuItemImage itemFromNormalImage: [NSString stringWithFormat: @"%@%@.png", btnName, isIPadPostfix]
                                                           selectedImage: [NSString stringWithFormat: @"%@On%@.png", btnName, isIPadPostfix]
                                                                  target: self
                                                                selector: @selector(pause)
                                    ];
        pauseBtn.position = ccp((GameWidth / 2.0f) * 0.80, (GameHeight / 2.0f) * 0.85);
        
        btnName = @"resetBtn";
        
        resetBtn = [CCMenuItemImage itemFromNormalImage: [NSString stringWithFormat: @"%@%@.png", btnName, isIPadPostfix]
                                                           selectedImage: [NSString stringWithFormat: @"%@On%@.png", btnName, isIPadPostfix]
                                                                  target: self
                                                                selector: @selector(reset)
                                   ];
        resetBtn.position = ccp((GameWidth / 2.0f) * kResetBtnRelativeX, (GameHeight / 2.0f) * (-3));

        btnName = @"infoBtn";
        
        infoBtn = [CCMenuItemImage itemFromNormalImage: [NSString stringWithFormat: @"%@%@.png", btnName, isIPadPostfix]
                                                           selectedImage: [NSString stringWithFormat: @"%@On%@.png", btnName, isIPadPostfix]
                                                                  target: self
                                                                selector: @selector(showInfo)
                                   ];
        infoBtn.position = ccp((GameWidth / 2.0f) * kInfoBtnRelativeX, (GameHeight / 2.0f) * (-3));
        
        btnName = @"helpBtn";
        
        helpBtn = [CCMenuItemImage itemFromNormalImage: [NSString stringWithFormat: @"%@%@.png", btnName, isIPadPostfix]
                                                           selectedImage: [NSString stringWithFormat: @"%@On%@.png", btnName, isIPadPostfix]
                                                                  target: self
                                                                selector: @selector(help)
                                   ];
        helpBtn.position = ccp((GameWidth / 2.0f) * kHelpBtnRelativeX, (GameHeight / 2.0f) * (-3));
        
        //help sprite
        
        help = [CCSprite spriteWithFile: [NSString stringWithFormat: @"help%@.png", isIPadPostfix]];
        help.position = ccp(GameWidth / 2, GameHeight * 2);
        
        [self addChild: help];

        menu = [CCMenu menuWithItems: pauseBtn, infoBtn, helpBtn, resetBtn, nil];
        
        [self addChild: menu];
    }
    
    return self;
}

- (void) pause
{
    [self.gameLayerDelegate pause];
    
    [shadow runAction:
                    [CCSequence actions:
                                        [CCFadeTo actionWithDuration: 0.3 opacity: 200],
                                        nil
                    ]
    ];
    
    //place buttons
    
    [resetBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * kResetBtnRelativeX, (GameHeight / 2.0f) * kResetBtnRelativeY)]                
    ];
    
    [helpBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * kHelpBtnRelativeX, (GameHeight / 2.0f) * kHelpBtnRelativeY)]                
    ];
    
    [infoBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * kInfoBtnRelativeX, (GameHeight / 2.0f) * kInfoBtnRelativeY)]                
    ];
    
    [pauseBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * 1.2, (GameHeight / 2.0f) * 0.85)]
    ];
    
    //enable showing chartboost
    
    CanDisplayChartBoost = YES;
}

- (void) showInfo
{
    //request more apps
    [[NSNotificationCenter defaultCenter] postNotificationName: kRequestMoreAppsNotificationKey object: nil];
}

- (void) reset
{
    [shadow runAction:
                    [CCSequence actions:
                                        [CCFadeOut actionWithDuration: 0.1f],
                                        [CCCallFunc actionWithTarget: self.gameLayerDelegate selector: @selector(unpause)],
                                        nil
                    ]
    ];
    
    [resetBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * kResetBtnRelativeX, (GameHeight / 2.0f) * (-3))]                
    ];
    
    [helpBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * kHelpBtnRelativeX, (GameHeight / 2.0f) * (-3))]                
    ];
    
    [infoBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * kInfoBtnRelativeX, (GameHeight / 2.0f) * (-3))]                
    ];

    [pauseBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * 0.80, (GameHeight / 2.0f) * 0.85)]
    ];
    
    [help runAction:
                    [CCMoveTo actionWithDuration: 0.2f position: ccp(GameWidth / 2.0f, GameHeight * 2.0f)]
    ];
    
    //disable showing chartboost
    CanDisplayChartBoost = NO;
}

- (void) help
{
    [help runAction:
                    [CCMoveTo actionWithDuration: 0.2f position: ccp(GameWidth / 2.0f, GameHeight / 2.0f)]
    ];
    
    [resetBtn runAction:
                        [CCSequence actions:
                                            [CCMoveTo actionWithDuration: 0.4f position: ccp(-GameWidth, 0)],
                                            [CCPlace actionWithPosition: ccp(GameWidth * 2, GameHeight * (-0.37))],
                                            [CCMoveTo actionWithDuration: 0.5f position: ccp(GameWidth * 0.3, GameHeight * (-0.37))],
                                            nil
                        ]
    ];
    
    [helpBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * kHelpBtnRelativeX, (GameHeight / 2.0f) * (-3))]                
    ];
    
    [infoBtn runAction:
                        [CCMoveTo actionWithDuration: 0.2f position: ccp((GameWidth / 2.0f) * kInfoBtnRelativeX, (GameHeight / 2.0f) * (-3))]                
    ];
}

@end
