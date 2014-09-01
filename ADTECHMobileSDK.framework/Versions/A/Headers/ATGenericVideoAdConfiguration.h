//
//  ATGenericVideoAdConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 1/23/13.
//  Copyright (c) 2013 ADTECH AG. All rights reserved.
//

#import <ADTECHMobileSDK/ADTECHMobileSDK.h>
#import "ATVideoAdConfiguration.h"

/**
 * Holds the placement configuration for video ads shown by ATMoviePlayerController that are served by ad.com.
 * You create an instance of this object and set on it the needed values in order to receive and show video ads from a placement you have configured server side.
 * Set the configuration object on the ATMoviePlayerController that you use, once it is configured.
 * If you change the configuration while already playing video content, the changes will take effect only when fetching new ads.
 *
 * Available in 3.1 and later.
 */
@interface ATGenericVideoAdConfiguration : ATVideoAdConfiguration<NSCopying>
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
 * The configuration deafult values will be loaded from the configuration file (ADTECHAdConfiguration.plist).
 *
 * Available in 3.1 and later.
 */
+ (ATGenericVideoAdConfiguration*)configuration;

@end
