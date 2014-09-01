//
//  ATVdopiaConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG. on 3/2/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//
//  www.adtech.com 
//

#import <Foundation/Foundation.h>

typedef enum ATVdopiaBannerLocation
{
    kATVdopiaLocationTop = 1,
    kATVdopiaLocationBottom = 2,
} ATVdopiaBannerLocation; /// Available in 2.1 and later.

/**
 * Holds the configuration used for the Vdopia ads.
 * Default values are loaded from the ADTECHAdConfiguration.plist file when the ATAdConfiguration gets created. The values under the dictionary specified by the 'VdopiaConfig' key are used. 
 * The config can be changed during runtime.
 * 
 * You can find the ADTECHAdConfiguration.plist in the Resources folder of the SDK framework. You'll need to manually include it in your application.
 * The ADTECHAdConfiguration.plist comes with preset values and you can change them to your convenience.
 *
 * Available in 2.1 and later.
 *
 * @see ATAdConfiguration
 */
@interface ATVdopiaConfiguration : NSObject<NSCopying>
{
    NSString *appID;
    ATVdopiaBannerLocation bannerLocation; 
}

/**
 * The application identifier you get from your Vdopia account.
 *
 * Available in 2.1 and later.
 */
@property (nonatomic, copy, readonly) NSString *appID;

/**
 * Where the banner is placed on your view. The Vdopia SDK needs to know if you placed the banner
 * at the top or at the bottom of the screen. This applies only for banner ads.
 *
 * Possible values are 1 meaning the banner is placed at the top of the screen or 2 meaning it is placed at the bottom.
 * You can change the default value in the ATAdConfiguration file by setting the "bannerLocation" dictionary entry for Vdopia to either 1 or 2 (NSNumber).
 *
 * Available in 2.1 and later.
 */
@property (nonatomic, assign) ATVdopiaBannerLocation bannerLocation;

@end
