//
//  ContextMenuViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/03.
//
//

#import "ContextMenuViewController.h"
#import "WebserviceComunication.h"

#import "MainViewController.h"


@interface ContextMenuViewController () <UITextFieldDelegate>
{
    PDBackgroundTaskManager *backgroundTaskManager;
}
@end

@implementation ContextMenuViewController

@synthesize background;
@synthesize weatherOption;
@synthesize bulletinOption;
@synthesize trafficOption;
@synthesize marketOption;
@synthesize searchOption;
@synthesize shareOption;
@synthesize commentsOption;

@synthesize dictMarkets;
@synthesize marketDataReceivedCount;

@synthesize searchView;
@synthesize closeButton;
@synthesize searchText;

@synthesize isEnabled;
@synthesize isSearch;
@synthesize dictWeather;

#pragma mark -


-(UIView *)searchView
{
    if(!searchView)
    {
        searchView = [[UIView alloc] init];
        //[searchView setFrame:CGRectMake(0, 0, 290, 45)];
        
        closeButton = [[UIButton alloc] init];
        [closeButton setFrame:CGRectMake(10, 10, 25, 25)];
        [closeButton setImage:[UIImage imageNamed:@"search_close_button.png"] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(searchCloseHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        searchText = [[UITextField alloc] init];
        searchText.delegate = self;
        [searchText setFrame:CGRectMake(45, 10, 195, 25)];
        [searchText setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
        [searchText setTextColor:[UIColor darkGrayColor]];
        [searchText setBackgroundColor:[UIColor whiteColor]];
        [searchText setPlaceholder:@"Enter search criteria"];
        searchText.returnKeyType = UIReturnKeySearch;
        //[searchText setTextAlignment:NSTextAlignmentNatural]; // Not supported on iOS6 ?
        [searchText.layer setCornerRadius:2.5];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 25)];
        searchText.leftView = paddingView;
        searchText.leftViewMode = UITextFieldViewModeAlways;
        
        [searchView addSubview:closeButton];
        [searchView addSubview:searchText];
    }
    return searchView;
}

-(id)init
{
    [self setIsEnabled:TRUE];
    
    return self;
}

-(void)viewDidLoad
{
    self.background = [[UIView alloc] init];
    [self.background setBackgroundColor:[UIColor blackColor]];
    [self.background setAlpha:0.8f];
    [self.view addSubview:background];
    
    self.weatherOption = [[ContextOptionViewController alloc] initWithTitle:@"weather"];
    self.bulletinOption = [[ContextOptionViewController alloc] initWithTitle:@"bulletin"];
    self.trafficOption = [[ContextOptionViewController alloc] initWithTitle:@"traffic"];
    self.marketOption = [[ContextOptionViewController alloc] initWithTitle:@"markets"];
    self.searchOption = [[ContextOptionViewController alloc] initWithTitle:@"search"];
    self.commentsOption = [[ContextOptionViewController alloc] initWithTitle:@"comments"];
    self.shareOption = [[ContextOptionViewController alloc] initWithTitle:@"share"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optionHandler:) name:@"CONTEXT_OPTION_SELECTED" object:nil];
    
    // WEATHER
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherCompleteHandler:) name:@"WEATHER_REQUEST" object:nil];

    // this observer is for when we change weather
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weatherChangedHandler:) name:@"WEATHER_CHANGED" object:nil];
    
    // BULLETINS
    // add observer for when the data is recieved
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bulletinCompleteHandler:) name:@"BULLETIN_REQUEST" object:nil];
   
    // TRAFFIC
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trafficCompleteHandler:) name:@"TRAFFIC_REQUEST" object:nil];
    
    // Markets
    marketDataReceivedCount = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(marketsCompleteHandler:) name:@"MARKETS_REQUEST" object:nil];
    
    // REQUEST NOTIFICATIONS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsCompleteHandler:) name:@"COMMENTS_REQUEST" object:nil];
    
    // RESET THE CONTEXT OPTION
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContextMenu) name:@"RESET_CONTEXT_OPTIONS" object:nil];
    
    // Configure Search View
    // Close Button, Input Field, Search Button
