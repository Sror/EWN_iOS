//
//  ContactDetailsViewController.m
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import "ContactDetailsViewController.h"

#import "MainViewController.h"

@interface ContactDetailsViewController ()

@end

@implementation ContactDetailsViewController

@synthesize picker;
@synthesize pickerArray;
@synthesize tableArray;
@synthesize ctArray;
@synthesize jhbArray;

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
    
    self.picker = [[CustomPickerViewController alloc] init];
    [self.cityField setDelegate:self];
    [self.picker setTextField:self.cityField];
    
    self.pickerArray = [NSMutableArray arrayWithObjects:@"Cape Town", @"Johannesburg", nil];
    self.ctArray = [[NSMutableArray alloc] init];
    self.jhbArray = [[NSMutableArray alloc] init];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.cityView.layer setCornerRadius:5.0];
    
    [self.cityField setFont:[UIFont fontWithName:kFontOpenSansRegular size:12]];
    [self.cityField setText:[self.pickerArray objectAtIndex:currentSection]];
    
    // CommonConstants
    
    currentSection = 0;
    [self addEntry:kTypeCall Label:@"Newsroom" Value:@"0214464867"];
    [self addEntry:kTypeCall Label:@"24 Hour Hotline" Value:@"0860006397"];
    [self addEntry:kTypeFax Label:@"Fax" Value:@"+27 021 446 4880"];
    [self addEntry:kTypeCall Label:@"Traffic Line" Value:@"0839137483"];
    [self addEntry:kTypeSms Label:@"SMS Traffic line" Value:@"31567"];
    [self addEntry:kTypeCall Label:@"567 Studio Phone" Value:@"0214460567"];
    [self addEntry:kTypeCall Label:@"94.5 KFM" Value:@"0861536945"];
    [self addEntry:kTypeCall Label:@"Main Switchboard" Value:@"0214464700"];
    
    currentSection = 1;
    [self addEntry:kTypeCall Label:@"Newsroom" Value:@"0115063555"];
    [self addEntry:kTypeCall Label:@"24 Hour Hotline" Value:@"0860006397"];
    [self addEntry:kTypeFax Label:@"Fax" Value:@"086 501 2014"];
    [self addEntry:kTypeCall Label:@"Traffic Line" Value:@"0839137483"];
    [self addEntry:kTypeSms Label:@"SMS Traffic line" Value:@"31702"];
    [self addEntry:kTypeCall Label:@"702 Studio Phone" Value:@"0118830702"];
    [self addEntry:kTypeCall Label:@"94.7 Highveld Stereo" Value:@"0118838947"];
    [self addEntry:kTypeCall Label:@"Main Switchboard" Value:@"0115063702"];
    
    // Reset currentSection to 0 after building up Arrays
    currentSection = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)build
{
    switch (currentSection) {
        case 0:
            self.tableArray = self.ctArray;
            break;
            
        case 1:
            self.tableArray = self.jhbArray;
            break;
            
        default:
            break;
    }
    
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
    
    switch (currentSection) {
        case 0:
            [self.ctArray addObject:newDick];
            break;
            
        case 1:
            [self.jhbArray addObject:newDick];
            break;
            
        default:
            break;
    }
}

// ==============================================================================================================================
// TEXTFIELD METHODS
// ==============================================================================================================================

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // set picker
    [self.picker setDataArray:self.pickerArray];
    [self.cityField setInputView:self.picker.view];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // update field and action item
    DLog(@"Item Selected : %d", (int)[self.picker itemSelected]);
    
    currentSection = (int)[self.picker itemSelected];
    [self build];
    
    // Storing??
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setInteger:(int)[self.picker itemSelected] forKey:@"ContactDetailsCity"];
//    [defaults synchronize];
}

// ==============================================================================================================================
// TABLE METHODS
// ==============================================================================================================================

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
    [cell setOptionValue:[tempDick objectForKey:@"value"]];
    
    if([[tempDick objectForKey:@"type"] isEqualToString:kTypeFax])
    {
        NSString *faxLabel = [NSString stringWithFormat:@"%@ : %@", [tempDick objectForKey:@"label"], [tempDick objectForKey:@"value"]];
        [cell.label setText:faxLabel];
    }
    else
    {
        [cell.label setText:[tempDick objectForKey:@"label"]];
    }
    
    //DLog(@"CELL : %@", tempDick);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dick = [self.tableArray objectAtIndex:(int)indexPath.row];
    NSString *type = [dick objectForKey:@"type"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    if([kTypeCall isEqualToString:type])
    {
        //DLog(@"CALL");
        [objMainView phoneWithNumber:[dick objectForKey:@"value"]];
    }
    else if([kTypeSms isEqualToString:type])
    {
        //DLog(@"SMS");
        [objMainView openMessageComposer:[dick objectForKey:@"value"]];
    }
    else if([kTypeEmail isEqualToString:type])
    {
        //DLog(@"EMAIL");
        [objMainView openMessageComposer:[dick objectForKey:@"value"]];
    }
    else if([kTypeFax isEqualToString:type])
    {
        //DLog(@"FAX");
    }
}


@end
