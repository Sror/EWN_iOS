//
//  NewsListViewController.m
//  EWN
//
//  Created by Sumit Kumar on 4/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NewsListViewController.h"
#import "CommanConstants.h"
#import "CustomAlertView.h"
#import "WebserviceComunication.h"
#import "MainViewController.h"

@implementation NewsListViewController

@synthesize tlbListTop;
@synthesize scrlvwNewsContent;
@synthesize latestContentsView;
@synthesize videoContentsView;
@synthesize imagesContentsView;
@synthesize audioContentsView;
@synthesize twitterContentsView;
@synthesize dragDownContentType;
@synthesize searchView;
@synthesize topBackground;
@synthesize pages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    [self.tlbListTop release];
    [self.scrlvwNewsContent release];
    [self.videoContentsView release];
    [self.imagesContentsView release];
    [self.audioContentsView release];
    [self.twitterContentsView release];
    [self.searchView release];
    [self.topBackground release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(Boolean)getIsInFocus {
    return isInFocus;
}

#pragma mark - View lifecycle
/**-----------------------------------------------------------------
 Function Name  : viewDidLoad
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 19-Apr-2013
 Purpose        : In this Function I add the content view of List view in this view.
 ------------------------------------------------------------------*/

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    pages = 4;
    if (version2 && [[WebserviceComunication sharedCommManager] isOnline]) {
        pages = 5;
    }
    
    bIsRunningReload = FALSE;
    isStartupComplete = FALSE;
    
    isCompleteAnimation = TRUE;
        
    [self.scrlvwNewsContent setBackgroundColor:[UIColor clearColor]];
    [self.scrlvwNewsContent setAlwaysBounceHorizontal:TRUE];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.height == 568)
        {
            strXibContentList = kstrContentsListViewController_iPhone5;
            strXibSearchContentList = kstrSearchNewsListViewController_iPhone5;
        }
        else
        {
            strXibContentList = kstrContentsListViewController;
            strXibSearchContentList = kstrSearchNewsListViewController;
        }
    }
    
    self.dragDownContentType = DragDownViewContentTypeLatest;
    
    [Flurry logEvent:KFlurryEventContentTypeViewed withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kcontentLatest,kstrContentType, nil]];
    
    yourPagesArray = [[NSMutableArray alloc] init];
    
    [self initListViews];
    
    if (version2 && [[WebserviceComunication sharedCommManager] isOnline]) {
        self.twitterContentsView = [[ContentsListViewController alloc] initWithNibName:strXibContentList bundle:nil CurrentContentType:@"Twitter" NextContentType:@""];
        [self.twitterContentsView.view setTag:6];
        [self.twitterContentsView.view setFrame:CGRectMake(1280,0,320,self.view.frame.size.height)];
        [self.scrlvwNewsContent addSubview:self.twitterContentsView.view];
        [self.twitterContentsView setupForTwitter];
    }
    
    numLastContentOffset = self.scrlvwNewsContent.frame.origin.x;
    
    self.searchView = [[SearchNewsListViewController alloc] initWithNibName:strXibSearchContentList bundle:nil];
    [self.searchView.view setTag:5];
    [self.searchView.view setFrame:CGRectMake(0,0,320,self.view.frame.size.height)];
    [self.searchView.view setHidden:TRUE];
    [self.scrlvwNewsContent addSubview:self.searchView.view];
    
    // left and right swipe recognizers for left and right animation
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [recognizer setDelegate:self];
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [recognizer setDelegate:self];
    
    [self.scrlvwNewsContent setPagingEnabled:TRUE];
   
    [self.scrlvwNewsContent setContentSize:CGSizeMake(self.scrlvwNewsContent.frame.size.width * pages, self.scrlvwNewsContent.frame.size.height)];
    [self.scrlvwNewsContent setDelegate:self];
    [self.scrlvwNewsContent setShowsHorizontalScrollIndicator:FALSE];
    [self.scrlvwNewsContent setShowsVerticalScrollIndicator:FALSE];
    
    /* Register Notifications for API Responses */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeLatestNews) name:@"LATEST" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeVideo) name:@"VIDEO" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeImages) name:@"IMAGES" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeAudio) name:@"AUDIO" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retryLatestNews) name:@"RETRY" object:nil];
    
    if([[WebserviceComunication sharedCommManager] isOnline])
    {
        [[WebserviceComunication sharedCommManager] getCategory];
        // update progress
        [[WebserviceComunication sharedCommManager] setProgess:0.2f withTag:17];
        [[WebserviceComunication sharedCommManager] getInFocus];
        // update progress
        [[WebserviceComunication sharedCommManager] setProgess:0.2f withTag:17];
        [self performSelector:@selector(ReloadAllData) withObject:nil afterDelay:0.0];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReloadAllData) name:kPushNotificationName object:nil];
    }
    
    topBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320 * pages, 44)];
    [topBackground setImage:[UIImage imageNamed:kstrImgToolbar]];
    [self.scrlvwNewsContent addSubview:topBackground];
    
    //Add Title Labels
    CGFloat x;
    
    x = kTITLE_CURRENT_PAGE_X;
    
    for (int i = 0; i < kTotal_Pages; i++)
    {
        if (i != 0)
        {
            x = (i * 320) - kTITLE_NEXT_PAGE_X;
        }
        
        NSString *strTitle = @"";
        
        switch (i)
        {
            case 0:
                strTitle = kCONTENT_TITLE_LATEST;
                break;
                
            case 1:
                strTitle = kCONTENT_TITLE_VIDEO;
                break;
                
            case 2:
                strTitle = kCONTENT_TITLE_IMAGE;
                break;
                
            case 3:
                strTitle = kCONTENT_TITLE_AUDIO;
                break;
                
            case 4:
                if (version2 && [[WebserviceComunication sharedCommManager] isOnline]) {
                    strTitle = @"twitter";
                }
                break;
            default:
                strTitle = kCONTENT_TITLE_LATEST;
                break;
        }
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, 100, 40)];
        [lblTitle setText:strTitle];
        [lblTitle setTag:kTITLE_LABEL_TAG_OFFSET+(i+1)];
        [lblTitle setFont:[UIFont fontWithName:kFontOpenSansRegular size:22.0]];
        [lblTitle setTextColor:(i == 0) ? [UIColor grayColor] : [UIColor lightGrayColor]];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [self.scrlvwNewsContent addSubview:lblTitle];
    }
    
}

