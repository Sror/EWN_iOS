//
//  AudioPlayerViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/17.
//
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayerViewController : UIViewController
{
}

@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *playArea;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseArea;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIButton *stopArea;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *progressView;
@property (nonatomic, strong) IBOutlet UIView *loadingContainerView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) AVPlayerItem *audioItem;

@property (assign) BOOL isPlaying;
@property (assign) BOOL isCurrent;

-(void)preparePlayerItemWithUrl:(NSString *)url;

-(void)playHandler:(id)sender;
-(void)pauseHandler:(id)sender;
-(void)stopHandler:(id)sender;

@end
