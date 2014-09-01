//
//  ArticleDetailMaster.m
//  EWN
//
//  Created by Arpit Jain on 6/12/13.
//
//

#import "ArticleDetailMaster.h"

#import "MainViewController.h"

#define kDefaultCount 60

@interface ArticleDetailMaster ()

@end

@implementation ArticleDetailMaster
@synthesize scrvwMasterDetail;

@synthesize strCurrentArticleID;
@synthesize strCurrentContentType;
@synthesize isOpen;

/**-----------------------------------------------------------------
 Function Name  : initWithNibName
 Created By     : Arpit Jain
 Created Date   : 6-June-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method initialize variables.
 ------------------------------------------------------------------*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        numPreviousTag = 500;
        numTotalAddedViews = kDefaultCount;
    }
    return self;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [vwCenterArticle scrollViewWillBeginDragging:scrollView];
}
/**-----------------------------------------------------------------
 Function Name  : scrollViewDidEndDragging
 Created By     : Arpit Jain
 Created Date   : 6-June-2013
 Modified By    :
 Modified Date  :
 Purpose        :  this method sets the scroll off set.
 ------------------------------------------------------------------*/
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    int initialTag;
    initialTag = 500;
    [scrollView setScrollEnabled:FALSE];
    [vwCenterArticle.scrvwMainView setScrollEnabled:FALSE];
    [vwFirstArticle.scrvwMainView setScrollEnabled:FALSE];
    [vwLastArticle.scrvwMainView setScrollEnabled:FALSE];
}
/**-----------------------------------------------------------------
 Function Name  : scrollViewDidEndDecelerating
 Created By     : Arpit Jain
 Created Date   : 6-June-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method sets the scroll off set.
 ------------------------------------------------------------------*/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView setScrollEnabled:TRUE];
    [vwCenterArticle.scrvwMainView setScrollEnabled:TRUE];
    [vwFirstArticle.scrvwMainView setScrollEnabled:TRUE];
    [vwLastArticle.scrvwMainView setScrollEnabled:TRUE];
    
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = (int)(scrollView.contentOffset.x / pageWidth) + 0.5;
    
    if (page == 0) {
        if (numCurrentPage != 0) {
            [vwCenterArticle.objStoryTimelineView viewDidDisappear:FALSE];
            [self PrepareDetailViewForContentType:strCurrentContentType withCurrentArticle:numCurrentPage-1];
        }
    } else if(page == 1 && numCurrentPage == 0) {
        [vwCenterArticle.objStoryTimelineView viewDidDisappear:FALSE];
        [self PrepareDetailViewForContentType:strCurrentContentType withCurrentArticle:numCurrentPage+1];
    } else if(page == 2) {
        if (numCurrentPage != numTotalPages-1) {
            [vwCenterArticle.objStoryTimelineView viewDidDisappear:FALSE];
            [self PrepareDetailViewForContentType:strCurrentContentType withCurrentArticle:numCurrentPage+1];
        }
    }
}
/**-----------------------------------------------------------------
 Function Name  : viewDidLoad
 Created By     : Arpit Jain
 Created Date   : 13-Jun-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method initialize variables and Loads the view.
 ------------------------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.scrvwMasterDetail setBackgroundColor:[UIColor clearColor]];
    [self.scrvwMasterDetail setAlwaysBounceHorizontal:TRUE];
    
    NSString *strXib = kstrContentDetailViewController_iPhone5;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.height == 568) {
            strXib = kstrContentDetailViewController_iPhone5;
        } else {
            strXib = kstrContentDetailViewController;
        }
    }
    
    [self.progressLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:11.0]];
    
    [self.scrvwMasterDetail setContentSize:CGSizeMake(self.scrvwMasterDetail.frame.size.width * 3, self.scrvwMasterDetail.frame.size.height)];
    
    vwLastArticle = [[ContentDetailViewController alloc] initWithNibName:strXib bundle:nil];
    CGRect frame = CGRectMake(0, 0, vwLastArticle.view.frame.size.width , vwLastArticle.view.frame.size.height);
    [vwLastArticle.view setFrame:frame];
    [vwLastArticle.view setTag:100];
    [self.scrvwMasterDetail addSubview:vwLastArticle.view];
    
    vwCenterArticle = [[ContentDetailViewController alloc] initWithNibName:strXib bundle:nil];
    [vwCenterArticle.view setFrame:CGRectMake(320, 0, vwCenterArticle.view.frame.size.width, vwCenterArticle.view.frame.size.height)];
    [vwCenterArticle.view setTag:101];
    [self.scrvwMasterDetail addSubview:vwCenterArticle.view];
    
    vwFirstArticle = [[ContentDetailViewController alloc] initWithNibName:strXib bundle:nil];
    [vwFirstArticle.view setFrame:CGRectMake(640 ,0, vwFirstArticle.view.frame.size.width , vwFirstArticle.view.frame.size.height)];
    [vwFirstArticle.view setTag:101];
    [self.scrvwMasterDetail addSubview:vwFirstArticle.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**-----------------------------------------------------------------
 Function Name  : PrepareDetailViewForContentType:(NSString *)strContentType withCurrentArticle:(int)numCurrentArticle
 Created By     : Sumit Kumar
 Created Date   : 13-Jun-2013
 Modified By    :
 Modified Date  :
 Purpose        : Prepares article details based on content type and moves to current article
 ------------------------------------------------------------------*/
