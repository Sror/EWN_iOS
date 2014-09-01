//
//  BulletinPageViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/17.
//
//

#import "BulletinPageViewController.h"

@interface BulletinPageViewController ()
{
    
}
@end

@implementation BulletinPageViewController

@synthesize newsPlayer;
@synthesize trafficPlayer;
@synthesize myPicker;
@synthesize dataArray;
@synthesize bulletinArray;
@synthesize selectedCity;

/* Lazy Load */
-(AudioPlayerViewController *)newsPlayer
{
    if(!newsPlayer)
    {
        newsPlayer = [[AudioPlayerViewController alloc] init];
    }
    return newsPlayer;
}

-(AudioPlayerViewController *)trafficPlayer
{
    if(!trafficPlayer)
    {
        trafficPlayer = [[AudioPlayerViewController alloc] init];
    }
    return trafficPlayer;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    selectedCity = self.getSelectedCityForBulletin;
    myPicker = [[CustomPickerViewController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelected) name:@"SYNC_BULLETIN" object:nil];
    return self;
}

-(void) updateSelected {
    selectedCity = self.getSelectedCityForBulletin;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.textView.layer setCornerRadius:5.0];
    
    [self.textField setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [self.textField setDelegate:self];
    [self.textField setText:[[[bulletinArray objectForKey:@"News"] objectAtIndex:selectedCity] objectForKey:@"Title"]];
    
    self.dataArray = [[NSMutableArray alloc] init];
    int amount = [[bulletinArray objectForKey:@"News"] count];
    for (int x = 0; x < amount; x++) {
        [self.dataArray addObject:[[[bulletinArray objectForKey:@"News"] objectAtIndex:x] objectForKey:@"Title"]];
    }
    
    [self configure];
}

-(void)startEditing {
    [self.textField becomeFirstResponder];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configure
{
    // just sense check we have the values
    [self.view addSubview:self.newsPlayer.view];
    [self.newsPlayer.view setFrame:CGRectMake(10, 45, self.newsPlayer.view.frame.size.width, self.newsPlayer.view.frame.size.height)];
    [self.newsPlayer.titleLabel setText:@"News bulletin"];
    [self.newsPlayer preparePlayerItemWithUrl:[[[bulletinArray objectForKey:@"News"] objectAtIndex:selectedCity] objectForKey:@"Url"]];
//    DLog(@"URL for News = %@", [[[bulletinArray objectForKey:@"News"] objectAtIndex:selectedCity] objectForKey:@"Url"]);
    
    [self.view addSubview:self.trafficPlayer.view];
    [self.trafficPlayer.view setFrame:CGRectMake(10, 95, self.self.trafficPlayer.view.frame.size.width, self.self.trafficPlayer.view.frame.size.height)];
    [self.trafficPlayer.titleLabel setText:@"Traffic bulletin"];
    [self.trafficPlayer preparePlayerItemWithUrl:[[[bulletinArray objectForKey:@"Traffic"] objectAtIndex:selectedCity] objectForKey:@"Url"]];
//    DLog(@"URL for Traffic = %@", [[[bulletinArray objectForKey:@"Traffic"] objectAtIndex:selectedCity] objectForKey:@"Url"]);
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
    [self setSelectedCityForBulletin:selectedCity];
    
    [self.newsPlayer preparePlayerItemWithUrl:[[[bulletinArray objectForKey:@"News"] objectAtIndex:selectedCity] objectForKey:@"Url"]];
    [self.trafficPlayer preparePlayerItemWithUrl:[[[bulletinArray objectForKey:@"Traffic"] objectAtIndex:selectedCity] objectForKey:@"Url"]];
}

-(void) setSelectedCityForBulletin:(NSInteger) city {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:city forKey:@"BulletinCity"];
    [defaults setBool:YES forKey:@"BulletinCitySet"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_LOCATION_DEFAULTS" object:nil];
}

-(NSInteger) getSelectedCityForBulletin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger tmp = [defaults integerForKey:@"BulletinCity"];
    [defaults synchronize];
    return tmp;
}

-(void)dealloc
{
    self.newsPlayer;
    self.trafficPlayer;
    self.myPicker;
    self.dataArray;
    
}

@end