/**-----------------------------------------------------------------
 Function Name  : restoreLastContentTypeData
 Created By     : Jainesh patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : calls the function restoreLastContentTypeData.
 ------------------------------------------------------------------*/

- (void)viewWillAppear:(BOOL)animated
{
    [self restoreLastContentTypeData];
}

/**-----------------------------------------------------------------
 Function Name  : restoreLastContentTypeData
 Created By     : Jainesh patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : restores the last content type data.
 ------------------------------------------------------------------*/

- (void)restoreLastContentTypeData
{
    switch (self.dragDownContentType)
    {
        case DragDownViewContentTypeLatest:
        {
            [self.scrlvwNewsContent setContentOffset:CGPointMake(0,0) animated:NO];
        }
            break;
            
        case DragDownViewContentTypeVideo:
        {
            [self.scrlvwNewsContent setContentOffset:CGPointMake(320,0) animated:NO];
        }
            break;
            
        case DragDownViewContentTypeImages:
        {
            [self.scrlvwNewsContent setContentOffset:CGPointMake(640,0) animated:NO];
        }
            break;
            
        case DragDownViewContentTypeAudio:
        {
            [self.scrlvwNewsContent setContentOffset:CGPointMake(960,0) animated:NO];
        }
            break;
            
        default:
            break;
    }
}

/**-----------------------------------------------------------------
 Function Name  : ReloadAllData
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : Reloads all data and remove views.
 ------------------------------------------------------------------*/

