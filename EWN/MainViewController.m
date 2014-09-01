//
//  mainViewController.m
//  EWN
//
//  Created by Pratik Prajapati on 4/24/13.
//
//

#import "MainViewController.h"
#import "WebserviceComunication.h"
#import "SplashScreenViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MainViewController ()

@end    

@implementation MainViewController

@synthesize breakingNewsNotification;

@synthesize newsListViewController;
@synthesize contextMenu;
@synthesize contextPage;
@synthesize isSideViewOpen;
@synthesize isArticleDetailOpen;
@synthesize isSearchOpen;
@synthesize searchString;
@synthesize lblCurrentCategory;
@synthesize scrvwMainScroll;

@synthesize vwSideMenuHandler = _vwSideMenuHandler;
@synthesize articleDetailMaster = _articleDetailMaster;
@synthesize sideMenuViewController = _sideMenuViewController;

@synthesize settingsView;
@synthesize contactView;

@synthesize commentModal;
@synthesize loadingScreen;
@synthesize contentDetailLightbox;
@synthesize lightBoxScroll;

@synthesize config;
@synthesize notificationArticleId;

@synthesize prevCategory;

@synthesize currentInFocusName;

# pragma mark
# pragma mark - View Lifecycle
/**-----------------------------------------------------------------
 Function Name  : initWithNibName
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Allocation of objects and variables.
 ------------------------------------------------------------------*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        arrCategories = [[NSMutableArray alloc]init];
        isSideViewOpen = FALSE;
        isArticleDetailOpen = FALSE;
        isSearchOpen = FALSE;
        isCategoryOpen = FALSE;
        bIsSearchNewsVisible = FALSE;
    }
    
    return self;
}

/**-----------------------------------------------------------------
 Function Name  : viewDidLoad
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : will call when view did loads.
 ------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    numPan_MIN_X = 245;
    numPan_MAX_X = self.view.frame.size.width;
    
    // For iOS 7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        viewTop.frame = CGRectMake(0, 20, viewTop.frame.size.width, viewTop.frame.size.height);
        viewBackground.frame = CGRectMake(0, 20, viewBackground.frame.size.width, viewBackground.frame.size.height);
    }
    
    [viewTop.layer setShadowColor:[UIColor grayColor].CGColor];
    [viewTop.layer setShadowOffset:CGSizeMake(0, 1)];
    [viewTop.layer setShadowOpacity:0.6];
    [viewTop.layer setShadowRadius:2.0];
    
    [self.scrvwMainScroll setContentSize:CGSizeMake(self.scrvwMainScroll.frame.size.width,self.scrvwMainScroll.frame.size.height*2)];
    [self.scrvwMainScroll setShowsHorizontalScrollIndicator:FALSE];
    [self.scrvwMainScroll setShowsVerticalScrollIndicator:FALSE];
    [self.scrvwMainScroll setContentOffset:CGPointMake(0, self.scrvwMainScroll.frame.size.height)];
    [self.scrvwMainScroll setScrollsToTop:FALSE];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.height == 568)
        {
            // Code for iPhone 4-inch screen
            splashScreenViewController = [[SplashScreenViewController alloc] initWithNibName:kstrSplashScreenViewController_iPhone5 bundle:nil];
            strXibSettings = kstrSettingsViewController_iPhone5;
            strXibContact = kstrContactViewController_iPhone5;
            strXibContribute = kstrContributeViewController_iPhone5;
        }
        else
        {
            // Code for iPhone 3.5-inch screen
            splashScreenViewController = [[SplashScreenViewController alloc] initWithNibName:kstrSplashScreenViewController_iPhone bundle:nil];
            strXibSettings = kstrSettingsViewController;
            strXibContact = kstrContactViewController;
            strXibContribute = kstrContributeViewController;
        }
    }
    
    // Remove Splash, then also display the ContextMenu
    [splashScreenViewController.view setTag:8000];
    [self.view addSubview:splashScreenViewController.view];
    
    [lblCurrentCategory setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:22.0]];
    [lblCurrentCategory setTextColor:[UIColor colorWithHexString:@"dc0707"]];
    
    if (![[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrName] isEqualToString:@"(null)"])
    {
        NSString *strCurrentCategorylabel = [[NSString alloc] initWithFormat:@"%@",[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrName]];
        [lblCurrentCategory setText:[strCurrentCategorylabel lowercaseString]];
    }
    else
    {
        [lblCurrentCategory setText:@""];
    }
    
    [self performSelector:@selector(addNewsListView) withObject:nil afterDelay:0.0];
    
    // make our existing layout work beyond iOS6
    if ([self respondsToSelector:NSSelectorFromString(@"edgesForExtendedLayout")]) {
        [self setValue:[NSNumber numberWithInt:0] forKey:@"edgesForExtendedLayout"];
    }
    
    // ADTech
    self.config = [ATAdtechAdConfiguration configuration];
    [config setAlias:@"test-app-5"];
    [config setDomain:@"a.adtech.de"];
    [config setNetworkID:567];
    [config setSubNetworkID:1];
    [config setGroupID:100];
    [config setAllowLocationServices:YES];
    [config setEnableImageBannerResize:YES];
    
    // notification initiation
    [self createNotificationObservers];
}

//===========================================================================
// Contribute Audio
//===========================================================================

- (void)presentAudioPicker {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
    
    [picker setDelegate: self];
    [picker setAllowsPickingMultipleItems:NO];
    picker.prompt = NSLocalizedString (@"Audio to attach", "Prompt in media item picker");
    
    [self presentModalViewController: picker animated: YES];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) collection {
    DLog(@"Audio = %@",[collection.items objectAtIndex:0]);
    [self dismissModalViewControllerAnimated: YES];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    [self dismissModalViewControllerAnimated: YES];
}

//===========================================================================
// Contribute Video
//===========================================================================

- (void)presentVideoPicker {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:YES];
    [self presentModalViewController:imagePicker animated:YES];
}

//===========================================================================
// Contribute Images
//===========================================================================

- (void)presentImagePicker {    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)recropImage:(UIImage *)imageToCrop tagNumber:(int)tag {
    PECropViewController *controller = [[PECropViewController alloc] init];
    float cropwidth = 520;
    float cropHeight = 311;
    CGFloat ratio = cropwidth / cropHeight;
//    controller.imageCropRect = CGRectMake((self.view.frame.size.width - cropwidth) / 2, (self.view.frame.size.height - cropHeight) / 2, cropwidth, cropHeight);
    [controller setCropAspectRatio:ratio];
    [controller setKeepingCropAspectRatio:YES];
    controller.delegate = self;
    controller.image = imageToCrop;
    controller.originalImage = [imageToCrop copy];
    controller.view.tag = tag;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:NO];
    
    if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info objectForKey:@"UIImagePickerControllerMediaURL"];
        
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *videoImage = [[UIImage alloc] initWithCGImage:oneRef];
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:2];
        [info setObject:videoImage forKey:@"VideoImage"];
        [info setObject:videoUrl forKey:@"VideoUrl"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRIBUTE_IMAGE_PICKER" object:info];
        return;
    }
    
    UIImage *theImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    PECropViewController *controller = [[PECropViewController alloc] init];
    float cropwidth = 520;
    float cropHeight = 311;
//    controller.imageCropRect = CGRectMake((self.view.frame.size.width - cropwidth) / 2, (self.view.frame.size.height - cropHeight) / 2, cropwidth, cropHeight);
    CGFloat ratio = cropwidth / cropHeight;
    [controller setCropAspectRatio:ratio];
    [controller setKeepingCropAspectRatio:YES];
    controller.delegate = self;
    controller.image = theImage;
    controller.originalImage = [theImage copy];
    controller.view.tag = 99;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:3];
    [info setObject:croppedImage forKey:@"CroppedImage"];
    [info setObject:controller.originalImage forKey:@"OriginalImage"];
    NSNumber *tagNumber = [[NSNumber alloc] initWithInt:controller.view.tag];
    [info setObject:tagNumber forKey:@"TagNumber"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRIBUTE_IMAGE_PICKER" object:info];
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

/**-----------------------------------------------------------------
 Function Name  : addNewsListView
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : It adds news view list view.
 ------------------------------------------------------------------*/
