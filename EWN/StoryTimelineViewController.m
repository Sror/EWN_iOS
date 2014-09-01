//
//  StoryTimelineViewController.m
//  EWN
//
//  Created by Jainesh Patel on 5/1/13.
//
//

#import "StoryTimelineViewController.h"
#import "StoryTimelineCell.h"
#import "AReachability.h"
#import "MNMBottomPullToRefreshManager.h"


#define kContentHeightOffset            60.0f



@interface StoryTimelineViewController ()

@end

@implementation StoryTimelineViewController
@synthesize relatedBackground;
@synthesize btnRelated,btnTimeline;
@synthesize tblTimeLineLeft,tblTimeLineRight;
@synthesize scrvwTimeLine,scrvwRelatedStory;
@synthesize dicArticleId;
@synthesize strSelfCurrentContentType;
@synthesize delegate;
@synthesize pullToRefreshManagerForTimeline_,pullToRefreshManagerForRelatedStory_;
@synthesize imgvwTimelineBar;
@synthesize arrStoryTimelineDataForLeft;
@synthesize arrStoryTimelineDataForRight;

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
    
    [self.relatedBackground setBackgroundColor:[UIColor colorWithHexString:@"333333"]];
    
    self.arrStoryTimelineDataForLeft = [[NSMutableArray alloc] init];
    self.arrStoryTimelineDataForRight = [[NSMutableArray alloc] init];
    
    float vwWidth, vwHeight;
    vwWidth = self.scrvwTimeLine.frame.size.width;
    vwHeight = self.scrvwTimeLine.frame.size.height;
    
    lblNostoryTimeline = [[UILabel alloc]initWithFrame:CGRectMake(0, (vwHeight/2)-40, vwWidth, 40)];
    [lblNostoryTimeline setTextColor:[UIColor whiteColor]];
    [lblNostoryTimeline setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12]];
    [lblNostoryTimeline setBackgroundColor:[UIColor clearColor]];
    [lblNostoryTimeline setText:kstrNoStoryTimeLinedDataMessage];
    [lblNostoryTimeline setNumberOfLines:2];
    [self.scrvwTimeLine addSubview:lblNostoryTimeline];
    [lblNostoryTimeline setHidden:TRUE];
    
    lblNoRelatedStory = [[UILabel alloc]initWithFrame:CGRectMake(0, (vwHeight/2)-40, vwWidth, 40)];
    [lblNoRelatedStory setTextColor:[UIColor whiteColor]];
    [lblNoRelatedStory setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12]];
    [lblNoRelatedStory setBackgroundColor:[UIColor clearColor]];
    [lblNoRelatedStory setText:kstrNoRelatedDataMessage];
    [lblNoRelatedStory setNumberOfLines:2];
    [self.scrvwRelatedStory addSubview:lblNoRelatedStory];
    [lblNoRelatedStory setHidden:TRUE];
    
    self.strSelfCurrentContentType = kstrTimeline;
    numTagCounter =0;
    numTagForTimeline = 0;
    self.bIsNoRealtedNews = FALSE;
    self.bIsNoStoryNews = FALSE;
    self.bIsFirstSwipe = TRUE;
    
    [btnRelated.titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12.0]];
    [btnTimeline.titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12.0]];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [pullToRefreshManagerForTimeline_ relocatePullToRefreshView];
    [pullToRefreshManagerForRelatedStory_ relocatePullToRefreshView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_INIT_RELATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_RELOAD_RELATED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_INIT_STORYTIME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_RELOAD_STORYTIME object:nil];
    
    if (threadRelated)
    {
        [threadRelated cancel];
    }
    
    if (threadStorytimeline)
    {
        [threadStorytimeline cancel];
    }
    
    [[[WebserviceComunication sharedCommManager] arrStoryTimeline] removeAllObjects];
    [[[WebserviceComunication sharedCommManager] arrRelatedStory] removeAllObjects];
    
    [self arrStoryTimelineDataForLeft];
    [self arrStoryTimelineDataForRight];
}


- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**-----------------------------------------------------------------
 Function Name  : sortAndGroupArrayByDate
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : create and fill the array according to date for storytimeline.
 ------------------------------------------------------------------*/

