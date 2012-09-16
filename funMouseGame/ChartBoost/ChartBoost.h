//
//  ChartBoost.h
//  ChartBoost
//  v2.054
//
//  Created by Kenneth Ballenegger on 8/1/11.
//  Copyright 2011 ChartBoost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@protocol ChartBoostDelegate <NSObject>
@optional

// All of the delegate methods below are optional.
// Implement them only when you need to more finely control ChartBoost's behavior.



// Called before requesting an interestitial from the back-end
// Only useful to prevent an ad from being implicitly displayed on fast app switching
- (BOOL)shouldRequestInterstitial;

// Called when an interstitial has been received, before it is presented on screen
// Return NO if showing an interstitial is currently innapropriate, for example if the user has entered the main game mode.
// This is also the method you want to use if you're going to display the interestitial yourself.
- (BOOL)shouldDisplayInterstitial:(UIView *)interstitialView;

// Called when an interstitial has failed to come back from the server
- (void)didReturnWithNoInterstitial;

// Called when the user dismisses the interstitial
// If you are displaying the add yourself, dismiss it now.
- (void)didDismissInterstitial:(UIView *)interstitialView;

// Same as above, but only called when dismissed for a close
- (void)didCloseInterstitial:(UIView *)interstitialView;

// Same as above, but only called when dismissed for a click
- (void)didClickInterstitial:(UIView *)interstitialView;


// Called when an more apps page has been received, before it is presented on screen
// Return NO if showing an interstitial is currently innapropriate, for example if the user has entered the main game mode.
// This is also the method you want to use if you're going to display the interestitial yourself.
- (BOOL)shouldDisplayMoreApps:(UIView *)moreAppsView;

// Called when a more apps page has failed to come back from the server
- (void)didReturnWithNoMoreAppsPage;

// Called when the user dismisses the more apps view
// If you are displaying the add yourself, dismiss it now.
- (void)didDismissMoreApps:(UIView *)moreAppsView;

// Same as above, but only called when dismissed for a close
- (void)didCloseMoreApps:(UIView *)moreAppsView;

// Same as above, but only called when dismissed for a click
- (void)didClickMoreApps:(UIView *)moreAppsView;


@end


@interface ChartBoost : NSObject

@property (retain) NSString *appId;
@property (retain) NSString *appSignature;
@property (assign) BOOL cache;

@property (retain) id <ChartBoostDelegate> delegate;


// Get the singleton
+ (ChartBoost *)sharedChartBoost;

// Notify ChartBoost of an install
- (void)install;

// Load an interstitial, optionally takes a location argument
- (void)loadInterstitial;
- (void)loadInterstitial:(NSString *)location;

// Shows an interstitial, should only be used if you are caching the interstitial
- (void)showInterstitial:(UIView *)view;

// Load the "More Apps" page
- (void)loadMoreApps;

@end