-(void)ReloadAllData {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPushNotificationName object:nil];
    
    isInFocus = NO;    
    
    [self DisabelSearchView];
    
    [self ResetAllData];
    
    [self.latestContentsView addProgressViewWithMessage:@"loading"];
    [self.videoContentsView addProgressViewWithMessage:@"loading"];
    [self.imagesContentsView addProgressViewWithMessage:@"loading"];
    [self.audioContentsView addProgressViewWithMessage:@"loading"];
    
    [self FetchAllData];
    
    // Reset the notifications
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RESET_CONTEXT_OPTIONS" object:nil];
}

-(void)RefreshAllData
{
    DLog(@"FIRST REFRESH");
    
    bIsRunningReload = TRUE;
    
    [self DisabelSearchView];
    
    [self ResetAllData];
    
    [self.latestContentsView addProgressViewWithMessage:@"loading"];
    [self.videoContentsView addProgressViewWithMessage:@"loading"];
    [self.imagesContentsView addProgressViewWithMessage:@"loading"];
    [self.audioContentsView addProgressViewWithMessage:@"loading"];
    
    [[WebserviceComunication sharedCommManager] resetDictRequestDateFor:kcontentLatest];
    [[WebserviceComunication sharedCommManager] resetDictRequestDateFor:kstrVideo];
    [[WebserviceComunication sharedCommManager] resetDictRequestDateFor:kContentImages];
    [[WebserviceComunication sharedCommManager] resetDictRequestDateFor:kstrAudio];
    
    [self FetchAllData];
}

/**-----------------------------------------------------------------
 Function Name  : ReloadAllData
 Created By     : Armpit Jane
 Created Date   : 09-Dec-2013
 Modified By    : Arpit Jain
 Modified Date  : 09-Dec-2013
 Purpose        : Reloads all data and remove views.
 ------------------------------------------------------------------*/

-(void)ReloadInFocus {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPushNotificationName object:nil];
    
    [self ResetAllData];
    [self enableInFocus];
    
    [self.latestContentsView addProgressViewWithMessage:@"loading"];
    
    [[WebserviceComunication sharedCommManager] setIsInFocus:YES];
    [[WebserviceComunication sharedCommManager] getInFocusNewsInit]; 
    
//    if ([[WebserviceComunication sharedCommManager] isOnline]) {
//        [[WebserviceComunication sharedCommManager] getInFocusNewsInit];        
//    } else {
//        NSString *infocusId = [[WebserviceComunication sharedCommManager] strInFocusId];
//        [[WebserviceComunication sharedCommManager] setArrLatestNews:[[CacheDataManager sharedCacheManager] getContentsWithInFocusId:infocusId withLimit:kDefaultBatchCount]];
//        [self performSelectorOnMainThread:@selector(completeLatestNews) withObject:nil waitUntilDone:TRUE];
//    }
    
    // Reset the notifications
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RESET_CONTEXT_OPTIONS" object:nil];
}

/**-----------------------------------------------------------------
 Function Name  : ResetAllData
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : Remove all data and set the variables.
 ------------------------------------------------------------------*/
-(void)ResetAllData
{
    bIsRunningReload = TRUE;
    
    [self.latestContentsView RemoveSubviews];
    [self.videoContentsView RemoveSubviews];
    [self.imagesContentsView RemoveSubviews];
    [self.audioContentsView RemoveSubviews];
        
    [[WebserviceComunication sharedCommManager]setNumPageNoForLatest:0];
    [[WebserviceComunication sharedCommManager]setNumPageNoForVideo:0];
    [[WebserviceComunication sharedCommManager]setNumPageNoForImages:0];
    [[WebserviceComunication sharedCommManager]setNumPageNoForAudio:0];
    
    [[[WebserviceComunication sharedCommManager] arrLatestNews] removeAllObjects];
    [[[WebserviceComunication sharedCommManager] arrVideo] removeAllObjects];
    [[[WebserviceComunication sharedCommManager] arrImages] removeAllObjects];
    [[[WebserviceComunication sharedCommManager] arrAudio] removeAllObjects];
    
    [[WebserviceComunication sharedCommManager] setIsInFocus:NO];
    
    [self updateTitles];
}

