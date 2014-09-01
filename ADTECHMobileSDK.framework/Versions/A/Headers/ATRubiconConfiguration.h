//
//  ATRubiconConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 4/4/13.
//  Copyright (c) 2013 ADTECH AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBSAdRequest;

/**
 * Holds the configuration used for the Rubicon ads. You can set here different parameters for the Rubicon ad's behavior and for better targeting.
 * The configuration can be changed during runtime, but values will apply only on the subsequent ads shown.
 *
 * Available in 3.2 and later.
 *
 * @see ATAdConfiguration
 */
@interface ATRubiconConfiguration : NSObject

/**
 * The request object with all the placement and targeting details, as described in the Rubicon project user guide.
 *
 * Available in 3.2 and later.
 */
@property (nonatomic, strong) MBSAdRequest *request;

@end