- (void)sortAndGroupArrayByDate
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_INIT_STORYTIME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_RELOAD_STORYTIME object:nil];
    
    
    [self.arrStoryTimelineDataForLeft removeAllObjects];
    [self.arrStoryTimelineDataForRight removeAllObjects];
    numTagForTimeline = 0;
    
    
    /**-----------------------------------------------------------------
     Updated On : 8-Jun-2013
     Updated By : Sumit Kumar
     Purpose    : Updated logic for grouping of article items
     ------------------------------------------------------------------*/
    NSMutableArray *arrTemp;
    arrTemp = [[[WebserviceComunication sharedCommManager] arrStoryTimeline] mutableCopy];
    
    if ([arrTemp count] == 0)
    {
        [lblNostoryTimeline setHidden:FALSE];
        self.bIsNoStoryNews = TRUE;
        
        [self.imgvwTimelineBar setHidden:TRUE];
    }
    else
    {
        if (![self.scrvwTimeLine isHidden])
        {
            [self.imgvwTimelineBar setHidden:FALSE];
            [lblNostoryTimeline setHidden:TRUE];
            self.bIsNoStoryNews = FALSE;
        }
    }
    
    int i =0;
    for (RelatedStoryAndTimeline *dic in arrTemp)
    {
        //DLog(@"Fetching each item : %@", dic);
        
        NSString *strDate= [[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[dic publishDate]];
        
        NSMutableDictionary *dicToAdd = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSMutableArray arrayWithObjects:dic, nil],strDate, nil];
        
        if(i%2 == 0)
        {
            [self.arrStoryTimelineDataForLeft addObject:dicToAdd];
        }
        else
        {
            [self.arrStoryTimelineDataForRight addObject:dicToAdd];
        }
        i = i+1;
    }
    /*-----------------------------------------------------------------*/
    
    [self configureTableviewScrolling];
    [tblTimeLineLeft reloadData];
    [tblTimeLineRight reloadData];
    
    [[[WebserviceComunication sharedCommManager] dictStoryTimeline] removeAllObjects];
    
    [self RemoveStoryActivityInidicator];
    
    [pullToRefreshManagerForTimeline_ tableViewReloadFinished];
    
    if ([arrTemp count] >= 30) {
        DLog(@"HIDE THIS GUY ALREADY");
        [pullToRefreshManagerForTimeline_ setPullToRefreshViewVisible:NO];
    }
}
/**-----------------------------------------------------------------
 Function Name  : HideRelatedStoryBtn
 Created By     : Arpit Jain.
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Hide related story button.
 ------------------------------------------------------------------*/

-(void)HideRelatedStoryBtn
{
    self.btnRelated.selected = FALSE;
    self.btnRelated.hidden = TRUE;
    self.scrvwRelatedStory.hidden = TRUE;
    self.btnTimeline.hidden = FALSE;
    self.btnTimeline.selected = TRUE;
}
/**-----------------------------------------------------------------
 Function Name  : HideStoryTimeLineBtn
 Created By     : Arpit Jain.
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Hide story timeline button.
 ------------------------------------------------------------------*/
-(void)HideStoryTimeLineBtn
{
    self.scrvwTimeLine.hidden = TRUE;
    self.btnTimeline.selected = FALSE;
    self.btnRelated.selected = TRUE;
    self.btnRelated.hidden = FALSE;
    self.scrvwRelatedStory.hidden = FALSE;
    self.btnTimeline.hidden = TRUE;
}
/**-----------------------------------------------------------------
 Function Name  : configureTableviewScrolling
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : configure the Table view Scrolling
 ------------------------------------------------------------------*/

- (void)configureTableviewScrolling
{
    //calculate left table height
    int noOfSectionInLeftTable = [self.arrStoryTimelineDataForLeft count];
    int noOfRowsInLeftTable = 0;
    
    for(int l=0;l<[self.arrStoryTimelineDataForLeft count];l++)
    {
        noOfRowsInLeftTable = noOfRowsInLeftTable + [[[self.arrStoryTimelineDataForLeft objectAtIndex:l] valueForKey:[[[self.arrStoryTimelineDataForLeft objectAtIndex:l] allKeys] objectAtIndex:0]] count];
    }
    
    int leftTableHeght = ( noOfSectionInLeftTable * 35 ) + (noOfRowsInLeftTable * 120);
    
    //calculate right table height
    int noOfSectionInRightTable = [self.arrStoryTimelineDataForRight count];
    int noOfRowsInRightTable = 0;
    
    for(int l=0;l<[self.arrStoryTimelineDataForRight count];l++)
    {
        noOfRowsInRightTable = noOfRowsInRightTable + [[[self.arrStoryTimelineDataForRight objectAtIndex:l] valueForKey:[[[self.arrStoryTimelineDataForRight objectAtIndex:l] allKeys] objectAtIndex:0]] count];
    }
    
    int rightTableHeght = ( noOfSectionInRightTable * 35 ) + (noOfRowsInRightTable * 120) + 63;
    
    // pretty sure this is where we are jazzing the timeline
    [scrvwTimeLine setContentSize:CGSizeMake(scrvwTimeLine.frame.size.width,MAX(leftTableHeght, rightTableHeght)+10+60)];
    [scrvwTimeLine setBackgroundColor:[UIColor clearColor]]; // For iOS7
    
    tblTimeLineLeft.frame = CGRectMake(0, tblTimeLineLeft.frame.origin.y, tblTimeLineLeft.frame.size.width, MAX(leftTableHeght, rightTableHeght));
    tblTimeLineRight.frame = CGRectMake(tblTimeLineRight.frame.origin.x, tblTimeLineRight.frame.origin.y, tblTimeLineRight.frame.size.width, MAX(leftTableHeght, rightTableHeght));
    
    [self performSelector:@selector(addPullToRefresh) withObject:nil afterDelay:0.2];
}

/**-----------------------------------------------------------------
 Function Name  : addPullToRefresh
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Add pull to refresh view
 ------------------------------------------------------------------*/

- (void)addPullToRefresh
{
    pullToRefreshManagerForTimeline_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 ScrollView:scrvwTimeLine withClient:self];
    [pullToRefreshManagerForTimeline_ relocatePullToRefreshView];
}
/**-----------------------------------------------------------------
 Function Name  : showTimelineView
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : It shows Timeline View
 ------------------------------------------------------------------*/

