//
//  ContextPageViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/04.
//
//

#import "ContextPageViewController.h"
#import "MainViewController.h"
#import "EWNCloseButton.h"
#import "PDSocialSharingManager.h"



@implementation ContextPageViewController

@synthesize background;
@synthesize titleBackground;
@synthesize titleLabel;
@synthesize closeButton;

@synthesize weatherPage;
@synthesize bulletinPage;
@synthesize trafficPage;
@synthesize commentsPage;
@synthesize marketsPage;

@synthesize isOpening;
@synthesize isClosing;

@synthesize dictWeather;
@synthesize dictBulletin;
@synthesize dictTraffic;
@synthesize dictMarkets;

@synthesize articleId;
@synthesize sharingText;
@synthesize sharingUrl;

/* Lazy Load */
-(MarketPageViewController *)marketsPage
{
    if(!marketsPage)
    {
        NSString *strXib = @"MarketPageViewController";
        marketsPage = [[MarketPageViewController alloc] initWithNibName:strXib bundle:nil];
    }
    return marketsPage;
}

-(WeatherPageViewController *)weatherPage
{
    if(!weatherPage)
    {
        NSString *strXib = @"WeatherPageViewController";
        weatherPage = [[WeatherPageViewController alloc] initWithNibName:strXib bundle:nil];
    }
    return weatherPage;
}

-(BulletinPageViewController *)bulletinPage
{
    if(!bulletinPage)
    {
        NSString *strXib = @"BulletinPageViewController";
        bulletinPage = [[BulletinPageViewController alloc] initWithNibName:strXib bundle:nil];
    }
    return bulletinPage;
}

-(TrafficPageViewController *)trafficPage
{
    if(!trafficPage)
    {
        NSString *strXib = @"TrafficPageViewController";
        trafficPage = [[TrafficPageViewController alloc] initWithNibName:strXib bundle:nil];
    }
    return trafficPage;
}

-(CommentsPageViewController *)commentsPage
{
    if(!commentsPage)
    {
        NSString *strXib = @"CommentsPageViewController";
        commentsPage = [[CommentsPageViewController alloc] initWithNibName:strXib bundle:nil];
    }
    return commentsPage;
}
/* END */

-(void)viewDidLoad
{
    initFrame = self.view.frame;
    [self.view setClipsToBounds:FALSE];
    
    self.background = [[UIView alloc] init];
    [self.background setFrame:CGRectMake(0, 0, initFrame.size.width, initFrame.size.height)];
    [self.background setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.background];
    
    // TITLE BAR
    self.titleBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"context_header_bg.png"]];
    [self.titleBackground setFrame:CGRectMake(0, -15, 320, 54)];
    [self.titleBackground setUserInteractionEnabled:FALSE];
    [self.view addSubview:self.titleBackground];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFrame:CGRectMake(10, 0, initFrame.size.width, 30)];
    [self.titleLabel setText:@"title"];
    [self.titleLabel setTextColor:[UIColor colorWithHexString:@"dc0707"]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:18.0]];
    [self.view addSubview:self.titleLabel];
    
    self.closeButton = [[EWNCloseButton alloc] init];
    [self.closeButton setFrame:CGRectMake((initFrame.size.width - 25), 5, 20, 20)];
    [self.closeButton addTarget:self action:@selector(closeHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLocationDefaults) name:@"SET_LOCATION_DEFAULTS" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    initFrame = [UIScreen mainScreen].bounds; // self.view.frame; // Update the initFrame, as it is now offset in mainViewController to bottom of display
    initFrame.origin.y = initFrame.size.height;
    [self.view setFrame:initFrame];
}

-(void)closeHandler:(id)sender
{
    [self displayContextPage:NO WithOffset:0];    
    [self.commentsPage close];
}

-(void)displayContextPage:(BOOL)display WithOffset:(float)offset
{
    if(display)
    {
        self.isOpening = YES;
        
        CGRect tempFrame = initFrame;
        tempFrame.origin.y = initFrame.size.height - offset;
        
        // if ios 6 offset by 20
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
            tempFrame.origin.y -= 20;
        }
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.view.frame = tempFrame;
                         }
                         completion:^(BOOL finished){
                             self.isOpening = NO;
                         }
         ];
    }
    else
    {
        self.isClosing = YES;
        
        CGRect tempFrame = self.view.frame;
        tempFrame.origin.y = initFrame.size.height;
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.view setFrame:tempFrame];
                         }
                         completion:^(BOOL finished){
                             self.isClosing = NO;
                             [self removeContextPage];
                         }
         ];
    }
}


-(void)removeContextPage
{
    [self.weatherPage.view removeFromSuperview];
    [self.bulletinPage.view removeFromSuperview];
    [self.trafficPage.view removeFromSuperview];
    [self.commentsPage.view removeFromSuperview];
    [self.marketsPage.view removeFromSuperview];
}

