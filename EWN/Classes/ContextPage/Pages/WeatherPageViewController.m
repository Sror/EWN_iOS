//
//  WeatherPageViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/15.
//
//

#import "WeatherPageViewController.h"

@implementation WeatherPageViewController

@synthesize myPicker;
@synthesize dataArray;
@synthesize weatherArray;
@synthesize selectedCity;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    selectedCity = self.getSelectedCityForWeather;
    myPicker = [[CustomPickerViewController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelected) name:@"SYNC_WEATHER" object:nil];
    return self;
}

-(void) updateSelected {
    selectedCity = self.getSelectedCityForWeather;
    [self.cityText setText:[[[weatherArray objectForKey:@"WeatherReport"] objectAtIndex:selectedCity] objectForKey:@"Title"]];
}

-(void)viewDidLoad
{
    /* FONTS */
    [self.dateLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [self.highLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:28.0]];
    [self.lowLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:20.0]];
    
    [self.cityView.layer setCornerRadius:5];
    
    [self.todayView setBackgroundColor:[UIColor whiteColor]];
    [self.todayView.layer setCornerRadius:5];
    [self.todayView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.todayView.layer setBorderWidth:1.0f];
    [self.todayView.layer setMasksToBounds:YES];
    
    [self.forecastView.layer setCornerRadius:5];
    [self.forecastView.layer setMasksToBounds:YES];
    [self.forecastView setBackgroundColor:[UIColor colorWithHexString:@"ededed"]];
    
    /* FORECAST */
    [self setForecast];
    
    [self.cityText setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12.0]];
    [self.cityText setDelegate:self];
    [self.cityText setText:[[[weatherArray objectForKey:@"WeatherReport"] objectAtIndex:selectedCity] objectForKey:@"Title"]];
    
    self.dataArray = [[NSMutableArray alloc] init];
    int amount = [[weatherArray objectForKey:@"WeatherReport"] count];
    for (int x = 0; x < amount; x++) {
        [self.dataArray addObject:[[[weatherArray objectForKey:@"WeatherReport"] objectAtIndex:x] objectForKey:@"Title"]];
    }
}

// this should happen first
-(void) viewWillAppear:(BOOL)animated {
    [self setToday];
}

-(UIView *)createForecastItem:(int)index
{
    // get the item from the array
    NSDictionary *weatherItem = [[[[[weatherArray objectForKey:@"WeatherReport"] objectAtIndex:selectedCity] objectForKey:@"Forecasts"] objectForKey:@"Forecast"] objectAtIndex:index];
    
    UIView *forecastItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 80)];
    
    // Day, Thumb, High, Low
    UILabel *dayLabel = [[UILabel alloc] init];
    [dayLabel setFrame:CGRectMake(0, 5, 50, 20)];
    [dayLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [dayLabel setTextColor:[UIColor darkGrayColor]];
    NSString *day = [weatherItem objectForKey:@"Day"];
    [dayLabel setText:[[day substringToIndex:3] uppercaseString]];
    [dayLabel setTextAlignment:NSTextAlignmentCenter];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [imageView setImageAsynchronouslyFromUrl:[weatherItem objectForKey:@"ImageUrl"] animated:YES];
    
    UILabel *highLabel = [[UILabel alloc] init];
    [highLabel setFrame:CGRectMake(0, 55, 50, 15)];
    [highLabel setFont:[UIFont fontWithName:kFontOpenSansBold size:11.0]];
    NSString *max = [weatherItem objectForKey:@"MaxTemp"];
    [highLabel setText:[max stringByAppendingString:@"°C"]];
    [highLabel setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *lowLabel = [[UILabel alloc] init];
    [lowLabel setFrame:CGRectMake(0, 70, 50, 15)];
    [lowLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:11.0]];
    NSString *min = [weatherItem objectForKey:@"MinTemp"];
    [lowLabel setText:[min stringByAppendingString:@"°C"]];
    [lowLabel setTextAlignment:NSTextAlignmentCenter];
    
    [forecastItem addSubview:dayLabel];
    [forecastItem addSubview:imageView];
    [forecastItem addSubview:highLabel];
    [forecastItem addSubview:lowLabel];
    
    return forecastItem;
}

-(void) setForecast {
    /* FORECAST */
    for (UIView *subView in self.forecastView.subviews) {
        [subView removeFromSuperview];
    }
     
    UIView *forecastContainer = [[UIView alloc] init];
    for(int i = 0; i < 6; i++)
    {
        UIView *testView = [self createForecastItem:i+1];
        CGRect frame = testView.frame;
        frame.origin.x = (i * frame.size.width);
        [testView setFrame:frame];
        [forecastContainer addSubview:testView];
    }
    [self.forecastView addSubview:forecastContainer];
}

-(void) setToday {
    NSDictionary *weatherItem = [[[[[weatherArray objectForKey:@"WeatherReport"] objectAtIndex:selectedCity] objectForKey:@"Forecasts"] objectForKey:@"Forecast"] objectAtIndex:0];
    
    [self.todayImageView setImageAsynchronouslyFromUrl:[weatherItem objectForKey:@"ImageUrl"] animated:YES];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *prefixDateFormatter = [[NSDateFormatter alloc] init];
    [prefixDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [prefixDateFormatter setDateFormat:@"EEE, MMMM d%, YYYY"];
    NSString *prefixDateString = [prefixDateFormatter stringFromDate:date];
    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [monthDayFormatter setDateFormat:@"d"];
    int date_day = [[monthDayFormatter stringFromDate:date] intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    NSString *dateString = [prefixDateString stringByReplacingOccurrencesOfString:@"%" withString:suffix];
    dateString = [@"Today, " stringByAppendingString:dateString];
    
    NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] initWithString:dateString];
    NSRange selectedRange = NSMakeRange(0, 11);
    [tmpString beginEditing];
    [tmpString addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:kFontOpenSansBold size:12.0]
                   range:selectedRange];
    [tmpString endEditing];
    [self.dateLabel setAttributedText:tmpString];
    
    NSString *city = [[[weatherArray objectForKey:@"WeatherReport"] objectAtIndex:selectedCity] objectForKey:@"Title"];
    city = [[city substringToIndex:3] uppercaseString];
    city = [city stringByAppendingString:@" - "];
    NSString *max = [weatherItem objectForKey:@"MaxTemp"];
    [self.highLabel setText:[city stringByAppendingString:[max stringByAppendingString:@"°C"]]];
    NSString *min = [weatherItem objectForKey:@"MinTemp"];
    [self.lowLabel setText:[min stringByAppendingString:@"°C"]];
}

/* TEXTFIELD DELEGATE METHODS */

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [myPicker setTextField:textField];
    [myPicker setDataArray:self.dataArray];
    NSInteger *tmp = (NSInteger*)selectedCity;
    [myPicker setItemSelected:tmp];
    [textField setInputView:[myPicker view]];
    return TRUE;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSInteger *tmp = [myPicker itemSelected];
    selectedCity = (long)tmp;
    [self setSelectedCityForDefaults:selectedCity];
    [self setToday];
    [self setForecast];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WEATHER_CHANGED" object:self];
}

-(void) setSelectedCityForDefaults:(NSInteger) city {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:city forKey:@"WeatherCity"];
    [defaults setBool:YES forKey:@"WeatherCitySet"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SET_LOCATION_DEFAULTS" object:nil];
}

-(NSInteger) getSelectedCityForWeather {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger tmp = [defaults integerForKey:@"WeatherCity"];
    [defaults synchronize];
    return tmp;
}

-(void)dealloc
{
    [self.myPicker release];
    [self.dataArray release];
    [super dealloc];
}

@end