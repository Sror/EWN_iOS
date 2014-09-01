//
//  ATMobileAnalytics+Constants.h
//  ADTECHMobileAnalyticsSDK
//
//  Created by ADTECH GmbH on 6/17/13.
//  Copyright (c) 2013 ADTECH GmbH. All rights reserved.
//

#import <ADTECHMobileAnalyticsSDK/ATMobileAnalytics.h>

/// the amount key used on analytics purchase event
extern NSString *const kATPurchaseEventAmountKey;

@interface ATMobileAnalytics (Constants)

+ (void)resetAppDownloadEvent;

@end