-(void)displayWeather
{
    mType = @"weather";
    
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        NSString *formatString = nil;
        
        if ([mType isEqualToString:@"weather"])
            formatString = @"weather";
        else if ([mType isEqualToString:@"bulletin"])
            formatString = @"bulletin";
        else if ([mType isEqualToString:@"traffic"])
            formatString = @"traffic";
        else if ([mType isEqualToString:@"comments"])
            formatString = @"comments";
        
        if (formatString) {
            NSString *messageString = [NSString stringWithFormat:@"You cannot access the %@ while your connection is offline. Please try again later.", formatString];
            [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
            return;
        }
    }
    
    [self.titleLabel setText:@"weather"];
    [self.weatherPage.view setFrame:CGRectMake(0, self.titleLabel.frame.size.height, self.weatherPage.view.frame.size.width, self.weatherPage.view.frame.size.height)];
    [self.view addSubview:self.weatherPage.view];
    float pageHeight = (self.weatherPage.view.frame.size.height + kContextPageTitleHeight);
    [self displayContextPage:YES WithOffset:pageHeight];
}

- (void)setWeatherArray {
    self.weatherPage.weatherArray = self.dictWeather;
}

-(void)displayMarkets
{
    mType = @"markets";
    
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO) {
        NSString *formatString = @"markets";
        
        if (formatString) {
            NSString *messageString = [NSString stringWithFormat:@"You cannot access the %@ while your connection is offline. Please try again later.", formatString];
            [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
            return;
        }
    }
    
    [self.titleLabel setText:@"markets"];
    [self.marketsPage.view setFrame:CGRectMake(0, self.titleLabel.frame.size.height, self.marketsPage.view.frame.size.width, self.marketsPage.view.frame.size.height)];
    [self.view addSubview:self.marketsPage.view];
    float pageHeight = (self.marketsPage.view.frame.size.height + kContextPageTitleHeight);
    [self displayContextPage:YES WithOffset:pageHeight];
}

- (void)setMarketData {
    NSArray *tmpArray = [self.dictMarkets objectForKey:@"Commodities"];
    int amount = [tmpArray count];
    for (int x = 0; x < amount; x++) {
        [self.marketsPage.marketArray addObject:[tmpArray objectAtIndex:x]];
    }
    
    tmpArray = [self.dictMarkets objectForKey:@"Currencies"];
    amount = [tmpArray count];
    for (int x = 0; x < amount; x++) {
        [self.marketsPage.marketArray addObject:[tmpArray objectAtIndex:x]];
    }
}

-(void)displayBulletin {
    mType = @"bulletin";
    
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO) {
        NSString *formatString = nil;
        
        if ([mType isEqualToString:@"weather"])
            formatString = @"weather";
        else if ([mType isEqualToString:@"bulletin"])
            formatString = @"bulletin";
        else if ([mType isEqualToString:@"traffic"])
            formatString = @"traffic";
        else if ([mType isEqualToString:@"comments"])
            formatString = @"comments";
        
        if (formatString) {
            NSString *messageString = [NSString stringWithFormat:@"You cannot access the %@ while your connection is offline. Please try again later.", formatString];
            [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
            return;
        }
    }
    
    [self.titleLabel setText:@"bulletins"];
    
    [self.bulletinPage.view setFrame:CGRectMake(0, self.titleLabel.frame.size.height, self.bulletinPage.view.frame.size.width, self.bulletinPage.view.frame.size.height)];
    [self.view addSubview:self.bulletinPage.view];
    
    float pageHeight = (self.bulletinPage.view.frame.size.height + kContextPageTitleHeight);
    [self displayContextPage:YES WithOffset:pageHeight];
}

- (void)setBulletinArray {
    self.bulletinPage.bulletinArray = self.dictBulletin;
}

-(void)displayTraffic
{
    mType = @"traffic";
    
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        NSString *formatString = nil;
        
        if ([mType isEqualToString:@"weather"])
            formatString = @"weather";
        else if ([mType isEqualToString:@"bulletin"])
            formatString = @"bulletin";
        else if ([mType isEqualToString:@"traffic"])
            formatString = @"traffic";
        else if ([mType isEqualToString:@"comments"])
            formatString = @"comments";
        
        if (formatString) {
            NSString *messageString = [NSString stringWithFormat:@"You cannot access the %@ while your connection is offline. Please try again later.", formatString];
            [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
            return;
        }
    }
    
    [self.titleLabel setText:@"traffic"];
    
    int x = 0;
    int y = self.titleLabel.frame.size.height;
    int w = self.trafficPage.view.frame.size.width;
    int h = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - kContextPageTitleHeight; // self.trafficPage.view.frame.size.height;
    
    [self.trafficPage.view setFrame:CGRectMake(x, y, w, h)];
    [self.view addSubview:self.trafficPage.view];
    
    float pageHeight = (self.trafficPage.view.frame.size.height + kContextPageTitleHeight); // Initial Height - This is modified further by the page based on content ...
    [self displayContextPage:YES WithOffset:pageHeight];
}

