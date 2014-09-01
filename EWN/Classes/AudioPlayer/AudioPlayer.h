//
//  AudioPlayer.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/18.
//
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "AudioPlayerViewController.h"

@interface AudioPlayer : NSObject
{
    AVPlayer *audioPlayer;
}

@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) AudioPlayerViewController *audioPlayerView; // Reference to current AudioPlayerViewController, wherever he may be ...
@property (nonatomic, strong) AVPlayerItem *audioPlayerItem;
@property (nonatomic, strong) NSURL *audioURL;
@property (strong, nonatomic) id periodicObserver;

+(id)sharedInstance;

-(void)updatePlayerWithView:(AudioPlayerViewController *)playerView;
-(void)stopAndCleanPlayer;
-(void)initPlayerWithUrl:(AVPlayerItem *)audioItem;
-(void)playerItemDidReachEnd:(NSNotification *)notification;
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
-(void)showLoader;
-(void)hideLoader;

@end