- (void)initListViews {
    self.latestContentsView = [[ContentsListViewController alloc] initWithNibName:strXibContentList bundle:nil CurrentContentType:kstrLatest NextContentType:kstrVideo];
    [self.latestContentsView.view setTag:1];
    [self.latestContentsView.view setFrame:CGRectMake(0, 0, 320,self.view.frame.size.height-4)];
    [self.scrlvwNewsContent addSubview:self.latestContentsView.view];
    
    self.videoContentsView = [[ContentsListViewController alloc] initWithNibName:strXibContentList bundle:nil CurrentContentType:kstrVideo NextContentType:kstrImages];
    [self.videoContentsView.view setTag:2];
    [self.videoContentsView.view setFrame:CGRectMake(320,0,320,self.view.frame.size.height)];
    [self.scrlvwNewsContent addSubview:self.videoContentsView.view];
    
    self.imagesContentsView = [[ContentsListViewController alloc] initWithNibName:strXibContentList bundle:nil CurrentContentType:kstrImages NextContentType:kstrAudio];
    [self.imagesContentsView.view setTag:3];
    [self.imagesContentsView.view setFrame:CGRectMake(640,0,320,self.view.frame.size.height)];
    [self.scrlvwNewsContent addSubview:self.imagesContentsView.view];
    
    self.audioContentsView = [[ContentsListViewController alloc] initWithNibName:strXibContentList bundle:nil CurrentContentType:kstrAudio NextContentType:@"Twitter"];
    [self.audioContentsView.view setTag:4];
    [self.audioContentsView.view setFrame:CGRectMake(960,0,320,self.view.frame.size.height)];
    [self.scrlvwNewsContent addSubview:self.audioContentsView.view];
}
/**-----------------------------------------------------------------
 Function Name  : FetchAllData
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : Fetch all data by calling webservice.
 ------------------------------------------------------------------*/

-(void)FetchAllData
{
    if([[WebserviceComunication sharedCommManager] isOnline])
    {
        [[WebserviceComunication sharedCommManager] performSelector:@selector(getLatestNewsInit)];
//        PDBackgroundTaskManager *backgroundTaskManager = [PDBackgroundTaskManager backgroundTaskManager];
//        [backgroundTaskManager executeBackgroundTaskWithExpirationHandler:nil executionHandler:^(PDBackgroundTaskManager *manager, NSString *taskName) {
//            [[WebserviceComunication sharedCommManager] performSelector:@selector(getLatestNewsInit)];
//        }];
    }
    else
    {
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            
            [[WebserviceComunication sharedCommManager] setArrLatestNews:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kcontentLatest andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrId]]];
            [[WebserviceComunication sharedCommManager] setArrVideo:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrVideo andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrId]]];
            [[WebserviceComunication sharedCommManager] setArrImages:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kContentImages andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrId]]];
            [[WebserviceComunication sharedCommManager] setArrAudio:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrAudio andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrId]]];
        
            [self performSelectorOnMainThread:@selector(completeLatestNews) withObject:nil waitUntilDone:TRUE];
            [self performSelectorOnMainThread:@selector(completeVideo) withObject:nil waitUntilDone:TRUE];
            [self performSelectorOnMainThread:@selector(completeImages) withObject:nil waitUntilDone:TRUE];
            [self performSelectorOnMainThread:@selector(completeAudio) withObject:nil waitUntilDone:TRUE];
            [[WebserviceComunication sharedCommManager] setProgess:1.0f withTag:17];
        
        });
    }
}

/**-----------------------------------------------------------------
 Function Name  : scrollViewWillBeginDragging
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : store the lastcontent offset of scroll view to do scrolling according to content offset.
 ------------------------------------------------------------------*/

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    numLastContentOffset = scrollView.contentOffset.x;
}

// For Custom Paging
- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    return;
    
    //This is the index of the "page" that we will be landing at
    NSUInteger nearestIndex = (NSUInteger)(targetContentOffset->x / scrollView.bounds.size.width + 0.5f);
    
    //Just to make sure we don't scroll past your content
    nearestIndex = MAX( MIN( nearestIndex, yourPagesArray.count - 1 ), 0 );
    
    //This is the actual x position in the scroll view
    CGFloat xOffset = nearestIndex * scrollView.bounds.size.width;
    
    //I've found that scroll views will "stick" unless this is done
    xOffset = xOffset==0 ? 1:xOffset;
    
    //Tell the scroll view to land on our page
    *targetContentOffset = CGPointMake(xOffset, targetContentOffset->y);
}