- (void)addNewsListView
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568)
        {
            newsListViewController = [[NewsListViewController alloc]initWithNibName:kstrNewsListViewController_iPhone5 bundle:nil];
            [newsListViewController.view setFrame:CGRectMake(self.scrvwMainScroll.frame.origin.x,self.scrvwMainScroll.frame.size.height,newsListViewController.view.frame.size.width ,newsListViewController.view.frame.size.height)];
            [self.scrvwMainScroll addSubview:newsListViewController.view];
            
            self.articleDetailMaster = [[ArticleDetailMaster alloc]initWithNibName:kstrArticleMasterViewController_iPhone5 bundle:nil];
            [self.articleDetailMaster.view setFrame:CGRectMake(0, 0, self.articleDetailMaster.view.frame.size.width, self.articleDetailMaster.view.frame.size.height)];
            [self.scrvwMainScroll addSubview:self.articleDetailMaster.view];
        }
        else
        {            
            newsListViewController = [[NewsListViewController alloc]initWithNibName:kstrNewsListViewController bundle:nil];
            [newsListViewController.view setFrame:CGRectMake(self.scrvwMainScroll.frame.origin.x,self.scrvwMainScroll.frame.size.height,newsListViewController.view.frame.size.width ,newsListViewController.view.frame.size.height)];
            [self.scrvwMainScroll addSubview:newsListViewController.view];
            
            
            self.articleDetailMaster = [[ArticleDetailMaster alloc]initWithNibName:kstrArticleMasterViewController bundle:nil];
            [self.articleDetailMaster.view setFrame:CGRectMake(0, 0, self.articleDetailMaster.view.frame.size.width, self.articleDetailMaster.view.frame.size.height)];
            [self.scrvwMainScroll addSubview:self.articleDetailMaster.view];
        }
        int offsetY = 0;
        
        // For iOS 7
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            offsetY = 20;
        }
        self.vwSideMenuHandler = [[UIView alloc] initWithFrame:CGRectMake(0,offsetY,self.view.frame.size.width,self.view.frame.size.height)];
        [self.vwSideMenuHandler setUserInteractionEnabled:TRUE];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnSideMenu_Pressed:)];
        [tapRecognizer setNumberOfTouchesRequired:1];
        [tapRecognizer setNumberOfTapsRequired:1];
        [self.vwSideMenuHandler addGestureRecognizer:tapRecognizer];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self.vwSideMenuHandler addGestureRecognizer:panRecognizer];
    }
    
}