- (void)showTimelineView
{
    UIView *footerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblTimeLineLeft.frame.size.width, 60.0f)];
    footerView1.backgroundColor = [UIColor clearColor];
    self.tblTimeLineLeft.tableFooterView = footerView1;
    
    UIView *footerView2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblTimeLineRight.frame.size.width, 60.0f)];
    footerView2.backgroundColor = [UIColor clearColor];
    self.tblTimeLineRight.tableFooterView = footerView2;
    
    
    scrvwTimeLine.hidden = FALSE;
    scrvwRelatedStory.hidden = TRUE;
    imgvwTimelineBar.hidden = FALSE;
    [lblNostoryTimeline setHidden:TRUE];
    [lblNoRelatedStory setHidden:TRUE];
    
    [self.btnTimeline setBackgroundColor:[UIColor blackColor]];
    [self.btnTimeline setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.btnTimeline setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [self.btnRelated setBackgroundColor:kUICOLOR_RELATED_BACK];
    
    if(!self.bIsNoStoryNews)
    {
        [lblNostoryTimeline setHidden:TRUE];
        [lblNoRelatedStory setHidden:TRUE];
        [self.imgvwTimelineBar setHidden:FALSE];
    }
    else
    {
        [self.imgvwTimelineBar setHidden:TRUE];
        [lblNostoryTimeline setHidden:FALSE];
        [lblNoRelatedStory setHidden:TRUE];
    }
    btnTimeline.selected = YES;
    
    btnRelated.selected = NO;
}
/**-----------------------------------------------------------------
 Function Name  : showRelatedStoryView
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : It shows Related story View
 ------------------------------------------------------------------*/

- (void)showRelatedStoryView
{
    UIView *footerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblTimeLineLeft.frame.size.width, 60.0f)];
    footerView1.backgroundColor = [UIColor clearColor];
    self.tblTimeLineLeft.tableFooterView = footerView1;
    
    UIView *footerView2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblTimeLineRight.frame.size.width, 60.0f)];
    footerView2.backgroundColor = [UIColor clearColor];
    self.tblTimeLineRight.tableFooterView = footerView2;
    
    
    scrvwTimeLine.hidden = TRUE;
    scrvwRelatedStory.hidden = FALSE;
    imgvwTimelineBar.hidden = TRUE;
    [lblNostoryTimeline setHidden:TRUE];
    [lblNoRelatedStory setHidden:TRUE];
    
    [self.btnTimeline setBackgroundColor:kUICOLOR_RELATED_BACK];
    [self.btnRelated setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.btnRelated setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.btnRelated setBackgroundColor:[UIColor blackColor]];
    
    self.strSelfCurrentContentType = kstrRelated;
    
    if(!self.bIsNoRealtedNews)
    {
        [lblNostoryTimeline setHidden:TRUE];
        [lblNoRelatedStory setHidden:TRUE];
    }
    else
    {
        [lblNoRelatedStory setHidden:FALSE];
        [lblNostoryTimeline setHidden:TRUE];
    }
    btnRelated.selected = YES;
    btnTimeline.selected = NO;
}

/**-----------------------------------------------------------------
 Function Name  : showRelatedStoryView
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : It shows Related story View
 ------------------------------------------------------------------*/

