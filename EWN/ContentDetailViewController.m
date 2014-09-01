//
//  ContentDetailViewController.m
//  EWN
//
//  Created by Jainesh Patel on 4/30/13.
//
//

#import "ContentDetailViewController.h"
#import "MainViewController.h"
#import "NSString+HTML.h"
#import "PullableView.h"
#import "WebserviceComunication.h"
#import "AppDelegate.h"
#import "EWNDragHandleView.h"


@interface ContentDetailViewController ()

@end

@implementation ContentDetailViewController
@synthesize dicArticleDetail;
@synthesize objStoryTimelineView;
@synthesize parentContentType;
@synthesize alrtvwReachable;
@synthesize scrvwMainView;
@synthesize scrvwContentDetail;
@synthesize thumbView;
@synthesize showAds;
@synthesize dragHandleView;
@synthesize relatedButton;
@synthesize contentAndRelatedWidth;
@synthesize displayAds;

AppDelegate *appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    showAds = kShowAdsBOOL;
    displayAds = true;
    if (self) {
        // Custom initialization
    }
    return self;
}
/**-----------------------------------------------------------------
 Function Name  : viewDidLoad
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : called when view did loads.
 ------------------------------------------------------------------*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bFlurryReported = FALSE;
    
    scrollOffset_X = scrvwMainView.contentOffset.x;
    scrollOffset_Y = scrvwMainView.contentOffset.y;
    
    closedCenter= CGPointMake(160, 480);
    openedCenter =  CGPointMake(160, 200);
    
    [vwContentDetail setFrame:CGRectMake(0, 0, vwContentDetail.frame.size.width, vwContentDetail.frame.size.height)];
    [self.scrvwMainView addSubview:vwContentDetail];
    
    [self initializeRelatedStoryView];
    
    NSString *strContentType;
    
    if([[WebserviceComunication sharedCommManager]isOnline]) {
        if (![[dicArticleDetail valueForKey:kstrContentType] valueForKey:kstrName]) {
            strContentType = [[NSString alloc] initWithString:kcontentLatest];
        } else {
            strContentType = [[NSString alloc] initWithFormat:@"%@",[[dicArticleDetail valueForKey:kstrContentType] valueForKey:kstrName]];
        }
    } else {
        if (![dicArticleDetail valueForKey:kstrContentType]) {
            strContentType = [[NSString alloc] initWithString:kcontentLatest];
        } else {
            strContentType = [[NSString alloc]initWithFormat:@"%@",[dicArticleDetail valueForKey:kstrContentType]];
        }
    }
    
    [strContentType release];
    strContentType = nil;
    
    [self.scrvwMainView setBounces:FALSE];
    [self.scrvwMainView setPagingEnabled:TRUE];
    
    UISwipeGestureRecognizer *recognizer;
    
    // left and right swipe recognizers for left and right animation
    leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
    [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTopSwipe:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [recognizer setNumberOfTouchesRequired:1];
    [recognizer setCancelsTouchesInView:TRUE];
    [recognizer setDelegate:self];
    [recognizer setEnabled:TRUE];
    [scrvwContentDetail addGestureRecognizer:recognizer];
    
    [recognizer release];
    recognizer = nil;
    
    // Related Button
    [self.relatedButton.titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:11.0]];
    [self.relatedButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.relatedButton addTarget:self action:@selector(showRelatedHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    // Thumbnail Scroller
    self.thumbView = [[RelatedScrollerViewController alloc] init];
    [scrvwContentDetail addSubview:self.thumbView.view];
    
    // Fonts
    [lblTitle setNumberOfLines:0];
    [lblTitle setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:16.0]];
    [lblTitle setTextColor:[UIColor colorWithHexString:@"272727"]];
    
    [lblTime setNumberOfLines:0];
    [lblTime setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [lblTime setTextColor:[UIColor grayColor]];
    
    [lblDescription setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
    
    contentAndRelatedWidth = vwContentDetail.frame.size.width + objStoryTimelineView.view.frame.size.width;
    
    [super viewDidLoad];
}

-(void) handlePan:(UIPanGestureRecognizer *) panny {
    [self showStoryTimelineViewNoAnimation];
}

-(IBAction)showRelatedHandler:(id)sender {
    [self showStoryTimelineView:TRUE];
}

/**-----------------------------------------------------------------
 Function Name  : gestureRecognizer
 Created By     : Jainesh Patel.
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : recognize the touch geture.
 ------------------------------------------------------------------*/

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)initializeRelatedStoryView {
    if (self.objStoryTimelineView) {
        [self.objStoryTimelineView.view removeFromSuperview];
    }
    
    NSString *strXib;
    strXib = kstrStoryTimelineViewController_iPhone5;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.height == 568)
        {
            strXib = kstrStoryTimelineViewController_iPhone5;
        }
        else
        {
            strXib = kstrStoryTimelineViewController;
        }
    }
    
    [[[WebserviceComunication sharedCommManager] arrStoryTimeline] removeAllObjects];
    [[[WebserviceComunication sharedCommManager] arrRelatedStory] removeAllObjects];
    
    self.objStoryTimelineView = [[StoryTimelineViewController alloc] initWithNibName:strXib bundle:nil];
    self.objStoryTimelineView.delegate = self;
    self.objStoryTimelineView.dicArticleId = dicArticleDetail;
    [self.objStoryTimelineView.view setTag:2];
    [self.objStoryTimelineView.view setFrame:CGRectMake(vwContentDetail.frame.size.width, 0, objStoryTimelineView.view.frame.size.width, self.objStoryTimelineView.view.frame.size.height)];
    
    [self.scrvwMainView addSubview:self.objStoryTimelineView.view];
    [strXib release];
    strXib = nil;
}

