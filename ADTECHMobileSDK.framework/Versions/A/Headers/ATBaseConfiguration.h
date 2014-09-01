//
//  ATBaseConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 5/10/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATConfigurationConstants.h"

/**
 * Holds the generic configuration for ADTECH services.
 *
 * Available in 2.2 and later.
 */
@interface ATBaseConfiguration : NSObject
{
    NSString *hostApplicationName;
    NSString *schema;
	NSString *domain;
	NSUInteger port;
	BOOL openLandingPagesThroughBrowser;
}

/**
 * Holds the name of the application where the Adtech Professional SDK is integrated and used.
 * The property is readonly and its value is loaded from the *ADTECHAdConfiguration.plist* when the corresponding ADTECH object (ATBannerView, ATInterstitialView, ATMoviePlayerController) is created.
 * You need to manually ad the name of the host application into the *ADTECHAdConfiguration.plist* property file.
 *
 * Available in 1.0 and later.
 * 
 * @warning In case that different campaigns are needed for different versions of the same app you can customize this name by building in the app version as well (e.g. "MyHostApplication_v1.0" or "MyHostApplication1.0")
 * You need to make sure the campaigns targeting this separate versions also have the same description for the targeted application.
 */
@property(nonatomic,copy,readonly) NSString *hostApplicationName;

/**
 * Holds the protocol schema to be used when creating the request for the ad. Typically its value will be either @"http" (kATProtocolSchemaHTTP) or @"https" (kATProtocolSchemaHTTPS).
 * All requests explicitly made by the SDK will use this protocol schema.
 *
 * The default value will be loaded from the *ADTECHAdConfiguration.plist* property file when needed and you can change this value anytime at runtime.
 * By changing the value at runtime you can configure different schemes for different ADTECH objects (ATBannerView, ATInterstitialView, ATMoviePlayerController).
 *
 * Defaults to kATProtocolSchemaHTTP.
 *
 * Available in 3.1 and later.
 */
@property(nonatomic,copy) NSString *schema;

/**
 * Holds the domain from where the ad will be requested.
 * The default value will be loaded from the *ADTECHAdConfiguration.plist* property file when needed and you can change this value anytime at runtime.
 * By changing the value at runtime you can configure different domains for different ADTECH objects (ATBannerView, ATInterstitialView, ATMoviePlayerController).
 *
 * Available in 1.0 and later.
 */
@property(nonatomic,copy) NSString *domain;

/**
 * Allows overriding the TCP port number the requests will be made on.
 * All requests explicitly made by the SDK for a particular banner, interstitial or ad enabled video player will use this TCP port.
 *
 * The default value will be loaded from the *ADTECHAdConfiguration.plist* property file when needed and you can change this value anytime at runtime.
 * Leaving the port value on 0 (the default value) will ensure that the correct default port will be used for all supported protocols.
 *
 * Defaults to 0.
 *
 * Available in 3.1 and later.
 */
@property(nonatomic,assign) NSUInteger port;

/**
 * Controls the behaviour when opening landing pages for non-rich type ads.
 * When the value is set to YES, all landing page URLs will open in the
 * in-app browser. Use this value when you know that all your landing page URLs are pointing to web pages.
 * When the value is set to NO, the landing page URL will be processed before opening it to determine its type. If it is determined that
 * it points to a web page, the in-app browser is shown and the page is loaded. If it is determined that the landing page URL is
 * a platform specific URL requesting access to native features (like using the "tel:" protocol for making phone calls), that action is taken
 * without showing the in-app browser. Making phone calls will prompt the users for permission.
 * 
 * All the platform supported URL schemes are permitted. You can find details about what these are here:
 * http://developer.apple.com/library/ios/#featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html
 *
 * Default value will be loaded from the ADTECHAdConfiguration.plist property file upon creation. If the value is missing from the configuration file, defaults to YES.
 *
 * Available in 3.0.1 and later.
 *
 * @warning Setting the value to NO will cause slight delays in taking the action or showing the landing web page,
 * because of the time the SDK needs to process the URL. If the value is YES and a platform specific URL is set as the landing page URL
 * the in-app browser is shown which will then handle on its own the special scheme. This can leave a blank in-app browser shown when
 * returning to the application.
 *
 * @warning Setting the value to NO has the limitation of handling a maximum number of 5 redirections. If that is not acceptable
 * set the value of the flag to YES.
 *
 * @note Starting SDK version 3.3, the maximum number of redirections has been raised to 20.
 */
@property(nonatomic,assign) BOOL openLandingPagesThroughBrowser;