-(void)callTimeLineStoryAPI
{
    if([[WebserviceComunication sharedCommManager] isOnline])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortAndGroupArrayByDate) name:kNOTIFICATION_RELOAD_STORYTIME object:nil];
        
        //[[WebserviceComunication sharedCommManager] setNumPageNoForStoryTimeline:[[WebserviceComunication sharedCommManager]numPageNoForStoryTimeline]+1];
        [[WebserviceComunication sharedCommManager] getStorytimelineByArticleId:[dicArticleId articleID]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([self.strSelfCurrentContentType isEqualToString:kstrTimeline])
    {
        if ([[[WebserviceComunication sharedCommManager] arrStoryTimeline] count] < 40) {
            [pullToRefreshManagerForTimeline_ tableViewScrolled];
        }
    }
    else if ([self.strSelfCurrentContentType isEqualToString:kstrRelated])
    {
        if ([[[WebserviceComunication sharedCommManager] arrRelatedStory] count] < 40) {
            [pullToRefreshManagerForRelatedStory_ tableViewScrolled];
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([self.strSelfCurrentContentType isEqualToString:kstrTimeline])
    {
        if ([[[WebserviceComunication sharedCommManager] arrStoryTimeline] count] < 40) {
            [pullToRefreshManagerForTimeline_ tableViewReleased];
        }
    }
    else if ([self.strSelfCurrentContentType isEqualToString:kstrRelated])
    {
        if ([[[WebserviceComunication sharedCommManager] arrRelatedStory] count] < 40) {
            [pullToRefreshManagerForRelatedStory_ tableViewReleased];
        }
    }
}
/**-----------------------------------------------------------------
 Function Name  : bottomPullToRefreshTriggered
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Triggered the bottom Pull To Refresh.
 ------------------------------------------------------------------*/
- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager
{
    if([[WebserviceComunication sharedCommManager] isOnline])
    {
        
        if([self.strSelfCurrentContentType isEqualToString:kstrTimeline])
        {
            threadStorytimeline = [[NSThread alloc] initWithTarget:self selector:@selector(callTimeLineStoryAPI) object:nil];
            [threadStorytimeline start];
        }
        else if ([self.strSelfCurrentContentType isEqualToString:kstrRelated])
        {
            threadRelated = [[NSThread alloc] initWithTarget:self selector:@selector(reload_RelatedStoryscrollview) object:nil];
            [threadRelated start];
        }
    }
}

/**-----------------------------------------------------------------
 Function Name  : allocateAndCreateRelatedStoryViews
 Created By     : Jainesh Patel
 Created Date   : 3-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : Allocate and creates New Views.
 ------------------------------------------------------------------*/

-(void)allocateAndCreateRelatedStoryViews
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_INIT_RELATED object:nil];
    
    float numX = 0;
    float numY = 6;
    float numDiffX = 126;
    float numDiffY = 20;
    float numWidth = 110;
    float numHeight = 100;
    
    [self.scrvwRelatedStory setContentSize:CGSizeMake(self.scrvwRelatedStory.frame.size.width,self.scrvwRelatedStory.contentSize.height+numDiffY+numY+kContentHeightOffset)];
    [self.scrvwRelatedStory setBackgroundColor:[UIColor clearColor]]; // For iOS7
    
    numTagCounter = 0;
    
    NSMutableArray *arrContentItem;
    
    if([[WebserviceComunication sharedCommManager] isOnline])
    {
        arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrRelatedStoryNew]];
    }
    else
    {
        arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrRelatedStory]];
    }
    
    for (UIView *vwPullToRefresh in self.scrvwRelatedStory.subviews)
    {
        [vwPullToRefresh removeFromSuperview];
        vwPullToRefresh = nil;
    }
    
    if ([arrContentItem count] == 0 && ![self.scrvwRelatedStory isHidden])
    {
        [self.scrvwRelatedStory addSubview:lblNoRelatedStory];
        
        [lblNoRelatedStory setHidden:FALSE];
        self.bIsNoRealtedNews = TRUE;
    }
    
    for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++)
    {
        UIView *vwContentType = [[UIView alloc]initWithFrame:CGRectMake(numX, numY, numWidth,numHeight)];
        
        //jainesh
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
        [vwContentType addGestureRecognizer:tapRecognizer];
        
        [tapRecognizer release];
        
        [vwContentType setTag:numTagCounter];
        
        [self.scrvwRelatedStory addSubview:vwContentType];
        
        UIView *vwContentBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, numWidth, numHeight)];
        vwContentBox.backgroundColor = [UIColor darkGrayColor];
        [vwContentType addSubview:vwContentBox];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5,3,numWidth-10, numHeight-40)];
        [imageView setTag:101];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        imageView.image = [UIImage imageNamed:kImgNameDefault];
        
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setOpaque:NO];
        
        [vwContentType addSubview:imageView];
        
        UILabel *Description =[[UILabel alloc]initWithFrame:CGRectMake(5,imageView.frame.size.height,vwContentType.frame.size.width-10,40)];
        Description.tag = 99;
        Description.textColor = [UIColor whiteColor];
        [Description setBackgroundColor:[UIColor clearColor]];
        [Description setFont:[UIFont fontWithName:kFontOpenSansRegular size:10]];
        [Description setNumberOfLines:2];
        
        [vwContentType addSubview:Description];
        
        //if([[arrContentItem objectAtIndex:numIndex] thumbnilImageUrlData] != nil)
        if([[arrContentItem objectAtIndex:numIndex] thumbnilImageFile] != nil)
        {
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:[[arrContentItem objectAtIndex:numIndex] thumbnilImageFile]];
            
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            if ([imageData length] > 0)
            {
                [imageView setImage:[UIImage imageWithData:imageData]];
            }
            else
            {
                [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
            }
            [Description setText:[[arrContentItem objectAtIndex:numIndex] contentTitle]];
            [imageData release];
            imageData = nil;
            [imageView release];
            imageView = nil;
        }
        else
        {
            if([[WebserviceComunication sharedCommManager] isOnline])
            {
                NSString *strUrl;
                strUrl = [[NSString alloc]initWithFormat:@"%@",[[arrContentItem objectAtIndex:numIndex] thumbnilImageUrl]];
                dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
                dispatch_async(myQueue, ^{
                    [imageView setImageAsynchronouslyFromUrl:strUrl animated:YES];
                });
                [strUrl release];
                strUrl = nil;
            }
            else
            {
                [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
            }
            [Description setText:[[arrContentItem objectAtIndex:numIndex] contentTitle]];
        }
        
        numX = numX + numDiffX;
        
        if(numX > 126)
        {
            numDiffY = 120;
            numX = 0;
            numY = numY + numDiffY;
        }
        numTagCounter = numTagCounter + 1;
        
        [Description release];
        Description = nil;
        [vwContentBox release];
        vwContentBox = nil;
        [vwContentType release];
        vwContentType = nil;
    }
    
    if(numY < self.scrvwRelatedStory.frame.size.height && !self.bIsNoRealtedNews)
    {
        [self.scrvwRelatedStory setContentSize:CGSizeMake(self.scrvwRelatedStory.frame.size.width,self.scrvwRelatedStory.frame.size.height+10+kContentHeightOffset)];
    }
    else
    {
        if(numX == 126)
        {
            [self.scrvwRelatedStory setContentSize:CGSizeMake(self.scrvwRelatedStory.frame.size.width,numY+numDiffY + kContentHeightOffset)];
        }
        else
        {
            [self.scrvwRelatedStory setContentSize:CGSizeMake(self.scrvwRelatedStory.frame.size.width, numY + kContentHeightOffset)];
        }
    }
    
    pullToRefreshManagerForRelatedStory_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 ScrollView:self.scrvwRelatedStory withClient:self];
    
    [pullToRefreshManagerForRelatedStory_ relocatePullToRefreshView];
    
    numNextX = numX;
    numNextY = numY;
    
    [arrContentItem removeAllObjects];
    
    [self removeWebServiceDictonaryForRelatedStory];
    
    [self RemoveRelatedActivityInidicator];
}