// CONTEXT MENU
- (void)contextMenuInit {
    // called after start up
    if (self.contextMenu != nil) {
        return;
    }
    
    self.contextMenu = [[ContextMenuViewController alloc] init];
    self.contextPage = [[ContextPageViewController alloc] init];
    [self.contextMenu setContextPage:self.contextPage];
    [self.contextMenu.view setFrame:CGRectMake(0, (self.view.frame.size.height - 60), 0, 0)];
    [self.view insertSubview:self.contextMenu.view belowSubview:splashScreenViewController.view];
    [self.contextMenu updateContextMenu:kContentListOptions];
    
    // CONTEXT PAGE
    [self.contextPage.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.contextPage.view];
}

/**-----------------------------------------------------------------
 Function Name  : viewWillAppear
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : It calls Reload data when connection is available.
 ------------------------------------------------------------------*/
- (void)viewWillAppear:(BOOL)animated
{
}

# pragma mark
# pragma mark - Other implementation

/**-----------------------------------------------------------------
 Function Name  : btnPlus_Pressed:
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Calls web-service to get Categories, Opens custom
 dropdown view later on.
 ------------------------------------------------------------------*/

-(IBAction)btnPlus_Pressed:(id)sender
{
}

/**-----------------------------------------------------------------
 Function Name  : openDropDownOfCategories
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Simply oepns Dropdown with animation.
 ------------------------------------------------------------------*/

-(void)openDropDownOfCategories
{
    if (dropDownCategories)
    {
        if ([dropDownCategories.view isDescendantOfView:self.view])
        {
            isCategoryOpen = TRUE;
        }
        else
        {
            isCategoryOpen = FALSE;
        }
    }
    
    if (!isCategoryOpen)
    {
        if([[WebserviceComunication sharedCommManager] isOnline] == TRUE)
        {
            dropDownCategories = [[DropDownView alloc] initWithArrayData:[[WebserviceComunication sharedCommManager] arrCategories] cellHeight:30 heightTableView:240 paddingTop:-2 paddingLeft:100 paddingRight:100 refView:btnPlus animation:BLENDIN openAnimationDuration:1 closeAnimationDuration:1];
        }
        else
        {
            dropDownCategories = [[DropDownView alloc] initWithArrayData:[[CacheDataManager sharedCacheManager] getCatogery] cellHeight:30 heightTableView:240 paddingTop:-2 paddingLeft:100 paddingRight:100 refView:btnPlus animation:BLENDIN openAnimationDuration:1 closeAnimationDuration:1];
        }
        
        dropDownCategories.delegate = self;
        [self.view addSubview:dropDownCategories.view];
        
        isCategoryOpen = TRUE;
        
        [dropDownCategories openAnimation];
        [dropDownCategories viewDidAppear:NO];
    }
    
    [[WebserviceComunication sharedCommManager] closeProgressView];
}
/**-----------------------------------------------------------------
 Function Name  : btnSideMenu_Pressed
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Simply oepns side bar with animation.
 ------------------------------------------------------------------*/