-(void)PrepareDetailViewForContentType:(NSString *)strContentType withCurrentArticle:(int)numCurrentArticle {
    NSMutableArray *arrLatest;
    Contents *dicSelected;
    
    ParentContentType leadingParentType;
    ParentContentType currentParentType;
    
    [vwLastArticle.scrvwMainView setContentOffset:CGPointMake(0, 0)];
    [vwCenterArticle.scrvwMainView setContentOffset:CGPointMake(0, 0)];
    [vwCenterArticle.scrvwContentDetail setContentOffset:CGPointMake(0, 0)];
    [vwCenterArticle.scrvwContentDetail setScrollEnabled:TRUE];
    [vwCenterArticle initializeRelatedStoryView];
    [vwFirstArticle.scrvwMainView setContentOffset:CGPointMake(0, 0)];
    
    if([[WebserviceComunication sharedCommManager]isOnline]) {
        if ([strContentType isEqualToString:kCONTENT_TITLE_LATEST]) {
            arrLatest = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrLatestNews]];
            
//            if(([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews] || version2) && [[[WebserviceComunication sharedCommManager] arrLeadingNews] count] > 0) {
            
            if(([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews]) && [[[WebserviceComunication sharedCommManager] arrLeadingNews] count] > 0) {
                if(![[WebserviceComunication sharedCommManager] isInFocus]) {
//                    NSMutableArray *arrLeadingNews = [[[WebserviceComunication sharedCommManager] arrLeadingNews] objectAtIndex:0];
                    [arrLatest insertObject:[[CacheDataManager sharedCacheManager] getLeadingNewsEntity] atIndex:0];
                }
                leadingParentType = ParentContentTypeLeadingNews;
            } else {
                leadingParentType = ParentContentTypeLatestNews;
            }
            
            currentParentType = ParentContentTypeLatestNews;
        } else if ([strContentType isEqualToString:kCONTENT_TITLE_VIDEO]) {
            arrLatest = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrVideo]];
            
            currentParentType = ParentContentTypeVideo;
        } else if ([strContentType isEqualToString:kCONTENT_TITLE_IMAGE]) {
            arrLatest = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrImages]];
            
            currentParentType = ParentContentTypeImages;
        } else if ([strContentType isEqualToString:kCONTENT_TITLE_AUDIO]) {
            arrLatest = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrAudio]];
            
            currentParentType = ParentContentTypeAudio;
        } else if ([strContentType isEqualToString:kCONTENT_TITLE_SEARCH]) {
            arrLatest = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrSearchNews]];
            
            currentParentType = ParentContentTypeSearchedNews;
        } else {
            arrLatest = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrBreakingNews]];
            
            currentParentType = ParentContentTypeLatestNews;
        }
    } else {
        if ([strContentType isEqualToString:kCONTENT_TITLE_LATEST]) {
            arrLatest = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrLatestNews]];
            
            if([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews]) {
                [arrLatest insertObject:[[CacheDataManager sharedCacheManager] getLeadingNewsEntity] atIndex:0];
                leadingParentType = ParentContentTypeLeadingNews;
            } else {
                leadingParentType = ParentContentTypeLatestNews;
            }
            currentParentType = ParentContentTypeLatestNews;
        } else if ([strContentType isEqualToString:kCONTENT_TITLE_VIDEO]) {
            arrLatest = [NSMutableArray arrayWithArray:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrVideo andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId]]];
            
            currentParentType = ParentContentTypeVideo;
        } else if ([strContentType isEqualToString:kCONTENT_TITLE_IMAGE]) {
            arrLatest = [NSMutableArray arrayWithArray:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kContentImages andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId]]];
            currentParentType = ParentContentTypeImages;
        } else {
            arrLatest = [NSMutableArray arrayWithArray:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrAudio andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId]]];
            currentParentType = ParentContentTypeAudio;
        }
    }
        
    numCurrentPage = numCurrentArticle;
    numTotalPages = [arrLatest count];
    strCurrentContentType = strContentType;
    
    if (numCurrentArticle >= 0 && numCurrentArticle < [arrLatest count]) {
        dicSelected = [arrLatest objectAtIndex:numCurrentArticle];
        
        strCurrentContentType = [[NSString alloc] initWithString:strContentType];
        
        if ([dicSelected articleID] != nil) {
            strCurrentArticleID = [[NSString alloc] initWithString:[dicSelected articleID]];
        } else if([dicSelected objectForKey:kstrArticleID]) {
            strCurrentArticleID = [[NSString alloc] initWithString:[dicSelected objectForKey:kstrArticleID]];
        }
        
        // Load Current Article
        {
            [vwCenterArticle.view setHidden:FALSE];
            
            if (leadingParentType == ParentContentTypeLeadingNews && numCurrentArticle == 0)
            {
                [vwCenterArticle setParentContentType:leadingParentType];
            }
            else
            {
                [vwCenterArticle setParentContentType:currentParentType];
            }

            vwCenterArticle.contentTypeString = strContentType;
            [vwCenterArticle setDicArticleDetail:dicSelected];
            [vwCenterArticle displayAllDetails];
        }
        
        // Load Left Article
        if (numCurrentArticle >= 1) {
            dicSelected = [arrLatest objectAtIndex:numCurrentArticle-1];
            
            [vwLastArticle.view setHidden:FALSE];
            
            if (leadingParentType == ParentContentTypeLeadingNews && numCurrentArticle-1 == 0) {
                [vwLastArticle setParentContentType:leadingParentType];
            } else {
                [vwLastArticle setParentContentType:currentParentType];
            }
            
            vwLastArticle.contentTypeString = strContentType;
            [vwLastArticle setDicArticleDetail:dicSelected];
            [vwLastArticle displayAllDetails];
            
        }
        
        int lastIndex = [arrLatest count] - 2;
        
        // Load Right Article
        if (numCurrentArticle <= lastIndex) {
            dicSelected = [arrLatest objectAtIndex:numCurrentArticle+1];
            
            [vwFirstArticle.view setHidden:FALSE];
            
            if (leadingParentType == ParentContentTypeLeadingNews && numCurrentArticle == 0) {
                [vwFirstArticle setParentContentType:leadingParentType];
            } else {
                [vwFirstArticle setParentContentType:currentParentType];
            }
            
            vwFirstArticle.contentTypeString = strContentType;
            [vwFirstArticle setDicArticleDetail:dicSelected];
            [vwFirstArticle displayAllDetails];
        }
        
        if (numTotalPages > 1)
        {
            if (numCurrentArticle >= 1 && numCurrentArticle <= lastIndex)
            {
                [vwCenterArticle.view setFrame:CGRectMake(320, 0, vwCenterArticle.view.frame.size.width, vwCenterArticle.view.frame.size.height)];
                [vwLastArticle.view setFrame:CGRectMake(0, 0, vwLastArticle.view.frame.size.width, vwLastArticle.view.frame.size.height)];
                [vwFirstArticle.view setFrame:CGRectMake(640, 0, vwFirstArticle.view.frame.size.width, vwFirstArticle.view.frame.size.height)];
                [self.scrvwMasterDetail setContentOffset:CGPointMake(320, 0)];
                [self.scrvwMasterDetail setContentSize:CGSizeMake(960, 0)];
            }
            else if(numCurrentArticle == 0)
            {
                [vwCenterArticle.view setFrame:CGRectMake(0, 0, vwCenterArticle.view.frame.size.width, vwCenterArticle.view.frame.size.height)];
                [vwFirstArticle.view setFrame:CGRectMake(320, 0, vwFirstArticle.view.frame.size.width, vwFirstArticle.view.frame.size.height)];
                [vwFirstArticle.view setHidden:FALSE];
                [vwLastArticle.view setHidden:TRUE];
                [self.scrvwMasterDetail setContentOffset:CGPointMake(0, 0)];
                [self.scrvwMasterDetail setContentSize:CGSizeMake(640, 0)];
            }
            else if(numCurrentArticle == [arrLatest count]-1)
            {
                [vwCenterArticle.view setFrame:CGRectMake(320, 0, vwCenterArticle.view.frame.size.width, vwCenterArticle.view.frame.size.height)];
                [vwLastArticle.view setFrame:CGRectMake(0, 0, vwLastArticle.view.frame.size.width, vwLastArticle.view.frame.size.height)];
                [vwLastArticle.view setHidden:FALSE];
                
                [vwFirstArticle.view setHidden:TRUE];
                [self.scrvwMasterDetail setContentOffset:CGPointMake(320, 0)];
                [self.scrvwMasterDetail setContentSize:CGSizeMake(640, 0)];
            }
        }
        else
        {
            [vwCenterArticle.view setFrame:CGRectMake(0, 0, vwCenterArticle.view.frame.size.width, vwCenterArticle.view.frame.size.height)];
            [vwFirstArticle.view setHidden:TRUE];
            [vwLastArticle.view setHidden:TRUE];
            [self.scrvwMasterDetail setContentOffset:CGPointMake(0, 0)];
            [self.scrvwMasterDetail setContentSize:CGSizeMake(320, 0)];
        }
        [self.scrvwMasterDetail setScrollEnabled:TRUE];
        [vwCenterArticle.scrvwMainView setScrollEnabled:TRUE];
        [vwFirstArticle.scrvwMainView setScrollEnabled:TRUE];
        [vwLastArticle.scrvwMainView setScrollEnabled:TRUE];
    }
    else if([arrLatest count] > 0)
    {
        [self PrepareDetailViewForContentType:strContentType withCurrentArticle:0];
    }
    
    // Update Comments
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [[objMainView contextMenu] updateComments:[vwCenterArticle.dicArticleDetail articleID]];
    
    // SHARING
    NSString *sharingText = [vwCenterArticle.dicArticleDetail contentTitle];
    NSString *shareUrl = [vwCenterArticle.dicArticleDetail contentURL];
    [[objMainView contextPage] setSharingValues:sharingText shareUrl:shareUrl];
    
    // COMMENTING
    NSString *articleId = [vwCenterArticle.dicArticleDetail articleID];
    [objMainView contextPage].articleId = articleId;
    
    [self updateProgress];
    
    // let us do some cleanup
    [sharingText release];
    sharingText = nil;
    [shareUrl release];
    shareUrl = nil;
}


