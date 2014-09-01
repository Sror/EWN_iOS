//
//  SideMenuViewController.m
//  EWN
//
//  Created by Pratik Prajapati on 4/24/13.
//
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

//@synthesize tfSearch;
@synthesize dataArray;
@synthesize engageProtocol;
@synthesize firstSectionDict;
@synthesize contributeImage;

# pragma mark
# pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

/**-----------------------------------------------------------------
 Function Name  : viewDidLoad
 Created By     : Jainesh Patel
 Created Date   : 5-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : Allocation of objects has been done here.
 ------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tblSideMenu setBackgroundColor:[UIColor clearColor]];
    [tblSideMenu setSeparatorColor:[UIColor darkGrayColor]];
    
    [tblSideMenu setTableFooterView:[[UIView alloc] init]];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    NSString *userId = [objMainView userIdReturn];
    if (![userId isEqualToString:@""]) {
        [self.loginLabel setText:@"Sign Out"];
    }

    [self.loginButton removeTarget:self action:@selector(gotoJanrain:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.loginButton addTarget:self action:@selector(gotoJanrain:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [contributeImage setImage:[UIImage imageNamed:@"icon_contribute"]];
    
    [self.contributeButton addTarget:self action:@selector(contributeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingsButton addTarget:self action:@selector(settingsButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactButton addTarget:self action:@selector(contactButton:) forControlEvents:UIControlEventTouchUpInside];
}

/**-----------------------------------------------------------------
 Function Name  : viewDidAppear
 Created By     : Jainesh Patel
 Created Date   : 5-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : Calling the webservice of category.
 ------------------------------------------------------------------*/

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    // Construct DataArray - Categories, In Focus
    
    // First Section
    if ([[[WebserviceComunication sharedCommManager] arrCategories] count] == 1) {
        firstSectionDict = [NSDictionary dictionaryWithObject:[[CacheDataManager sharedCacheManager] getCatogery] forKey:@"data"];
        [[WebserviceComunication sharedCommManager] setArrCategories:[firstSectionDict objectForKey:@"data"]];
    } else {
        firstSectionDict = [NSDictionary dictionaryWithObject:[[WebserviceComunication sharedCommManager] arrCategories] forKey:@"data"];
    }
    
    [self.dataArray addObject:firstSectionDict];
    
    // Second Section
    if ([[WebserviceComunication sharedCommManager] isOnline]) {
        NSDictionary *secondSectionDict = [NSDictionary dictionaryWithObject:[[CacheDataManager sharedCacheManager] getInFocusArray] forKey:@"data"];
        [self.dataArray addObject:secondSectionDict];
    }
    
    [tblSideMenu reloadData];
}