/**-----------------------------------------------------------------
 Function Name  : handleTopSwipe
 Created By     : Arpit Jain.
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : To do scrolling to top of content view according to content offset.
 ------------------------------------------------------------------*/

-(void)handleTopSwipe:(UISwipeGestureRecognizer *)recognizer {
    if (scrvwContentDetail.contentSize.height > scrvwContentDetail.frame.size.height+50 && ![scrvwContentDetail isScrollEnabled]) {
        [scrvwContentDetail setScrollEnabled:TRUE];
        [scrvwContentDetail setContentOffset:CGPointMake(0, scrvwContentDetail.contentOffset.y - 50) animated:YES];
    } else {
        float diffY;
        diffY = scrvwContentDetail.contentSize.height - scrvwContentDetail.frame.size.height;
        if (diffY > 0 && ![scrvwContentDetail isScrollEnabled]) {
            [scrvwContentDetail setScrollEnabled:TRUE];
            [scrvwContentDetail setContentOffset:CGPointMake(0, scrvwContentDetail.contentOffset.y - diffY) animated:YES];
        }
    }
}
/**-----------------------------------------------------------------
 Function Name  : handleLeftSwipe
 Created By     : Arpit Jain.
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : To do scrolling to previous content view according to content offset.
 ------------------------------------------------------------------*/
-(void)handleLeftSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self.scrvwMainView removeGestureRecognizer:leftRecognizer];
    if(self.scrvwMainView.contentOffset.x == scrvwContentDetail.frame.size.width-20) {
        [self.scrvwMainView setContentOffset:CGPointMake(0,0) animated:TRUE];
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
    if(self.scrvwMainView.contentOffset.x == 0)
    {
        [self.scrvwMainView setContentOffset:CGPointMake(scrvwContentDetail.frame.size.width-20,0) animated:TRUE];
    }
    else
    {
        [self btnNextClick:nil];
        [self displayAllDetails];
        [self.scrvwMainView setFrame:CGRectMake(0, self.scrvwMainView.frame.origin.y, self.scrvwMainView.frame.size.width, self.scrvwMainView.frame.size.height)];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[[WebserviceComunication sharedCommManager] arrStoryTimeline] removeAllObjects];
    [[[WebserviceComunication sharedCommManager] arrRelatedStory] removeAllObjects];
}


- (void)didReceiveMemoryWarning
{
    DLog(@"Something is causing MASSIVE MEMORY ISSUES!!!");
    displayAds = false;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self.dragHandleView release];
    self.dragHandleView = nil;
    [super viewDidUnload];
}

#pragma mark Custom method

/**-----------------------------------------------------------------
 Function Name  : loadAllDataForContentDetail
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Load all data for Content's detail.
 ------------------------------------------------------------------*/

-(void)loadAllDataForContentDetail
{
    self.objStoryTimelineView.dicArticleId = dicArticleDetail;
    
    [[WebserviceComunication sharedCommManager] setNumPageNoForStoryTimeline:0];
    [[WebserviceComunication sharedCommManager] setNumRelatedStory:0];
    
    [self.objStoryTimelineView btnRelatedStoryCllick:self.objStoryTimelineView.btnRelated];
}

/**-----------------------------------------------------------------
 Function Name  : selectedArticleDetail
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : it selects article detail and calls the method display all detail.
 ------------------------------------------------------------------*/

