//
//  AudioPlayer.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/18.
//
//  Singleton Pattern

#import "AudioPlayer.h"

@implementation AudioPlayer

@synthesize audioPlayerItem;
@synthesize audioURL;
@synthesize audioPlayer;
@synthesize audioPlayerView;


/* Lazy Load */
-(AVPlayer *)audioPlayer
{
    if(!audioPlayer)
    {
        audioPlayer = [[AVPlayer alloc] init];
    }
    return audioPlayer;
}

+(id)sharedInstance {
    static AudioPlayer *sharedAudioPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAudioPlayer = [[self alloc] init];
    });
    return sharedAudioPlayer;
}

-(void)updatePlayerWithView:(AudioPlayerViewController *)playerView
{
    if(self.audioPlayerView)
    {
        if(self.audioPlayerView != playerView)
        {
            //[self stopAndCleanPlayer];
            [self.audioPlayerView stopHandler:nil];
        }
    }
    
    audioPlayerView = playerView; // Update reference to current AudioPlayerView
    
    if (self.audioPlayerItem)
    {
        [self initPlayerWithUrl:self.audioPlayerItem]; // Add listeners and start playback
    }
//    [self initPlayerWithUrl:self.audioPlayerView.audioItem]; // Add listeners and start playback
}

-(void)stopAndCleanPlayer
{
//    DLog(@"Cleaning");

    // clear the loader
    [self hideLoader];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.audioPlayer.currentItem];
    [self.audioPlayer removeObserver:self forKeyPath:@"status"];
    [self.audioPlayer removeTimeObserver:self.periodicObserver];
    
    [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];

    self.audioPlayerView.audioItem = nil; // Remove from the AudioPlayerViewController
}

-(void)initPlayerWithUrl:(AVPlayerItem *)audioItem
{
//    DLog(@"Requesting : %@", audioItem);
    // show a loading view!!!
    [self showLoader];
    
    if (self.audioURL)
    {
        self.audioPlayer = [[AVPlayer alloc] initWithURL:self.audioURL];
    }
    else
    {
        self.audioPlayer = [AVPlayer playerWithPlayerItem:audioItem];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:audioItem];
    
    [self.audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    //[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    
    __weak AudioPlayer *weakSelf = self; // Weak Reference for CodeBlock
    self.periodicObserver = [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                   queue:NULL
                                              usingBlock:^(CMTime time){
                                                  if(time.value)
                                                  {
                                                      // clear the loader
                                                      [self hideLoader];
                                                      
                                                      if (!weakSelf.audioPlayerView.isPlaying) {
                                                          return;
                                                      }
                                                      
                                                      float duration = ((float)weakSelf.audioPlayer.currentItem.duration.value / (float)weakSelf.audioPlayer.currentItem.duration.timescale);
                                                      float currentTime = (float)((weakSelf.audioPlayer.currentTime.value) / weakSelf.audioPlayer.currentTime.timescale);
                                                      
                                                      float progressLength = (currentTime / duration) * 100;
                                                      progressLength = progressLength * 3;
                                                      
                                                      CGRect progressFrame = weakSelf.audioPlayerView.progressView.frame;
                                                      
                                                      progressFrame.size.width = progressLength;
                                                      
//                                                      DLog(@"Duration : %d Current : %d BarLength %f", (int)duration, (int)currentTime, progressLength);
                                                      
                                                      [UIView animateWithDuration:0.35f animations:^{
                                                          [weakSelf.audioPlayerView.progressView setFrame:progressFrame];
                                                      }completion:^(BOOL finished){
                                                          if ((int)currentTime >= (int)duration) {
                                                              [weakSelf.audioPlayerView stopHandler:nil];
                                                          }
                                                      }];
                                                      
                                                  }
                                              }];
    
    // TODO - Should these be attached to each new item, or do they persist through every reference?
    [self.audioPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.audioPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)playerItemDidReachEnd:(NSNotification *)notification
{
//    DLog(@"Audio Did Complete!");
    //[self stopAndCleanPlayer];
    [self.audioPlayerView stopHandler:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (object == self.audioPlayer && [keyPath isEqualToString:@"status"])
    {
        if (self.audioPlayer.status == AVPlayerStatusFailed) {
            DLog(@"AVPlayer Failed");
            
        }
        else if (self.audioPlayer.status == AVPlayerStatusReadyToPlay)
        {
            DLog(@"AVPlayerStatusReadyToPlay");

        }
        else if (self.audioPlayer.status == AVPlayerItemStatusUnknown)
        {
            DLog(@"AVPlayer Unknown");
            
        }
    }
    
    // TODO - When checking Reachability, if connection loss is reconnected, restarted the stream at the last saved position ...
    /* Manage Buffering for Current PlayerItem */
    if(object == self.audioPlayer.currentItem) {
        if([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            [self.audioPlayerView pauseHandler:nil];
        }
        else if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            [self.audioPlayerView playHandler:nil];
        }
    }
}

-(void)showLoader {
    [audioPlayerView.loadingIndicator startAnimating];
    [audioPlayerView.loadingContainerView setHidden:NO];
}

-(void)hideLoader {
    [audioPlayerView.loadingIndicator stopAnimating];
    [audioPlayerView.loadingContainerView setHidden:YES];
}

-(void)dealloc
{
    [self.audioPlayer release];
    [self.audioPlayerView release];
    [self.periodicObserver release];
    [super dealloc];    
}

@end