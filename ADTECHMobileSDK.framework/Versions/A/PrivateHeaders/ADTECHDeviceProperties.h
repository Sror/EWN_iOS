//
//  ADTECHDeviceProperties.h
//  ADTECHMobileAnalyticsSDK
//
//  Created by ADTECH GmbH on 6/10/13.
//  Copyright (c) 2013 ADTECH GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreGraphics/CoreGraphics.h>

@class ADTECHAnalyticsEvent;

@interface ADTECHDeviceProperties : NSManagedObject

@property (nonatomic, readonly) NSString * applicationVersion;
@property (nonatomic, readonly) NSString * os;

@property (nonatomic, readonly) NSString * manufacturer;
@property (nonatomic, readonly) NSString * model;

@property (nonatomic, readonly) CGFloat screenWidth;
@property (nonatomic, readonly) CGFloat screenHeight;
@property (nonatomic, readonly) CGFloat screenDensity;

@property (nonatomic, readonly) ADTECHAnalyticsEvent *event;

+ (instancetype)deviceProperties;

@end
