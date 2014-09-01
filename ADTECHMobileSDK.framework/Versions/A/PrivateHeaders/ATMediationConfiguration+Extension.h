//
//  ATMediationConfiguration+Extension.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 3/16/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//

#import <ADTECHMobileSDK/ATAdConfiguration.h>

extern NSString *const kADTECHADMOBProviderName;
extern NSString *const kADTECHIADProviderName;
extern NSString *const kADTECHMILLENNIALProviderName;
extern NSString *const kADTECHGREYSTRIPEProviderName;
extern NSString *const kADTECHVDOPIAProviderName;
extern NSString *const kADTECHRUBICONProviderName;

@interface ATAdMobConfiguration ()
@property (nonatomic, assign) BOOL throwErrorOnLoad;
@end

@interface ATAdConfiguration()
@property (nonatomic, assign) BOOL iAdThrowErrorOnLoad;
- (NSArray*)supportedMediationPartners;
@end

@interface ATMillennialConfiguration ()
@property (nonatomic, assign) BOOL throwErrorOnLoad;
@end

@interface ATGreystripeConfiguration ()
@property (nonatomic, assign) BOOL throwErrorOnLoad;
@end

@interface ATVdopiaConfiguration ()
@property (nonatomic, assign) BOOL throwErrorOnLoad;
@end

@interface ATRubiconConfiguration ()
@property (nonatomic, assign) BOOL throwErrorOnLoad;
@end