/**-----------------------------------------------------------------
 Function Name  : handleLeftSwipe
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : To do scrolling to previous content view according to content offset.
 ------------------------------------------------------------------*/

-(void)handleLeftSwipe:(UISwipeGestureRecognizer *)recognizer
{
    DLog(@"Swipe left");
    if(self.scrlvwNewsContent.contentOffset.x == 0)
    {
    }
    else  if(self.scrlvwNewsContent.contentOffset.x == 320)
    {
        [self.scrlvwNewsContent setContentOffset:CGPointMake(0,0) animated:YES];
        self.dragDownContentType = DragDownViewContentTypeLatest;
        [Flurry logEvent:KFlurryEventContentTypeViewed withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kcontentLatest,kstrContentType, nil]];
    }
    else if(self.scrlvwNewsContent.contentOffset.x == 640)
    {
        [self.scrlvwNewsContent setContentOffset:CGPointMake(320,0) animated:YES];
        self.dragDownContentType = DragDownViewContentTypeVideo;
        [Flurry logEvent:KFlurryEventContentTypeViewed withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kstrVideo,kstrContentType, nil]];
    }
    else if(self.scrlvwNewsContent.contentOffset.x == 960)
    {
        [self.scrlvwNewsContent setContentOffset:CGPointMake(640,0) animated:YES];
        self.dragDownContentType = DragDownViewContentTypeImages;
        [Flurry logEvent:KFlurryEventContentTypeViewed withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kContentImages,kstrContentType, nil]];
    }
    
    
}
/**-----------------------------------------------------------------
 Function Name  : handleRightSwipe
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : To do scrolling to next content view according to content offset.
 ------------------------------------------------------------------*/

-(void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    DLog(@"Swipe right");
    if(self.scrlvwNewsContent.contentOffset.x == 0)
    {
        [self.scrlvwNewsContent setContentOffset:CGPointMake(320,0) animated:YES];
        self.dragDownContentType = DragDownViewContentTypeVideo;
        [Flurry logEvent:KFlurryEventContentTypeViewed withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kstrVideo,kstrContentType, nil]];
    }
    else  if(self.scrlvwNewsContent.contentOffset.x == 320)
    {
        [self.scrlvwNewsContent setContentOffset:CGPointMake(640,0) animated:YES];
        self.dragDownContentType = DragDownViewContentTypeImages;
        [Flurry logEvent:KFlurryEventContentTypeViewed withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kContentImages,kstrContentType, nil]];
    }
    else if(self.scrlvwNewsContent.contentOffset.x == 640)
    {
        [self.scrlvwNewsContent setContentOffset:CGPointMake(960,0) animated:YES];
        self.dragDownContentType = DragDownViewContentTypeAudio;
        [Flurry logEvent:KFlurryEventContentTypeViewed withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kstrAudio,kstrContentType, nil]];
    }
    else
    {
        float snapBackXcoordinate = self.scrlvwNewsContent.contentOffset.x+50;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        CGPoint newFrame = self.scrlvwNewsContent.contentOffset;
        newFrame.x = snapBackXcoordinate;
        [self.scrlvwNewsContent setContentOffset:newFrame];
        [UIView commitAnimations];
        
        [self performSelector:@selector(animateScrollviewright) withObject:nil afterDelay:0.3];
    }
}
/**-----------------------------------------------------------------
 Function Name  : animateScrollviewleft
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : To do animation of scrolling to left.
 ------------------------------------------------------------------*/

-(void)animateScrollviewleft
{
    float snapBackXcoordinateRev = self.scrlvwNewsContent.contentOffset.x+50;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    
    CGPoint newFrameRev = self.scrlvwNewsContent.contentOffset;
    newFrameRev.x = snapBackXcoordinateRev;
    [self.scrlvwNewsContent setContentOffset:newFrameRev];
    [UIView commitAnimations];
}
/**-----------------------------------------------------------------
 Function Name  : animateScrollviewright
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : To do animation of scrolling to right.
 ------------------------------------------------------------------*/

