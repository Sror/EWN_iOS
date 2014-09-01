//
//  ATConfigurationConstants.h
//  ADTECHMobileSDK
//
//  Created by ADTECH GmbH on 6/7/13.
//  Copyright (c) 2013 ADTECH GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kATLogOff,      /// no logging will be done.
    kATLogError,    /// only errors will be logged.
    kATLogWarning,  /// errors and warnings will be logged.
    kATLogInfo,     /// errors, warnings and general information will be logged.
    kATLogVerbose   /// detailed logging.
} ATLogLevel; /// Available in 1.0 and later.

extern NSString *kATConfigErrorDomain;                          /// the error domain passed on when an error occures
extern const int kATConfigGenericError;                         /// the generic error code passed on when an undefined error occures

extern const int kATConfigEmptyKeyError;                        /// the error code passed when the key is empty
extern const int kATConfigNilKeyError;                          /// the error code passed when the key is nil
extern const int kATConfigKeyNotFoundError;                     /// the error code passed when the key is not found
extern const int kATConfigEmptyValuesError;                     /// the error code passed when the values passed are empty
extern const int kATConfigInvalidCharError;                     /// the error code passed when an invalid char is used
extern const int kATConfigValueNotStringError;                  /// the error code passed when the value is not string
extern const int kATConfigMaxLengthExcededError;                /// the error code passed when the max allowed length is exceeded
extern const int kATConfigMaxKVPairsExcededError;               /// the error code passed when the max allowed count for key-value pairs is exceeded
extern const int kATConfigMaxValueTokensPerKeyExcededError;     /// the error code passed when the max allowed tokens count per one key is exceeded

extern NSString *const kATProtocolSchemaHTTP;                   /// the HTTP scheme used for domain where events are sent
extern NSString *const kATProtocolSchemaHTTPS;                  /// the HTTPS scheme used for domain where events are sent