-(void)selectedArticleDetail: (Contents *)dicDetail
{
    dicArticleDetail = dicDetail;
    if([[[WebserviceComunication sharedCommManager] arrStoryTimeline] containsObject:dicArticleDetail])
    {
        self.parentContentType = ParentContentTypeStoryTimeline;
    }
    else
    {
        self.parentContentType = ParentContentTypeRelatedStory;
    }
    
    [UIView beginAnimations:@"SETVIEW" context:nil];
    [UIView setAnimationDuration:0.3];
    [self.scrvwMainView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    [UIView commitAnimations];
    
    [self initializeRelatedStoryView];
    
    [self displayAllDetails];
    
    // Update Comments
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [[objMainView contextMenu] updateComments:dicArticleDetail.articleID];
    
    [scrvwContentDetail setScrollEnabled:TRUE];
}

/**-----------------------------------------------------------------
 Function Name  : callRelatedStoryAPI
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 
 Purpose        : It will call RelatedStoryAPI
 ------------------------------------------------------------------*/

-(void)callRelatedStoryAPI
{
    [[[WebserviceComunication sharedCommManager] arrRelatedStory] removeAllObjects];
    
    if([[WebserviceComunication sharedCommManager]isOnline])
    {
        [[WebserviceComunication sharedCommManager] getRelatedStoryByArticleId:[dicArticleDetail valueForKey:kstrArticleId]];
    }
    else
    {
        if ([dicArticleDetail valueForKey:kstrArticleId])
        {
            [[WebserviceComunication sharedCommManager] setArrRelatedStory:[[CacheDataManager sharedCacheManager] getRelatedStoryWithParentId:[dicArticleDetail valueForKey:kstrArticleId] andArticleType:kstrRelated]];
        }
        else
        {
            [[WebserviceComunication sharedCommManager] setArrRelatedStory:[[CacheDataManager sharedCacheManager] getRelatedStoryWithParentId:[dicArticleDetail valueForKey:kstrArticleID] andArticleType:kstrRelated]];
        }
    }
}


/**-----------------------------------------------------------------
 Function Name  : handleLeftSwipe
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 
 Purpose        : It will call StoryTimelineAPI
 ------------------------------------------------------------------*/

-(void)callStoryTimelineAPI {
    [[[WebserviceComunication sharedCommManager] arrStoryTimeline] removeAllObjects];
    
    if([[WebserviceComunication sharedCommManager]isOnline]) {
        [[WebserviceComunication sharedCommManager] getStorytimelineByArticleId:[dicArticleDetail articleID]];
    } else {
        [[WebserviceComunication sharedCommManager] setArrStoryTimeline:[[CacheDataManager sharedCacheManager] getRelatedStoryWithParentId:[dicArticleDetail articleID] andArticleType:kstrTimeline]];
    }
}
/**-----------------------------------------------------------------
 Function Name  : displayAllDetails
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 
 Purpose        : It will Display all detail of selected article.
 ------------------------------------------------------------------*/
- (void)displayAllDetails {
    // lets add the drag handle here
    if (self.contentTypeString && ([self.contentTypeString isEqualToString:@"articles"] || [[dicArticleDetail contentType] isEqualToString:@"newsarticle"] || [self.contentTypeString isEqualToString:@"BREAKING NEWS"])) {
        if (self.dragHandleView == nil) {
            float imgWidth = 45.0f; // image.size.width * 2;
            float imgHeight = 90.0; //  image.size.height + 10;
            self.dragHandleView = [[EWNDragHandleView alloc] initWithFrame:CGRectMake(vwContentDetail.frame.size.width - imgWidth + 10, 0, imgWidth, imgHeight)];
        }
        if (self.dragHandleView.superview == nil) {
            [self.scrvwMainView addSubview:self.dragHandleView];
            UIPanGestureRecognizer *panny = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            [panny setDelegate:self];
            [panny setEnabled:TRUE];
            [self.dragHandleView addGestureRecognizer:panny];
            [panny release];
            panny = nil;
        }
        [self.scrvwMainView bringSubviewToFront:self.dragHandleView];
        self.relatedButton.hidden = NO;
    } else {
        [self.dragHandleView removeFromSuperview];
        self.dragHandleView = nil;
        self.relatedButton.hidden = YES;
    }

    CGFloat numOrigin_X, numOrigin_Y, numSize_W, numSize_H;
    CGSize restrictTitleSize, targetSize;

    numOrigin_X = 10;
    numOrigin_Y = 10;
    numSize_W = self.scrvwContentDetail.frame.size.width - 20; // 10 padding left/right
    numSize_H = 0;
    
    //clear all UI controls before loadin new article
    lblTitle.text = @"";
    lblTime.text = @"";
    lblDescription.text = @"";
    
    if(bannerView) {
        [bannerView removeFromSuperview];
    }
    
    // TITLE
    lblTitle.text = [dicArticleDetail contentTitle];
    
    restrictTitleSize = CGSizeMake(numSize_W, 50);
    targetSize = [lblTitle.text sizeWithFont:lblTitle.font constrainedToSize:restrictTitleSize];
    
    [lblTitle setFrame:CGRectMake(numOrigin_X, numOrigin_Y, numSize_W, targetSize.height)];
    
    // AUTHOR / TIME
    numOrigin_Y = lblTitle.frame.origin.y + targetSize.height + 5;
    
    NSString *strAuthor = [dicArticleDetail author];
    NSString *strTime = [[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[dicArticleDetail publishDate]];
    
    NSMutableString *strSubtitle = [[[NSMutableString alloc] init] autorelease];
    
    if (strAuthor) {
        [strSubtitle appendFormat:@"%@, ", strAuthor];
    }
    
    if(strTime) {
        [strSubtitle appendString:strTime];
    }
    
    lblTime.text = strSubtitle;
    
    restrictTitleSize = CGSizeMake(numSize_W, 35);
    targetSize = [lblTime.text sizeWithFont:lblTime.font constrainedToSize:restrictTitleSize];
    
    [lblTime setFrame:CGRectMake(numOrigin_X, numOrigin_Y - 4, numSize_W, targetSize.height)];
    
    // IMAGE
    numOrigin_Y = lblTime.frame.origin.y + targetSize.height + 7;
    numSize_H = 162; // 268 x 161 : 0.6
    
    if (imgvwContentImage) {
        [imgvwContentImage removeFromSuperview];
        [imgvwContentImage release];
        imgvwContentImage = nil;
    }
    imgvwContentImage = [[ContentDetailImageview alloc] initWithFrame:CGRectMake(numOrigin_X, numOrigin_Y, numSize_W, numSize_H)];
    imgvwContentImage.userInteractionEnabled = TRUE;
    [scrvwContentDetail addSubview:imgvwContentImage];
    
    if(imgvwContentType) {
        [imgvwContentType removeFromSuperview];
        [imgvwContentType release];
        imgvwContentType = nil;
    }
    
    imgvwContentType = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn-play-video.png"]];
    [scrvwContentDetail addSubview:imgvwContentType];
    
    if([dicArticleDetail thumbnilImageFile] != nil) {
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:[dicArticleDetail thumbnilImageFile]];
        [imgvwContentImage setContentMode:UIViewContentModeScaleAspectFit];
        if ([imageData length] > 0) {
            [imgvwContentImage setImage:[UIImage imageWithData:imageData]];
        } else {
            [imgvwContentImage setImage:[UIImage imageNamed:kImgNameDefault]];
        }
        [imageData release];
        imageData = nil;
    } else {
        // The list view already saves the images!!!
        if([[WebserviceComunication sharedCommManager] isOnline]) {
            NSString *strUrl;
            strUrl = [[NSString alloc]initWithFormat:@"%@",[dicArticleDetail thumbnilImageUrl]];
            dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
            dispatch_async(myQueue, ^{
                [imgvwContentImage setImageAsynchronouslyFromUrl:strUrl animated:YES];
            });
            [strUrl release];
            strUrl = nil;
        } else {
            [imgvwContentImage setImage:[UIImage imageNamed:kImgNameDefault]];
        }
    }
    
    // THUMBNAIL SCROLL
    numOrigin_Y += (numSize_H + 10);
    
    // realted/attached media scroller
    if ([dicArticleDetail attachedMedia] && [[dicArticleDetail attachedMedia] isEqualToString:@"yes"]) {
        [self.thumbView.view setFrame:CGRectMake(0, numOrigin_Y, self.scrvwContentDetail.frame.size.width, 50)];
        [self.thumbView update:[dicArticleDetail articleID]];
        [self.thumbView.view setHidden:NO];
    } else {
        [self.thumbView.view setFrame:CGRectMake(0, numOrigin_Y, self.scrvwContentDetail.frame.size.width, 0)];
        [self.thumbView.view setHidden:YES];
    }
    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
    
    NSString *strDescription;
    NSString *strContentType;
    
    if (![dicArticleDetail contentType]) {
        strContentType = [[NSString alloc] initWithString:kcontentLatest];
    } else {
        strContentType = [[NSString alloc]initWithFormat:@"%@",[dicArticleDetail contentType]];
    }
    
    if ([strContentType isEqualToString:kcontentLatest]) {
        [self.objStoryTimelineView.view setHidden:FALSE];
    } else {
        [self.objStoryTimelineView.view setHidden:TRUE];
        [scrvwContentDetail setScrollEnabled:FALSE];
        [self.scrvwMainView setContentSize:CGSizeMake(vwContentDetail.frame.size.width, self.scrvwMainView.frame.size.height)];
    }
    
    if ([strContentType isEqualToString:kstrAudio]) {
        imgvwContentType.hidden = FALSE;
        imgvwContentType.image = [UIImage imageNamed:@"btn-play-audio.png"];
        [imgvwContentType setCenter:[imgvwContentImage center]];
        strDescription = [[dicArticleDetail valueForKey:kstrCaption] mutableCopy];
    } else if([strContentType isEqualToString:kstrVideo]) {
        imgvwContentType.hidden = FALSE;
        imgvwContentType.image = [UIImage imageNamed:@"btn-play-video.png"];
        [imgvwContentType setCenter:[imgvwContentImage center]];
        strDescription = [[dicArticleDetail valueForKey:kstrCaption] mutableCopy];
    } else if([strContentType isEqualToString:kContentImages]) {
        imgvwContentType.hidden = TRUE;
        strDescription = [[dicArticleDetail valueForKey:kstrCaption] mutableCopy];
    } else {
        imgvwContentType.hidden = TRUE;
        strDescription = [[dicArticleDetail valueForKey:kstrBodyText] mutableCopy];
        
        if(strDescription == nil) {
            strDescription = [[dicArticleDetail valueForKey:kstrIntroParagraph] mutableCopy];
        }
    }
    
    [imgvwContentImage addGestureRecognizer:tapRecognizer];
    
    [tapRecognizer release];
    tapRecognizer = nil;
    
    // BODY - DESCRIPTION
    // Config frame for description label
    numOrigin_Y += (thumbView.view.frame.size.height + 10);
    
    CGSize lblSize =  [strDescription sizeWithFont:lblDescription.font constrainedToSize:CGSizeMake(numSize_W, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    [lblDescription setTextColor:kUICOLOR_SIDEMNU_BACK];
    [lblDescription setFrame:CGRectMake(numOrigin_X, numOrigin_Y, numSize_W, lblSize.height)];
    [lblDescription setText:strDescription];
    [lblDescription sizeToFit];
    
    // RELATED ARTICLES BUTTON
    numOrigin_Y += lblDescription.frame.size.height + 17;
    [self.relatedButton setFrame:CGRectMake((numSize_W - self.relatedButton.frame.size.width) + 10, numOrigin_Y, self.relatedButton.frame.size.width, self.relatedButton.frame.size.height)];
    
    // ADTech
    if (showAds && displayAds) {
        numOrigin_Y += self.relatedButton.frame.size.height + 10;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        
        bannerView = [objMainView createAd];
        
        // Transform because setFrame does not work on banners
        float ratio = 50.0f / 320.0f;
        float tWidth = self.scrvwContentDetail.frame.size.width / 320.0f;
        float tHeight = (self.scrvwContentDetail.frame.size.width * ratio) / 50.0f;
        bannerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, tWidth, tHeight);
        bannerView.frame = CGRectMake(0, numOrigin_Y, bannerView.frame.size.width, bannerView.frame.size.height);
        [self.scrvwContentDetail addSubview:bannerView];
    }
    
    // UPDATE CONTENT SIZE
    int contentHeight = lblDescription.frame.origin.y + lblDescription.frame.size.height;
    contentHeight += bannerView.frame.size.height;
    contentHeight += 125; // 150 for Offset so article can hover over bar and not touch the bottom of the white bg
    
    [scrvwContentDetail setContentSize:CGSizeMake(scrvwContentDetail.frame.size.width, contentHeight)];
    [scrvwContentDetail setContentOffset:CGPointMake(0, 0)];
    
    [self showStoryTimelineView:FALSE]; // This kinda overwrites what's written above, resizing the width ...
    
    bFlurryReported = FALSE;    
}

/**-----------------------------------------------------------------
 Function Name  : getcapturedImageByContentType
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 
 Purpose        : It will Display all detail of selected article.
 ------------------------------------------------------------------*/

- (UIImage *)getcapturedImageByContentType
{
    UIImage *imgTemp;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    if(objMainView.newsListViewController.dragDownContentType == DragDownViewContentTypeLatest)
    {
        imgTemp = [objMainView.newsListViewController.latestContentsView captureScreen];
    }
    else if(objMainView.newsListViewController.dragDownContentType == DragDownViewContentTypeVideo)
    {
        imgTemp = [objMainView.newsListViewController.videoContentsView captureScreen];
    }
    else if(objMainView.newsListViewController.dragDownContentType == DragDownViewContentTypeImages)
    {
        imgTemp = [objMainView.newsListViewController.imagesContentsView captureScreen];
    }
    else
    {
        imgTemp = [objMainView.newsListViewController.audioContentsView captureScreen];
    }
    
    return imgTemp;
}
/**-----------------------------------------------------------------
 Function Name  : getDataByContentType
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 
 Purpose        : It will get all data by content type.
 ------------------------------------------------------------------*/
- (NSMutableArray *)getDataByContentType
{
    NSMutableArray *arrTemp;
    
    if (self.parentContentType == ParentContentTypeAudio)
    {
        arrTemp = [[[WebserviceComunication sharedCommManager] arrAudio] mutableCopy];
    }
    else if(self.parentContentType == ParentContentTypeVideo)
    {
        arrTemp = [[[WebserviceComunication sharedCommManager] arrVideo] mutableCopy];
    }
    else if(self.parentContentType == ParentContentTypeImages)
    {
        arrTemp = [[[WebserviceComunication sharedCommManager] arrImages] mutableCopy];
    }
    else if(self.parentContentType == ParentContentTypeLatestNews || self.parentContentType == ParentContentTypeLeadingNews)
    {
        arrTemp = [[[WebserviceComunication sharedCommManager] arrLatestNews] mutableCopy];
    }
    else if(self.parentContentType == ParentContentTypeSearchedNews)
    {
        arrTemp = [[[WebserviceComunication sharedCommManager] arrSearchNews] mutableCopy];
    }
    else if(self.parentContentType == ParentContentTypeStoryTimeline)
    {
        arrTemp = [[[WebserviceComunication sharedCommManager] arrLastStoryTimeline] mutableCopy];
    }
    else if(self.parentContentType == ParentContentTypeRelatedStory)
    {
        arrTemp = [[[WebserviceComunication sharedCommManager] arrLastRelatedStory] mutableCopy];
    } else {
        // default is latest news
        arrTemp = [[[WebserviceComunication sharedCommManager] arrLatestNews] mutableCopy];
    }
    
    return arrTemp;
}
/**-----------------------------------------------------------------
 Function Name  : getImageFromDocumentDirectory
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 
 Purpose        : It will get image from document directory.
 ------------------------------------------------------------------*/
- (UIImage *)getImageFromDocumentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"NewsList_ScreenShot.png"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *dataImage =  [[NSFileManager defaultManager] contentsAtPath:path];
        return [UIImage imageWithData:dataImage];
    }
    
    return nil;
}

