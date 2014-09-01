//
//  ADTECHDeviceIdentification.h
//  ADTECHMobileSDK
//
//  Created by ADTECH GmbH on 5/28/13.
//  Copyright (c) 2013 ADTECH GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DeviceIdentifierSource)
{
	kDeviceIdentifierSourceSDK = 0,
	kDeviceIdentifierSourceOS
};

@interface ADTECHDeviceIdentification : NSObject

+ (NSString*)deviceIdentifier;

+ (DeviceIdentifierSource)deviceIdentifierSource;

+ (BOOL)isTrackingEnabled;

@end
