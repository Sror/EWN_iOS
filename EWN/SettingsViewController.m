//
//  SettingsViewController.m
//  EWN
//
//  Created by Dolfie on 2013/12/03.
//
//

#import "SettingsViewController.h"
#import "UAPush.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize heading;
@synthesize optionOne;
@synthesize optionTwo;
@synthesize optionDiv;
@synthesize switchOne;
@synthesize switchTwo;
@synthesize minText;
@synthesize maxText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.heading setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:14.0]];
    [self.heading setTextColor:[UIColor darkGrayColor]];
    
    [self.optionOne setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
    [self.optionOne setTextColor:[UIColor darkGrayColor]];
    
    [self.optionTwo setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
    [self.optionTwo setTextColor:[UIColor darkGrayColor]];
    
    [self.optionDiv setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
    [self.optionDiv setTextColor:[UIColor darkGrayColor]];
    
    [self.switchOne setOn:NO];
    [self.switchOne addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    [self.switchOne setTag:0];
    
    [self.switchTwo setEnabled:NO];
    [self.switchTwo setOn:NO];
    [self.switchTwo addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    [self.switchTwo setTag:1];
    
    [self.minText setText:@""];
    [self.maxText setText:@""];
    
//    UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
//    datePicker.datePickerMode = UIDatePickerModeTime;
//    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
//    [self.minText setInputView:datePicker];
    
    [self.picker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.pickerView removeFromSuperview];
    
    [self.minText setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [self.minText setTextColor:[UIColor darkGrayColor]];
    [self.minText setKeyboardType:UIKeyboardTypeNumberPad];
    [self.minText setEnabled:NO];
    [self.minText setTag:0];
    [self.minText setInputView:self.pickerView];
    
    [self.maxText setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [self.maxText setTextColor:[UIColor darkGrayColor]];
    [self.maxText setKeyboardType:UIKeyboardTypeNumberPad];
    [self.maxText setEnabled:NO];
    [self.maxText setTag:1];
    [self.maxText setInputView:self.pickerView];
    
    [self.pickerButton setTarget:self];
    [self.pickerButton setAction:@selector(pickerButtonHandler:)];
    
    // CFBundleShortVersionString
    [self.aboutText setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:14.0]];
    
//    [lblDescription setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
    [self.versionText setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
    [self.versionText setText:[NSString stringWithFormat:@"V%@, mobilised by", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [self.versionText sizeToFit];
    int posX = (self.versionText.frame.origin.x + self.versionText.frame.size.width) + 5;
    [self.logo setFrame:CGRectMake(posX, self.logo.frame.origin.y, self.logo.frame.size.width, self.logo.frame.size.height)];
    
    [self update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    bool notifications = [defaults integerForKey:@"Notifications"];
    bool notificationsLimit = [defaults integerForKey:@"NotificationsLimit"];
    
    NSString *notificationsLimitMin = [defaults valueForKey:@"NotificationsLimitMin"];
    NSString *notificationsLimitMax = [defaults valueForKey:@"NotificationsLimitMax"];
    
    [self.switchOne setOn:notifications];
    [self.switchTwo setOn:notificationsLimit];
    
    [self.switchTwo setEnabled:notifications];
    [self.minText setEnabled:notifications];
    [self.maxText setEnabled:notifications];
    
    if(notificationsLimit)
    {
        [self.minText setEnabled:YES];
        [self.minText setText:notificationsLimitMin];
        
        [self.maxText setEnabled:YES];
        [self.maxText setText:notificationsLimitMax];
    }
    
    // Textfields
}

- (void)setState:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    switch([sender tag])
    {
        case 0:
            [defaults setBool:[sender isOn] forKey:@"Notifications"];
            [self.switchTwo setEnabled:[sender isOn]];
            [self.minText setEnabled:[sender isOn]];
            [self.maxText setEnabled:[sender isOn]];
            [[UAPush shared] setPushEnabled:[sender isOn]];
            break;
        case 1:
            [defaults setBool:[sender isOn] forKey:@"NotificationsLimit"];
            [self.minText setEnabled:[sender isOn]];
            [self.maxText setEnabled:[sender isOn]];
            break;
        default:
            break;
    }
    
    [defaults synchronize];
}

- (void)pickerButtonHandler:(id)sender
{
    [self.minText endEditing:YES];
    [self.maxText endEditing:YES];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSDate *fromDate = [[NSDate alloc] init];
    NSDate *toDate = [[NSDate alloc] init];
    
    NSString *fromString = self.minText.text;
    NSString *toString = self.maxText.text;
    
    fromDate = [dateFormatter dateFromString:fromString];
    toDate = [dateFormatter dateFromString:toString];
    
    
    DLog(@"FROM : %@",fromDate);
    DLog(@"TO : %@",toDate);
    
    [[UAPush shared] setQuietTimeFrom:fromDate to:toDate withTimeZone:[NSTimeZone localTimeZone]];
    [[UAPush shared] updateRegistration];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch([textField tag])
    {
        case 0:
            break;
            
        case 1:
            break;
            
        default:
            break;
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch([textField tag])
    {
        case 0:
            break;
            
        case 1:
            break;
            
        default:
            break;
    }

}

- (void)pickerValueChanged:(id)sender
{
    NSDate *date = [sender date];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    
    NSString *selectedTime = [df stringFromDate:date];
    
    if([self.minText isEditing])
    {
        [self.minText setText:selectedTime];
    }
    
    if([self.maxText isEditing])
    {
        [self.maxText setText:selectedTime];
    }
    
    // Only save if both min & max have been set
    if(![self.minText.text isEqualToString:@""] && ![self.maxText.text isEqualToString:@""])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:self.minText.text forKey:@"NotificationsLimitMin"];
        [defaults setValue:self.maxText.text forKey:@"NotificationsLimitMax"];
        [defaults synchronize];
    }
}

+ (BOOL)CanReceiveAlerts
{
    bool isEnabled = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    bool notifications = [defaults integerForKey:@"Notifications"];
    bool notificationsLimit = [defaults integerForKey:@"NotificationsLimit"];
    
    NSString *notificationsLimitMin = [defaults valueForKey:@"NotificationsLimitMin"];
    NSString *notificationsLimitMax = [defaults valueForKey:@"NotificationsLimitMax"];
    
    // Check time
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    [df setLocale:[NSLocale systemLocale]];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
        
    // TEMP Solution - Sort Times (min, max, current) and check current sits in the middle of array, between min and max ...
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    
    NSString *currenTime = [df stringFromDate:[NSDate date]];
    NSMutableArray *sortArray = [NSMutableArray arrayWithObjects:currenTime, notificationsLimitMin, notificationsLimitMax, nil];

    [sortArray sortUsingDescriptors:[NSArray arrayWithObject: sortOrder]];
    
    if(notifications)
    {
        isEnabled = YES;
    }
    
    if(notifications && notificationsLimit && sortArray.count > 1)
    {
        if(![currenTime isEqualToString:[sortArray objectAtIndex:1]])
        {
            isEnabled = NO;
        }
    }
    
    return isEnabled;
}

- (void)dealloc
{
    [self.picker removeTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [super dealloc];
    
}

@end
