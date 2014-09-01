//
//  ATAdMobConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 1/31/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

typedef NS_ENUM(NSUInteger, ATGender) /// Available in 2.0 and later.
{
    kATGenderUnknown,
    kATGenderMale,
    kATGenderFemale
};

/**
 * Holds the configuration used for the AdMob ads. You can set here different parameters for the AdMob ad's behavior and for better targeting.
 * Default values are loaded from the ADTECHAdConfiguration.plist file when the ATAdConfiguration gets created. The values under the dictionary specified by the 'AdMobConfig' key are used. 
 * The config can be changed during runtime.
 * 
 * You can find the ADTECHAdConfiguration.plist in the Resources folder of the SDK framework. You'll need to manually include it in your application.
 * The ADTECHAdConfiguration.plist comes with preset values and you can change them to your convenience.
 *
 * Available in 2.1 and later.
 *
 * @see ATAdConfiguration
 */
@interface ATAdMobConfiguration : NSObject<NSCopying>

/**
 * Required value created in the AdSense website. Create a new ad unit for every unique placement of an ad in your application.
 * Wrapper over the adUnitID from the GADBannerView. 
 * See the GADBannerView class header documentation for more details.
 *
 * Available in 2.1 and later.
 */
@property (nonatomic,copy) NSString *adUnitID;

/**
 * Passes extra details in AdMob ad requests.
 * Wrapper over the additionalParameters from the GADRequest. 
 * See the GADRequest class header documentation for more details and examples.
 *
 * Available in 2.1 and later.
 */
@property (nonatomic,copy) NSDictionary *additionalParameters;

/**
 * Test ads are returned to these devices. Device identifiers are the same used to register as a development device with Apple.
 * Wrapper over the testDevices from the GADRequest. 
 * See the GADRequest class header documentation for more details and examples.
 *
 * Available in 2.1 and later.
 *
 * @note Starting with AdMob iOS SDK version 5.0.8 only the Simulator can be placed in this array of test devices. Use the testing property instead of real devices.
 * @see testing
 */
@property (nonatomic,copy) NSArray *testDevices;

/**
 * Set to YES to enable delivery of test ads on all your devices. Don't forget to change this back to NO when going into production.
 *
 * Available in 2.1 and later.
 */
@property (nonatomic,assign) BOOL testing;

/**
 * The user's gender may be used to deliver more relevant AdMob ads.
 *
 * Available in 2.1 and later.
 */
@property (nonatomic,readwrite) ATGender gender;

/**
 * The user's birthday may be used to deliver more relevant ads.
 *
 * Available in 2.1 and later.
 */
@property (nonatomic,copy) NSDate *birthday;

/**
 * The user's current location may be used to deliver more relevant ads.
 * 
 * Available in 2.1 and later.
 *
 * @warning This value is exclusive with localizedDescription. If one is set, the other becomes defaulted to nil.
 * @see locationDescription
 */
@property (nonatomic,copy,readonly) CLLocation *location;

/**
 * The user's current location may be used to deliver more relevant ads.
 * 
 * Available in 2.1 and later.
 *
 * @warning This value is exclusive with location. If one is set, the other becomes defaulted to nil.
 * @see location
 */
@property (nonatomic,copy,readonly) NSString *locationDescription;

/**
 * A keyword is a word or phrase describing the current activity of the user such as @"Sports Scores". Each keyword is an NSString in the NSArray.
 * You can manipulate this array by using the adKeyword:, removeKeyword and resetKeywords calls.
 * This array will hold unique keywords, the same keyword will not be present multiple times.
 *
 * Available in 2.1 and later.
 *
 * @see [ATAdMobConfiguration addKeyword:]
 * @see [ATAdMobConfiguration removeKeyword:]
 * @see [ATAdMobConfiguration resetKeywords]
 */
@property (nonatomic,copy,readonly) NSArray *keywords;

/** 
 * Ads the keyword to the SDK's AdMob keywords list. Call is ignored if the keyword is nil or already exists.
 *
 * Available in 2.1 and later.
 *
 * @param keyword The string that represent a keyword.
 */
- (void)addKeyword:(NSString*)keyword;

/** 
 * Delets the keyword from the SDK's AdMob keywords list.
 *
 * Available in 2.1 and later.
 *
 * @param keyword The string that represent a keyword.
 */
- (void)removeKeyword:(NSString*)keyword;

/** 
 * Resets the SDK's AdMob keywords list to empty.
 *
 * Available in 2.1 and later.
 */
- (void)resetKeywords;

/** 
 * Set's the location of the user. Either CLLocation or NSString free text such as @"Champs-Elysees Paris" or @"94041 US" is expected.
 * If the object passed in as param has an incorrect type then it is ignored and the location and locationDescription ivars are defaulted to nil.
 *
 * Available in 2.1 and later.
 *
 * @warning Passing in a CLLocation, the location ivar is set and the locationDescription is defaulted to nil.
 * If a NSString is passed in then the locationDescription ivar is set and the location is defaulted to nil.
 *
 * @param aLocation representation of a location either as CLLocation or NSString represneting the physical address.
 */
- (BOOL)setUserLocation:(id)aLocation;

@end

