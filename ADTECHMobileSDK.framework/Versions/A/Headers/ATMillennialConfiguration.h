//
//  ATMillennialConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 2/14/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

extern const NSInteger kATMMDefaultRefreshTime; /// Available in 2.1 and later.

/**
 * Holds the configuration used for the Millennial Media ads. You can set here different parameters for the Millennial Media ad's behavior and for better targeting.
 * Default values are loaded from the ADTECHAdConfiguration.plist file when the ATAdConfiguration gets created. The values under the dictionary specified by the 'MillennialConfig' key are used. 
 * The config can be changed during runtime.
 * 
 * You can find the ADTECHAdConfiguration.plist in the Resources folder of the SDK framework. You'll need to manually include it in your application.
 * The ADTECHAdConfiguration.plist comes with preset values and you can change them to your convenience.
 *
 * Available in 2.1 and later.
 *
 * @see ATAdConfiguration
 */
@interface ATMillennialConfiguration : NSObject

/**
 * Updates the location used for ad requests.
 *
 * Available in 2.1 and later.
 *
 * @param aLocation The CLLocation object either created or received via the CLLocationManager delegate methods
 *
 * @warning Call this method when you receive a location update. If you turn location services off, call this function with a nil parameter. Location data becomes stale after 10 minutes and will no longer be passed with the ad request unless you update the location again.
 */
+ (void)updateLocation:(CLLocation*)aLocation;

/**
 * The Millennial Media Placement ID.
 *
 * Available in 2.1 and later.
 */
@property(nonatomic,copy) NSString *apid;

/**
 * The Millennial Media Goal Id for tracking conversions for your application.
 * The value will be loaded from the *ADTECHAdConfiguration.plist* property file upon ATBannerView creation. See GoalID key under MillennialConfig.
 * If this value is set and it's not an empty string then the conversion tracker is user, otherwise not. Remove the GoalID key from the plist config file if you do not want to use it.
 *
 * Available in 2.1 and later.
 */
@property(nonatomic,copy,readonly) NSString *conversionTrackerGoalID;

/**
 * Set the timer duration for the rotation of ads in seconds. Zero or negative value means never refresh.
 * The value will be loaded from the *ADTECHAdConfiguration.plist* property file upon ATBannerView creation and you can change this value anytime at runtime. See RefreshTime key under MillennialConfig.
 * If key is not found in the configuration file, it defaults to 60.
 *
 * Available in 2.1 and later.
 */
@property(nonatomic,readwrite) NSInteger refreshTime;

/**
 * Use this method to enable or disable the accelerometer.
 * The value will be loaded from the *ADTECHAdConfiguration.plist* property file upon ATBannerView creation and you can change this value anytime at runtime. See AccelerometerEnabled key under MillennialConfig.
 * If key is not found in the configuration file, it defaults to YES.
 *
 * Available in 2.1 and later.
 */	
@property(nonatomic,readwrite) BOOL accelerometerEnabled;

/**
 * Used to provide metadata that can help Millennial deliver more relevant ads to your users. Metadata is information that your users have shared with you, and you have permission to share with us such as age, gender, zip code, income, and other such information.
 * For a list of possible keys see http://wiki.millennialmedia.com/index.php/IOS_SDK
 * The value will be loaded from the *ADTECHAdConfiguration.plist* property file upon ATBannerView creation and you can change this value anytime at runtime. See RequestData key nunder MillennialConfig.
 * If key is not found in the configuration file, it defaults to nil.
 *
 * Available in 2.1 and later.
 */
@property(nonatomic,strong) NSDictionary *requestData;

@end
