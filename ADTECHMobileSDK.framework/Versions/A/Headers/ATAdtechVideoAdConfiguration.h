//
//  ATAdtechVideoAdConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 1/22/13.
//  Copyright (c) 2013 ADTECH AG. All rights reserved.
//

#import <ADTECHMobileSDK/ADTECHMobileSDK.h>
#import "ATVideoAdConfiguration.h"

/**
 * Holds the placement configuration for video ads shown by ATMoviePlayerController that are served by ADTECH.
 * You create an instance of this object and set on it the needed values in order to receive and show video ads from a placement you have configured server side.
 * Set the configuration object on the ATMoviePlayerController that you use, once it is configured.
 * If you change the configuration while already playing video content, the changes will take effect only when fetching new ads.
 *
 * Available in 3.1 and later.
 */
@interface ATAdtechVideoAdConfiguration : ATVideoAdConfiguration<NSCopying>
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
 * The configuration default values will be loaded from the configuration file (ADTECHAdConfiguration.plist).
 *
 * Available in 3.1 and later.
 */
+ (ATAdtechVideoAdConfiguration*)configuration;

@end
