//
//  ADTECHDeviceState.h
//  ADTECHMobileAnalyticsSDK
//
//  Created by ADTECH GmbH on 6/10/13.
//  Copyright (c) 2013 ADTECH GmbH. All rights reserved.
//

#import <ADTECHMobileAnalyticsSDK/ADTECHReachability.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

@class ADTECHAnalyticsEvent;

@interface ADTECHDeviceState : NSManagedObject

@property (nonatomic, readonly) NSString * carrier;
@property (nonatomic, readonly) NetworkStatus connectivityType;
@property (nonatomic, readonly) BOOL hasLocation;
@property (nonatomic, readonly) CLLocationDegrees latitude;
@property (nonatomic, readonly) CLLocationDegrees longitude;

@property (nonatomic, readonly) ADTECHAnalyticsEvent *event;

+ (instancetype)deviceState;

- (void)allowLocationServices;

@end
