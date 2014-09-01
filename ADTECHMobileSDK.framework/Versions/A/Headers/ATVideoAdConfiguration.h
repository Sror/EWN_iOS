//
//  ATVideoAdConfiguration.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 5/10/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATBaseConfiguration.h"
#import "ATVideoAdOverlay.h"

/// The available ad type to be presented during playback of video content
typedef enum
{
    kATVideoAdPreRoll,  ///< Ads to be shown before playback of content starts
    kATVideoAdMidRoll,  ///< Ads to be shown at some point during the playback of the content
    kATVideoAdPostRoll, ///< Ads to be shown at the end of playback of the content
    kATVideoAdOverlay,  ///< Overlay ads to be shown during content playback

} ATVideoAdType;

/**
 * Holds the base configuration for video ads shown by ATMoviePlayerController.
 * You create an instance of a specialized subclass of this object and set on it the needed values in order to receive and show video ads from a placement you have configured server side.
 * Set the configuration object on the ATMoviePlayerController that you use, once it is configured.
 * If you change the configuration while already playing video content, the changes will take effect only when fetching new ads.
 * Currently, there is only one specialized subclass that you can use: ATAdtechVideoAdConfiguration.
 *
 * Available in 2.2 and later.
 *
 * @see ATAdtechVideoAdConfiguration
 */
@interface ATVideoAdConfiguration : ATBaseConfiguration
{
    NSMutableArray *adTypes;
    
    CGSize videoDimension;
    NSTimeInterval videoLength;
    NSUInteger videoBitrate;
	NSString *videoType;
    
    NSMutableArray *overlays;
    
    NSUInteger maxWrapperRedirections;
}

/**
 * The optional desired size for the video ads. If set, a video of exact size is requested.
 * Defaults to CGSizeZero.
 *
 * Available in 2.2 and later.
 */
@property (nonatomic, assign) CGSize videoDimension;

/**
 * The optional desired video ad length. If set, matching video length will be smaller or equal to the specified value.
 * Defaults to 0.
 *
 * Available in 2.2 and later.
 */
@property (nonatomic, assign) NSTimeInterval videoLength;

/**
 * The optional video ad bitrate in kbps. If set, only a video of exactly the same bitrate can match.
 *
 * Available in 2.2 and later.
 */
@property (nonatomic, assign) NSUInteger videoBitrate;

/**
 * The optional video ad type. If set, only a video of exactly the same type can match.
 * Possible values are: image-gif, image-jpg, image-png, video-asf, video-avi, video-mov, video-mpg, video-mkv, video-wmv, video-ra, video-mp4,
 * although not all of these might be supported by the platform you are running the application on. Only one value can be used at one time.
 *
 * Available in 3.2.1 and later.
 */
@property (nonatomic, copy) NSString *videoType;

/**
 * The array of configured overlays to show during content playback.
 *
 * Available in 2.2 and later.
 */
@property (nonatomic, readonly, copy) NSArray *overlays;

/**
 * The maximum number of times wrapper redirections will be followed until reaching an actual inline video ad.
 * For an understanding of what a wrapper is, please consult the IAB VAST documentation.
 * The default value is 3. If you don't know and don't care about this value then leave it unchanged.
 *
 * Available in 2.2 and later.
 */
@property (nonatomic, assign) NSUInteger maxWrapperRedirections;

/** 
 * By checking this property you can see if the configuration is valid or not. For validity the following properties are checked: _hostApplicationName, domain, alias_
 * E.g. You can use this property to make sure that the configuration is correctly set up before playing the ATMoviePlayerController object.
 *
 * Available in 2.2 and later.
 */
@property(nonatomic, readonly) BOOL isValid;

/**
 * Enables presentation of the video ad type specified as parameter, if not already enabled.
 *
 * Available in 2.2 and later.
 *
 * @param type The type of ad to enable for this configuration instance. Possible values are: kATVideoAdPreRoll, kATVideoAdMidRoll and kATVideoAdPostRoll.
 */
- (void)enableAdType:(ATVideoAdType)type;

/**
 * Disables presentation of the video ad type specified as parameter, if it was enabled.
 *
 * Available in 2.2 and later.
 *
 * @param type The type of ad to disable for this configuration instance. Possible values are: kATVideoAdPreRoll, kATVideoAdMidRoll and kATVideoAdPostRoll.
 */
- (void)disableAdType:(ATVideoAdType)type;

/**
 * Checks if presentation of the video ad type specified as parameter is enabled or not.
 *
 * Available in 2.2 and later.
 *
 * @param type The type of ad to check for this configuration instance. Possible values are: kATVideoAdPreRoll, kATVideoAdMidRoll and kATVideoAdPostRoll.
 * @return YES if the specified ad type is enabled. NO if not.
 */
- (BOOL)isAdTypeEnabled:(ATVideoAdType)type;

/**
 * Adds a new overlay to be shown during content playback.
 *
 * Available in 2.2 and later.
 *
 * @param overlay A configured instance of an overlay to be shown
 * @see overlays
 * @see removeOverlay:
 *
 * @note Changing the overlays during playback will take effect only after the video is restarted.
 */
- (void)addOverlay:(ATVideoAdOverlay*)overlay;

/**
 * Removes an overlay from the array of overlays to be shown during playback.
 *
 * Available in 2.2 and later.
 *
 * @param overlay The overlay instance to be removed
 * @see overlays
 * @see addOverlay:
 *
 * @note Changing the overlays during playback will take effect only after the video is restarted.
 */
- (void)removeOverlay:(ATVideoAdOverlay*)overlay;

@end