- (void)setTrafficArray {
    self.trafficPage.trafficArray = self.dictTraffic;
}

-(void)displayComments
{
    mType = @"comments";
    
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        NSString *formatString = nil;
        
        if ([mType isEqualToString:@"weather"])
            formatString = @"weather";
        else if ([mType isEqualToString:@"bulletin"])
            formatString = @"bulletin";
        else if ([mType isEqualToString:@"traffic"])
            formatString = @"traffic";
        else if ([mType isEqualToString:@"comments"])
            formatString = @"comments";
        
        if (formatString) {
            NSString *messageString = [NSString stringWithFormat:@"You cannot access the %@ while your connection is offline. Please try again later.", formatString];
            [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
            return;
        }
    }
    
    
    if ([[WebserviceComunication sharedCommManager] isLoadingComments])
    {
        [[WebserviceComunication sharedCommManager] showAlert:@"Comments" message:@"Please wait while comments load."];
        return;
    }
    else
    {
        [self.titleLabel setText:@"comments"];
        
        [self.commentsPage.view setFrame:CGRectMake(0, self.titleLabel.frame.size.height, self.commentsPage.view.frame.size.width, self.commentsPage.view.frame.size.height)];
        [self.view addSubview:self.commentsPage.view];
        
        float pageHeight = (50 + kContextPageTitleHeight);
        [self displayContextPage:YES WithOffset:pageHeight];
        
        self.commentsPage.articleId = articleId;
        [self.commentsPage update];
    }    
}


#pragma mark - Sharing Methods

-(void)displayShare {
    NSArray *activityItems = [NSArray arrayWithObjects:sharingText, sharingUrl, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:activityViewController animated:YES completion:nil];
    
    return;
    
    // IF WE EVER NEED TO ACCOMMODATE IOS 5...
//    PDSocialSharingManager *socialSharingManager = [PDSocialSharingManager sharedInstance];
//    
//    [socialSharingManager showSharingOptions:sharingItems
//                                      target:[UIApplication sharedApplication].keyWindow.rootViewController
//                                    callback:^(PDSocialSharingManager *manager, BOOL successful, NSError *error) {
//                                        
//                                        if (successful && error == nil) {
//                                            
//                                            if ([manager selectedSocialSharingType] == PDSocialSharingTypeMail)
//                                                [[WebserviceComunication sharedCommManager] showAlert:@"Success" message:@"Your mail has been queued for delivery."];
//                                            else if ([manager selectedSocialSharingType] != PDSocialSharingTypeNone)
//                                                [[WebserviceComunication sharedCommManager] showAlert:@"Success" message:@"You have succesfully shared this article."];
//                                        }
//                                        else {
//                                            
//                                            if (error) {
//                                                NSString *alertMessage = [NSString stringWithFormat:@"An error occured while sharing.\n\n%@", error.localizedDescription];
//                                                [[WebserviceComunication sharedCommManager] showAlert:@"Sharing Error" message:alertMessage];
//                                            }
//                                            else {
//                                                [[WebserviceComunication sharedCommManager] showAlert:@"Sharing Error" message:@"An unexpected error has occured while sharing. Please try again later."];
//                                            }
//                                        }
//                                    }];

}

-(void) setSharingValues:(NSString*)text shareUrl:(NSString*)url  {
    self.sharingText = text;
    self.sharingUrl = url;
}