//jainesh
#pragma mark - Action Methods

/**-----------------------------------------------------------------
 Function Name  : btnPreviousClick
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 Purpose        : called when button previous tapped.
 ------------------------------------------------------------------*/
- (IBAction)btnPreviousClick:(id)sender
{
    NSMutableArray *arrTemp = [self getDataByContentType];
    
    if(self.parentContentType == ParentContentTypeLeadingNews)
    {
        if([[dicArticleDetail valueForKey:kstrArticleId] isEqualToString:[[[WebserviceComunication sharedCommManager] dictLeadingNews] valueForKey:kstrArticleId]])
        {
            if([arrTemp count]>0)
            {
                dicArticleDetail =  [[arrTemp objectAtIndex:([arrTemp count] - 1)] mutableCopy];
                self.parentContentType = ParentContentTypeLatestNews;
            }
        }
    }
    else
    {
        if([arrTemp count]>0)
        {
            int index = [arrTemp indexOfObject:dicArticleDetail];
            
            if(index == 0)
            {
                if(self.parentContentType == ParentContentTypeLatestNews)
                {
                    if ([[[WebserviceComunication sharedCommManager] dictLeadingNews] count] > 0)
                    {
                        dicArticleDetail =  [[[WebserviceComunication sharedCommManager] dictLeadingNews] mutableCopy];
                        self.parentContentType = ParentContentTypeLeadingNews;
                    }
                    else
                    {
                        dicArticleDetail =  [[arrTemp objectAtIndex:([arrTemp count] - 1)] mutableCopy];
                    }
                }
                else
                {
                    dicArticleDetail =  [[arrTemp objectAtIndex:([arrTemp count] - 1)] mutableCopy];
                }
            }
            else
            {
                dicArticleDetail =  [[arrTemp objectAtIndex:(index - 1)] mutableCopy];
            }
        }
    }
    [self loadAllDataForContentDetail];
}
/**-----------------------------------------------------------------
 Function Name  : btnNextClick
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 Purpose        : called when button Next tapped.
 ------------------------------------------------------------------*/