/**-----------------------------------------------------------------
 Function Name  : removeWebServiceDictonary
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Remove all unwanted Dictionaries.
 ------------------------------------------------------------------*/
-(void)removeWebServiceDictonaryForRelatedStory
{
    [[[WebserviceComunication sharedCommManager]dictRelatedStory] removeAllObjects];
}
/**-----------------------------------------------------------------
 Function Name  : AddRelatedActivityInidicator
 Created By     : Jainesh patel.
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Add Related Activity Inidicator.
 ------------------------------------------------------------------*/


-(void)AddRelatedActivityInidicator
{
    if (activityRelated)
    {
        [activityRelated removeFromSuperview];
    }
    
    float vwWidth, vwHeight;
    vwWidth = self.view.frame.size.width - self.scrvwRelatedStory.frame.origin.x;
    vwHeight = self.view.frame.size.height - self.scrvwRelatedStory.frame.origin.y;
    
    activityRelated = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityRelated setCenter:CGPointMake((vwWidth/2) - activityRelated.frame.size.width/2, (vwHeight/2) - activityRelated.frame.size.height/2)];
    [activityRelated startAnimating];
    
    [self.scrvwRelatedStory addSubview:activityRelated];
}
/**-----------------------------------------------------------------
 Function Name  : RemoveRelatedActivityInidicator
 Created By     : Jainesh patel.
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Remove Related Activity Inidicator.
 ------------------------------------------------------------------*/

-(void)RemoveRelatedActivityInidicator
{
    [activityRelated removeFromSuperview];
}
/**-----------------------------------------------------------------
 Function Name  : AddStoryActivityInidicator
 Created By     : Jainesh patel.
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Add Story Activity Inidicator
 ------------------------------------------------------------------*/
-(void)AddStoryActivityInidicator
{
    if (activityStorytime)
    {
        [activityStorytime removeFromSuperview];
    }
    
    float vwWidth, vwHeight;
    vwWidth = self.view.frame.size.width - self.scrvwTimeLine.frame.origin.x;
    vwHeight = self.view.frame.size.height - self.scrvwTimeLine.frame.origin.y;
    
    activityStorytime = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityStorytime setCenter:CGPointMake((vwWidth/2) - activityStorytime.frame.size.width/2, (vwHeight/2) - activityStorytime.frame.size.height/2)];
    [activityStorytime startAnimating];
    
    [self.scrvwTimeLine addSubview:activityStorytime];
}
/**-----------------------------------------------------------------
 Function Name  : RemoveStoryActivityInidicator
 Created By     : Jainesh patel.
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Remove Story Activity Inidicator.
 ------------------------------------------------------------------*/
-(void)RemoveStoryActivityInidicator
{
    [activityStorytime removeFromSuperview];
}
/**-----------------------------------------------------------------
 Function Name  : reload_scrollview
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 25-Apr-2013
 Purpose        : Reload the scrollview and creat new view acording tio content type.
 ------------------------------------------------------------------*/
-(void)reload_RelatedStoryscrollview
{
    if ([[WebserviceComunication sharedCommManager] isOnline])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddRelatedStories) name:kNOTIFICATION_RELOAD_RELATED object:nil];
        
        //[[WebserviceComunication sharedCommManager] setNumRelatedStory:[[WebserviceComunication sharedCommManager] numRelatedStory] + 1];
        [[WebserviceComunication sharedCommManager] getRelatedStoryByArticleId:[dicArticleId articleID]];
    }
}
/**-----------------------------------------------------------------
 Function Name  : AddRelatedStories
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 25-Apr-2013
 Purpose        : Add Related Stories articles.
 ------------------------------------------------------------------*/

