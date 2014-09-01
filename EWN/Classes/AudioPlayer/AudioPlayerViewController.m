//
//  AudioPlayerViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/17.
//
//

#import "AudioPlayerViewController.h"
#import "AudioPlayer.h"
#import "AReachability.h"



@interface AudioPlayerViewController ()

@property (nonatomic, strong) NSURL *audioUrl;

@end



@implementation AudioPlayerViewController

@synthesize audioItem;
@synthesize audioUrl;


-(id)init
{
    NSString *strXib = @"AudioPlayerViewController";
    if (!(self = [super initWithNibName:strXib bundle:nil])) return nil;
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view.layer setCornerRadius:5];
    [self.view.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.view.layer setBorderWidth:1.0f];
    [self.view.layer setMasksToBounds:YES];
    
    [self.progressView.layer setCornerRadius:5];
    [self.progressView setFrame:CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, 0, self.progressView.frame.size.height)];
    
    [self.titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12.0]];
    [self.titleLabel setTextColor:[UIColor darkGrayColor]];
    
    [self.playButton addTarget:self action:@selector(playHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.playArea addTarget:self action:@selector(playHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pauseButton addTarget:self action:@selector(pauseHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseArea addTarget:self action:@selector(pauseHandler:) forControlEvents:UIControlEventTouchUpInside];

    [self.stopButton addTarget:self action:@selector(stopHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopArea addTarget:self action:@selector(stopHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    self.isPlaying = FALSE;
    [self.pauseButton setHidden:YES];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)preparePlayerItemWithUrl:(NSString *)url {

    if ([url rangeOfString:@"http://"].location == NSNotFound) {
        self.audioUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [url copy]]];
    } else {
        self.audioUrl = [NSURL URLWithString:[url copy]];
    }
    
    if (self.audioUrl) {
        self.audioItem = [AVPlayerItem playerItemWithURL:audioUrl]; // Assigning to property automatically releases and sets property to nil before adding new Object
    } else {
        DLog(@"Audio URL is NULL and will prevent the audio player from playing.");
    }
}

-(void)playHandler:(id)sender {
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO) {
        NSString *messageString = @"Unable to download the audio, check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
        
    if(!self.isCurrent) {
        [[AudioPlayer sharedInstance] setAudioPlayerItem:[AVPlayerItem playerItemWithURL:self.audioUrl]];
        [[AudioPlayer sharedInstance] setAudioURL:self.audioUrl];
        [[AudioPlayer sharedInstance] updatePlayerWithView:self];
    }
    
    self.isCurrent = TRUE;
    self.isPlaying = TRUE;
    
    [self.playButton setHidden:YES];
    [self.playArea setHidden:YES];
    
    [self.pauseButton setHidden:NO];
    [self.pauseArea setHidden:NO];
    
    [self.progressView setAlpha:1.0];
    
    [[[AudioPlayer sharedInstance] audioPlayer] play];
}

-(void)pauseHandler:(id)sender {
    self.isPlaying = FALSE;
    
    [self.playButton setHidden:NO];
    [self.playArea setHidden:NO];
    
    [self.pauseButton setHidden:YES];
    [self.pauseArea setHidden:YES];
    
    [self.progressView setAlpha:0.5];
    
    [[[AudioPlayer sharedInstance] audioPlayer] pause];
}

-(void)stopHandler:(id)sender {
    if(self.isCurrent) {
        [self pauseHandler:nil];
        [self.progressView setFrame:CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, 0, self.progressView.frame.size.height)];
        [[AudioPlayer sharedInstance] stopAndCleanPlayer];
    }
    self.isCurrent = FALSE;
}

-(void)dealloc {
    self.audioItem;
}

@end
