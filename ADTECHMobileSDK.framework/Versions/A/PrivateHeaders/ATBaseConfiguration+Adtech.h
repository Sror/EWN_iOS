//
//  ATBaseConfiguration+Adtech.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 5/10/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//

#import "ATBaseConfiguration.h"

/// error descriptions used in ATAdConfiguration when the [addKey:value:error:] fails
extern NSString *kADTECHConfigGenericErrorDscr;
extern NSString *kADTECHConfigEmptyKeyErrorDscr;
extern NSString *kADTECHConfigNilKeyErrorDscr;
extern NSString *kADTECHConfigKeyNotFoundErrorDscr;
extern NSString *kADTECHConfigEmptyValuesErrorDscr;
extern NSString *kADTECHConfigInvalidCharErrorDscr;
extern NSString *kADTECHConfigValueNotStringErrorDscr;
extern NSString *kADTECHConfigMaxLengthExcededErrorDscr;
extern NSString *kADTECHConfigMaxKVPairsExcededErrorDscr;
extern NSString *kADTECHConfigMaxValueTokensPerKeyExcededErrorDscr;

extern BOOL kADTECHValidateSecureCertificates;

@interface ATBaseConfiguration ()<NSCoding>

@property(nonatomic,copy) NSString *hostApplicationName;

@property (nonatomic, readonly) NSDictionary *keyValueAdParams;

+ (NSBundle*)adtechBundle;
+ (NSBundle*)localizableBundle;

- (id)initWithNoDefaults;
- (void)copyValuesFromInstance:(ATBaseConfiguration*)instance;

- (void)reset;
- (BOOL)loadBaseConfig;

- (void)loadBaseDefaultsFrom:(ATBaseConfiguration*)defaults;

+ (void)setValidateSecureCertificates:(BOOL)validates;
+ (BOOL)validateSecureCertificates;

@end