- (IBAction)gotoJanrain:(id)sender {
    // check if we are loggin in
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    NSString *userId = [objMainView userIdReturn];
    if (![userId isEqualToString:@""]) {
        // ok so let's prompt first...
        CustomAlertView *alrtvwNotReachable = [[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:2];
        alrtvwNotReachable.lblHeading.text = @"Sign Out";
        alrtvwNotReachable.lblDetail.text = @"Do you want to sign out?";
        alrtvwNotReachable.view.tag = kALERT_TAG_SIGN_OUT;
        [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
        [alrtvwNotReachable.btn2 setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_SIGN_OUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut) name:kNOTIFICATION_SIGN_OUT object:nil];
        
        return;
    }
    
    // first check availability
    if (![objMainView netWorkAvailable]) {
        // TODO
        // alert about network issues
        return;
    }
    
    if (engageProtocol == nil) {
        engageProtocol = [[EngageProtocol alloc]init];
        engageProtocol.delegate = self;
    }
    
    NSString *appId = @"egbgbafpecbanbdmjhae";
    [JREngage setEngageAppId:appId tokenUrl:nil andDelegate:engageProtocol.delegate];
    
    [JREngage showAuthenticationDialog];
    [self closeSideMenu];
}

-(void) signOut {
    [[WebserviceComunication sharedCommManager] showAlert:@"Sign out" message:@"You have been signed out successfully."];
    [self.loginLabel setText:@"Sign In"];
}

#pragma mark - Sample protocol delegate
- (void) authenticationDidFailWithError:(NSError *) error forProvider:(NSString *) provider {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Sign In"
                          message: error.localizedFailureReason
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [JREngage removeDelegate:engageProtocol.delegate];
}

- (void) authenticationDidSucceedForUser:(NSDictionary *) authInfo forProvider:(NSString *)	provider {
    // Creating the dictionary this way as we have more control on not inserting nil values
    // into dictionary which causes crash - Andre
    NSMutableDictionary *authDetails = [NSMutableDictionary dictionary];
    
    if ([authInfo objectForKey:@"profile"])
    {
        if ([[authInfo objectForKey:@"profile"] objectForKey:@"providerName"])
            [authDetails setValue:[[authInfo objectForKey:@"profile"] objectForKey:@"providerName"] forKey:@"providerName"];
        
        if ([[authInfo objectForKey:@"profile"] objectForKey:@"displayName"])
            [authDetails setValue:[[authInfo objectForKey:@"profile"] objectForKey:@"displayName"] forKey:@"displayName"];
        
        if ([[authInfo objectForKey:@"profile"] objectForKey:@"email"])
            [authDetails setValue:[[authInfo objectForKey:@"profile"] objectForKey:@"email"] forKey:@"email"];
        
        if ([[authInfo objectForKey:@"profile"] objectForKey:@"photo"])
            [authDetails setValue:[[authInfo objectForKey:@"profile"] objectForKey:@"photo"] forKey:@"image"];
    }
    
    if ([authInfo objectForKey:@"token"]) {
        [authDetails setValue:[authInfo objectForKey:@"token"] forKey:@"id"];
    }
    
    // call the ewn webservice with these details
    [[[WebserviceComunication sharedCommManager] dictAuthenticate] addEntriesFromDictionary:authDetails];
    [[WebserviceComunication sharedCommManager] getAuthentication];
    
    [JREngage removeDelegate:engageProtocol.delegate];
    // register a receiver for the webservice
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationFromEWN) name:kNOTIFICATION_AUTHENTICATE object:nil];
}

- (void) authenticationDidNotComplete {
    // authentication error message
    [JREngage removeDelegate:engageProtocol.delegate];
}

- (void) authenticationFromEWN {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_AUTHENTICATE object:nil];
    
    NSDictionary *myDick = [[WebserviceComunication sharedCommManager] dictAuthenticate];
    NSString *userId = [myDick objectForKey:@"AuthenticateUserByTokenResult"];
    
    if (userId != nil) {
        // save the userId and alert the user
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        [objMainView userIdSave:userId];
        [self.loginLabel setText:@"Sign Out"];
    } else {
        // message here
        [[WebserviceComunication sharedCommManager] showAlert:@"Sign In" message:@"Unable to sign in. Please try again."];
    }
}

# pragma mark
# pragma mark - Other implementation
/**-----------------------------------------------------------------
 Function Name  : searchButtonTapped
 Created By     : Jainesh Patel
 Created Date   : 5-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : Calling the webservice of category.
 ------------------------------------------------------------------*/
- (IBAction)searchButtonTapped:(id)sender
{
    //[self btnSearch_Pressed:tfSearch];
}

/**-----------------------------------------------------------------
 Function Name  : closeSideMenu:
 Created By     : Pratik Prajapati
 Created Date   : 26-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Closes the Side Menu on pressing 'Search' button.
 ------------------------------------------------------------------*/

-(void)closeSideMenu
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    // Close the Side Menu
    
    [UIView beginAnimations:kstrShow context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.view setFrame:CGRectMake(-self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [objMainView.view setFrame:CGRectMake(0, objMainView.view.frame.origin.y, objMainView.view.frame.size.width, objMainView.view.frame.size.height)];
    [UIView commitAnimations];
    
    [self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
    [objMainView.vwSideMenuHandler removeFromSuperview];
    objMainView.isSideViewOpen = FALSE;
}

- (void)contributeButton:(id)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;    
    [objMainView enableContributeView];
}

- (void)settingsButton:(id)sender
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    [objMainView enableSettingsView];
}