- (void)AddRelatedStories
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_RELOAD_RELATED object:nil];
    
    float numDiffX = 126;
    float numDiffY = 20;
    float numWidth = 110;
    float numHeight = 100;
    
    
    NSMutableArray *arrContentItem;
    
    arrContentItem = [[WebserviceComunication sharedCommManager] arrRelatedStoryNew];
    
    for(int numIndex = 0; numIndex<[arrContentItem count]; numIndex++)
    {
        UIView *vwContentType = [[UIView alloc]initWithFrame:CGRectMake(numNextX, numNextY, numWidth,numHeight)];
        
        //jainesh
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
        [vwContentType addGestureRecognizer:tapRecognizer];
        
        [vwContentType setTag:numTagCounter];
        [self.scrvwRelatedStory addSubview:vwContentType];
        
        UIView *vwContentBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, numWidth, numHeight)];
        vwContentBox.backgroundColor = [UIColor darkGrayColor];
        [vwContentType addSubview:vwContentBox];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5,3,numWidth-10, numHeight-40)];
        [imageView setTag:101];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        imageView.image = [UIImage imageNamed:kImgNameDefault];
        
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setOpaque:NO];
        
        [vwContentType addSubview:imageView];
        
        UILabel *Description =[[UILabel alloc]initWithFrame:CGRectMake(5,imageView.frame.size.height,vwContentType.frame.size.width-10,40)];
        Description.textColor = [UIColor whiteColor];
        [Description setBackgroundColor:[UIColor clearColor]];
        [Description setFont:[UIFont fontWithName:kFontOpenSansRegular size:10]];
        [Description setNumberOfLines:2];
        
        [vwContentType addSubview:Description];
        
        //if([[arrContentItem objectAtIndex:numIndex] thumbnilImageUrlData] != nil)
        if([[arrContentItem objectAtIndex:numIndex] thumbnilImageFile] != nil)
        {
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:[[arrContentItem objectAtIndex:numIndex] thumbnilImageFile]];
            
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            if ([imageData length] > 0)
            {
                [imageView setImage:[UIImage imageWithData:imageData]];
            }
            else
            {
                [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
            }
            [Description setText:[[arrContentItem objectAtIndex:numIndex] contentTitle]];
        }
        else
        {
            if([[WebserviceComunication sharedCommManager] isOnline])
            {
                NSString *strUrl;
                strUrl = [[NSString alloc]initWithFormat:@"%@",[[arrContentItem objectAtIndex:numIndex] thumbnilImageUrl]];
                dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
                dispatch_async(myQueue, ^{
                    [imageView setImageAsynchronouslyFromUrl:strUrl animated:YES];
                });
            }
            else
            {
                [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
            }
            [Description setText:[[arrContentItem objectAtIndex:numIndex] contentTitle]];
        }
        
        numNextX = numNextX + numDiffX;
        
        if(numNextX > 126)
        {
            numDiffY = 120;
            numNextX = 0;
            numNextY = numNextY + numDiffY;
            
        }
        numTagCounter = numTagCounter + 1;
    }
    
    if (numTagCounter % 2 == 1)
    {
        [self.scrvwRelatedStory setContentSize:CGSizeMake(self.scrvwRelatedStory.contentSize.width,numNextY + 120 + kContentHeightOffset)];
    }
    else
    {
        [self.scrvwRelatedStory setContentSize:CGSizeMake(self.scrvwRelatedStory.contentSize.width,numNextY + kContentHeightOffset)];
    }
    
    [self removeWebServiceDictonaryForRelatedStory];
    [pullToRefreshManagerForRelatedStory_ tableViewReloadFinished];
}


# pragma mark - Action Methods
/**-----------------------------------------------------------------
 Function Name  : handleTapOnContent
 Created By     : Jainesh Patel
 Created Date   : 3-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : show the detail of time line and related.
 ------------------------------------------------------------------*/

- (IBAction)handleTapOnContent:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    UIView *vwTemp = gesture.view;
    
    RelatedStoryAndTimeline *dic;
    
    if([self.strSelfCurrentContentType isEqualToString:kstrTimeline])
    {
        NSPredicate *predicateFilter = [NSPredicate predicateWithFormat:@"ArticleID == %@",vwTemp.accessibilityValue];
        NSArray *arrTemp = [[[WebserviceComunication sharedCommManager] arrStoryTimeline] filteredArrayUsingPredicate:predicateFilter];
        
        if([arrTemp count] > 0)
        {
            dic = [arrTemp objectAtIndex:0];
        }
    }
    
    else if ([self.strSelfCurrentContentType isEqualToString:kstrRelated])
    {
        dic = [[[WebserviceComunication sharedCommManager] arrRelatedStory] objectAtIndex:vwTemp.tag];
    }
        
    [delegate selectedArticleDetail:dic];
}
/**-----------------------------------------------------------------
 Function Name  : btnStoryTimelineCllick
 Created By     : Jainesh Patel
 Created Date   : 3-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : show timeline view.
 ------------------------------------------------------------------*/

- (IBAction)btnStoryTimelineCllick:(id)sender
{
    [lblNostoryTimeline setHidden:TRUE];
    [lblNoRelatedStory setHidden:TRUE];
    [self.btnTimeline setBackgroundColor:[UIColor blackColor]];
    [self.btnTimeline setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.btnTimeline setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [self.btnRelated setBackgroundColor:kUICOLOR_RELATED_BACK];
    
    self.strSelfCurrentContentType = kstrTimeline;
    [Flurry logEvent:KFlurryEventTimeline_RelatedStorySwitching withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kstrStoryTimeline,kstrContentType, nil]];
    
    [self showTimelineView];
    
    if(self.bIsNoStoryNews)
    {
        [lblNostoryTimeline setHidden:FALSE];
        [self.imgvwTimelineBar setHidden:TRUE];
    }
    else if([[[WebserviceComunication sharedCommManager] arrStoryTimeline] count] == 0)
    {
        [self.imgvwTimelineBar setHidden:TRUE];
        [lblNostoryTimeline setHidden:TRUE];
        
        [self AddStoryActivityInidicator];
        
        threadStorytimeline = [[NSThread alloc] initWithTarget:self selector:@selector(initializeStoryTimeView) object:nil];
        [threadStorytimeline start];
    }
}
/**-----------------------------------------------------------------
 Function Name  : btnStoryTimelineCllick
 Created By     : Jainesh Patel
 Created Date   : 3-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : show Related story view.
 ------------------------------------------------------------------*/