- (IBAction)btnNextClick:(id)sender
{
    // get array by checking contenttype
    NSMutableArray *arrTemp = [self getDataByContentType];
    
    /// check if current article is leading news
    
    if(self.parentContentType == ParentContentTypeLeadingNews)
    {
        if([[dicArticleDetail valueForKey:kstrArticleId] isEqualToString:[[[WebserviceComunication sharedCommManager] dictLeadingNews] valueForKey:kstrArticleId]])
        {
            if([arrTemp count]>0)
            {
                dicArticleDetail =  [[arrTemp objectAtIndex:0] mutableCopy];
                self.parentContentType = ParentContentTypeLatestNews;
            }
        }
    }
    else
    {
        if([arrTemp count]>0)
        {
            int index = [arrTemp indexOfObject:dicArticleDetail];
            
            if(index == ([arrTemp count]-1))
            {
                if(self.parentContentType == ParentContentTypeLatestNews)
                {
                    if ([[[WebserviceComunication sharedCommManager] dictLeadingNews] count] > 0)
                    {
                        dicArticleDetail =  [[[WebserviceComunication sharedCommManager] dictLeadingNews] mutableCopy];
                        self.parentContentType = ParentContentTypeLeadingNews;
                    }
                    else
                    {
                        dicArticleDetail =  [[arrTemp objectAtIndex:0] mutableCopy];
                    }
                }
                else
                {
                    dicArticleDetail =  [[arrTemp objectAtIndex:0] mutableCopy];
                }
            }
            else
            {
                dicArticleDetail =  [[arrTemp objectAtIndex:index] mutableCopy];
                
            }
        }
    }
    
    [self loadAllDataForContentDetail];
}