//    [self.view addSubview:self.searchView];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHandler:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHandler:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self reloadContextData];
}

-(void)viewDidAppear:(BOOL)animated
{
    // Set some CONSTANTS
    contextMenuY = self.view.frame.origin.y;
    
    // Just in case there is no reference to the contextPage, add it manually ...
    if(!self.contextPage)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        self.contextPage = [objMainView contextPage];
    }
}

-(void)setLastType:(NSString *)mType {
    lastType = mType;
}

-(void)resetContextMenu {
    [self updateContextMenu:@"contentList"];
}

-(void)updateContextMenu:(NSString *)mType {    
    BOOL isBussiness = false;
    
    if ([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKeyPath:kstrId] isEqualToString:@"24fe2708-89d9-47ac-b3cd-5dc03c5fc6c2"]) {
        isBussiness = true;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        if (objMainView.isSearchOpen) {
            isBussiness = false;
        }
        if ([[WebserviceComunication sharedCommManager] isInFocus]) {
            isBussiness = false;
        }
    }
    
    // This is to avoid seeing the contextPage animating into its offscreen position.
    if(self.isInit)
    {
        [self.contextPage closeHandler:nil];
    }
    
    self.isInit = YES;
    
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height = 45;
    
    /* CONTENT LIST */
    if([kContentListOptions isEqualToString:mType])
    {
        lastType = mType;
        
        int optioncount = 4;
        if (version2) {
            // 24fe2708-89d9-47ac-b3cd-5dc03c5fc6c2
            if (isBussiness) {
                optioncount = 5;
            }
        } else {
            isBussiness = false;
        }
        
        viewFrame.size.width = 45 * optioncount;
        [self.view setFrame:viewFrame]; // Always set the view before shuffling the positions, otherwise strange results with touch events
        [self.background setFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
        [self removeOptions];
        
        [self.view addSubview:self.weatherOption.view];
        [self.view addSubview:self.bulletinOption.view];
        [self.view addSubview:self.trafficOption.view];
        if (isBussiness) {
            [self.view addSubview:self.marketOption.view];
        }
        [self.view addSubview:self.searchOption.view];
        
        [self.weatherOption setPosition:0];
        [self.bulletinOption setPosition:1];
        [self.trafficOption setPosition:2];
        if (isBussiness) {
            [self.searchOption setPosition:3];
            [self.marketOption setPosition:4];
        } else {
            [self.searchOption setPosition:3];
        }
    }
    
    /* CONTENT DETAIL */
    if([kContentDetailOptions isEqualToString:mType])
    {
        lastType = mType;
        
        viewFrame.size.width = 45 * 3;
        [self.view setFrame:viewFrame];
        [self.background setFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
        [self removeOptions];
        
        [self.view addSubview:self.searchOption.view];
        [self.view addSubview:self.shareOption.view];
        [self.view addSubview:self.commentsOption.view];
        
        [self.searchOption setPosition:0];
        [self.shareOption setPosition:1];
        [self.commentsOption setPosition:2];
    }
    
    /* SEARCH MODE */
    if([kSearchOptions isEqualToString:mType] || [kSearchOptionsNoFocus isEqualToString:mType])
    {        
        // Display Search Input
        viewFrame.size.width = 290;
        [self.view setFrame:viewFrame];
        [self.background setFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
        [self removeOptions];
        
        [self.view addSubview:self.searchView];
        [self.view addSubview:self.searchOption.view];
        
        [self.searchView setFrame:CGRectMake(0, 0, 290, 45)];
        CGRect searchOptionFrame = self.searchOption.view.frame;
        searchOptionFrame.origin.x = (self.searchView.frame.size.width - 45);
        [self.searchOption.view setFrame:searchOptionFrame];
        
        if([kSearchOptions isEqualToString:mType])
        {
            [self.searchText setText:@""];
            [self.searchText becomeFirstResponder];
        }
        
        [self setIsSearch:TRUE];
    }
    
    // Update DropShadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.background.bounds]; // Release?
    self.background.layer.masksToBounds = NO;
    self.background.layer.shadowColor = [UIColor blackColor].CGColor;
    self.background.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.background.layer.shadowOpacity = 0.8f;
    self.background.layer.shadowPath = shadowPath.CGPath;
    self.background.layer.shadowRadius = 2.0f;
}

-(void)reloadContextData {
    // WEATHER
    [[WebserviceComunication sharedCommManager] getWeather];
    // BULLETINS
    [[WebserviceComunication sharedCommManager] getBulletins];
    // TRAFFIC
    [[WebserviceComunication sharedCommManager] getTraffic];
    if (version2) {
        // MARKETS
        [[WebserviceComunication sharedCommManager] getMarkets];
    }
}

-(void)removeOptions
{
    // Remove all Options, re-added during update
    [self.weatherOption.view removeFromSuperview];
    [self.bulletinOption.view removeFromSuperview];
    [self.trafficOption.view removeFromSuperview];
    [self.marketOption.view removeFromSuperview];
    [self.searchOption.view removeFromSuperview];
    [self.commentsOption.view removeFromSuperview];
    [self.shareOption.view removeFromSuperview];
    
    [self.searchView removeFromSuperview];
    
    [self setIsSearch:FALSE];
    
    [self.searchView setFrame:CGRectMake(-300, 0, 300, 60)];
}

// Toggle Context Menu e.g. Disable when Offline
-(void)displayContextMenu:(BOOL)display
{
    [self setIsEnabled:display];
}

-(void)updateComments:(NSString *)string
{
    if ([[WebserviceComunication sharedCommManager] isOnline] == NO) {
        [self.commentsOption.commentCount setText:@"N/A"];
        [[self.contextPage commentsPage] cleanComments];
        return;
    }
    
    [self.commentsOption.commentCount setText:@""];
    [self.commentsOption.activityIndicatorView startAnimating];
    
    [[self.contextPage commentsPage] cleanComments];
    
    backgroundTaskManager = [PDBackgroundTaskManager backgroundTaskManager];
    [backgroundTaskManager executeBackgroundTaskWithExpirationHandler:^(PDBackgroundTaskManager *manager, NSString *taskName) {
        [self commentsCompleteHandler:nil];
    } executionHandler:^(PDBackgroundTaskManager *manager, NSString *taskName) {
         [[WebserviceComunication sharedCommManager] getCommentsInit:string];
    }];
}

-(void)optionHandler:(NSNotification *)notification
{
    NSString *optionType = [notification object];
    
    if (([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO) && optionType)
    {
        NSString *formatString = nil;
        
        if ([optionType isEqualToString:@"weather"])
            formatString = @"weather";
        else if ([optionType isEqualToString:@"bulletin"])
            formatString = @"bulletin";
        else if ([optionType isEqualToString:@"traffic"])
            formatString = @"traffic";
        else if ([optionType isEqualToString:@"comments"])
            formatString = @"comments";
        
        if (formatString) {
            NSString *messageString = [NSString stringWithFormat:@"You cannot access the %@ while your connection is offline. Please try again later.", formatString];
            [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
            return;
        }
    }
    
    // TODO check if the option is initialized
    if([optionType isEqualToString:@"weather"])
    {
        if ([self.contextPage.dictWeather count] == 0) {
            [self optionNotReady:@"The weather feed is loading, please try again in a moment." heading:@"Weather"];
            return;
        }
        [self.contextPage displayWeather];
    }
    
    if([optionType isEqualToString:@"bulletin"])
    {
        if ([self.contextPage.dictBulletin count] == 0) {
            [self optionNotReady:@"The bulletin audio stream is loading, please try again in a moment." heading:@"Bulletin"];
            return;
        }
        [self.contextPage displayBulletin];
    }
    
    if([optionType isEqualToString:@"traffic"])
    {
        if ([self.contextPage.dictTraffic count] == 0) {
            [self optionNotReady:@"The  traffic report is loading, please try again in a moment." heading:@"Traffic"];
            return;
        }
        [self.contextPage displayTraffic];
    }
    
    if([optionType isEqualToString:@"search"])
    {
        // Switch to Search Mode, otherwise trigger Search
        if(!isSearch)
        {
            [self updateContextMenu:kSearchOptions];
        }
        else
        {
            [self searchHandler];
        }
    }
    
    if([optionType isEqualToString:@"comments"])
    {
        [self.contextPage displayComments];
    }
    
    if([optionType isEqualToString:@"share"])
    {
        [self.contextPage displayShare];
    }
    
    if([optionType isEqualToString:@"markets"])
    {
        if ([self.contextPage.dictMarkets count] == 0) {
            [self optionNotReady:@"The  markets information is still loading, please try again in a moment." heading:@"Markets"];
            return;
        }
        [self.contextPage displayMarkets];
    }
}

-(void)optionNotReady:(NSString *)message heading:(NSString *)heading
{
    CustomAlertView *alrtvwNotReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
    [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:1];
    alrtvwNotReachable.lblHeading.text=heading;
    alrtvwNotReachable.lblDetail.text=message;
    [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
}


-(void)trafficCompleteHandler:(NSNotification *)notification {
    // lets set the contextpage's array straight from here
    self.contextPage.dictTraffic = [[WebserviceComunication sharedCommManager] dictTraffic];
    [self.contextPage setTrafficArray];
}

-(void)marketsCompleteHandler:(NSNotification *)notification {
    marketDataReceivedCount++;
    if (2 == marketDataReceivedCount) {
        dictMarkets = [[WebserviceComunication sharedCommManager] dictMarkets];
        self.contextPage.dictMarkets = self.dictMarkets;
        [self.contextPage setMarketData];
    }
}

-(void)bulletinCompleteHandler:(NSNotification *)notification {
    // lets set the contextpage's array straight from here
    self.contextPage.dictBulletin = [[WebserviceComunication sharedCommManager] dictBulletins];
    [self.contextPage setBulletinArray];
}

// this gets notified after we have made the call for weather
-(void)weatherCompleteHandler:(NSNotification *)notification
{
    self.dictWeather = [[WebserviceComunication sharedCommManager] dictWeather];
    self.contextPage.dictWeather = self.dictWeather;
    [self.contextPage setWeatherArray];
    [self weatherChanged];
}
// this happens when you change an option
-(void)weatherChangedHandler:(NSNotification *)notification
{
    [self weatherChanged];    
}

// this updates the text and icon on the context option for weather
-(void)weatherChanged {
    // change the weather icon and label
    int selectedCity = self.getSelectedCityForWeather;
    // just check this shit first
    if (selectedCity >= [[self.dictWeather objectForKey:@"WeatherReport"] count]) {
        selectedCity = 0;
    }
    
    NSString *iconUrl = [[[[[[self.dictWeather objectForKey:@"WeatherReport"] objectAtIndex:selectedCity] objectForKey:@"Forecasts"] objectForKey:@"Forecast"] objectAtIndex:0] objectForKey:@"ImageUrl"];
    [self.weatherOption setImageIcon:iconUrl];
    
    NSString *display = @"";
    display = [display stringByAppendingString:[[[[[[self.dictWeather objectForKey:@"WeatherReport"] objectAtIndex:selectedCity] objectForKey:@"Forecasts"] objectForKey:@"Forecast"] objectAtIndex:0] objectForKey:@"MaxTemp"]];
    display = [display stringByAppendingString:@"°C"];
    
    NSString *city = [[[self.dictWeather objectForKey:@"WeatherReport"] objectAtIndex:selectedCity] objectForKey:@"Title"];
    city = [city substringToIndex:3];
    city = [city stringByAppendingString:@"-"];
    display = [city stringByAppendingString:display];
    [self.weatherOption.optionTitle setText:[display uppercaseString]];
}

-(void)commentsCompleteHandler:(NSNotification *)notification
{
    [self.commentsOption.activityIndicatorView stopAnimating];
    [self.commentsOption.commentCount setText:[NSString stringWithFormat:@"%i", [[WebserviceComunication sharedCommManager] articleCommentCount]]];
    [self.contextPage.commentsPage updateIfOpen]; // This only updates the comments if commentsPage.isOpen
    [backgroundTaskManager endBackgroundTask];
}

-(void)searchHandler
{
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        if (self.searchText) {
            [self.searchText resignFirstResponder];
        }
        NSString *messageString = @"You cannot search for articles while your connection is offline.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
    
    [self.searchText resignFirstResponder];

    if([searchText.text length] < 3)
    {
        [[WebserviceComunication sharedCommManager]closeProgressView];
        CustomAlertView *alrtvwNotReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:1];
        alrtvwNotReachable.lblHeading.text=kstrSearchNews;
        alrtvwNotReachable.lblDetail.text=[NSString stringWithFormat:kstrPleaseEnterKeyword];
        [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
    }
    else
    {
        [Flurry logEvent:KFlurryEventKeyWordSearched withParameters:[NSDictionary dictionaryWithObjectsAndKeys:searchText.text, kstrSearchedtext, nil]];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        [objMainView performSelector:@selector(openSearchViewWithKeyword:) withObject:searchText.text afterDelay:0.1]; // Make a plan with this ...
        [[objMainView newsListViewController] performSelector:@selector(EnableSearchView:) withObject:searchText.text afterDelay:0.1];
    }
}

-(void)searchCloseHandler:(id)sender
{
    if([kContentListOptions isEqualToString:lastType])
    {
        [self updateContextMenu:kContentListOptions];
    }
    
    if([kContentDetailOptions isEqualToString:lastType])
    {
        [self updateContextMenu:kContentDetailOptions];
    }
}

-(void)keyboardHandler:(NSNotification *)notification
{
    // May be better to move this NSNotification to mainViewController, in case of the need to manage additional objects based onKeyboard ...
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
//    DLog(@"Size of Keyboard : %f", kbSize.height);
    
    if([[notification name] isEqualToString:UIKeyboardWillShowNotification])
    {
        if([self.searchText isFirstResponder])
        {
            [self.view setFrame:CGRectMake(
                                           self.view.frame.origin.x,
                                           (self.view.frame.origin.y - kbSize.height),
                                           self.view.frame.size.width,
                                           self.view.frame.size.height)];
        }
    }
    
    if([[notification name] isEqualToString:UIKeyboardWillHideNotification])
    {
        if(isSearch)
        {
            [self.view setFrame:CGRectMake(
                                           self.view.frame.origin.x,
                                           contextMenuY,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height)];
            
        }
    }
}


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchHandler];
    
    return NO;
}



/* ============================================================================= */
// Keeping track of what we have selected before
/* ============================================================================= */
-(NSInteger) getSelectedCityForWeather {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger tmp = [defaults integerForKey:@"WeatherCity"];
    [defaults synchronize];
    return tmp;
}

-(NSInteger) getSelectedCityForBulletins {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger tmp = [defaults integerForKey:@"BulletinCity"];
    [defaults synchronize];
    DLog(@"Selected city for bulletins from defaults %d",tmp);
    return tmp;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WEATHER_CHANGED" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WEATHER_REQUEST" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BULLETIN_REQUEST" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TRAFFIC_REQUEST" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CONTEXT_OPTION_SELECTED" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"COMMENTS_REQUEST" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self.background dealloc];
    
    [self.weatherOption dealloc];
    [self.bulletinOption dealloc];
    [self.trafficOption dealloc];
    [self.searchOption dealloc];
    [self.shareOption dealloc];
    [self.commentsOption dealloc];
    
    [self.searchOption dealloc];
    [self.closeButton dealloc];
    [self.searchText dealloc];
    
    [super dealloc];    
}

@end