- (IBAction)btnRelatedStoryCllick:(id)sender
{
    [lblNostoryTimeline setHidden:TRUE];
    [lblNoRelatedStory setHidden:TRUE];
    [self.btnTimeline setBackgroundColor:kUICOLOR_RELATED_BACK];
    [self.btnRelated setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.btnRelated setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.btnRelated setBackgroundColor:[UIColor blackColor]];
    
    self.strSelfCurrentContentType = kstrRelated;
    
    [Flurry logEvent:KFlurryEventTimeline_RelatedStorySwitching withParameters:[NSDictionary dictionaryWithObjectsAndKeys:kstrRelatedStory,kstrContentType, nil]];
    
    [self showRelatedStoryView];
    
    
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        lblNostoryTimeline.text = @"Cannot load the story timeline as your connection is offline.";
        lblNoRelatedStory.text = @"Cannot load the related stories as your connection is offline.";
        [lblNostoryTimeline setHidden:FALSE];
        [lblNoRelatedStory setHidden:FALSE];
        return;
    }
    
    
    if (self.bIsNoRealtedNews == FALSE && self.bIsFirstSwipe)
    {
        [self AddRelatedActivityInidicator];
        
        threadRelated = [[NSThread alloc] initWithTarget:self selector:@selector(initializeRelatedViews) object:nil];
        [threadRelated start];
        
    }
    else
    {
        if (![activityRelated isDescendantOfView:self.scrvwRelatedStory])
        {
            [lblNoRelatedStory setHidden:FALSE];
        }
    }
}
/**-----------------------------------------------------------------
 Function Name  : initializeRelatedViews
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 25-Apr-2013
 Purpose        : initialize The Related Views.
 ------------------------------------------------------------------*/
- (void)initializeRelatedViews
{
    if ([[WebserviceComunication sharedCommManager] isOnline])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allocateAndCreateRelatedStoryViews) name:kNOTIFICATION_INIT_RELATED object:nil];
        
        [[[WebserviceComunication sharedCommManager] arrRelatedStory] removeAllObjects];
        
        [[WebserviceComunication sharedCommManager] setNumRelatedStory:0];
        [[WebserviceComunication sharedCommManager] getRelatedStoryByArticleId:[dicArticleId articleID]];
    }
    else
    {
        if ([self.dicArticleId articleID])
        {
            [[WebserviceComunication sharedCommManager] setArrRelatedStory:[[CacheDataManager sharedCacheManager] getRelatedStoryWithParentId:[self.dicArticleId articleID] andArticleType:kstrRelated]];
        }
        else
        {
            [[WebserviceComunication sharedCommManager] setArrRelatedStory:[[CacheDataManager sharedCacheManager] getRelatedStoryWithParentId:[self.dicArticleId articleID] andArticleType:kstrRelated]];
        }
        
        [self performSelectorOnMainThread:@selector(allocateAndCreateRelatedStoryViews) withObject:nil waitUntilDone:NO];
    }
}
/**-----------------------------------------------------------------
 Function Name  : initializeStoryTimeView
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 25-Apr-2013
 Purpose        : initialize Story Time View
 ------------------------------------------------------------------*/
- (void)initializeStoryTimeView
{
    if ([[WebserviceComunication sharedCommManager] isOnline])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortAndGroupArrayByDate) name:kNOTIFICATION_INIT_STORYTIME object:nil];
        
        [[[WebserviceComunication sharedCommManager] arrStoryTimeline] removeAllObjects];
        [arrStoryTimelineDataForLeft removeAllObjects];
        [arrStoryTimelineDataForRight removeAllObjects];
        
        [[WebserviceComunication sharedCommManager] setNumPageNoForStoryTimeline:0];
        
        [[WebserviceComunication sharedCommManager] getStorytimelineByArticleId:[dicArticleId articleID]];
    }
    else
    {
        if([dicArticleId articleID])
        {
            [[WebserviceComunication sharedCommManager] setArrStoryTimeline:[[CacheDataManager sharedCacheManager] getRelatedStoryWithParentId:[dicArticleId articleID] andArticleType:kstrTimeline]];
        }
        else
        {
            [[WebserviceComunication sharedCommManager] setArrStoryTimeline:[[CacheDataManager sharedCacheManager] getRelatedStoryWithParentId: [dicArticleId articleID] andArticleType:kstrTimeline]];
        }
        [self performSelectorOnMainThread:@selector(sortAndGroupArrayByDate) withObject:nil waitUntilDone:NO];
    }
}