- (void)swipeOnScreenShot : (id)sender
{
}

/**-----------------------------------------------------------------
 Function Name  : handleTapOnContent
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 Purpose        : 
 ------------------------------------------------------------------*/
-(void)handleTouchDown:(TouchDownGestureRecognizer *)touchDown{
    // what a nice function...
}
/**-----------------------------------------------------------------
 Function Name  : handleTapOnContent
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 Purpose        : it prepare the file fopr the url and send the webservice request.
 ------------------------------------------------------------------*/
- (void)handleTapOnContent:(id)sender {
    if ([[dicArticleDetail contentType] isEqualToString:@"image"] || [[dicArticleDetail contentType] isEqualToString:@"newsarticle"] || [dicArticleDetail contentType] == nil) {
        // check if we have a file path
        if ([dicArticleDetail featuredImageFile] == nil) {
            // show a loader
            [self showLoader:@"Loading image"];
            // download the file
            [self downloadFeaturedImage];
            return;
        }
        [self showLightBoxImage];
        return;
    }
    
    // StoryTimeline - If touching Story/Timeline, display ...    
    if ([[WebserviceComunication sharedCommManager] isOnline]) {
        objWebAPIRequest = [[WebAPIRequest alloc] initWithDelegate:self];
        urlFile = [[WebserviceComunication sharedCommManager] prepareURLForFile:[dicArticleDetail filename] withContentType:[dicArticleDetail contentType]];
        DLog(@"url file here we go : %@",urlFile);
        [objWebAPIRequest webRequestWithUrl:urlFile];
    } else {
        alrtvwReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwReachable show:YES ShowDetail:YES NumberOfButtons:1];
        alrtvwReachable.lblHeading.text=[NSString stringWithFormat:@"No Internet Connection"];
        alrtvwReachable.lblDetail.text=[NSString stringWithFormat:@"Unable to download selected content. Please check your internet connection and try again later."];
        [alrtvwReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
    }
}