/**
 * Sets the logging level for the Adtech library.
 *
 * Available in 1.0 and later.
 *
 * @param level The value for the level of logging. Possible values are: kATLogOff, kATLogError, kATLogWarning, kATLogInfo, kATLogVerbose.
 *              See the ATLogLevel enum for possible values and details.
 */
+ (void)setLoggingLevel:(ATLogLevel)level;

/**
 * Returns the current version of the SDK in use.
 *
 * Available in 2.2 and later.
 */
+ (NSString*)version;

/** 
 * Checks if the string passed as parameter corresponds to the SDKs valid domain template.
 *
 * Available in 1.0 and later.
 *
 * @param aDomain The string that will be checked if it corresponds to a domain description or not.
 *
 * @return YES if the string matches the domain template, NO otherwise
 */
- (BOOL)isValidDomain:(NSString*)aDomain;

/** 
 * Enables the user to add optional key-value parameters that should be passed to the server when requesting an ad.
 * The possible keys are defined on server level and are individual for each user.
 *
 * Available in 1.0 and later.
 *
 * @param key The key that identifies a list of one or more values. Will be ignored if nil, empty or longer than 16 chars.
 *
 * @param values An array of values that define a key. Will be ignored if nil or empty. Can hold NSString objects,
 * anything else is ignored. Can hold up to 128 individual valid entries, anything above this will be ignored.
 * Individual entries can be up to 48 chars long, anything above this is ignored.
 *
 * @param error An error that will be returned if the add procedure failed. You may use nil if not interested in it.
 * See ATBaseConfiguration.h for specific error code, domain and description.
 *
 * @return YES if the operation was successful, NO otherwise.
 *
 * @see [ATBaseConfiguration removeUserKey:]
 *
 * @warning There are restrictions that apply for keys and values added. Anything that exceeds this limitation will be ignored with a warning log and an error will be generated.
 *
 * The maximum number of key-value pairs that can be used on one ad is 26. If you try to add more key-values, a warning is logged and an error generated.
 *
 * As a general consideration, this key-value pairs will be used for creating the ad request URL that has a length limitation of 4096.
 * It might be that although the above constraints are kept, still the URL to be too long (e.g. adding one key-value pair, where the value
 * is an array with 128 tokens each with 48 chars). This will be ignored at URL construction and you'll get a warning.
 *
 * The order of the value tokens is NOT guaranteed when the URL is constructed. The order might be different from that of the input array. 
 *
 * See the ADTECH Mobile SDK User Guide for more info on using this property.
 */
- (BOOL)addUserKey:(NSString*)key values:(NSArray*)values error:(NSError**)error;

/** 
 * Returns all the user defined keys from the configuration.
 *
 * Available in 1.0 and later.
 *
 * @return An array with all the user defined keys. Returns empty is no key is found.
 */
- (NSArray*)allUserKeys;

/** 
 * Returns the values that the configuration has under a given user defined key.
 *
 * Available in 1.0 and later.
 *
 * @param key The key that identifies a list of one or more values.
 *
 * @return An array with all the user defined values for the given key. Returns nil if the key was not found. 
 *
 * @see [ATBaseConfiguration allUserKeys]
 *
 * @warning The order of the values are not guaranteed and may differ from the order in what they were added in.
 */
- (NSArray*)valuesForKey:(NSString*)key;

/** 
 * Enables the user to remove a given value for a given key. Useful when the key contains multiple values (e.g. country = UK,DE,USA,FR) and only one needs to be removed (e.g. USA).
 * If the key is nil or not found then the call is ignored.
 *
 * Available in 1.0 and later.
 *
 * @param value The value to remove.
 *
 * @param key The key that identifies a list of one or more values.
 *
 * @param error An error that will be returned if the add procedure failed. You may use nil if not interested in it. See ATBaseConfiguration.h for specific error code, domain and description.
 *
 * @return YES if the operation was successful, NO otherwise.
 *
 * @see [ATBaseConfiguration removeUserKey:]
 */
- (BOOL)removeValue:(NSString*)value forKey:(NSString*)key error:(NSError**)error;

/** 
 * Removes the values for the specified key. If key is not found the call is ignored.
 *
 * Available in 1.0 and later.
 *
 * @param key The key that identifies a list of one or more values.
 *
 * @see [ATBaseConfiguration addUserKey:values:error:] 
 */
- (void)removeUserKey:(NSString*)key;

/** 
 * Removes all the key-value pairs.
 *
 * Available in 1.0 and later.
 *
 * @see [ATBaseConfiguration removeUserKey:] 
 */
- (void)removeAllUserKeys;

@end
