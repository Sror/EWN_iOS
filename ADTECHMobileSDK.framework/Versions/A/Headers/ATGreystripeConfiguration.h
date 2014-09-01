//
//  ATGreystripeConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 2/23/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The configuration object for Greystripe. This is part of ATAdConfiguration.
 * The values are loaded from the ADTECHAdConfiguration.plist file when the ATAdConfiguration gets created. The values under the dictionary specified by the 'GreystripeConfig' key are used.
 *
 * Available in 2.1 and later.
 *
 * @warning Interstitials are not supported.
 * @see ATAdConfiguration
 */
@interface ATGreystripeConfiguration : NSObject
{
    NSString *appID;
    NSDictionary *adCountBySize;
}

/**
 * The application identifier you get from your Greystrip account.
 *
 * Available in 2.1 and later.
 */
@property (nonatomic, copy, readonly) NSString *appID;

/**
 * Holds the number of needed ad views (banners) for each possbile Greystripe banner size.
 * By default there will be 1 banner for each size. If your application needs more than 1 banner of a certain size,
 * you need to add these values to the GreystripeConfig entry of the ADTECHAdConfiguration.plist file.
 *
 * In the adCountBySize dictionary entry under GreystripeConfig you need to add a mapping between
 * a number meaning the size of the ad and a number meaning how many such banners you'll need in your app.
 * The possible values for the size of the ad are defined by the GSAdSize enum provided with the Greystripe SDK.
 *
 * Example:
 *  key: @"Banner (320x48)"                 value: 2
 *  key: @"iPadMediumRectangle (300x250)"   value: 1
 *  key: @"iPadLeaderboard (728x90)"        value: 0
 *  key: @"iPadWideSkyscrapper (160x600)"   value: 1
 * Means that you'll need 2 small banners, 1 iPad ad view sized 300x250, NO iPad ad view sized 728x90, 1 iPad ad view sized 160x600.
 *
 * Available in 2.1 and later.
 *
 * @warning The Greystripe ads won't show as expected if you don't specify correctly the number of needed banners in your application.
 */
@property (nonatomic, copy, readonly) NSDictionary *adCountBySize;

@end