- (void)showLightBoxImage {
    [self hideLoader];
    NSString *filePath = [dicArticleDetail featuredImageFile];
    NSString *contentTitle = [dicArticleDetail contentTitle];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView showLightBoxImageView:filePath title:contentTitle];
}

- (void)downloadFeaturedImage {
    NSString *imageUrl = [dicArticleDetail featuredImageUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [request setTimeOutSeconds:5];
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        UIImage *image = [[UIImage alloc] initWithData:data];
        if (image == nil) {
            [self hideLoader];
            [[WebserviceComunication sharedCommManager] showAlert:@"Image Error" message:@"The image could not be downloaded at this time. Please try again later."];
            return;
        }
        [dicArticleDetail setFeaturedImageUrlData:UIImagePNGRepresentation(image)];
        [[CacheDataManager sharedCacheManager] UpdatefeaturedImage:dicArticleDetail];
        [self showLightBoxImage];
    }];
    [request setFailedBlock:^{
        [self hideLoader];
        [[WebserviceComunication sharedCommManager] showAlert:@"Image Error" message:@"The image could not be downloaded at this time. Please try again later."];
        
    }];
    [request startAsynchronous];
}

/**-----------------------------------------------------------------
 Function Name  : playFile
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 Purpose        : Play the file.
 ------------------------------------------------------------------*/

-(void)playFile
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade]; // UIStatusBarAnimationFade
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    prvContOff = ((MainViewController *)appDelegate.window.rootViewController).newsListViewController.scrlvwNewsContent.contentOffset;
    
    theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:urlFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackComplete:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController presentMoviePlayerViewControllerAnimated:theMovie];
    
    theMovie.moviePlayer.shouldAutoplay = TRUE;
    [theMovie.moviePlayer play];
}
/**-----------------------------------------------------------------
 Function Name  : moviePlaybackComplete
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 Purpose        : called when movie is completed.
 ------------------------------------------------------------------*/
- (void)moviePlaybackComplete:(NSNotification *)obj
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; // UIStatusBarAnimationFade
    
    // For iOS 7 - This has to be performed after a delay, otherwise it doesn't work on iOS 7 ...
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self performSelector:@selector(testMethod) withObject:nil afterDelay:0.2];
    
    [theMovie.moviePlayer setCurrentPlaybackTime:theMovie.moviePlayer.duration];
    [theMovie.moviePlayer stop];
    [theMovie.moviePlayer setContentURL:nil];
    [appDelegate.window.rootViewController dismissMoviePlayerViewControllerAnimated];
}

-(void)testMethod
{
    [((MainViewController *)appDelegate.window.rootViewController).newsListViewController.scrlvwNewsContent setContentOffset:prvContOff];
}

-(void)setItems:(NSObject *)items errorMessage:(NSString *)message error:(NSError *)error withTag:(int)tag
{
}
/**-----------------------------------------------------------------
 Function Name  : gotURLCheckingResponse
 Created By     : Jainesh Patel
 Created Date   : 3-may-2013
 Purpose        : This method gets the response of URL checking.
 ------------------------------------------------------------------*/