- (void)contactButton:(id)sender
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    [objMainView enableContactView];
}

# pragma mark
# pragma mark - UITextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    return YES;
}


# pragma mark
# pragma mark - UITableView Delegate,Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section >= 0)
    {
        NSArray *array = [[self.dataArray objectAtIndex:section] objectForKey:@"data"];
        return [array count];
    }
    /*-----------------------------------------------------------------*/
    
    return 0;
}

/**-----------------------------------------------------------------
 Function Name  : viewForHeaderInSection
 Created By     : Sumit kumar.
 Created Date   : 26-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : prepare the header for section.
 ------------------------------------------------------------------*/

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        // No Header for main Categories
        return nil;
    } else if(section == 1) {
        // check if we have in focus items
        if (![[WebserviceComunication sharedCommManager] isOnline]) {
            return nil;
        }
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        [headerView setBackgroundColor:kUICOLOR_SIDEMNU_HEADER];
        
        UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 140, 25)];
        headingLabel.textColor = [UIColor whiteColor];
        headingLabel.font = [UIFont fontWithName:kFontOpenSansRegular size:12.0];
        headingLabel.backgroundColor = kUICOLOR_SIDEMNU_HEADER;
        [headerView addSubview:headingLabel];
        
        headingLabel.text = kstrFOCUS;
        
        return headerView;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return 0;
    } else {
        if (![[WebserviceComunication sharedCommManager] isOnline]) {
            return 0;
        }
        return 25;
    }
}
/**-----------------------------------------------------------------
 Function Name  : cellForRowAtIndexPath
 Created By     : pratik prajapati.
 Created Date   : 26-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : prepare the cell content.
 ------------------------------------------------------------------*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"data"];
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", indexPath.section, indexPath.row];
    SideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[SideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.section == 0)
    {
        // Online/Offline mode - Update array in Webservice to ONLY return Category_Items, and not fackin' Dictionaries ...
        // Essentially, the same process as the updated version of the News, where it uses the same format both on/off the line ...
//        NSDictionary *dicData = [[[CacheDataManager sharedCacheManager] getCatogery] objectAtIndex:indexPath.row];
        
        if (indexPath.row < ([array count] - 1)) {
            [cell addSeperatorView];
        }
        
        NSDictionary *tmpData = [self.dataArray objectAtIndex:0];
//        DLog(@"Data = %@",[[tmpData objectForKey:@"data"] objectAtIndex:indexPath.row]);
        
        Category_Items *dicData = [[tmpData objectForKey:@"data"] objectAtIndex:indexPath.row];
        
        NSString *txt = [dicData categoryName];
        [cell.textLabel setText:txt];
        [cell.iconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ico_%@",[[dicData categoryName] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]];
    }
    else if(indexPath.section == 1)
    {
        if (array && array.count > 0)
        {
            if (indexPath.row < ([array count] - 1)) {
                [cell addSeperatorView];
            }
            InFocus_Items *item = [array objectAtIndex:indexPath.row];
            NSString *txt = [item title];
            [cell.textLabel setText:txt];
        }
        
        [cell.iconView setImage:[UIImage imageNamed:@"ico_Focus.png"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
}
/**-----------------------------------------------------------------
 Function Name  : didSelectRowAtIndexPath
 Created By     : pratik prajapati.
 Created Date   : 26-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : calls when cell selected
 ------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tfSearch setText:@""];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.shadowColor = [UIColor clearColor];
    
    // Get back to News...
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    [objMainView.scrvwMainScroll setContentOffset:CGPointMake(0, objMainView.scrvwMainScroll.frame.size.height) animated:YES];
    
    [objMainView.newsListViewController.scrlvwNewsContent setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [objMainView.newsListViewController.latestContentsView.scrlvwContentList setContentOffset:CGPointMake(objMainView.newsListViewController.latestContentsView.scrlvwContentList.contentOffset.x,0) animated:TRUE];
    
    [objMainView.newsListViewController.videoContentsView.scrlvwContentList setContentOffset:CGPointMake(objMainView.newsListViewController.videoContentsView.scrlvwContentList.contentOffset.x,0) animated:TRUE];
    
    [objMainView.newsListViewController.imagesContentsView.scrlvwContentList setContentOffset:CGPointMake(objMainView.newsListViewController.imagesContentsView.scrlvwContentList.contentOffset.x,0) animated:TRUE];
    
    [objMainView.newsListViewController.audioContentsView.scrlvwContentList setContentOffset:CGPointMake(objMainView.newsListViewController.audioContentsView.scrlvwContentList.contentOffset.x,0) animated:TRUE];
    
    /**-----------------------------------------------------------------
     Updated On : 7-Jun-2013
     Updated By : Sumit Kumar
     Purpose    : Removed Filter Types
     ------------------------------------------------------------------*/
    if(indexPath.section >= 0)
    {
        if([[WebserviceComunication sharedCommManager] isOnline] == TRUE)
        {
            // CATEGORY
            if(indexPath.section == 0)
            {
                //NSDictionary *dicCategory = [[[WebserviceComunication sharedCommManager] arrCategories]objectAtIndex:indexPath.row];
                NSArray *array = [[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"data"];
                
                Category_Items *item = (Category_Items *)[array objectAtIndex:indexPath.row];
                
                ////////////////
                // TEMP Solution - Convert Categoy_Items to NSDictionary, because portions of the app do not use the locally stored Entity only the NSDictionary from WebService
                ////////////////
                NSDictionary *dicCategory = [[NSMutableDictionary alloc] init];
                [dicCategory setValue:[item categoryId] forKey:kstrId];
                [dicCategory setValue:[item categoryName] forKey:kstrName];
                ////////////////
                
                [[WebserviceComunication sharedCommManager] setDictCurrentCategory:[dicCategory mutableCopy]];
                
                NSString *strCurrentCategorylabel = [NSString stringWithFormat:@"%@",[item categoryName]];
                
                [objMainView.lblCurrentCategory setText:[strCurrentCategorylabel lowercaseString]];
                [objMainView.newsListViewController performSelector:@selector(ReloadAllData) withObject:nil afterDelay:0.5];
            }
            
            // IN FOCUS
            if(indexPath.section == 1)
            {
                NSArray *array = [[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"data"];
                
                InFocus_Items *item = [array objectAtIndex:indexPath.row];
                
                //NSDictionary *test = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:item.id] forKeys:[NSArray arrayWithObject:kstrId]];
                [[WebserviceComunication sharedCommManager] setStrInFocusId:item.id];
                
                [objMainView.lblCurrentCategory setText:[item.title lowercaseString]];
                objMainView.currentInFocusName = [item.title lowercaseString];
                 
                [objMainView.newsListViewController performSelector:@selector(ReloadInFocus) withObject:nil afterDelay:0.5];
            }
            
        }
        else
        {
            Category_Items *currentCategory = (Category_Items *)[[[CacheDataManager sharedCacheManager] getCatogery] objectAtIndex:indexPath.row];
            NSMutableDictionary *dictNewCurrentCategory = [[NSMutableDictionary alloc] init];
            [dictNewCurrentCategory setObject:[currentCategory categoryId] forKey:kstrId];
            [dictNewCurrentCategory setObject:[currentCategory categoryName] forKey:kstrName];
            
            [[WebserviceComunication sharedCommManager] setDictCurrentCategory:dictNewCurrentCategory];
            
            NSString *strCurrentCategorylabel = [NSString stringWithFormat:@"%@",[currentCategory categoryName]];
            
            [objMainView.lblCurrentCategory setText:[strCurrentCategorylabel lowercaseString]];
            
            [objMainView.newsListViewController performSelector:@selector(ReloadAllData) withObject:nil afterDelay:0.5];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[[WebserviceComunication sharedCommManager] dictCurrentCategory] forKey:@"CurrentCategory"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self closeSideMenu];
        
        //[objMainView closeSearchNewsView];
    }
    /*-----------------------------------------------------------------*/
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.shadowColor = [UIColor blackColor];
}

# pragma mark
# pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