-(void)animateScrollviewright
{
    float snapBackXcoordinateRev = self.scrlvwNewsContent.contentOffset.x-50;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    
    CGPoint newFrameRev = self.scrlvwNewsContent.contentOffset;
    newFrameRev.x = snapBackXcoordinateRev;
    [self.scrlvwNewsContent setContentOffset:newFrameRev];
    [UIView commitAnimations];
}
/**-----------------------------------------------------------------
 Function Name  : gestureRecognizer
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : recognize the touch gesture
 ------------------------------------------------------------------*/
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(isCompleteAnimation == TRUE)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
/**-----------------------------------------------------------------
 Function Name  : animationDidStart
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : this method indicates that animation is not completed
 ------------------------------------------------------------------*/
-(void)animationDidStart:(CAAnimation *)anim
{
    isCompleteAnimation = FALSE;
}
/**-----------------------------------------------------------------
 Function Name  : animationDidStop
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : this method indicates that animation is completed
 ------------------------------------------------------------------*/
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    isCompleteAnimation = TRUE;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Scroll View Delegate
/**-----------------------------------------------------------------
 Function Name  : scrollViewDidScroll
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : this method sets the offset of scroll view and changes the lable position.
 ------------------------------------------------------------------*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= 20)
    {
        CGFloat offsetDiff;
        
        offsetDiff = lastOffset - scrollView.contentOffset.x;
        
        int currentPage;
        int diff;
        diff = currentX + scrollView.frame.size.width;
        
        currentPage = (currentX / scrollView.frame.size.width) + 2;
        
        for (UILabel *lblTitle in scrollView.subviews)
        {
            if ([lblTitle isKindOfClass:[UILabel class]]) {
                
                if (lblTitle.tag <= currentPage+kTITLE_LABEL_TAG_OFFSET && lblTitle.tag > kTITLE_LABEL_TAG_OFFSET) {
                    [lblTitle setFrame:CGRectMake(lblTitle.frame.origin.x - (offsetDiff*kTITLE_SINGLE_TRANSITION), lblTitle.frame.origin.y, lblTitle.frame.size.width, lblTitle.frame.size.height)];
                }
            }
        }
        
        lastOffset = scrollView.contentOffset.x;
    }
}
/**-----------------------------------------------------------------
 Function Name  : scrollViewDidEndDecelerating
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : this method sets the offset of scroll view and changes the lable position.
 ------------------------------------------------------------------*/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateTitles];
    
    if (scrollView.contentOffset.x >= 20)
    {
        currentX = self.scrlvwNewsContent.contentOffset.x;
        
        int currentPage;
        int diff;
        diff = currentX + scrollView.frame.size.width;
        
        currentPage = (currentX / scrollView.frame.size.width) + 2;
        
        [UIView beginAnimations:@"Slide" context:nil];
        [UIView setAnimationDuration:0.2];
        for (int i = currentPage; i <= kTotal_Pages ; i++)
        {
            UILabel *nextLabel = (UILabel*)[scrollView viewWithTag:i+kTITLE_LABEL_TAG_OFFSET];
            [nextLabel setFrame:CGRectMake(diff-kTITLE_NEXT_PAGE_X, nextLabel.frame.origin.y, nextLabel.frame.size.width, nextLabel.frame.size.height)];
            diff += scrollView.frame.size.width;
        }
        
        [UIView commitAnimations];
    }
}

/**-----------------------------------------------------------------
 Function Name  : EnableSearchView
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : this method enables the search view.
 ------------------------------------------------------------------*/