- (void) authenticationFromEWN {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_AUTHENTICATE object:nil];
       
    NSDictionary *myDick = [[WebserviceComunication sharedCommManager] dictAuthenticate];
    NSString *userId = [myDick objectForKey:@"AuthenticateUserByTokenResult"];
    
    if (userId != nil) {
        // save the userId and alert the user
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        [objMainView userIdSave:userId showMessage:YES];
                
        [self.commentsPage update];
    } else {
        // message here
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Sign In"
                              message: @"Unable to sign in. Please try again."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(NSString*)getAudioTrafficUrl:(int) trafficCity {
    NSString *ret = @"";
    NSDictionary *tmpBulletinArray = [[self.bulletinPage bulletinArray] copy];
    
    switch (trafficCity) {
        case 0 : // Cape Town
            ret = [[[tmpBulletinArray objectForKey:@"Traffic"] objectAtIndex:0] objectForKey:@"Url"];
            break;
        case 1 : // Pretoria
        case 2 : // Johannesburg
            ret = [[[tmpBulletinArray objectForKey:@"Traffic"] objectAtIndex:1] objectForKey:@"Url"];
            break;
    }
    
    return ret;
}

-(void) setLocationDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL weatherSet = [defaults boolForKey:@"WeatherCitySet"];
    BOOL bulletinSet = [defaults boolForKey:@"BulletinCitySet"];
    BOOL trafficSet = [defaults boolForKey:@"TrafficCitySet"];
    
    int amountSet = 0;
    
    // quick check if we have to continue
    if (weatherSet) {
        amountSet++;
    }
    if (bulletinSet) {
        amountSet++;
    }
    if (trafficSet) {
        amountSet++;
    }
    
    if (amountSet > 1) {
        [defaults synchronize];
        return;
    }
    
    NSInteger weather = [defaults integerForKey:@"WeatherCity"];
    NSInteger bulletin = [defaults integerForKey:@"BulletinCity"];
    NSInteger traffic = [defaults integerForKey:@"TrafficCity"];
    
    // set everyone from the weather
    if (weatherSet) {
        if (!bulletinSet && !trafficSet) {
            switch (weather) {
                case 0: // Bloemfontein
                case 4: // Johannesburg
                case 5: // Nelspruit
                case 9: // Rustenburg
                case 11: // Vereeniging
                    // b = GAUTENG 1
                    [defaults setInteger:1 forKey:@"BulletinCity"];
                    // t = Johannesburg 2
                    [defaults setInteger:2 forKey:@"TrafficCity"];
                    break;
                case 1: // Cape Town
                case 2: // Durban
                case 3: // George
                case 6: // Paarl
                case 7: // Plettenberg Bay
                case 10: // Strand
                    // b = CAPE TOWN 0
                    [defaults setInteger:0 forKey:@"BulletinCity"];
                    // t = Cape Town 0
                    [defaults setInteger:0 forKey:@"TrafficCity"];
                    break;
                case 8: // Pretoria
                    // b = GAUTENG 1
                    [defaults setInteger:1 forKey:@"BulletinCity"];
                    // t = Pretoria 1
                    [defaults setInteger:1 forKey:@"TrafficCity"];
                    break;
            }
        }
    }
    
    // set everyone from the bulletin
    if (bulletinSet) {
        if (!weatherSet && !trafficSet) {
            switch (bulletin) {
                case 0: // CAPE TOWN
                    // w = Cape Town 1
                    [defaults setInteger:1 forKey:@"WeatherCity"];
                    // t = Cape Town 0
                    [defaults setInteger:0 forKey:@"TrafficCity"];
                    break;
                case 1: // GAUTENG
                    // w = Johannesburg 4
                    [defaults setInteger:4 forKey:@"WeatherCity"];
                    // t = Johannesburg 2
                    [defaults setInteger:2 forKey:@"TrafficCity"];
                    break;
            }
        }
        // WEATHER_CHANGED
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WEATHER_CHANGED" object:nil];
    }
    
    // set everyone from the traffic
    if (trafficSet) {
        if (!bulletinSet && !weatherSet) {
            switch (traffic) {
                case 0: // Cape Town
                    // b = CAPE TOWN 0
                    [defaults setInteger:0 forKey:@"BulletinCity"];
                    // w = Cape Town 1
                    [defaults setInteger:1 forKey:@"WeatherCity"];
                    break;
                case 1: // Pretoria
                    // b = GAUTENG 1
                    [defaults setInteger:1 forKey:@"BulletinCity"];
                    // w = Pretoria 8
                    [defaults setInteger:8 forKey:@"WeatherCity"];
                    break;
                case 2: // Johannesburg
                    // b = GAUTENG 1
                    [defaults setInteger:1 forKey:@"BulletinCity"];
                    // w = Johannesburg 4
                    [defaults setInteger:4 forKey:@"WeatherCity"];
                    break;
            }
        }
        // WEATHER_CHANGED
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WEATHER_CHANGED" object:nil];
    }
    
    [defaults setBool:YES forKey:@"BulletinCitySet"];
    [defaults setBool:YES forKey:@"WeatherCitySet"];
    [defaults setBool:YES forKey:@"TrafficCitySet"];
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SYNC_WEATHER" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SYNC_TRAFFIC" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SYNC_BULLETIN" object:nil];
}

-(void) dealloc
{
    [self.background release];
    [self.titleBackground release];
    [self.titleBackground release];
    [self.closeButton release];
    
    [self.weatherPage release];
    [self.bulletinPage release];
    [self.trafficPage release];
    [self.marketsPage release];
    [self.commentsPage release];
    [super dealloc];
}

@end