-(IBAction)btnSideMenu_Pressed:(id)sender {
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // If Article Detail is visible, Go Back
    if(isArticleDetailOpen) {
        [self disableArticleView];
        return;
    }
    
    if(isSearchOpen) {
        [self disableSearchView];
        return;
    }
    
    if(isSettingsOpen)
    {
        [self hidePages];
        return;
    }
    
    if(isContactOpen)
    {
        [self hidePages];
        return;
    }
    
    // If in Search Mode
    
    if (isSideViewOpen)
    {
        [UIView beginAnimations:kstrShow context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [appDelegate.window.rootViewController.view setFrame:CGRectMake(0, appDelegate.window.rootViewController.view.frame.origin.y, appDelegate.window.rootViewController.view.frame.size.width, appDelegate.window.rootViewController.view.frame.size.height)];
        [UIView commitAnimations];
        [self.sideMenuViewController.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
        
        [self.vwSideMenuHandler removeFromSuperview];
        
        isSideViewOpen = FALSE;
    }
    else
    {
        // close the context menu
        [self.contextPage displayContextPage:NO WithOffset:0];
        // close the keyboard
        [self.view endEditing:YES];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.height == 568)
        {
            self.sideMenuViewController = [[SideMenuViewController alloc] initWithNibName:kstrSideMenuViewController_iPhone5 bundle:nil];
        }
        else
        {
            self.sideMenuViewController = [[SideMenuViewController alloc] initWithNibName:kstrSideMenuViewController_iPhone bundle:nil];
        }
        
        [appDelegate.window addSubview:self.sideMenuViewController.view];
        [appDelegate.window sendSubviewToBack:self.sideMenuViewController.view];
        
        [UIView beginAnimations:kstrShow context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [appDelegate.window.rootViewController.view setFrame:CGRectMake(numPan_MIN_X, appDelegate.window.rootViewController.view.frame.origin.y, appDelegate.window.rootViewController.view.frame.size.width, appDelegate.window.rootViewController.view.frame.size.height)];
        [UIView commitAnimations];
        
        [self.view addSubview:self.vwSideMenuHandler];
        
        isSideViewOpen = TRUE;
    }
}

-(void)btnSideMenu_Config:(NSString *)strType
{
    if([strType isEqualToString:@"BACK"]) {
        [btnSideMenu setImage:[UIImage imageNamed:@"icon-back.png"] forState:UIControlStateNormal];
    }
    if([strType isEqualToString:@"NORMAL"]) {
        [btnSideMenu setImage:[UIImage imageNamed:@"ico-menu.png"] forState:UIControlStateNormal];
    }
}

/**-----------------------------------------------------------------
 Function Name  : btnRefresh_Pressed
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Bring the view to latest content type view.
 ------------------------------------------------------------------*/

-(IBAction)btnRefresh_Pressed:(id)sender {
    // are we in focus
    Boolean inFocus = [newsListViewController getIsInFocus];
    // are we in search mode
    Boolean inSearchMode = isSearchOpen;
    // are we not on all news
    Boolean onAllNews = [[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews];
    
    isArticleDetailOpen = FALSE;
    isSearchOpen = FALSE;
    
    [self btnSideMenu_Config:@"NORMAL"];
    
    [self.scrvwMainScroll setContentOffset:CGPointMake(0, self.scrvwMainScroll.frame.size.height) animated:YES];
    
    [newsListViewController.scrlvwNewsContent setContentOffset:CGPointMake(30, 0) animated:YES];
    [newsListViewController scrollViewDidScroll:newsListViewController.scrlvwNewsContent];
    [newsListViewController.scrlvwNewsContent setContentOffset:CGPointMake(0, 0) animated:YES];
    [newsListViewController.latestContentsView.scrlvwContentList setContentOffset:CGPointMake(0,0) animated:YES];
    
    newsListViewController.dragDownContentType = DragDownViewContentTypeLatest;
    
    if(bIsSearchNewsVisible) {
        [self closeSearchNewsView];
    }
    
    [self.newsListViewController DisabelSearchView];
    
    if (inFocus || inSearchMode || !onAllNews) {
        Category_Items *currentCategory = (Category_Items *)[[[CacheDataManager sharedCacheManager] getCatogery] objectAtIndex:0];
        NSMutableDictionary *dictNewCurrentCategory = [[NSMutableDictionary alloc] init];
        [dictNewCurrentCategory setObject:[currentCategory categoryId] forKey:kstrId];
        [dictNewCurrentCategory setObject:[currentCategory categoryName] forKey:kstrName];
        
        [[WebserviceComunication sharedCommManager] setDictCurrentCategory:dictNewCurrentCategory];
        
        NSString *strCurrentCategorylabel = [[NSString alloc] initWithFormat:@"%@",[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrName]];
        [lblCurrentCategory setText:[strCurrentCategorylabel lowercaseString]];
        
        [self.newsListViewController performSelector:@selector(ReloadAllData) withObject:nil afterDelay:0.0];
    
        [[NSUserDefaults standardUserDefaults] setObject:[[WebserviceComunication sharedCommManager] dictCurrentCategory] forKey:@"CurrentCategory"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    [[self contextMenu] updateContextMenu:kContentListOptions];
    
    // HIDE PAGES
    [self hidePages];
}

#pragma mark -
#pragma mark DropDownView Delegate

/**-----------------------------------------------------------------
 Function Name  : dropDownCellSelected:
 Created By     : Pratik Prajapati
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Called when user selects pertucular Category
 from list of Categories.
 ------------------------------------------------------------------*/

-(void)dropDownCellSelected:(NSInteger)returnIndex
{
    DLog(@"THIS?");
    
    isCategoryOpen = FALSE;
    if([[WebserviceComunication sharedCommManager] isOnline] == TRUE)
    {
        NSDictionary *dicCategory = [[[WebserviceComunication sharedCommManager] arrCategories]objectAtIndex:returnIndex];
        
        if (![[dicCategory objectForKey:kstrName] isEqualToString:[self.lblCurrentCategory text]])
        {
            [[WebserviceComunication sharedCommManager] setDictCurrentCategory:[[[WebserviceComunication sharedCommManager] arrCategories]objectAtIndex:returnIndex]];
            NSString *strCurrentCategorylabel = [NSString stringWithFormat:@"%@",[dicCategory objectForKey:kstrName]];
            
            [lblCurrentCategory setText:[strCurrentCategorylabel lowercaseString]];
            [Flurry logEvent:KFlurryEventCategorySwitched withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[dicCategory objectForKey:kstrName],kstrCategoryName,[dicCategory objectForKey:kstrId],kstrCategoryId, nil]];
            
            [newsListViewController performSelector:@selector(ReloadAllData) withObject:nil afterDelay:0.5];
        }
    }
    else
    {
        Category_Items *currentCategory = (Category_Items *)[[[CacheDataManager sharedCacheManager] getCatogery] objectAtIndex:returnIndex];
        
        NSMutableDictionary *dictNewCurrentCategory = [[NSMutableDictionary alloc] init];
        [dictNewCurrentCategory setObject:[currentCategory categoryId] forKey:kstrId];
        [dictNewCurrentCategory setObject:[currentCategory categoryName] forKey:kstrName];
        
        [[WebserviceComunication sharedCommManager] setDictCurrentCategory:dictNewCurrentCategory];
        
        NSString *strCurrentCategorylabel = [NSString stringWithFormat:@"%@",[currentCategory categoryName]];
        
        
        [lblCurrentCategory setText:[strCurrentCategorylabel lowercaseString]];
        
        [newsListViewController performSelector:@selector(ReloadAllData) withObject:nil afterDelay:0.5];
    }
}


# pragma mark
# pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    DLog(@"MEMORY WARNING!!!");
    [super didReceiveMemoryWarning];
}


/**-----------------------------------------------------------------
 Function Name  : move
 Created By     : sumit kumar.
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : method calls when pengesture moves.
 ------------------------------------------------------------------*/

-(void)move:(id)sender
{
    [self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan)
    {
        numPan_First_X = [self.view center].x;
        numPan_First_Y = [self.view center].y;
    }
    
    if (numPan_First_X+translatedPoint.x > numPan_MIN_X )
    {
        translatedPoint = CGPointMake(numPan_First_X + translatedPoint.x, numPan_First_Y);
    }
    else
    {
        translatedPoint = CGPointMake(numPan_MIN_X + 2, numPan_First_Y);
    }
    
    [[[sender view] superview] setCenter:translatedPoint];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
        CGFloat velocityX = (0.2*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
        
        CGFloat finalX = translatedPoint.x + velocityX;
        
        if (velocityX > 0)
        {
            finalX = numPan_MAX_X;
        }
        else
        {
            if (finalX < (numPan_MIN_X + (numPan_MIN_X /2)))
            {
                finalX = numPan_MIN_X;
            }
            else
            {
                finalX = numPan_MAX_X;
            }
        }
        
        CGFloat finalY = numPan_First_Y;
        
        if (finalX < numPan_MIN_X)
        {
            finalX = numPan_MIN_X;
        } else if (finalX > numPan_MAX_X)
        {
            finalX = numPan_MAX_X;
        }
        
        if (finalY < 0)
        {
            finalY = 0;
        } else if (finalY > self.view.frame.size.height)
        {
            finalY = self.view.frame.size.height;
        }
        
        CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
        [[[sender view] superview] setCenter:CGPointMake(finalX, finalY)];
        [UIView commitAnimations];
        
        if (finalX == numPan_MIN_X)
        {
            [self btnSideMenu_Pressed:nil];
        }
        
    }
}
/**-----------------------------------------------------------------
 Function Name  : openSearchViewWithKeyword
 Created By     : sumit kumar.
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : method opens search view with keyboard.
 ------------------------------------------------------------------*/

- (void)openSearchViewWithKeyword:(NSString*)strKeyword
{
    bIsSearchNewsVisible = TRUE;
}
/**-----------------------------------------------------------------
 Function Name  : closeSearchNewsView
 Created By     : sumit kumar.
 Created Date   : 24-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Close the Search News View with animation.
 ------------------------------------------------------------------*/

- (void)closeSearchNewsView
{
    DLog(@"CLOSE SEARCH Wayne");
    
    if (bIsSearchNewsVisible)
    {
        bIsSearchNewsVisible = FALSE;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

// ==============================================================================================================================
// ARTICLE VIEW
// ==============================================================================================================================

- (void)enableArticleView
{
    isArticleDetailOpen = YES;
    
    [self.scrvwMainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [self btnSideMenu_Config:@"BACK"];
    
    [self.contextMenu updateContextMenu:kContentDetailOptions];
}

- (void)disableArticleView
{
    isArticleDetailOpen = FALSE;
        
    if(!isSearchOpen)
    {
        [self.scrvwMainScroll setContentOffset:CGPointMake(0, self.scrvwMainScroll.frame.size.height) animated:YES];
        [self btnSideMenu_Config:@"NORMAL"];
        [self.contextMenu updateContextMenu:kContentListOptions];
    }
    else
    {
        [self.scrvwMainScroll setContentOffset:CGPointMake(0, self.scrvwMainScroll.frame.size.height) animated:YES];
        [self.contextMenu updateContextMenu:kSearchOptionsNoFocus];
        [self.contextMenu setLastType:kContentListOptions];
    }
}

// ==============================================================================================================================
// SEARCH VIEW
// ==============================================================================================================================

- (void)enableSearchView
{
    isSearchOpen = YES;
    
    [self.lblCurrentCategory setText:@"search"];
    
    [self btnSideMenu_Config:@"BACK"];
    
    // If Search was triggered from Article view, disable Article
    [self disableArticleView];
    
    [self.contextMenu updateContextMenu:kSearchOptionsNoFocus];
}

- (void)disableSearchView
{
    isSearchOpen = NO;
    
    [self resetCurrentCategoryLabel];
    
    [self btnSideMenu_Config:@"NORMAL"];
    
    [self.newsListViewController DisabelSearchView];
    
    [self.contextMenu updateContextMenu:kContentListOptions];
}

// ==============================================================================================================================
// CONTRIBUTE PAGE
// ==============================================================================================================================

- (void)enableContributeView {
    self.contributeView = [[ContributeViewController alloc] initWithNibName:strXibContribute bundle:nil];
    [self.contributeView.view setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [self.scrvwMainScroll addSubview:self.contributeView.view];
    
    [self.articleDetailMaster.view setHidden:YES];
    [self.contextMenu.view setHidden:YES];
    
    [self.lblCurrentCategory setText:@"contribute"];
    
    [self btnSideMenu_Config:@"BACK"];
    [self.sideMenuViewController closeSideMenu];
    
    [self.scrvwMainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.scrvwMainScroll setScrollEnabled:NO];
}

- (void)disableContributeView {
    [self.articleDetailMaster.view setHidden:NO];
    [self.contextMenu.view setHidden:NO];
    
    [self.contributeView.view removeFromSuperview];
    self.contributeView = nil;
    
    [self.scrvwMainScroll setScrollEnabled:YES];
    
    [self resetCurrentCategoryLabel];
}

- (void)displayContributeTerms {
    NSString *nibName = @"TermsViewController_iPhone4";
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        nibName = @"TermsViewController";
    }
    
    self.termsViewController = [[TermsViewController alloc] initWithNibName:nibName bundle:nil];
    [self.termsViewController.view setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];    
    [self.view addSubview:self.termsViewController.view];
}

- (void)closeContributeTerms {
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [self.termsViewController.view removeFromSuperview];
}

// ==============================================================================================================================
// SETTINGS PAGE
// ==============================================================================================================================

-(void)enableSettingsView
{
    isSettingsOpen = YES;
    
    self.settingsView = [[SettingsViewController alloc] initWithNibName:strXibSettings bundle:nil];
    [self.settingsView.view setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [self.scrvwMainScroll addSubview:self.settingsView.view];
    
    [self.articleDetailMaster.view setHidden:YES];
    [self.contextMenu.view setHidden:YES];
    
    [self.lblCurrentCategory setText:@"settings"];
    
    [self btnSideMenu_Config:@"BACK"];
    [self.sideMenuViewController closeSideMenu];
    
    [self.scrvwMainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)disableSettingsView
{
    isSettingsOpen = NO;
    
    [self.articleDetailMaster.view setHidden:NO];
    [self.contextMenu.view setHidden:NO];
    
    [self.settingsView.view removeFromSuperview];
    self.settingsView = nil;
    
    [self resetCurrentCategoryLabel];
}

// ==============================================================================================================================
// CONTACT PAGE
// ==============================================================================================================================

- (void)enableContactView
{
    isContactOpen = YES;

    self.contactView = [[ContactViewController alloc] initWithNibName:strXibContact bundle:nil];
    [self.contactView.view setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [self.scrvwMainScroll addSubview:self.contactView.view];
    
    [self.articleDetailMaster.view setHidden:YES];
    [self.contextMenu.view setHidden:YES];
    
    [self.lblCurrentCategory setText:@"contact"];
    
    [self btnSideMenu_Config:@"BACK"];
    [self.sideMenuViewController closeSideMenu];
    
    [self.scrvwMainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.scrvwMainScroll setScrollEnabled:NO];
}

- (void)disableContactView
{
    isContactOpen = NO;
    
    [self.articleDetailMaster.view setHidden:NO];
    [self.contextMenu.view setHidden:NO];
    
    [self.contactView.view removeFromSuperview];
    self.contactView = nil;
    
    [self.scrvwMainScroll setScrollEnabled:YES];
    
    [self resetCurrentCategoryLabel];
}

- (void)resetCurrentCategoryLabel {
    // get the current selected category name
    if (![[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrName] isEqualToString:@"(null)"]) {
        NSString *strCurrentCategorylabel = [[NSString alloc] initWithFormat:@"%@",[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrName]];
        if (!isSearchOpen) {
            if (![[WebserviceComunication sharedCommManager] isInFocus]) {
                [self.lblCurrentCategory setText:[strCurrentCategorylabel lowercaseString]];
            } else {                
                [self.lblCurrentCategory setText:currentInFocusName];
            }
        }
    } else {
        [self.lblCurrentCategory setText:@"all news"];
    }
}

- (void)hidePages
{
    [self btnSideMenu_Config:@"NORMAL"];
    [self.scrvwMainScroll setContentOffset:CGPointMake(0, self.scrvwMainScroll.frame.size.height) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    int offsetY = (int)self.scrvwMainScroll.contentOffset.y;
    int frameY = (int)self.scrvwMainScroll.frame.size.height;
    
    // Purpose of this is to smoothly animate out a Page before removing it from scrvwMainScroll
    if(offsetY < frameY) {
        [self enableArticleView];
        return;
    }
    
    if(isArticleDetailOpen) {
        [self disableArticleView];
    }
    
    [self disableContributeView];
    
    if(isSettingsOpen) {
        [self disableSettingsView];
    }
    
    if(isContactOpen) {
        [self disableContactView];
    }
}

// ==============================================================================================================================
// REMOTE NOTIFICATIONS
// ==============================================================================================================================
-(void)createNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBreakingNewsFromNotification) name:kNOTIFICATION_BREAKING_NEWS_FROM_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBreakingNewsFromNotification) name:kNOTIFICATION_BREAKING_NEWS_FROM_NOTIFICATION_DISPLAY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeContributeTerms) name:kNOTIFICATION_CLOSE_CONTRIBUTE_TERMS object:nil];
}

-(void)checkForPendingBreakingNews {
    if (breakingNewsNotification != nil) {
        [self handleNotification:breakingNewsNotification];
    }
}

-(void)handleNotification:(NSDictionary *)userInfo {
    NSDictionary *detail = [userInfo objectForKey:@"aps"];
    int numberOfButtons = 1;
        
    if ([detail objectForKey:@"articleId"]) {
        notificationArticleId = [[detail objectForKey:@"articleId"] copy];
        numberOfButtons = 2;
    }
    
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
    [alertView show:YES ShowDetail:YES NumberOfButtons:numberOfButtons];
    alertView.lblHeading.text = @"Breaking News Alert!";
    alertView.lblDetail.text = [detail objectForKey:@"alert"];
    
    if (2 == numberOfButtons) {
        [alertView.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
        [alertView.btn2 setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        // set the tag so we action the ok button
        alertView.view.tag = kALERT_TAG_BREAKING_NEWS_FROM_NOTIFICATION;
    } else {
        // no tag so we just chillax when this dude actions it
        [alertView.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
    }
}

-(void)getBreakingNewsFromNotification {
    // so apply a loader to the face
    [self showBreakingLoadingScreen];
    // do a webservice call
    [[WebserviceComunication sharedCommManager] getContentItem:notificationArticleId];
}

-(void)showBreakingNewsFromNotification {
    [self hideBreakingLoadingScreen];
    [self.articleDetailMaster PrepareDetailViewForContentType:kstrBREAKINGNEWS withCurrentArticle:0];
    [self enableArticleView];
}

-(void)showBreakingLoadingScreen {
    [self showBreakingLoadingScreen:@"Loading breaking news..."];
}

-(void)showBreakingLoadingScreen:(NSString*)message {
    // the actual loading view
    loadingScreen= [[UIView alloc] initWithFrame:self.view.frame];
    [loadingScreen setBackgroundColor:[UIColor clearColor]];
	[loadingScreen setUserInteractionEnabled:TRUE];
    
    // Transparent Background
    UIView *background = [[UIView alloc] initWithFrame:self.view.frame];
    // Make a little bit of the superView show through
    [background setBackgroundColor:[UIColor whiteColor]];
    background.alpha = 0.7;
    [loadingScreen addSubview:background];
    
    // Activity Indicator
    UIActivityIndicatorView *spinnyGuy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    [spinnyGuy setColor:[UIColor grayColor]];
    // Set the resizing mask so it's not stretched
    spinnyGuy.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    // Place it in the middle of the view
    spinnyGuy.center = loadingScreen.center;
    // Add it into the spinnerView
    [loadingScreen addSubview:spinnyGuy];
    // Start it spinning!
    [spinnyGuy startAnimating];
    
    // now the label
    UILabel *loadingMessage = [[UILabel alloc] init];
    [loadingMessage setFont:[UIFont fontWithName:kFontOpenSansBold size:14.0]];
    loadingMessage.textColor = [UIColor darkGrayColor];
    [loadingMessage setText:message];
    [loadingMessage sizeToFit];
    [loadingMessage setBackgroundColor:[UIColor clearColor]];
    loadingMessage.center = CGPointMake((loadingScreen.frame.size.width / 2),spinnyGuy.frame.origin.y + spinnyGuy.frame.size.height + 20);
    [loadingScreen addSubview:loadingMessage];
    
    // Fading Animation
    CATransition *animation = [CATransition animation];
    // Set the type to a nice wee fade
    [animation setType:kCATransitionFade];
    // Add it to the superView
    [[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    
    [self.view addSubview:loadingScreen];
    
//    UITapGestureRecognizer *tmp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBreakingLoadingScreen)];
//    [tmp setNumberOfTouchesRequired:1];
//    [tmp setNumberOfTapsRequired:1];
//    [self.loadingScreen addGestureRecognizer:tmp];
}

-(void)hideBreakingLoadingScreen {
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [self.loadingScreen removeFromSuperview];
}

// ==============================================================================================================================
// LIGHTBOX IMAGE VIEW
// ==============================================================================================================================

-(void)showLightBoxImageView:(NSString *) filePath title:(NSString *) titleString {
    contentDetailLightbox = [[ContentDetailLightbox alloc] initWithFrame:self.view.frame];
    [contentDetailLightbox display:filePath title:titleString];
    // Fading Animation
    CATransition *animation = [CATransition animation];
    // Set the type to a nice wee fade
    [animation setType:kCATransitionFade];
    // Add it to the superView
    [[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [self.view addSubview:contentDetailLightbox];
}

-(void)showMultipleLightBoxImages:(NSArray *) filePaths titles:(NSArray *) titleStrings index:(int) selectedIndex{
    lightBoxScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    for (int x = 0; x < [filePaths count]; x++) {
        float xOffset = self.view.frame.size.width * x;
        CGRect tmpFrame = CGRectMake(xOffset, self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height);
        ContentDetailLightbox *lightbox = [[ContentDetailLightbox alloc] initWithFrame:tmpFrame];
        [lightbox display:[filePaths objectAtIndex:x] title:[titleStrings objectAtIndex:x]];
        [lightBoxScroll addSubview:lightbox];
    }
    [lightBoxScroll setContentSize:CGSizeMake(self.view.frame.size.width * [filePaths count], self.view.frame.size.height)];
    [lightBoxScroll setBounces:NO];
    [lightBoxScroll setPagingEnabled:YES];

    CGRect frame = lightBoxScroll.frame;
    frame.origin.x = frame.size.width * selectedIndex;
    frame.origin.y = 0;
    [lightBoxScroll scrollRectToVisible:frame animated:YES];
    
    // Fading Animation
    CATransition *animation = [CATransition animation];
    // Set the type to a nice wee fade
    [animation setType:kCATransitionFade];
    // Add it to the superView
    [[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [self.view addSubview:lightBoxScroll];
}

// ==============================================================================================================================
// POST COMMENTS MODAL
// ==============================================================================================================================
-(void)postCommentModal:(NSString*) articleId {
    // instantiate
    commentModal = [[CommentModalPostViewController alloc] init];
    commentModal.articleId = articleId;
    [self.view addSubview:commentModal.view];
}

// ==============================================================================================================================
// User ID
// ==============================================================================================================================

// return the user id
-(void) userIdClear {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@"" forKey:@"UserId"];
    [userDefaults synchronize];
}

// save user id
-(void) userIdSave:(NSString *) userId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:userId forKey:@"UserId"];
    [userDefaults synchronize];
    [[WebserviceComunication sharedCommManager] showAlert:@"Sign In" message:@"You have been signed in."];
}

// save user id
-(void) userIdSave:(NSString *) userId showMessage:(BOOL) showM {
    if (showM) {
        [self userIdSave:userId];
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:userId forKey:@"UserId"];
    [userDefaults synchronize];
}

// return user id
-(NSString *) userIdReturn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"UserId"];
    if (userId == nil) {
        userId = @"";
    }
    return userId;
}

// ==============================================================================================================================
// Network
// ==============================================================================================================================

- (Boolean) netWorkAvailable {
    AReachability *networkReachability = [AReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        // alert what happened
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection required" message:@"You need an active internet connection to perform this action."];
        return NO;
    } else {
        return YES;
    }
}

// ==============================================================================================================================
//  PHONE / EMAIL / MESSAGE METHODS
// ==============================================================================================================================

- (void)phoneWithNumber:(NSString *)number {
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:number
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Call", nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]]; // @"telprompt:%@"
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
    } else {
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
    }
}

- (void)openEmailComposer:(NSString *)rec {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:rec]];
        [mailViewController setSubject:@""];
        [mailViewController setMessageBody:@"You message ..." isHTML:NO];
        [self presentModalViewController:mailViewController animated:YES];
    } else {
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)openMessageComposer:(NSString *)rec {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
        messageViewController.messageComposeDelegate = self;
        [messageViewController setRecipients:[NSArray arrayWithObject:rec]];
        [messageViewController setBody:@"Your message ..."];
        [self presentModalViewController:messageViewController animated:YES];
    } else {
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
}

-(ATBannerView *)createAd {
    ATBannerView *bannerView = [[ATBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [bannerView setConfiguration:self.config];
    [bannerView setViewController:self];
    [bannerView setDelegate:self];
    [bannerView load];
    
    return bannerView;
}

// ADTech
-(void)didFetchNextAd:(ATBannerView *)view {
    [view setHidden:NO];
}

@end
