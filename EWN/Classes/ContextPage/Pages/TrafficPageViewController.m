//
//  TrafficPageViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/17.
//
//

#import "TrafficPageViewController.h"
#import "NSString+HTML.h"
#import "MainViewController.h"

@interface TrafficPageViewController ()

@end

@implementation TrafficPageViewController

@synthesize trafficPlayer;
@synthesize myPicker;
@synthesize dataArray;
@synthesize selectedCity;
@synthesize trafficArray;
@synthesize isOpen;

-(AudioPlayerViewController *)trafficPlayer
{
    if(!trafficPlayer)
    {
        trafficPlayer = [[AudioPlayerViewController alloc] init];
    }
    return trafficPlayer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    selectedCity = self.getSelectedCityForTraffic;
    myPicker = [[CustomPickerViewController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelected) name:@"SYNC_TRAFFIC" object:nil];
    return self;
}

-(void) updateSelected {
    selectedCity = self.getSelectedCityForTraffic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizesSubviews = NO;
        
    [self.textView.layer setCornerRadius:5];
    
    [self.textField setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [self.textField setDelegate:self];
    [self.textField setText:[[[trafficArray objectForKey:@"Traffic"] objectAtIndex:selectedCity] objectForKey:@"Title"]];
    
    self.trafficLabel.numberOfLines = 0;
    [self.trafficLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [self.trafficLabel setTextColor:[UIColor darkGrayColor]];
    
    self.dataArray = [[NSMutableArray alloc] init];
    int amount = [[trafficArray objectForKey:@"Traffic"] count];
    for (int x = 0; x < amount; x++) {
        [self.dataArray addObject:[[[trafficArray objectForKey:@"Traffic"] objectAtIndex:x] objectForKey:@"Title"]];
    }
    
    [self configure];
}

// ONLY SET THE HEIGHT IF IT ACTUALLY APPEARS
- (void)viewWillAppear:(BOOL)animated {
    [self setTextReport];
    [self configure];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.trafficScroll flashScrollIndicators];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configure
{
    [self.view addSubview:self.trafficPlayer.view];
    int y = self.view.frame.size.height - self.trafficPlayer.view.frame.size.height - 10;
    [self.trafficPlayer.view setFrame:CGRectMake(10, y, self.trafficPlayer.view.frame.size.width, self.trafficPlayer.view.frame.size.height)];
    [self.trafficPlayer.titleLabel setText:@"Traffic bulletin"];
    [self.trafficPlayer preparePlayerItemWithUrl:self.getTrafficBulletinUrl];
}

-(void) setTextReport {
    NSString *strDescription;
    strDescription = [[[trafficArray objectForKey:@"Traffic"] objectAtIndex:selectedCity] objectForKey:@"Report"];
    
    // It has been decided by the powers that be that the traffic report is going to be plain text and nothing else.
    [self.trafficLabel setText:strDescription];
    
    [self.trafficLabel sizeToFit];
    [self resizeTrafficContainer];
}

-(void)resizeTrafficContainer {    
    // let's set the scrollview height
    self.trafficScroll.contentSize = CGSizeMake(self.trafficScroll.frame.size.width, self.trafficLabel.frame.size.height);
    
    // this is the maximum overall height this guy can be
    int maxHeight = [UIScreen mainScreen].bounds.size.height > 480 ? 470 : 380;
    int spaces = 40;
    
    int textFieldHeight = self.textField.frame.size.height;
    int playerHeight = self.trafficPlayer.view.frame.size.height;
    
    int heightWithoutScrollView = spaces + textFieldHeight + playerHeight;
    
    // now what we want the scrollview to be
    int maxScrollViewHeight = maxHeight - heightWithoutScrollView;
    int newScrollViewHeight = self.trafficLabel.frame.size.height;
    if (newScrollViewHeight > maxScrollViewHeight) {
        newScrollViewHeight = maxScrollViewHeight;
    }
    
    CGRect scrollFrame = CGRectMake(self.trafficScroll.frame.origin.x, self.trafficScroll.frame.origin.y, self.trafficScroll.frame.size.width, newScrollViewHeight);
    
    int newHeight = newScrollViewHeight + heightWithoutScrollView;
    if (newHeight > maxHeight) {
        newHeight = maxHeight;
    }
    
    CGRect tmpFrame = CGRectMake(0, 30, self.view.frame.size.width, newHeight);
    
    int y = tmpFrame.size.height - self.trafficPlayer.view.frame.size.height - 10;
    CGRect tmpPlayerFrame = CGRectMake(self.trafficPlayer.view.frame.origin.x, y, self.trafficPlayer.view.frame.size.width, self.trafficPlayer.view.frame.size.height);
    
    [UIView animateWithDuration:0.2
    delay:0
    options: UIViewAnimationOptionCurveEaseOut
    animations:^{
        self.view.frame = tmpFrame;
        self.trafficPlayer.view.frame = tmpPlayerFrame;
        self.trafficScroll.frame = scrollFrame;
        [self.trafficScroll flashScrollIndicators];
    }
    completion:^(BOOL finished){
        CGRect frame = CGRectMake(0, 0, self.trafficScroll.frame.size.width, self.trafficScroll.frame.size.height); //wherever you want to scroll
        [self.trafficScroll scrollRectToVisible:frame animated:YES];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        int offset = newHeight + 30;
        self.isOpen = (offset > 30) ? YES : NO;
        if ([objMainView contextPage].view.frame.origin.y < 400) {
            [[objMainView contextPage] displayContextPage:self.isOpen WithOffset:offset];
        }
    }];
    

}

-(NSString*) getTrafficBulletinUrl {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    return [[objMainView contextPage] getAudioTrafficUrl:selectedCity];
}

/* TEXTFIELD DELEGATE METHODS */

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [myPicker setTextField:self.textField];
    [myPicker setDataArray:self.dataArray];
    NSInteger *tmp = (NSInteger*)selectedCity;
    [myPicker setItemSelected:tmp];
    [textField setInputView:[myPicker view]];
    return TRUE;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSInteger *tmp = [myPicker itemSelected];
    selectedCity = (long)tmp;
    [self setSelectedCityForTraffic:selectedCity];
    [self setTextReport];
    [self configure];
}

-(void) setSelectedCityForTraffic:(NSInteger) city {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:city forKey:@"TrafficCity"];
    [defaults setBool:YES forKey:@"TrafficCitySet"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_LOCATION_DEFAULTS" object:nil];
}

-(NSInteger) getSelectedCityForTraffic {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger tmp = [defaults integerForKey:@"TrafficCity"];
    [defaults synchronize];
    return tmp;
}

-(void)dealloc
{
    [self.trafficPlayer release];
    [self.myPicker release];
    [self.dataArray release];
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