# pragma mark
# pragma mark - UITableView Delegate,Datasource Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 10)
    {
        return [[[self.arrStoryTimelineDataForLeft objectAtIndex:section] valueForKey:[[[self.arrStoryTimelineDataForLeft objectAtIndex:section] allKeys] objectAtIndex:0]] count] ;
    }
    
    else
    {
        return [[[self.arrStoryTimelineDataForRight objectAtIndex:section] valueForKey:[[[self.arrStoryTimelineDataForRight objectAtIndex:section] allKeys] objectAtIndex:0]] count];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView.tag == 10)
    {
        return [self.arrStoryTimelineDataForLeft count];
    }
    else
    {
        return [self.arrStoryTimelineDataForRight count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
    StoryTimelineCell *cell = (StoryTimelineCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    RelatedStoryAndTimeline *dic;
    if(tableView.tag == 10)
    {
        dic = [[[self.arrStoryTimelineDataForLeft objectAtIndex:indexPath.section] valueForKey:[[[self.arrStoryTimelineDataForLeft objectAtIndex:indexPath.section] allKeys] objectAtIndex:0]] objectAtIndex:indexPath.row];
    }
    else
    {
        dic = [[[self.arrStoryTimelineDataForRight objectAtIndex:indexPath.section] valueForKey:[[[self.arrStoryTimelineDataForRight objectAtIndex:indexPath.section] allKeys] objectAtIndex:0]] objectAtIndex:indexPath.row];
    }
    
    if (cell == nil)
    {
        cell = [[StoryTimelineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor]; // For iOS7
        
        if([dic thumbnilImageFile] != nil)
        {
            DLog(@"WE HAVE IMAGE DATA!!");
            
            //NSData *imageData = [[[ NSData alloc]initWithData:[dic thumbnilImageUrlData]] autorelease];
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:[dic thumbnilImageFile]];
            
            [cell.imgvwCOntentImage setContentMode:UIViewContentModeScaleAspectFit];
            if ([imageData length] > 0)
            {
                [cell.imgvwCOntentImage setImage:[UIImage imageWithData:imageData]];
            }
            else
            {
                [cell.imgvwCOntentImage setImage:[UIImage imageNamed:kImgNameDefault]];
            }
        }
        else
        {
            if([[WebserviceComunication sharedCommManager] isOnline])
            {
                NSString *strUrl;
                strUrl = [[NSString alloc]initWithFormat:@"%@",[dic thumbnilImageUrl]];
                dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
                dispatch_async(myQueue, ^{
                    [cell.imgvwCOntentImage setImageAsynchronouslyFromUrl:strUrl animated:YES];
                });
            }
            else
            {
                [cell.imgvwCOntentImage setImage:[UIImage imageNamed:kImgNameDefault]];
            }
        }
    }
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
    
    cell.vwContentBox.accessibilityValue = [dic articleID];
    cell.vwContentBox.tag = numTagForTimeline;
    [cell.vwContentBox addGestureRecognizer:tapRecognizer];
    cell.lblTitle.text = [dic contentTitle];
    
    if(tableView.tag == 10)
    {
        
    }
    else
    {
        [[cell.contentView.subviews lastObject] setFrame:CGRectMake(9,0,110, 100)];
    }
    
    numTagForTimeline = numTagForTimeline + 1;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [tableView setBackgroundColor:[UIColor clearColor]]; // For iOS7
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *imgvwArrow;
    UILabel *headingLabel;
    UIImageView *imgvwTime;
    NSString *strHeaderDate;
    NSString *strArrowDirection;
    if(tableView.tag == 10)
    {
        imgvwTime = [[UIImageView alloc] initWithFrame:CGRectMake(headerView.frame.size.width - 25, 7, 15, 15)];
        imgvwTime.image = [UIImage imageNamed:@"ico-time.png"];
        headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgvwTime.frame.origin.x - 75, 5, 80, 20)];
        
        headingLabel.textAlignment = NSTextAlignmentLeft;
        headingLabel.textColor = [UIColor lightGrayColor];
        headingLabel.font = [UIFont fontWithName:kFontOpenSansRegular size:12.0];
        [headingLabel setBackgroundColor:[UIColor clearColor]];
        
        strHeaderDate = [[[self.arrStoryTimelineDataForLeft objectAtIndex:section] allKeys] objectAtIndex:0];
        strArrowDirection = @"timeline-arrow-left.png";
        imgvwArrow = [[UIImageView alloc] initWithFrame:CGRectMake(headerView.frame.size.width-8, 6, 8, 16)];
        imgvwArrow.image = [UIImage imageNamed:strArrowDirection];
        [headerView addSubview:imgvwArrow];
    }
    else
    {
        headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerView.frame.size.width - 90, 3, 80, 20)];
        
        headingLabel.textAlignment = NSTextAlignmentLeft;
        headingLabel.textColor = [UIColor lightGrayColor];
        headingLabel.font = [UIFont fontWithName:kFontOpenSansRegular size:12.0];
        [headingLabel setBackgroundColor:[UIColor clearColor]];
        
        imgvwTime = [[UIImageView alloc] initWithFrame:CGRectMake(headingLabel.frame.origin.x - 17, 7, 15, 15)];
        imgvwTime.image = [UIImage imageNamed:@"ico-time.png"];
        
        strHeaderDate = [[[self.arrStoryTimelineDataForRight objectAtIndex:section] allKeys] objectAtIndex:0];
        strArrowDirection = @"timeline-arrow-right.png";
        imgvwArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 8, 16)];
        imgvwArrow.image = [UIImage imageNamed:strArrowDirection];
        [headerView addSubview:imgvwArrow];
    }
    
    headingLabel.text = strHeaderDate;
    [headerView addSubview:headingLabel];
    [headerView addSubview:imgvwTime];
    [headerView addSubview:imgvwArrow];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)removeAllView
{
    [[[WebserviceComunication sharedCommManager] dictRelatedStory] removeAllObjects];
    [[[WebserviceComunication sharedCommManager] arrRelatedStory] removeAllObjects];
    
    [[[WebserviceComunication sharedCommManager] dictStoryTimeline] removeAllObjects];
    [[[WebserviceComunication sharedCommManager] arrStoryTimeline] removeAllObjects];
    
    [self allocateAndCreateRelatedStoryViews];
    [self.tblTimeLineLeft reloadData];
    [self.tblTimeLineRight reloadData];
}

@end
