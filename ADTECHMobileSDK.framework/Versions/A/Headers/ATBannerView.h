//
//  ATBannerView.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 11/4/11.
//  Copyright (c) 2011 ADTECH AG. All rights reserved.
//
//  www.adtech.com 
//

#import <UIKit/UIKit.h>

@class ATAdConfiguration;
@protocol ATBannerViewDelegate;

/**
 * Represents one ad banner that you place on one of your views.
 *
 * For each ad banner you want to place in your app create one instance of this class.
 * The view will call the delegate when different events occur in the ad's lifecycle.
 *
 * Available in 1.0 and later.
 *
 * @see ATBannerViewDelegate
 */
@interface ATBannerView : UIView
{
}

/// The delegate gets notified of different events in the lifecycle of the ad. It is not required to be set.
///
/// Available in 1.0 and later.
///
/// @see ATBannerViewDelegate
@property (nonatomic, weak) id<ATBannerViewDelegate> delegate;

/**
 * The view controller that is the owner of the ad view being shown.
 *
 * Available in 1.0 and later.
 *
 * @warning *You must set this property before calling load. Ads won't get loaded without this property being set.*
 */
@property (nonatomic, weak) UIViewController *viewController;

/// Allows configuring the ad and specifying different parameters for better targeting.
///
/// Available in 1.0 and later.
///
/// @see ATAdConfiguration
@property (nonatomic, strong) ATAdConfiguration *configuration;

/** Set the value to reflect the visibility of the ad on screen.
 *
 * For example, when the ad goes off screen set this to NO. When it comes back into view set it to YES.
 * While the ad's visibility is NO, new ads are not fetched.
 * 
 * Available in 1.0 and later.
 *
 * @warning *Important:* You should always set the visibility of the ad when it's state of being shown changes.
 * For example, you should set the visiblity to NO when a different screen is being shown,
 * the screen is turned off by the user or the ad exits the screen being placed on a scrollable view.
 * Similarly, you should set visibility to YES when the view preseting the ad comes back into view,
 * the screen is turned on or the ad is scrolled back into the screen.
 *
 * A suggestion for managing the ad visibility is setting the value inside the viewDidAppear and viewDidDisappear methods of you view controllers.
 */
@property (nonatomic, assign) BOOL visible;

/**
 * Begins loading the ads.
 *
 * The ad should be configured before calling this method.
 * The delegate will be called on events only after this call.
 *
 * Available in 1.0 and later.
 *
 * @warning *Important:* After calling *load* the banner will automatically refresh the ads using the refreshInterval provided by the ad or by the banner configuration.
 * If a request fails the SDK stops fetching ads until you call ATBannerView::load again.
 *
 * @warning *Important:* Before calling *load* you should always check the validity of the ad configuration by checking the ads configuration isValid property.
 * Failing to ensure a valid configuration will result in the ad not being correctly loaded and displayed.
 */
- (void)load;

@end
