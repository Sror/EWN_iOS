//
//  ADTECHLog.h
//  ADTECHMobileSDK
//
//  Created by ADTECH GmbH on 6/18/13.
//  Copyright (c) 2013 ADTECH GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADTECHLog : NSObject

+ (void)createLoggers;

+ (void)setFileLoggingEnabled:(BOOL)enabled;
+ (NSString*)lastLogFilePath;

+ (void)setLoggingLevel:(int)level;

@end