- (void)EnableSearchView:(NSString*)strKeyword
{
    bIsSearchNewsVisible = YES;
    
    [topBackground setHidden:YES];
    
    // This needs to hide all labels ...
    
    [(UILabel*)[self.scrlvwNewsContent viewWithTag:kTITLE_LABEL_TAG_OFFSET+1] setText:kCONTENT_TITLE_SEARCH];
    //for (int index = 2; index <= kTotal_Pages; index++)
    for (int index = 0; index <= kTotal_Pages; index++)
    {
        [(UILabel*)[self.scrlvwNewsContent viewWithTag:kTITLE_LABEL_TAG_OFFSET+index] setHidden:TRUE];
    }
    
    [self.scrlvwNewsContent setContentSize:CGSizeMake(self.scrlvwNewsContent.frame.size.width, self.scrlvwNewsContent.frame.size.height)];
    
    [self.latestContentsView.view setHidden:TRUE];
    [self.videoContentsView.view setHidden:TRUE];
    [self.imagesContentsView.view setHidden:TRUE];
    [self.audioContentsView.view setHidden:TRUE];
    
    // Back Button & Category Heading
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView enableSearchView];
    
    [self.searchView.view setHidden:FALSE];
    
    self.searchView.searchText = strKeyword;
    [self.searchView loadSearchNews];    
}

/**-----------------------------------------------------------------
 Function Name  : DisabelSearchView
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 22-Apr-2013
 Purpose        : this method disabel the search view.
 ------------------------------------------------------------------*/
- (void)DisabelSearchView
{
    [topBackground setHidden:NO];
    
    [(UILabel*)[self.scrlvwNewsContent viewWithTag:kTITLE_LABEL_TAG_OFFSET+1] setText:kCONTENT_TITLE_LATEST];
    
    [self.searchView.view setHidden:TRUE];
    [self.searchView closePickers];
    
    [self.latestContentsView.view setHidden:FALSE];
    [[self.scrlvwNewsContent viewWithTag:kTITLE_LABEL_TAG_OFFSET+1] setHidden:FALSE];

    [self.videoContentsView.view setHidden:FALSE];
    [[self.scrlvwNewsContent viewWithTag:kTITLE_LABEL_TAG_OFFSET+2] setHidden:FALSE];
    
    [self.imagesContentsView.view setHidden:FALSE];
    [[self.scrlvwNewsContent viewWithTag:kTITLE_LABEL_TAG_OFFSET+3] setHidden:FALSE];
    
    [self.audioContentsView.view setHidden:FALSE];
    [[self.scrlvwNewsContent viewWithTag:kTITLE_LABEL_TAG_OFFSET+4] setHidden:FALSE];
    
    [self.scrlvwNewsContent setContentSize:CGSizeMake(pages * self.scrlvwNewsContent.frame.size.width, self.scrlvwNewsContent.frame.size.height)];
    
    bIsSearchNewsVisible = NO;
}


/**-----------------------------------------------------------------
 Function Name  : EnableSearchView
 Created By     : Armpit Jane
 Created Date   : 09-Dec-2013
 Modified By    : Armpit Jane
 Modified Date  : 09-Dec-2013
 Purpose        : This prepares the News List for the In Focus category i.e. hides all but Articles
 ------------------------------------------------------------------*/

- (void)enableInFocus
{
    if(isInFocus) return;
    isInFocus = YES;
    
    [self.videoContentsView.view setHidden:TRUE];
    [self.imagesContentsView.view setHidden:TRUE];
    [self.audioContentsView.view setHidden:TRUE];
    
    for (int index = 2; index <= kTotal_Pages; index++)
    {
        [(UILabel*)[self.scrlvwNewsContent viewWithTag:kTITLE_LABEL_TAG_OFFSET+index] setHidden:TRUE];
    }
    
    [self.scrlvwNewsContent setContentSize:CGSizeMake(self.scrlvwNewsContent.frame.size.width, self.scrlvwNewsContent.frame.size.height)];
}

- (void)disableInFocus
{
    // This is basically reset when ReloadAllData is called ...
}

