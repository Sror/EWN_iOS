//
//  ATBannerViewDelegate.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 11/9/11.
//  Copyright (c) 2011 ADTECH AG. All rights reserved.
//
//  www.adtech.com 
//

#import <Foundation/Foundation.h>

/**
 * Implement this protocol to be notified of different events in the lifecycle of the ad.
 *
 * Available in 1.0 and later.
 */
@protocol ATBannerViewDelegate<NSObject>
@optional

/**
 * Called when the ad will take over the screen in order to give the application the chance to pause ongoing activities.
 * This is in response for user interaction with the ad.
 *
 * Available in 1.0 and later.
 *
 * @param view The ad view that will take over the screen.
 */
- (void)shouldSuspendForAd:(ATBannerView*)view;

/**
 * Called when the ad will relinquish control of the screen as a result of the user dismissing it.
 *
 * Available in 1.0 and later.
 *
 * @param view The ad view that had control of the screen.
 */
- (void)shouldResumeForAd:(ATBannerView*)view;

/**
 * Called when the ad is about to resize. You could at this time rearrange your application content to make space for the resized ad.
 * If you want to animate the ad being resized this a good place to do it. An ad can both grow or shrink as a result of a resize.
 * Not all ads will exercise the option of resizing. Resizing ads should be placed on screens where the application content allows rearranging or can accommodate a resized ad.
 * Even if the content is not resizing, the ad will still try to resize over the application content (until closed).
 *
 * Available in 2.0 and later.
 *
 * @param view The ad view that is going to be resized
 * @param size The size the ad is going to be resized to
 *
 * @see didResizeAd:toSize:
 *
 * @warning The ad frame will be changed automatically according to the resize parameters received from the ad.
 *          The SDK will try to place the ad at the highest possible Z order within only its direct parent view in order to cover the application content.
 *          After the ad closes, its initial frame will be restored.
 */
- (void)willResizeAd:(ATBannerView*)view toSize:(CGSize)size;

/**
 * Called when the ad finished resizing to the specified size.
 *
 * Available in 2.0 and later.
 *
 * @param view The ad view that is going to be resized
 * @param size The size the ad is going to be resized to
 *
 * @see willResizeAd:toSize:
 */
- (void)didResizeAd:(ATBannerView*)view toSize:(CGSize)size;

/**
 * Called when the user interaction with the ad triggers leaving the application.
 * This can be, for example, opening a URL in Safari or Maps or another application registered to handle the URL specified by the ad.
 * You should save the state of the application when you get this call.
 *
 * Available in 1.0 and later.
 *
 * @param view The ad view that triggered leaving the application.
 */
- (void)willLeaveApplicationForAd:(ATBannerView*)view;

/**
 * Called when an ad is successfully fetched from the configured campaign.
 * You will get one call each time a new ad is fetched successfully from the campaign.
 *
 * Available in 1.0 and later.
 *
 * @param view The ad view that displays ad.
 */
- (void)didFetchNextAd:(ATBannerView*)view;

/**
 * Called when the server sends back a custom mediation marker instead of an ad. This is an opportunity for your application
 * to perform an action during the lifecycle of the banner, like showing an ad through some other SDK you use.
 * The campaign can be configured server-side to allow custom mediation with a certain fill-rate.
 * Once your app receives this callback, the SDK stops getting new ads and hands over control to the application. The app can
 * perform any kind of action it needs. It is up to the application to call load again on the banner to start receiving new ads
 * (and maybe new custom mediation opportunities). During the time the banner is stopped following
 * delivery of a custom mediation event, the last ad is kept displayed. The application can choose to hide the banner until it is time
 * to resume its delivery of ads.
 *
 * @param view The ad view that displays the ads.
 *
 * Available in 3.2 and later.
 *
 * @see [ATBannerView load]
 */
- (void)didStopOnCustomMediation:(ATBannerView*)view;

/**
 * Called when an ad could not be fetched with the currently set configuration.
 * You will get one call each time an ad failed being fetched.
 * If the configuration allows auto-refresh, a new ad is requested automatically.
 *
 * Available in 1.0 and later.
 *
 * @param view The ad view that displays the ads.
 *
 * @warning *Important:* If a request fails the SDK stops fetching ads until you call [ATBannerView load] again. See the logs in order to know the reason for the error.
 *
 * @see [ATBannerView load]
 *
 */
- (void)didFailFetchingAd:(ATBannerView*)view;

@end