/**-----------------------------------------------------------------
 Function Name  : PrepareDetailViewForOffline
 Created By     : Arpit Jain
 Created Date   : 13-Jun-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method prepares the detail view for offline.
 ------------------------------------------------------------------*/
-(void)PrepareDetailViewForOffline:(NSString *)strContentType andArticle:(NSString*)strArticleID {
    if (strContentType == nil) {
        DLog(@"strContentType == nil");
        strContentType = self.strCurrentContentType;
        
        if (strContentType == nil) {
            return;
        }
    }
    
    NSMutableArray *arrLatest;
    
    ParentContentType leadingParentType;
    ParentContentType currentParentType;
    
    [vwLastArticle.scrvwMainView setContentOffset:CGPointMake(0, 0)];
    [vwCenterArticle.scrvwMainView setContentOffset:CGPointMake(0, 0)];
    [vwCenterArticle.scrvwContentDetail setContentOffset:CGPointMake(0, 0)];
    [vwCenterArticle.scrvwContentDetail setScrollEnabled:TRUE];
    [vwCenterArticle initializeRelatedStoryView];
    [vwFirstArticle.scrvwMainView setContentOffset:CGPointMake(0, 0)];
    
    if ([strContentType isEqualToString:kCONTENT_TITLE_LATEST])
    {
        arrLatest = [NSMutableArray arrayWithArray:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kcontentLatest andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId]]];
        
        if([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews] && [[WebserviceComunication sharedCommManager] dictLeadingNews])
        {
            [arrLatest insertObject:[[WebserviceComunication sharedCommManager] dictLeadingNews] atIndex:0];
            leadingParentType = ParentContentTypeLeadingNews;
        }
        else
        {
            leadingParentType = ParentContentTypeLatestNews;
        }
        currentParentType = ParentContentTypeLatestNews;
    }
    else if ([strContentType isEqualToString:kCONTENT_TITLE_VIDEO])
    {
        arrLatest = [NSMutableArray arrayWithArray:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrVideo andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId]]];
        
        currentParentType = ParentContentTypeVideo;
    }
    else if ([strContentType isEqualToString:kCONTENT_TITLE_IMAGE])
    {
        arrLatest = [NSMutableArray arrayWithArray:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kContentImages andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId]]];
        currentParentType = ParentContentTypeImages;
    }
    else if ([strContentType isEqualToString:kCONTENT_TITLE_AUDIO])
    {
        arrLatest = [NSMutableArray arrayWithArray:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrAudio andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId]]];
        currentParentType = ParentContentTypeAudio;
    } else {
        arrLatest = [NSMutableArray arrayWithArray:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kcontentLatest andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId]]];
    }
    
    
    if (arrLatest && arrLatest.count > 0)
    {
        NSPredicate *predicateFilter = [NSPredicate predicateWithFormat:@"ArticleID == %@", strArticleID];
        
        NSArray *arrArticle = [arrLatest filteredArrayUsingPredicate:predicateFilter];
        
        if ([arrArticle count] > 0)
        {
            int index;
            index = [arrLatest indexOfObject:[arrArticle objectAtIndex:0]];
            
            [self PrepareDetailViewForContentType:strContentType withCurrentArticle:index];
        }
    }
    else
    {
        DLog(@"arrLatest is either nil or has no items.")
    }
    
    
    [self updateProgress];
}

-(void)updateProgress
{
    NSString *progressString = [NSString stringWithFormat:@"%d / %d", (numCurrentPage + 1), numTotalPages ];
    [self.progressLabel setText:progressString];
}

@end