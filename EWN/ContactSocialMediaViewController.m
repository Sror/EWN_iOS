//
//  ContactSocialMediaViewController.m
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import "ContactSocialMediaViewController.h"
#import "AReachability.h"


@interface ContactSocialMediaViewController ()

@end

@implementation ContactSocialMediaViewController

@synthesize tableArray;

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
    
    self.tableArray = [[NSMutableArray alloc] init];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self addEntry:kTypeTwitter Label:@"EWN Reporter" Value:@"ewnreporter"];
    [self addEntry:kTypeTwitter Label:@"EWN Updates" Value:@"ewnupdates"];
    [self addEntry:kTypeTwitter Label:@"EWN Sport" Value:@"ewnsport"];
    [self addEntry:kTypeTwitter Label:@"EWN Traffic" Value:@"ewntraffic"];
    [self addEntry:kTypeFacebook Label:@"EWN" Value:@"https://www.facebook.com/pages/Eyewitness-News/168892509821961"];
    [self addEntry:kTypeYoutube Label:@"EWN Youtube Videos" Value:@"EWNonline"];
    [self addEntry:kTypePinterest Label:@"EWN Pinterest" Value:@"http://www.pinterest.com/ewnfeatures/"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)build
{
    // Resize view + Table based on Entries
    int newSize = (int)[self.tableView rowHeight] * [self.tableArray count];
    int newHeight = self.tableView.frame.origin.y + newSize;
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, newHeight)];
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, newSize)];
    
    [self.tableView reloadData];
}

- (void)addEntry:(NSString *)type Label:(NSString *)label Value:(NSString *)value
{
    
    NSArray *entries = [NSArray arrayWithObjects:type, label, value, nil];
    NSArray *keys    = [NSArray arrayWithObjects:@"type", @"label", @"value", nil];
    
    NSDictionary *newDick = [NSDictionary dictionaryWithObjects:entries forKeys:keys];
    
    [self.tableArray addObject:newDick];
}

// ==============================================================================================================================
// TABLE METHODS
// ==============================================================================================================================

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@":: Table Count : %d", [self.tableArray count]);
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *tempDick = [self.tableArray objectAtIndex:(int)indexPath.row];
    
    if (cell == nil)
    {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setImage:[tempDick objectForKey:@"type"]];
    [cell.label setText:[tempDick objectForKey:@"label"]];
    [cell setOptionValue:[tempDick objectForKey:@"value"]];
    
    //DLog(@"CELL : %@", tempDick);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        NSString *messageString = @"Unable to connect to the internet, check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
    
    
    NSDictionary *dick = [self.tableArray objectAtIndex:(int)indexPath.row];
    NSString *type = [dick objectForKey:@"type"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *tempUrl = [[NSString alloc] init];
    
    
    if([kTypeFacebook isEqualToString:type])
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]])
        {
            tempUrl = [NSString stringWithFormat:@"fb://profile/%@", @"168892509821961"];
        }
        else
        {
            tempUrl = [dick objectForKey:@"value"];
        }
    }
    else if([kTypeTwitter isEqualToString:type])
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
        {
            tempUrl = [NSString stringWithFormat:@"twitter://user?screen_name=%@", [dick objectForKey:@"value"]];
        }
        else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]])
        {
            tempUrl = [NSString stringWithFormat:@"tweetbot://%@/timeline", [dick objectForKey:@"value"]];
        }
        else
        {
            tempUrl = [NSString stringWithFormat:@"https://twitter.com/%@/", [dick objectForKey:@"value"]];
        }
    }
    else if([kTypeYoutube isEqualToString:type])
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"youtube://"]])
        {
            tempUrl = [NSString stringWithFormat:@"youtube://user/%@", [dick objectForKey:@"value"]];
        }
        else
        {
            tempUrl = [NSString stringWithFormat:@"http://www.youtube.com/%@/", [dick objectForKey:@"value"]];
        }
    }
    else if([kTypePinterest isEqualToString:type])
    {
        tempUrl = [dick objectForKey:@"value"];
    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're about to leave the app.\nWould you like to proceed?"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Proceed", nil];
    
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex != [alertView cancelButtonIndex]) {
            NSURL *url = [NSURL URLWithString:tempUrl];
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
}

@end
