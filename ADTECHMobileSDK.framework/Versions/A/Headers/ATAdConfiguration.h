//
//  ATAdConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 11/9/11.
//  Copyright (c) 2011 ADTECH AG. All rights reserved.
//
//  www.adtech.com 
//

#import <Foundation/Foundation.h>
#import "ATBaseConfiguration.h"

#import "ATAdMobConfiguration.h"
#import "ATMillennialConfiguration.h"
#import "ATGreystripeConfiguration.h"
#import "ATVdopiaConfiguration.h"
#import "ATRubiconConfiguration.h"

/**
 * Holds the base configuration for banner and interstitial ads. You can set here different parameters for the ad's behavior.
 * Default values are loaded from the ADTECHAdConfiguration.plist file when the ATBannerView gets created.
 *
 * The placement identifying details can be set on the concrete configuration instances ATAdtechAdConfiguration or ATGenericAdConfiguration
 * that inherit from this class.
 *
 * You can find the ADTECHAdConfiguration.plist in the Resources folder of the SDK framework. You'll need to manually include it in your application.
 * The ADTECHAdConfiguration.plist comes with preset values and you can change them to your convenience.
 *
 * Available in 1.0 and later.
 *
 * @see ATBaseConfiguration
 * @see ATAdtechAdConfiguration
 * @see ATGenericAdConfiguration
 * @see [ATBannerView configuration]
 */
@interface ATAdConfiguration : ATBaseConfiguration
{
    NSUInteger groupID;
    
    BOOL allowLocationServices;
    BOOL enableImageBannerResize;
    
    ATAdMobConfiguration *adMobConfig;
    ATMillennialConfiguration *millennialConfig;
    BOOL isiAdEnabled;
    ATGreystripeConfiguration *greystripeConfig;
    ATVdopiaConfiguration *vdopiaConfig;
	ATRubiconConfiguration *rubiconConfig;
}

/** 
 * Holds the group id of the ATBannerView. This is used to solve tilling and companion situations where two or more ads should show ads relative to each other.
 * ATBannerView objects having the same groupID will be treated in a special manner by the ad server in the sense that they will be servered ads that depend on each other or complete each other.
 * Setting it to 0 will signal that the ATBannerView does not belong to any group. Default is 0.
 * The value of the number does not matter, but what matters is the fact that two or more ATBannerView objects have the same groupID.
 * E.g. If you have 2 ATBannerView objects on the same page that shouls show companion ads, you need to set them the same groupID (not 0). It does not matter that is 100 or 234 as far as both ATBannerView objects have the same value set.
 * See the ADTECH Mobile SDK User Guide for a better undestanding of Tilling and Companion.
 *
 * Available in 1.0 and later.
 */
@property(nonatomic,readwrite) NSUInteger groupID;

/** 
 * By checking this property you can see if the configuration is valid or not. For validity the following properties are checked: _alias, domain_
 * E.g. You can use this property to make sure that the configuration is correctly set up before calling the load methon on the ATBannerView object.
 *
 * Available in 1.0 and later.
 *
 * @see [ATBannerView load]
 */
@property(nonatomic,readonly) BOOL isValid;

/**
 * You can allow ADTECH ads to use your location by settings this value to YES.
 * By default, location services are disabled for ADTECH ads. Enabling location services will allow for richer, more engaging ads.
 *
 * Available in 2.0 and later.
 */
@property(nonatomic,readwrite) BOOL allowLocationServices;

/**
 * Allows or disallows banner auto-resizing to the actual image size received for simple image ads.
 * For example, when enabled, if a banner is set to have the initial size of {320, 50} and a simple image ad is received of size {240, 40},
 * the banner will resize itself to {240, 40}. If the next ad is {320, 50}, the banner resizes itself again to {320, 50}.
 * When enabled, the banner adapts its size to the actual size of the simple image ad received. Mediated ads do not trigger resizing.
 * When the banner is about to resize it will call the [ATBannerViewDelegate willResizeAd:toSize:] on its delegate.
 * After the banner has resized it will call the [ATBannerViewDelegate didResizeAd:toSize:] on its delegate.
 *
 * Default value is NO.
 *
 * Available in 2.2.1 and later.
 */
@property(nonatomic,readwrite) BOOL enableImageBannerResize;

/**
 * When set to YES, the banner will hide itself after the first refresh interval passes. If you want to load a new ad,
 * call load on the banner and set the banner to not be hidden. The recommended place to do that is inside the
 * didFetchNextAd: callback on the delegate.
 *
 * Default value is NO.
 *
 * Available in 3.1 and later.
 *
 * @warning Be sure to set the hidden property back to NO on the banner if you want to show another ad.
 *
 * @see [ATBannerView load]
 * @see [ATBannerViewDelegate didFetchNextAd:]
 */
@property(nonatomic,readwrite) BOOL hideAfterRefreshInterval;

/**
 * Holds the configuration for the AdMob ads.
 *
 * Available in 2.0 and later.
 *
 * @see ATAdMobConfiguration
 */
@property(nonatomic,copy,readonly) ATAdMobConfiguration *adMobConfig;

/**
 * Holds the configuration for the Millennial Media ads.
 *
 * Available in 2.0 and later.
 *
 * @see ATMillennialConfiguration
 */
@property(nonatomic,copy,readonly) ATMillennialConfiguration *millennialConfig;

/**
 * Shows if iAd support is enabled or not in the SDK.
 *
 * iAd is configured using the iTunes Connect portal, but in order to know if the SDK should mediate also iAd or not,
 * you must put in the configuration file an empty section for it, named "iAdConfig". If the configuration file has this section
 * and your OS version is 4.0 or greater, iAd will be enabled.
 *
 * Available in 2.0 and later.
 */
@property(nonatomic,readonly) BOOL isiAdEnabled;

/**
 * Holds the configuration for the Greystripe ads.
 *
 * Available in 2.0 and later.
 *
 * @see ATGreystripeConfiguration
 */
@property(nonatomic,copy,readonly) ATGreystripeConfiguration *greystripeConfig;

/**
 * Holds the configuration for the Vdopia ads.
 *
 * Available in 2.0 and later.
 *
 * @see ATVdopiaConfiguration;
 */
@property(nonatomic,copy,readonly) ATVdopiaConfiguration *vdopiaConfig;

/**
 * Holds the configuration for the Rubicon (MobSmith) ads.
 *
 * Available in 3.2 and later.
 *
 * @see ATRubiconConfiguration;
 */
@property(nonatomic,copy,readonly) ATRubiconConfiguration *rubiconConfig;

@end
