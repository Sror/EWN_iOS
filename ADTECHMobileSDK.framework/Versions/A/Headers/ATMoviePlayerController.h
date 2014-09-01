//
//  ATMoviePlayerController.h
//  ADTECHMobileSDK
//
//  Created by ADTECH AG on 4/18/12.
//  Copyright (c) 2012 ADTECH AG. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@class ATVideoAdConfiguration;

/**
 * Movie player that allows for VAST compliant advertisement. Depending on the configuration provided
 * ads will be fetched and presented during the playback of the video content.
 * Currently, linear videos are supported (pre-roll, mid-roll and post-roll video ads).
 *
 * The ATMoviePlayerController can be used as a normal movie player controller that will introduce
 * ads during playback of the video content as configured.
 *
 * Available in 2.2 and later.
 *
 * @warning: *You must call stop before releasing the movie player on iOS 4.3 or earlier*
 */
@interface ATMoviePlayerController : MPMoviePlayerController
{
    ATVideoAdConfiguration *configuration;
    UIViewController *__weak presentingViewController;
}

/**
 * The configuration specifies the placement details used for serving ads and the type of ads to be presented.
 *
 * Available in 2.2 and later.
 */
@property (nonatomic, strong) ATVideoAdConfiguration *configuration;

/**
 * The view controller that is the presenter of the video being shown. It is used to present modally screens when the user
 * engages and interacts with the shown ads.
 *
 * Available in 2.2 and later.
 *
 * @warning *You must set this property before calling play. Ads won't get loaded without this property being set.*
 */
@property (nonatomic, weak) UIViewController *presentingViewController;

@end
