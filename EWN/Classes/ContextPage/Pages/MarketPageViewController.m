//
//  MarketPageViewController.m
//  EWN
//
//  Created by Dolfie Jay on 2014/04/02.
//
//

#import "MarketPageViewController.h"

@interface MarketPageViewController ()

@end

@implementation MarketPageViewController

@synthesize marketArray;
@synthesize marketTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    self.marketArray = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    marketTable.layer.borderWidth = 1;
    marketTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [marketTable.layer setCornerRadius:10];
    marketTable.separatorColor = [UIColor clearColor];
    [marketTable setBounces:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [marketArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    MarketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        // allocate the cell
        cell = [[MarketTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    [cell initValues:[marketArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 44)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    [headerView addSubview:[self tableViewHeadingLabel:0 labelText:@"Market"]];
    [headerView addSubview:[self tableViewHeadingLabel:102 labelText:@"Indicator"]];
    [headerView addSubview:[self tableViewHeadingLabel:204 labelText:@"Value"]];
    
    [headerView addSubview:[self seperatorLine:102]];
    [headerView addSubview:[self seperatorLine:204]];
    
    UIView *bottomborder = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 306, 1)];
    [bottomborder setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:bottomborder];

    return headerView;
}

- (UILabel *)tableViewHeadingLabel:(int)x labelText:(NSString *)labelString {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 12, 100, 22)];
    [label setText:labelString];
    [label setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:13.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

- (UIView *)seperatorLine:(int) x {
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 1, 44)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    return seperator;
}

@end
