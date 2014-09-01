//
//  ADTECHReachability+Conversion.h
//  ADTECHMobileAnalyticsSDK
//
//  Created by ADTECH GmbH on 5/29/13.
//  Copyright (c) 2013 ADTECH GmbH. All rights reserved.
//

#import "ADTECHReachability.h"

@interface ADTECHReachability (Conversion)

+ (NSString*)stringFromNetworkStatus:(NetworkStatus)status;

@end
