//
//  ATAdtechAdConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 1/21/13.
//  Copyright (c) 2013 ADTECH AG. All rights reserved.
//

#import <ADTECHMobileSDK/ADTECHMobileSDK.h>
#import "ATAdConfiguration.h"

/**
 * Holds the specific configuration of ads served by ADTECH. You can set here the placement identification details.
 * Default values are loaded from the ADTECHAdConfiguration.plist file when you create a new instance of the configuration.
 *
 * You can find the ADTECHAdConfiguration.plist in the Resources folder of the SDK framework. You'll need to manually include it in your application.
 * The ADTECHAdConfiguration.plist comes with preset values and you can change them to your convenience.
 *
 * Available in 3.1 and later.
 *
 * @see ATAdConfiguration
 * @see ATBaseConfiguration
 * @see [ATBannerView configuration]
 * @see [ATInterstitialView configuration]
 */
@interface ATAdtechAdConfiguration : ATAdConfiguration<NSCopying>
{
}

/**
 * Holds the network id of the ad provider. This is configured on the ADTECH IQ server.
 * The default value will be loaded from the *ADTECHAdConfiguration.plist* property file upon ATBannerView creation and you can change this value anytime at runtime.
 * By changing the value at runtime you can configure different networkIDs for different ADTECH objects (ATBannerView, ATInterstitialView, ATMoviePlayerController).
 *
 * Available in 1.0 and later.
 */
@property(nonatomic,readwrite) NSUInteger networkID;

/**
 * Holds the sub-network id of the ad provider. This is configured on the Adtech IQ server.
 * The default value will be loaded from the *ADTECHAdConfiguration.plist* property file upon ATBannerView creation and you can change this value anytime at runtime.
 * By changing the value at runtime you can configure different subNetworkIDs for different ADTECH objects (ATBannerView, ATInterstitialView, ATMoviePlayerController).
 *
 * Available in 1.0 and later.
 */
@property(nonatomic,readwrite) NSUInteger subNetworkID;

/**
 * Holds the alias of a placement. The alias uniquely identifies a banner, interstitial or video ad setup within the application.
 * The alias typically has 3 components separated by the '-' character. The components are as follows:
 *     *description*: identifies the screen where the ad view is located within the app. _(e.g. home, map, results, ...)_
 *     *position*: identifies the position of the ad within the screen. _(e.g. top, bottom, middle, other, ...)_
 *     *size*: defines the size of the ad and it's usually a number
 * By default this value is *nil* making the configuration invalid and you need to programmatically specify it at runtime before the ATBannerView is loaded.
 * The server will use this value to look up and return only those ads the match the placement of the ad within the app.
 *
 * Available in 1.0 and later.
 *
 * @warning The alias is validated against nil and empty string (@""), all other values are considered valid.
 * @see See the ADTECH Mobile SDK User Guide for a better understanding of the alias.
 */
@property(nonatomic,copy) NSString *alias;

/**
 * Checks if the string passed as parameter corresponds to the SDKs valid alias template.
 * See the ADTECH Mobile SDK User Guide for a better understanding of the alias description.
 *
 * Available in 1.0 and later.
 *
 * @param anAlias The string that will be checked if it corresponds to the alias template.
 *
 * @return YES if the string matches the alias template, NO otherwise.
 *
 * @see alias
 */
- (BOOL)isValidAlias:(NSString*)anAlias;

/**
 * Creates a new autoreleased instance of the configuration. This is a convenience method.
 * The configuration values will be loaded from the configuration file (ADTECHAdConfiguration.plist).
 *
 * Available in 3.1 and later.
 */
+ (ATAdtechAdConfiguration*)configuration;

@end