- (void)completeLatestNews {
    if(!isStartupComplete) {
        isStartupComplete = TRUE;
        [[WebserviceComunication sharedCommManager] setIsStartupComplete:TRUE];
        // fill up the animation
        [[WebserviceComunication sharedCommManager] setProgess:0.6f withTag:17];
    }
    
    if ([[[WebserviceComunication sharedCommManager] arrLatestNews] count] > 0) {
        [self.latestContentsView allocateAndCreateViews];
        [self.latestContentsView removeProgressView];
        numVisiblePages++;
    } else {
        [self.latestContentsView addNoResults:@"No results for Articles"];
    }
    
    if ([[[WebserviceComunication sharedCommManager] arrLatestNews] count] > 0) {
        // Articles
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        // This initiates the context menu
        [objMainView contextMenuInit];
        // WAIT BEFORE PREPARING THE THIS
        [objMainView.articleDetailMaster PrepareDetailViewForContentType:kCONTENT_TITLE_LATEST withCurrentArticle:0];
    }
    
    // Don't request the other guys when in focus
    if ([[WebserviceComunication sharedCommManager] isInFocus]) {
        bIsRunningReload = TRUE;
    }
    
    if([[WebserviceComunication sharedCommManager] isOnline]) {
        if (bIsRunningReload) {
//            bIsRunningReload = FALSE;
            [[WebserviceComunication sharedCommManager] getVedioInit];
            
    //        [[WebserviceComunication sharedCommManager] getImagesInit];
    //        [[WebserviceComunication sharedCommManager] getAudioInit];
            
            // what we need to do here as well is check if we have a pending breaking news notification
            // TODO THIS HAS TO HAPPEN ONLY ONCE
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            MainViewController *objMainView = (MainViewController *)window.rootViewController;
            [objMainView checkForPendingBreakingNews];
        }
    }
}

- (void)completeVideo {
    if ([[[WebserviceComunication sharedCommManager] arrVideo] count] > 0) {
        [self.videoContentsView allocateAndCreateViews];
        [self.videoContentsView removeProgressView];
        numVisiblePages++;
    } else {
        [self.videoContentsView addNoResults:@"No results for Videos"];
    }
    if([[WebserviceComunication sharedCommManager] isOnline]) {
        if (bIsRunningReload) {
            [[WebserviceComunication sharedCommManager] getImagesInit];
        }
    }
}

- (void)completeImages {
    if ([[[WebserviceComunication sharedCommManager] arrImages] count] > 0) {
        [self.imagesContentsView allocateAndCreateViews];
        [self.imagesContentsView removeProgressView];
        numVisiblePages++;
    } else {
        [self.imagesContentsView addNoResults:@"No results for Images"];
    }
    if([[WebserviceComunication sharedCommManager] isOnline]) {
        if (bIsRunningReload) {
            [[WebserviceComunication sharedCommManager] getAudioInit];
        }
    }
}

- (void)completeAudio
{
    if ([[[WebserviceComunication sharedCommManager] arrAudio] count] > 0)
    {
        [self.audioContentsView allocateAndCreateViews];
        [self.audioContentsView removeProgressView];
        numVisiblePages++;
    } else {
        [self.audioContentsView addNoResults:@"No results for Audio"];
    }
    bIsRunningReload = FALSE;
}

- (void)retryLatestNews {
    [self.latestContentsView RemoveSubviews];
    [[WebserviceComunication sharedCommManager]setNumPageNoForLatest:0];
    [[[WebserviceComunication sharedCommManager] arrLatestNews] removeAllObjects];
    [self.latestContentsView addRetryButton];
}

-(void)updateTitles {
    // Update Title Colours - Select : DarkGray, Remainder : LightGray
    int currentIndex = (self.scrlvwNewsContent.contentOffset.x / self.scrlvwNewsContent.frame.size.width);
    for (int i = currentIndex; i <= kTotal_Pages ; i++)
    {
        UILabel *label = (UILabel*)[self.scrlvwNewsContent viewWithTag:i+kTITLE_LABEL_TAG_OFFSET];
        
//        [label setTextColor:(i == (currentIndex + 1)) ? [UIColor darkGrayColor] : [UIColor lightGrayColor]];
        // If animations are too intense and f@ck with performance, use above instead
        [UIView transitionWithView:label
                          duration:0.1
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent
                        animations:^{
                            [label setTextColor:(i == (currentIndex + 1)) ? [UIColor colorWithHexString:@"272727"] : [UIColor lightGrayColor]];
                        }
                        completion:nil];
    }
}

@end
