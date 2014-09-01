//
//  ATInterstitialViewDelegate.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 11/24/11.
//  Copyright (c) 2011 ADTECH AG. All rights reserved.
//
//  www.adtech.com 
//

#import <Foundation/Foundation.h>

@class ATInterstitialView;

/**
 * Defines the interface the delegate of an interstitial ads
 *
 * Available in 1.0 and later.
 */
@protocol ATInterstitialViewDelegate <NSObject>

/**
 * The ad was hidden from view. It gets called either when the ad is dismissed by the user or the refresh timer fires for the ad.
 * You should take down the interstitial ad from the screen at this time.
 *
 * Available in 1.0 and later.
 *
 * @param view The interstitial ad view that was shown.
 *
 * @note You must implement and take action when this method is called on the delegate.
 */
- (void)didHideInterstitialAd:(ATInterstitialView*)view;

@optional

/**
 * Called when the interstial ad is fetched from a campaign and available to be displayed.
 * You should put up the ad on the screen at this time.
 *
 * Available in 1.0 and later.
 *
 * @param view The interstitial ad view that fetched the ad.
 */
- (void)didSuccessfullyFetchInterstitialAd:(ATInterstitialView*)view;

/**
 * Called when the server sends back a custom mediation event instead of an ad. This is an opportunity for your application
 * to perform an action instead of showing an ADTECH provided interstitial, like showing an ad using another SDK you use.
 * The campaign can be configured server-side to allow custom mediation with a certain fill-rate.
 * Once your app receives this callback, the SDK will not display an interstitial and hands over control to the application.
 * The app can perform any kind of action it wants, not necessarily mediation related.
 *
 * @param view The interstitial ad view that fetched the ad.
 *
 * Available in 3.2 and later.
 *
 * @see [ATBannerViewDelegate didStopOnCustomMediation:]
 */
- (void)didFetchCustomMediation:(ATInterstitialView*)view;

/**
 * Called when an ad fails to be fetched. Usually this happens because of networking conditions and in rare cases if an exceptions occurs on the server.
 * You can call load to try again, if you think the conditions leading to the error have changed.
 *
 * Available in 1.0 and later.
 *
 * @param view The interstitial ad view that failed getting an ad.
 */
- (void)didFailFetchingInterstitialAd:(ATInterstitialView*)view;

/**
 * Called when the user interaction with the ad triggers leaving the application.
 * This can be, for example, opening a URL in Safari or Maps or another application registered to handle the URL specified by the ad.
 * You should save the state of the application when you get this call.
 *
 * Available in 1.0 and later.
 *
 * @param view The ad view that triggered leaving the application.
 *
 * @warning *Important:* If a request fails the SDK stops fetching ads until you call [ATInterstitialView load] again. See the logs in order to know the reason for the error.
 *
 * @see ATInterstitialView load
 *
 */
- (void)willLeaveApplicationForInterstitialAd:(ATInterstitialView*)view;

@end
