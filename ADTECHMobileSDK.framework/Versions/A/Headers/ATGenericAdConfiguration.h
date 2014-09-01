//
//  ATGenericAdConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 1/23/13.
//  Copyright (c) 2013 ADTECH AG. All rights reserved.
//

#import <ADTECHMobileSDK/ADTECHMobileSDK.h>
#import "ATAdConfiguration.h"

/**
 * Holds the configuration of ads served by ad.com. You can set here the placement identification details.
 *
 * Available in 3.1 and later.
 *
 * @see ATAdConfiguration
 * @see ATBaseConfiguration
 * @see [ATBannerView configuration]
 * @see [ATInterstitialView configuration]
 */
@interface ATGenericAdConfiguration : ATAdConfiguration<NSCopying>
{
}

/**
 * The mobile placement identifier. This value uniquely identifies a placement that is configured server-side.
 *
 * Available in 3.1 and later.
 */
@property (nonatomic, copy) NSString *mpID;

/**
 * Creates a new autoreleased instance of the configuration. This is a convenience method.
 *
 * Available in 3.1 and later.
 */
+ (ATGenericAdConfiguration*)configuration;

/**
 * Checks if the string passed as parameter corresponds to the SDKs valid mobile placement ID template.
 * See the ADTECH Mobile SDK User Guide for a better understanding of the mobile placement ID description.
 *
 * Available in 3.1 and later.
 *
 * @param anID The string that will be checked if it corresponds to the mobile placement identifier template.
 *
 * @return YES if the string matches the template, NO otherwise.
 *
 * @see mpID
 */
- (BOOL)isValidMobilePlacementID:(NSString*)anID;

@end