-(void)gotURLCheckingResponse: (ASIHTTPRequest *)response
{
    [objWebAPIRequest hideIndicator];
    objWebAPIRequest.delegate = nil;
    objWebAPIRequest = nil;
    
    if(response.responseStatusCode == 404)
    {
        alrtvwReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwReachable show:YES ShowDetail:YES NumberOfButtons:1];
        alrtvwReachable.lblHeading.text=[NSString stringWithFormat:kstrError];
        alrtvwReachable.lblDetail.text=[NSString stringWithFormat:kstrFileIsNotFound];
        [alrtvwReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
    }
    
    else if(response.responseStatusCode == 200)
    {
        [self playFile];
    }
    else if(response.responseStatusCode == 302)
    {
        [self playFile];
    }
    else
    {
        alrtvwReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwReachable show:YES ShowDetail:YES NumberOfButtons:1];
        alrtvwReachable.lblHeading.text=[NSString stringWithFormat:kstrUnknownError];
        alrtvwReachable.lblDetail.text=[NSString stringWithFormat:kstrErrorPlaying];
        [alrtvwReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
    }
    [response cancel];
}
/**-----------------------------------------------------------------
 Function Name  : scrollViewDidScroll
 Created By     : Arpit Jain.
 Created Date   : 3-June-2013
 Purpose        : This method sets the scroll view offset.
 ------------------------------------------------------------------*/

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int scrollViewHeight = (int)scrollView.frame.size.height;
    int scrollContentSizeHeight = (int)scrollView.contentSize.height;
    int scrollOffsetY = (int)scrollView.contentOffset.y;
    
    if (scrvwContentDetail == scrollView && !bFlurryReported)
    {
        [Flurry logEvent:KFlurryEventArticleViewed withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[dicArticleDetail contentTitle],kstrTitle,[dicArticleDetail articleID],kstrArticleId, nil]];
        bFlurryReported = TRUE;
    }
    else if (scrollOffsetY + scrollViewHeight >= scrollContentSizeHeight)
    {
        // then we are at the end
        [scrvwContentDetail setScrollEnabled:FALSE];
    }
}
/**-----------------------------------------------------------------
 Function Name  : scrollViewDidEndDecelerating
 Created By     : Arpit Jain.
 Created Date   : 3-June-2013
 Purpose        : This method sets the scroll view offset.
 ------------------------------------------------------------------*/
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == scrvwMainView)
    {
        if(scrollView.contentOffset.x >= (vwContentDetail.frame.size.width - 30) && ![objStoryTimelineView isOpen]) // Where is this 30 coming from?
        {
            [self loadAllDataForContentDetail];
            [self.objStoryTimelineView setBIsFirstSwipe:FALSE];
            scrollOffset_X = scrvwMainView.contentOffset.x+1;
            [objStoryTimelineView setIsOpen:TRUE];
        }
        else if(scrollView.contentOffset.x == 0)
        {
            [self showStoryTimelineView:FALSE];
            [objStoryTimelineView setIsOpen:FALSE];
            
            float bottomEdge = scrvwContentDetail.contentOffset.y + scrvwContentDetail.frame.size.height;
            if (bottomEdge >= scrvwContentDetail.contentSize.height) {
                // we are at the end
                [scrvwContentDetail setScrollEnabled:FALSE];
            } else {
                [scrvwContentDetail setScrollEnabled:TRUE];
            }
        }
    }
}

// Use this to track setContentOffset's completion
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDecelerating:scrollView];
}

/**-----------------------------------------------------------------
 Function Name  : scrollViewWillBeginDragging
 Created By     : Arpit Jain.
 Created Date   : 3-June-2013
 Purpose        : This method sets the scroll view offset.
 ------------------------------------------------------------------*/
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tapPoint = [scrollView.panGestureRecognizer locationInView:self.scrvwMainView];
    
    if(scrollView == scrvwMainView)
    {
        scrollOffset_X = scrvwMainView.contentOffset.x;
        scrollOffset_Y = scrvwMainView.contentOffset.y;
    }
}

-(void)showStoryTimelineView:(BOOL)isVisible
{
    if(isVisible)
    {
        int contentWidth = (vwContentDetail.frame.size.width + objStoryTimelineView.view.frame.size.width);
        int offsetX = (contentWidth - vwContentDetail.frame.size.width - 10); // Check out this 10, I think it's just the padding ... But review the Xib
        
        [self.scrvwMainView setContentSize:CGSizeMake(contentWidth, self.scrvwMainView.frame.size.height)];
        [self.scrvwMainView setContentOffset:CGPointMake(offsetX, 0) animated:TRUE];
    }
    else
    {
        [self.scrvwMainView setContentSize:CGSizeMake(vwContentDetail.frame.size.width, self.scrvwMainView.frame.size.height)];
        [self.scrvwMainView setContentOffset:CGPointMake(0, 0) animated:TRUE];
    }
}

-(void)showStoryTimelineViewNoAnimation
{
    [self.scrvwMainView setContentSize:CGSizeMake(contentAndRelatedWidth, self.scrvwMainView.frame.size.height)];
}

- (void)showLoader:(NSString *)message {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView showBreakingLoadingScreen:message];
}

- (void)hideLoader {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView hideBreakingLoadingScreen];
}

- (void) dealloc {
    [imgvwContentType release];
    [super dealloc];
}

@end
