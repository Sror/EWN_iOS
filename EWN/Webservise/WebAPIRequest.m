
/*------------------------------------------------------------------------
 File Name: WebAPIRequest.m
 Created By: Pratik Prajapati
 Created Date: 23-Nov-2012
 Last Modified on: 19-Dec-2012
 Purpose: Common class for Web-service calls and Parsing of its
 response, no matter type of response. (XML/JSON)
 -------------------------------------------------------------------------*/

#import "WebAPIRequest.h"
#import "AppDelegate.h"

#import "ContentsListViewController.h"
#import "StoryTimelineViewController.h"
#import "SearchNewsListViewController.h"
#import "ContentDetailViewController.h"

@interface UIAlertView (AuthDialog)
@end

# pragma mark
# pragma mark

@implementation UIImageView (AsyncImageView)


-(void)setImageAsynchronouslyFromUrl:(NSString *)imageUrl animated:(BOOL)isAnimated article:(Contents *)article {
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        UIImage *image = [[[UIImage alloc] initWithData:data] autorelease];
        [self removeActivityIndicatorFromImageView];
        if (image != nil) {
            self.image = image;
        } else {
            self.image = [UIImage imageNamed:kImgNameDefault];
        }
        
        if(isAnimated) {
            [self animateImage];
        }
        [self setContentMode:UIViewContentModeScaleAspectFit];
        
        [article setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
        [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:article];
    }];
    [request setFailedBlock:^{
        [self removeActivityIndicatorFromImageView];
    }];
    [request startAsynchronous];
}

/*------------------------------------------------------------------
 Procedure/Function Name: setImageAsynchronouslyFromUrl
 Created By: Pratik Prajapati
 Created Date: 18-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Asynchronous request with URL of an Image using
 ASIHTTPRequest and uses a 'Block' pattern. Also
 manages Activity incicator.
 ------------------------------------------------------------------*/

-(void)setImageAsynchronouslyFromUrl:(NSString *)imageUrl animated:(BOOL)isAnimated
{
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        UIImage *image = [[[UIImage alloc] initWithData:data] autorelease];
        [self removeActivityIndicatorFromImageView];
        if (image != nil)
        {
            self.image = image;
        }
        else
        {
            self.image = [UIImage imageNamed:kImgNameDefault];
        }
        
        if(isAnimated)
            [self animateImage];
        [self setContentMode:UIViewContentModeScaleAspectFit];
        
        id nextResponder = [[[[self superview] superview] superview] nextResponder];
        
        if (self.image)
        {
            dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
            dispatch_async(myQueue, ^{
                if ([nextResponder isKindOfClass:[ContentsListViewController class]])
                {
                    int numArticleIndex;
                    numArticleIndex = [self superview].tag;
                    
                    
                    if ([[(ContentsListViewController*)nextResponder strSelfCurrentContentType] isEqualToString:kstrLatest])
                    {
                        BOOL bIndexInRange;
                        bIndexInRange = FALSE;
                        
                        if([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews])
                        {
                            if (numArticleIndex == 0)
                            {
                                // Use Leading Dictionary
                                bIndexInRange = TRUE;
                            }
                            else
                            {
                                // Use Latest array to get currentDictionary
                                int numCount;
                                numCount = [[[WebserviceComunication sharedCommManager] arrLatestNews] count];
                                if (numArticleIndex -1 >= 0 && numArticleIndex - 1 < numCount)
                                {
                                    bIndexInRange = TRUE;
                                }
                            }
                        }
                        else
                        {
                            int numCount;
                            numCount = [[[WebserviceComunication sharedCommManager] arrLatestNews] count];
                            if (numArticleIndex >=0 && numArticleIndex < numCount)
                            {
                                bIndexInRange = TRUE;
                            }
                        }
                        
                        if (bIndexInRange)
                        {
                            
                            Contents *dictCurrentArticle;
                            
                            if([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews] && ![[WebserviceComunication sharedCommManager] isInFocus])
                            {
                                if (numArticleIndex == 0)
                                {
                                    // Use Leading Dictionary
                                    dictCurrentArticle = [[[WebserviceComunication sharedCommManager] arrLeadingNews] objectAtIndex:0];
                                }
                                else
                                {
                                    // Use Latest array to get currentDictionary
                                    // Investigate this ... it's -1 here but not in the contentlistview
                                    dictCurrentArticle = [[[WebserviceComunication sharedCommManager] arrLatestNews] objectAtIndex:numArticleIndex - 1];
                                }
                            } else {
                                dictCurrentArticle = [[[WebserviceComunication sharedCommManager] arrLatestNews] objectAtIndex:numArticleIndex];
                            }
                            
                            [dictCurrentArticle setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                            
                            if([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews] && ![[WebserviceComunication sharedCommManager] isInFocus])
                            {
                                if (numArticleIndex == 0)
                                {
                                    // Upate LeadingNews entry
                                    [[CacheDataManager sharedCacheManager] updateLeadingNews:dictCurrentArticle];
                                }
                                else
                                {
                                    // Use Latest array to get currentDictionary
                                    [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:dictCurrentArticle];
                                    [[[WebserviceComunication sharedCommManager] arrLatestNews] replaceObjectAtIndex:numArticleIndex - 1 withObject:[dictCurrentArticle autorelease]];
                                }
                            }
                            else
                            {
                                [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:dictCurrentArticle];
                                if (numArticleIndex >= 0 && numArticleIndex < [[[WebserviceComunication sharedCommManager] arrLatestNews] count])
                                {
                                    [[[WebserviceComunication sharedCommManager] arrLatestNews] replaceObjectAtIndex:numArticleIndex withObject:[dictCurrentArticle autorelease ]];
                                }
                            }
                        }
                    }
                    else if ([[(ContentsListViewController*)nextResponder strSelfCurrentContentType] isEqualToString:kstrVideo])
                    {
                        int numCount;
                        numCount = [[[WebserviceComunication sharedCommManager] arrVideo] count];
                        
                        if (numArticleIndex >= 0 && numArticleIndex < numCount)
                        {
                            
                            Contents *dictCurrentArticle;
                            
                            dictCurrentArticle = [[[WebserviceComunication sharedCommManager] arrVideo] objectAtIndex:numArticleIndex];
                            
                            [dictCurrentArticle setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                            
                            [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:dictCurrentArticle];
                            
                            if (numArticleIndex >= 0 && numArticleIndex < [[[WebserviceComunication sharedCommManager] arrVideo] count])
                            {
                                [[[WebserviceComunication sharedCommManager] arrVideo] replaceObjectAtIndex:numArticleIndex withObject:dictCurrentArticle];
                            }
                        }
                    }
                    else if([[(ContentsListViewController*)nextResponder strSelfCurrentContentType] isEqualToString:kstrImages])
                    {
                        int numCount;
                        numCount = [[[WebserviceComunication sharedCommManager] arrImages] count];
                        if (numArticleIndex >= 0 && numArticleIndex < numCount)
                        {
                            Contents *dictCurrentArticle;
                            
                            dictCurrentArticle = [[[WebserviceComunication sharedCommManager] arrImages] objectAtIndex:numArticleIndex];
                            
                            [dictCurrentArticle setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                            
                            [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:dictCurrentArticle];
                            if (numArticleIndex >= 0 && numArticleIndex < [[[WebserviceComunication sharedCommManager] arrImages] count])
                            {
                                [[[WebserviceComunication sharedCommManager] arrImages] replaceObjectAtIndex:numArticleIndex withObject:dictCurrentArticle];
                            }
                        }
                    }
                    else if ([[(ContentsListViewController*)nextResponder strSelfCurrentContentType] isEqualToString:kstrAudio])
                    {
                        int numCount;
                        numCount = [[[WebserviceComunication sharedCommManager] arrAudio] count];
                        if (numArticleIndex >= 0 && numArticleIndex < numCount)
                        {
                            Contents *dictCurrentArticle;
                            
                            dictCurrentArticle = [[[WebserviceComunication sharedCommManager] arrAudio] objectAtIndex:numArticleIndex];
                            
                            [dictCurrentArticle setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                            
                            [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:dictCurrentArticle];
                            if (numArticleIndex >= 0 && numArticleIndex < [[[WebserviceComunication sharedCommManager] arrAudio] count])
                            {
                            [[[WebserviceComunication sharedCommManager] arrAudio] replaceObjectAtIndex:numArticleIndex withObject:dictCurrentArticle];
                            }
                        }
                    }
                    else if ([[(ContentsListViewController*)nextResponder strSelfCurrentContentType] isEqualToString:kCONTENT_TITLE_SEARCH])
                    {
                        
                    }
                }
                else if ([nextResponder isKindOfClass:[StoryTimelineViewController class]])
                {
                    int numArticleIndex;
                    numArticleIndex = [self superview].tag;
                    
                    RelatedStoryAndTimeline *dictCurrentArticle;
                    
                    if([[[self superview] superview] isKindOfClass:[UIScrollView class]])
                    {
                        if([[[WebserviceComunication sharedCommManager] arrRelatedStory]count] > 0 && (numArticleIndex >=0 && numArticleIndex < [[[WebserviceComunication sharedCommManager] arrRelatedStory]count]))
                        {
                            dictCurrentArticle = [[[WebserviceComunication sharedCommManager] arrRelatedStory] objectAtIndex:numArticleIndex];
                            [dictCurrentArticle setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                            
                            [[CacheDataManager sharedCacheManager] UpdateRelatedStoryAndTimeLineByArticleId:dictCurrentArticle  withCurrentContentType:kstrRelated];
                            if (numArticleIndex >= 0 && numArticleIndex < [[[WebserviceComunication sharedCommManager] arrRelatedStory] count])
                            {
                                [[[WebserviceComunication sharedCommManager] arrRelatedStory] replaceObjectAtIndex:numArticleIndex withObject:dictCurrentArticle];
                            }
                        }
                    }
                }
                else if([nextResponder isKindOfClass:[UITableView class]] && [[[[nextResponder nextResponder] nextResponder] nextResponder] isKindOfClass:[StoryTimelineViewController class]])
                {
                    StoryTimelineViewController *storyView = (StoryTimelineViewController*)[[[nextResponder nextResponder] nextResponder] nextResponder];
                    RelatedStoryAndTimeline *dictCurrentArticle;
                    
                    if ([nextResponder tag] == 10)
                    {
                        NSIndexPath  *indexPath = [nextResponder indexPathForCell:(UITableViewCell*)[[[self superview] superview] superview]];
                        // Left Array
                        if([[storyView arrStoryTimelineDataForLeft] count] > 0)
                        {
                            dictCurrentArticle = [[[[storyView arrStoryTimelineDataForLeft] objectAtIndex:indexPath.section] valueForKey:[[[[storyView arrStoryTimelineDataForLeft] objectAtIndex:indexPath.section] allKeys] objectAtIndex:0]] objectAtIndex:indexPath.row];
                            
                            [dictCurrentArticle setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                            
                            [[CacheDataManager sharedCacheManager] UpdateRelatedStoryAndTimeLineByArticleId:dictCurrentArticle withCurrentContentType:kstrTimeline];
                            
                            NSPredicate *predicateFilter = [NSPredicate predicateWithFormat:@"ArticleID == %@",[dictCurrentArticle articleID]];
                            
                            NSArray *arrTemp = [[[WebserviceComunication sharedCommManager] arrStoryTimeline] filteredArrayUsingPredicate:predicateFilter];
                            int numArticleIndex = 0;
                            if([arrTemp count] > 0)
                            {
                                numArticleIndex = [[[WebserviceComunication sharedCommManager] arrStoryTimeline] indexOfObject:[arrTemp objectAtIndex:0]];
                            }
                            if (numArticleIndex >= 0 && numArticleIndex < [[[WebserviceComunication sharedCommManager] arrStoryTimeline] count])
                            {
                                [[[WebserviceComunication sharedCommManager] arrStoryTimeline] replaceObjectAtIndex:numArticleIndex withObject:dictCurrentArticle];
                            }
                        }
                    }
                    else
                    {
                        // Right Array
                        NSIndexPath  *indexPath = [nextResponder indexPathForCell:(UITableViewCell*)[[[self superview] superview] superview]];
                        // Left Array
                        if([[storyView arrStoryTimelineDataForRight] count] > 0)
                        {
                            dictCurrentArticle = [[[[storyView arrStoryTimelineDataForRight] objectAtIndex:indexPath.section] valueForKey:[[[[storyView arrStoryTimelineDataForRight] objectAtIndex:indexPath.section] allKeys] objectAtIndex:0]] objectAtIndex:indexPath.row];
                            
                            [dictCurrentArticle setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                            
                            [[CacheDataManager sharedCacheManager] UpdateRelatedStoryAndTimeLineByArticleId:dictCurrentArticle withCurrentContentType:kstrTimeline];
                            
                            NSPredicate *predicateFilter = [NSPredicate predicateWithFormat:@"ArticleID == %@",[dictCurrentArticle articleID]];
                            
                            NSArray *arrTemp = [[[WebserviceComunication sharedCommManager] arrStoryTimeline] filteredArrayUsingPredicate:predicateFilter];
                            int numArticleIndex = 0;
                            if([arrTemp count] > 0)
                            {
                                numArticleIndex = [[[WebserviceComunication sharedCommManager] arrStoryTimeline] indexOfObject:[arrTemp objectAtIndex:0]];
                            }
                            if (numArticleIndex >= 0 && numArticleIndex < [[[WebserviceComunication sharedCommManager] arrStoryTimeline] count])
                            {
                                [[[WebserviceComunication sharedCommManager] arrStoryTimeline] replaceObjectAtIndex:numArticleIndex withObject:dictCurrentArticle];
                            }
                            
                        }
                    }
                }
                else if([nextResponder isKindOfClass:[UIView class]] && [[nextResponder nextResponder] isKindOfClass:[SearchNewsListViewController class]])
                {
                    SearchNewsListViewController *searchView = (SearchNewsListViewController*)[nextResponder nextResponder];
                    Contents *dictCurrentArticle;
                    
                    NSIndexPath  *indexPath = [searchView.tblSearchResults indexPathForCell:(UITableViewCell*)[[self superview] superview]];
                    
                    if([[[WebserviceComunication sharedCommManager] arrSearchNews] count] > 0)
                    {
                        dictCurrentArticle = [[[WebserviceComunication sharedCommManager] arrSearchNews] objectAtIndex:indexPath.row];
                        
                        [dictCurrentArticle setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                        
                        if (indexPath.row >= 0 && indexPath.row < [[[WebserviceComunication sharedCommManager] arrSearchNews] count])
                        {
                            [[[WebserviceComunication sharedCommManager] arrSearchNews] replaceObjectAtIndex:indexPath.row withObject:dictCurrentArticle];
                        }
                    }
                }
                else if([nextResponder isKindOfClass:[UIView class]] && [[nextResponder nextResponder] isKindOfClass:[ContentDetailViewController class]])
                {
                    ContentDetailViewController *detailView = (ContentDetailViewController*)[nextResponder nextResponder];
                    
                    NSMutableArray *arrTemp;
                    
                    if (detailView.parentContentType == ParentContentTypeAudio)
                    {
                        arrTemp = [[[WebserviceComunication sharedCommManager] arrAudio] mutableCopy];
                    }
                    else if(detailView.parentContentType == ParentContentTypeVideo)
                    {
                        arrTemp = [[[WebserviceComunication sharedCommManager] arrVideo] mutableCopy];
                    }
                    else if(detailView.parentContentType == ParentContentTypeImages)
                    {
                        arrTemp = [[[WebserviceComunication sharedCommManager] arrImages] mutableCopy];
                    }
                    else if(detailView.parentContentType == ParentContentTypeLatestNews)
                    {
                        arrTemp = [[[WebserviceComunication sharedCommManager] arrLatestNews] mutableCopy];
                    }
                    else if(detailView.parentContentType == ParentContentTypeLeadingNews)
                    {
                        arrTemp = [NSMutableArray arrayWithObject:[[[WebserviceComunication sharedCommManager] arrLeadingNews] mutableCopy]];
                    }
                    else if(detailView.parentContentType == ParentContentTypeSearchedNews)
                    {
                        arrTemp = [[[WebserviceComunication sharedCommManager] arrSearchNews] mutableCopy];
                    }
                    else if(detailView.parentContentType == ParentContentTypeStoryTimeline)
                    {
                        arrTemp = [[[WebserviceComunication sharedCommManager] arrLastStoryTimeline] mutableCopy];
                    }
                    else if(detailView.parentContentType == ParentContentTypeRelatedStory)
                    {
                        arrTemp = [[[WebserviceComunication sharedCommManager] arrLastRelatedStory] mutableCopy];
                    } else {
                        return;
                    }
                    
                    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat:@"ArticleID == %@",[detailView.dicArticleDetail articleID]];
                    
                    NSArray *arrArticle = [arrTemp filteredArrayUsingPredicate:predicateFilter];
                    
                    int numArticleIndex = 0;
                    if([arrArticle count] >0)
                    {
                        numArticleIndex = [arrTemp indexOfObject:[arrArticle objectAtIndex:0]];
                    }
                    
                    int numCount;
                    numCount = [arrTemp count];
                    
                    if(numArticleIndex >= 0 && numArticleIndex < numCount)
                    {
                        [detailView.dicArticleDetail setThumbnilImageUrlData:UIImagePNGRepresentation(self.image)];
                        if (numArticleIndex >= 0 && numArticleIndex < [arrTemp count])
                        {
                            [arrTemp replaceObjectAtIndex:numArticleIndex withObject:detailView.dicArticleDetail];
                        }
                        if (detailView.parentContentType == ParentContentTypeAudio)
                        {
                            
                            [[WebserviceComunication sharedCommManager] setArrAudio:[arrTemp mutableCopy]];
                            [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[arrTemp objectAtIndex:numArticleIndex]];
                            
                        }
                        else if(detailView.parentContentType == ParentContentTypeVideo)
                        {
                            [[WebserviceComunication sharedCommManager] setArrVideo:[arrTemp mutableCopy]];
                            [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[arrTemp objectAtIndex:numArticleIndex]];
                        }
                        else if(detailView.parentContentType == ParentContentTypeImages)
                        {
                            [[WebserviceComunication sharedCommManager] setArrImages:[arrTemp mutableCopy]];
                            [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[arrTemp objectAtIndex:numArticleIndex]];
                            
                        }
                        else if(detailView.parentContentType == ParentContentTypeLatestNews)
                        {
                            // TODO - WAYNE!! IMPORTANT - Update this method to update the current entry in coredata and return to array
//                            [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[arrTemp objectAtIndex:numArticleIndex]];
//                            [[WebserviceComunication sharedCommManager] setArrLatestNews:[arrTemp mutableCopy]];
                        }
                        else if(detailView.parentContentType == ParentContentTypeLeadingNews)
                        {
                            // TODO - Does this need fixing? When does this even occur ...
//                            [[CacheDataManager sharedCacheManager] updateLeadingNews:[arrTemp objectAtIndex:0]];
//                            [[WebserviceComunication sharedCommManager] setDictLeadingNews:[arrTemp objectAtIndex:0]];
                        }
                        else if(detailView.parentContentType == ParentContentTypeSearchedNews)
                        {
                            [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[arrTemp objectAtIndex:numArticleIndex]];
                            [[WebserviceComunication sharedCommManager] setArrSearchNews:[arrTemp mutableCopy]];
                        }
                        else if(detailView.parentContentType == ParentContentTypeStoryTimeline)
                        {
                            [[WebserviceComunication sharedCommManager] setArrLastStoryTimeline:arrTemp];
                            
                            [[CacheDataManager sharedCacheManager] UpdateRelatedStoryAndTimeLineByArticleId:[arrTemp objectAtIndex:numArticleIndex] withCurrentContentType:kstrTimeline];
                            
                        }
                        else if(detailView.parentContentType == ParentContentTypeRelatedStory)
                        {
                            [[WebserviceComunication sharedCommManager] setArrLastRelatedStory:[arrTemp mutableCopy]];
                            
                            [[CacheDataManager sharedCacheManager] UpdateRelatedStoryAndTimeLineByArticleId:[arrTemp objectAtIndex:numArticleIndex] withCurrentContentType:kstrRelated];
                        }
                    }
                }
            });
        }
    }];
    [request setFailedBlock:^{
        [self removeActivityIndicatorFromImageView];
    }];
    [request startAsynchronous];
}

/*------------------------------------------------------------------
 Procedure/Function Name: setImageAsynchronouslyFromUrl
 Created By: Pratik Prajapati
 Created Date: 19-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Animates image when it has been downloaded asynchronously
 and it's ready to show.
 ------------------------------------------------------------------*/

-(void)animateImage
{
    self.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.7];
    self.alpha = 1;
    [UIView commitAnimations];
}

/*------------------------------------------------------------------
 Procedure/Function Name: setImageAsynchronouslyFromUrl
 Created By: Pratik Prajapati
 Created Date: 19-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Shows Activity Indicator on Image-view when an Image is
 being downloaded in background.
 ------------------------------------------------------------------*/

-(void)showActivityIndicatorToImageView
{
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingIndicator.hidesWhenStopped = TRUE;
    [self addSubview:loadingIndicator];
    [loadingIndicator setFrame:CGRectMake(self.frame.size.width/2-15,self.frame.size.height/2-15,30,30)];
    [loadingIndicator startAnimating];
    [loadingIndicator release];
}

/*------------------------------------------------------------------
 Procedure/Function Name: setImageAsynchronouslyFromUrl
 Created By: Pratik Prajapati
 Created Date: 19-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Removes Activity Indicator from Image-view when an Image
 has been downloaded and it's ready to show.
 ------------------------------------------------------------------*/

-(void)removeActivityIndicatorFromImageView
{
    for(UIView *view in self.subviews){
        if([view isKindOfClass:[UIActivityIndicatorView class]]){
            UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)view;
            [indicator removeFromSuperview];
        }
    }
}

@end



# pragma mark
# pragma mark

@implementation NSDictionary (XMLReaderNavigation)

/*------------------------------------------------------------------
 Procedure/Function Name: retrieveForPath
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Accepts path of object seperated by '.' we want to filter
 from NSDictionary and enumerates it.
 ------------------------------------------------------------------*/

- (id)retrieveForPath:(NSString *)navPath
{
    // Split path on dots
    NSArray *pathItems = [navPath componentsSeparatedByString:@"."];
    
    // Enumerate through array
    NSEnumerator *e = [pathItems objectEnumerator];
    NSString *path;
    
    // Set first branch from self
    id branch = [self objectForKey:[e nextObject]];
    int count = 1;
    
    while ((path = [e nextObject])){
        // Check if this branch is an NSArray
        if([branch isKindOfClass:[NSArray class]]){
            if ([path isEqualToString:@"last"]){
                branch = [branch lastObject];
            }
            else{
                if ([branch count] > [path intValue]){
                    branch = [branch objectAtIndex:[path intValue]];
                }
                else{
                    branch = nil;
                }
            }
        }
        else{
            // branch is assumed to be an NSDictionary
            branch = [branch objectForKey:path];
        }
        
        count++;
    }
    
    return branch;
}

@end

/**************************************************************************************************************************************/

# pragma mark
# pragma mark

@implementation WebRequestActivityView

@synthesize borderView,showNetworkActivityIndicator,originalView,labelWidth,activityIndicator,activityLabel;
static WebRequestActivityView *webRequestActivityView = nil;

# pragma mark
# pragma mark - WebRequestActivityView - Show

/*------------------------------------------------------------------
 Procedure/Function Name: currentActivityView
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Returns the currently displayed Activity view, or nil
 if there isn't any.
 ------------------------------------------------------------------*/

+ (WebRequestActivityView *)currentActivityView;
{
    return webRequestActivityView;
}

/*------------------------------------------------------------------
 Procedure/Function Name: activityViewForView
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Creates an instance of 'WebRequestActivityView' interface
 and calls constructor which initializes a View in which
 we want to add Loading view, Text and Width of label.
 ------------------------------------------------------------------*/

+ (WebRequestActivityView *)activityViewForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth
{
    // Immediately remove any existing activity view:
    if (webRequestActivityView)
        [self removeView];
    
    // Remember the new view (so this is a singleton):
    webRequestActivityView = [[self alloc] initForView:addToView withLabel:labelText width:aLabelWidth];
    
    return webRequestActivityView;
}

/*------------------------------------------------------------------
 Procedure/Function Name: initForView
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Constructor which configures the Activity view having
 Background view, Bordered view, Label using the specified
 label text and width and Loading indicator. Adds this
 Activity view as a subview of the specified view with
 covering keyboard.
 ------------------------------------------------------------------*/

- (WebRequestActivityView *)initForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;
{
	if (!(self = [super initWithFrame:CGRectZero]))
		return nil;
	
    self.originalView = addToView;
    addToView = [self viewForView:addToView];
    
    // Configure this view (the background) and its subviews:
    self.labelWidth = aLabelWidth;
    [self setupBackground];
    self.borderView = [self makeBorderView];
    self.activityIndicator = [self makeActivityIndicator];
    self.activityLabel = [self makeActivityLabelWithText:labelText];
    
	// Assemble the subviews.
	[addToView addSubview:self];
    [self addSubview:self.borderView];
    [self.borderView addSubview:self.activityIndicator];
    [self.borderView addSubview:self.activityLabel];
    
	// Animates the view.
	[self animateShow];
    
	return self;
}

/*------------------------------------------------------------------
 Procedure/Function Name: viewForView
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Returns a view to which we need to add the Activity view.
 If there is a keyboard displayed, the view is changed to
 the keyboard's superview.
 ------------------------------------------------------------------*/

- (UIView *)viewForView:(UIView *)view;
{
    UIView *keyboardView = [self getKeyboardView];
    
    if (keyboardView)
        view = keyboardView.superview;
    
    return view;
}

/*------------------------------------------------------------------
 Procedure/Function Name: getKeyboardView
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Checks if keyboard is displayed. If it is displayed, then
 returns it. Otherwise returns nothing.
 ------------------------------------------------------------------*/

- (UIView *)getKeyboardView;
{
	NSArray *windows = [[UIApplication sharedApplication] windows];
	for (UIWindow *window in [windows reverseObjectEnumerator])
	{
		for (UIView *view in [window subviews])
		{
            // UIPeripheralHostView is used from iOS 4.0, UIKeyboard was used in previous versions:
			if (!strcmp(object_getClassName(view), "UIPeripheralHostView") || !strcmp(object_getClassName(view), "UIKeyboard"))
			{
				return view;
			}
		}
	}
	
	return nil;
}

/*------------------------------------------------------------------
 Procedure/Function Name: setupBackground
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Sets the Alpha level of Background view of Activity view.
 Background view is 'self' in our case.
 ------------------------------------------------------------------*/

- (void)setupBackground;
{
	self.opaque = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
}

/*------------------------------------------------------------------
 Procedure/Function Name: makeBorderView
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Returns a new view to contain the Activity indicator and
 Label. Makes it semi-transparent rounded rectangle.
 ------------------------------------------------------------------*/

- (UIView *)makeBorderView;
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.opaque = NO;
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
    view.layer.cornerRadius = 10.0;
    return view;
}

/*------------------------------------------------------------------
 Procedure/Function Name: makeActivityIndicator
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Returns a new Activity indicator view. It uses a large
 white indicator.
 ------------------------------------------------------------------*/

- (UIActivityIndicatorView *)makeActivityIndicator;
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator startAnimating];
    return indicator;
}

/*------------------------------------------------------------------
 Procedure/Function Name: makeActivityLabelWithText
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Returns a new Activity label. It uses centered white text.
 ------------------------------------------------------------------*/

- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:kFontOpenSansSemiBold size:[UIFont systemFontSize]];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.text = labelText;
    
    return label;
}

/*------------------------------------------------------------------
 Procedure/Function Name: animateShow
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Animates the Activity view. It fades in the background
 and zooms from a large size.
 ------------------------------------------------------------------*/

- (void)animateShow;
{
    self.alpha = 0.0;
    self.borderView.transform = CGAffineTransformMakeScale(3.0, 3.0);
    
	[UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:0.3];            // Uncomment to see the animation in slow motion
	
    self.borderView.transform = CGAffineTransformIdentity;
    self.alpha = 1.0;
    
	[UIView commitAnimations];
}



# pragma mark
# pragma mark - WebRequestActivityView - Layout

/*------------------------------------------------------------------
 Procedure/Function Name: layoutSubviews
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Set positions and frames of various views that make up the
 activity view, including after rotation.
 ------------------------------------------------------------------*/

- (void)layoutSubviews;
{
    // If we're animating a transform, don't lay out now, as can't use the frame property when transforming:
    if (!CGAffineTransformIsIdentity(self.borderView.transform))
        return;
    
    self.frame = [self enclosingFrame];
    
    CGSize maxSize = CGSizeMake(260, 400);
    CGSize textSize = [self.activityLabel.text sizeWithFont:[UIFont fontWithName:kFontOpenSansSemiBold size:[UIFont systemFontSize]] constrainedToSize:maxSize lineBreakMode:self.activityLabel.lineBreakMode];
    
    // Use the fixed width if one is specified:
    if (self.labelWidth > 10)
        textSize.width = self.labelWidth;
    
    // Require that the label be at least as wide as the indicator, since that width is used for the border view:
    if (textSize.width < self.activityIndicator.frame.size.width)
        textSize.width = self.activityIndicator.frame.size.width + 10.0;
    
    // If there's no label text, don't need to allow height for it:
    if (self.activityLabel.text.length == 0)
        textSize.height = 0.0;
    
    self.activityLabel.frame = CGRectMake(self.activityLabel.frame.origin.x, self.activityLabel.frame.origin.y, textSize.width, textSize.height);
    
    // Calculate the size and position for the border view: with the indicator vertically above the label, and centered in the receiver:
	CGRect borderFrame = CGRectZero;
    borderFrame.size.width = textSize.width + 30.0;
    borderFrame.size.height = self.activityIndicator.frame.size.height + textSize.height + 40.0;
    borderFrame.origin.x = floor(0.5 * (self.frame.size.width - borderFrame.size.width));
    borderFrame.origin.y = floor(0.5 * (self.frame.size.height - borderFrame.size.height));
    self.borderView.frame = borderFrame;
	
    // Calculate the position of the indicator: horizontally centered and near the top of the border view:
    CGRect indicatorFrame = self.activityIndicator.frame;
	indicatorFrame.origin.x = 0.5 * (borderFrame.size.width - indicatorFrame.size.width);
	indicatorFrame.origin.y = 20.0;
    self.activityIndicator.frame = indicatorFrame;
    
    // Calculate the position of the label: horizontally centered and near the bottom of the border view:
	CGRect labelFrame = self.activityLabel.frame;
    labelFrame.origin.x = floor(0.5 * (borderFrame.size.width - labelFrame.size.width));
	labelFrame.origin.y = borderFrame.size.height - labelFrame.size.height - 10.0;
    self.activityLabel.frame = labelFrame;
}

/*------------------------------------------------------------------
 Procedure/Function Name: enclosingFrame
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Returns the frame to use for the Activity view. If there
 is a keyboard displayed, the frame is changed to cover
 the keyboard also.
 ------------------------------------------------------------------*/

- (CGRect)enclosingFrame;
{
    CGRect frame = self.superview.bounds;
    
    if (self.superview != self.originalView)
        frame = [self.originalView convertRect:self.originalView.bounds toView:self.superview];
    
    return frame;
}

# pragma mark
# pragma mark - WebRequestActivityView - Remove

/*------------------------------------------------------------------
 Procedure/Function Name: removeViewAnimated
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Animates the Activity view from the superview and
 releases it. If it is not animating, removes and
 releases it immediately.
 ------------------------------------------------------------------*/

+ (void)removeViewAnimated:(BOOL)animated;
{
    if (!webRequestActivityView)
        return;
    
    if (animated)
        [webRequestActivityView animateRemove];
    else
        [[self class] removeView];
}

/*------------------------------------------------------------------
 Procedure/Function Name: animateRemove
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Animates the Activity view out, avoids the removal until
 the animation is complete. It fades out the background
 and zooms in.
 ------------------------------------------------------------------*/

- (void)animateRemove;
{
    if (self.showNetworkActivityIndicator) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
        
    self.borderView.transform = CGAffineTransformIdentity;
    
	[UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:0.3];            // Uncomment to see the animation in slow motion
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
	
    self.borderView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.alpha = 0.0;
    
	[UIView commitAnimations];
}

/*------------------------------------------------------------------
 Procedure/Function Name: removeAnimationDidStop
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Called when animation for removing Activity view is
 finished.
 ------------------------------------------------------------------*/

- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    [[self class] removeView];
}

/*------------------------------------------------------------------
 Procedure/Function Name: removeView
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Immediately removes and releases the Activity view
 without any animation.
 ------------------------------------------------------------------*/

+ (void)removeView;
{
    if (!webRequestActivityView)
        return;
    
    if (webRequestActivityView.showNetworkActivityIndicator)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [webRequestActivityView removeFromSuperview];
    webRequestActivityView = nil;
}

/*------------------------------------------------------------------
 Procedure/Function Name: setShowNetworkActivityIndicator
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Whether to show the Network activity indicator in the
 status bar. Set to YES if the activity is Network related.
 This can be toggled on and off as desired while the
 activity view is visible (e.g. have it on while fetching
 data, then disable it while parsing it).
 ------------------------------------------------------------------*/

- (void)setShowNetworkActivityIndicator:(BOOL)show;
{
    showNetworkActivityIndicator = show;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
}

- (void)dealloc;
{
    if ([webRequestActivityView isEqual:self])
        webRequestActivityView = nil;
    
    [super dealloc];
}

@end

/**************************************************************************************************************************************/

NSString *const kXMLReaderTextNodeKey = @"text";

# pragma mark
# pragma mark

@implementation WebAPIRequest

@synthesize requestTag;
@synthesize strMessage;
@synthesize userAuthRequired;
@synthesize requestArray;
@synthesize delegate;

-(NSMutableArray *)requestArray
{
    if(!requestArray)
    {
        requestArray = [[NSMutableArray alloc] init];
    }
    return requestArray;
}

# pragma mark
# pragma mark - ASIHTTPRequest delegate methods

/*------------------------------------------------------------------
 Procedure/Function Name: authenticationNeededForRequest
 Created By: Pratik Prajapati
 Created Date: 10-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: ASIHTTPRequest delegate method which is called if you
 are connecting to a server that requires authentication.
 ------------------------------------------------------------------*/

- (void)authenticationNeededForRequest:(ASIHTTPRequest *)theRequest
{
    [self hideIndicator];
    
    
    if(userAuthRequired){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Login" message:[theRequest authenticationRealm] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
//        [alertView addTextFieldWithValue:@"" label:@"Username"];
//        [alertView addTextFieldWithValue:@"" label:@"Password"];
        [alertView show];
        [alertView release];
    }
    else{
        [self.delegate setItems:nil errorMessage:@"Authentification failed." error:theRequest.error withTag:requestTag];
        // TODO: Break Loop
        responseParsingDone = TRUE;
        
    }
}

/*------------------------------------------------------------------
 Procedure/Function Name: alertView:clickedButtonAtIndex
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: If user presses 'Cancel', we're cancelling request and
 "requestFailed" method will be called later on. If user
 enters credentials then retry with provided credentials.
 ------------------------------------------------------------------*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0) {
        // Cancel the request.
        [WebRequestAuth cancelAuthentication];
    }
    
    else if(buttonIndex==1){
        // Countinue Request with entered Credentials.
        [self showIndicatorWithText:strMessage];
        [WebRequestAuth setUsername:[[alertView textFieldAtIndex:0] text]];
        [WebRequestAuth setPassword:[[alertView textFieldAtIndex:1] text]];
        [WebRequestAuth retryUsingSuppliedCredentials];
    }
}



//- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;
//{
//    [delegate gotURLCheckingResponse:request];
//}

/*------------------------------------------------------------------
 Procedure/Function Name: requestFinished
 Created By: Pratik Prajapati
 Created Date: 23-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: ASIHTTPRequest delegate method which is called when
 connection is established and request is completed.
 It sends 'ASIHTTPRequest' object by which I have checked
 response status.
 ------------------------------------------------------------------*/

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [requestArray removeObject:request];
    
    if(request.isCancelled) {
        DLog(@"REQUEST CANCEL - %d",requestTag);
        [self.delegate requestCancel:nil errorMessage:nil withTag:requestTag];
        return;
    }
    
    NSString *contentType = [[request responseHeaders] objectForKey:@"Content-Type"];
    
//    DLog(@"REQUEST COMPLETE - Type : %@", contentType);
//    DLog(@"REQUEST COMPLETE - Code : %d", request.responseStatusCode);
//    const char *bar = [request.responseString UTF8String];
//    NSString *safestring = [NSString stringWithUTF8String:bar];
//    DLog(@"REQUEST = %@", safestring);
//    DLog(@"REQUEST = %@", request.responseString);
    
    [delegate gotURLCheckingResponse:request];
    
    // Detect whether response is XML or JSON.
    // this just defaults to XML
    responseType = XML;
    if([contentType isEqualToString:@"application/json; charset=utf-8"]){
        responseType = JSON;
    }
    
    if(request.responseStatusCode == 500) {
        DLog(@"WebAPIRequest : Internal Server Error - Prompt and Exit");
        [self hideIndicator];
        [self.delegate errorHandler:@"response" title:kstrInternalServerError error:request.error message:kstrInternalServerErrorMessage];
    }
    
    if(request.responseStatusCode == 503) {
        DLog(@"WebAPIRequest : Internal Server Error - Prompt and Exit");
        [self hideIndicator];
        [self.delegate errorHandler:@"response" title:kstrInternalServerError error:request.error message:kstrInternalServerErrorMessage];
    }
    
    if(request.responseStatusCode == 400) {
        [self hideIndicator];
        ////DLog(@"Invalid code.");
    }
    
    else if(request.responseStatusCode == 403) {
        [self hideIndicator];
        ////DLog(@"Code already used.");
    }
    
    else if(request.responseStatusCode == 200) {
        // Parse response in Background Thread.
        NSData *responseData = [request responseData];
        [self performSelectorInBackground:@selector(parseResponse:) withObject:responseData];
    } else {
        [self hideIndicator];
        DLog(@"Unexpected error occured.");
        [self.delegate setItems:nil errorMessage:@"Unexpected error occured." error:request.error withTag:requestTag];
        responseParsingDone = TRUE;
    }
}

/*------------------------------------------------------------------
 Procedure/Function Name: requestFailed
 Created By: Pratik Prajapati
 Created Date: 23-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: ASIHTTPRequest delegate method which is called when
 it finds any connection issue or an error during
 downliading from server.
 (time out, no connection, connection interrupted, ...)
 ------------------------------------------------------------------*/

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    [self.delegate gotURLCheckingResponse:request];
    
    DLog(@"%@",error.localizedDescription);
    
    [self hideIndicator];
    [self.delegate setItems:nil errorMessage:error.localizedDescription error:request.error withTag:requestTag];
    
    // TODO: Break Loop
    responseParsingDone = TRUE;
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    [delegate gotURLCheckingResponse:request];
}


# pragma mark
# pragma mark - Other methods implementation

/*------------------------------------------------------------------
 Procedure/Function Name: parseResponse
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: This method is called when downloading of data is
 completed. It parses the data by detecting whether
 the response is of type XML or JSON. Prsing is done
 in background thread.
 ------------------------------------------------------------------*/

-(void)parseResponse:(NSData *)dataResponse;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
//    NSString *strResponse = [[[NSString alloc]initWithData:dataResponse encoding:NSUTF8StringEncoding]autorelease];
//    strResponse = [strResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    DLog(@"RESPONSE \n\n%@\n\n",strResponse);
    
    // Parse data using appropriate parser.
    if(responseType == XML){
        [WebRequestActivityView currentActivityView].activityLabel.text = @"Parsing XML...";
        dataObject = [self objectWithData:dataResponse];
//        DLog(@"-------------------------------------------");
//        DLog(@"%@",[(NSDictionary *)dataObject description]);
//        DLog(@"-------------------------------------------");
    }
    
    else if(responseType == JSON)
    {
        NSString *strVersion = [[UIDevice currentDevice] systemVersion];
        float version = [strVersion floatValue];
        
        NSError *jsonError = nil;
        ////DLog(@"%@",[dataResponse description]);
        [WebRequestActivityView currentActivityView].activityLabel.text = @"Parsing JSON...";
        
        if(version >= _IOS_VERSION_MIN_REQUIRED_NSJON){
            dataObject = [NSJSONSerialization JSONObjectWithData:dataResponse options:kNilOptions error:&jsonError];
        }
        else{
            dataObject = [dataResponse objectFromJSONDataWithParseOptions:kNilOptions error:&jsonError];
        }
        
        ////DLog(@"%@",[dataObject description]);
        
        if(jsonError != nil){
            ////DLog(@"JSON Error: %@",[jsonError description]);
            return;
        }
        
        else{
            if ([dataObject isKindOfClass:[NSArray class]]){
//                NSArray *jsonArray = (NSArray *)dataObject;
                ////DLog(@"-------------------------------------------");
                ////DLog(@"%@",jsonArray);
                ////DLog(@"-------------------------------------------");
                ////DLog(@"%d",[jsonArray count]);
            }
            else{
//                NSDictionary *jsonDictionary = (NSDictionary *)dataObject;
                ////DLog(@"-------------------------------------------");
                ////DLog(@"%@",jsonDictionary);
                ////DLog(@"-------------------------------------------");
            }
        }
    }
    [self performSelectorOnMainThread:@selector(sendDataToCallerClass:) withObject:dataObject waitUntilDone:YES];
    [pool release];
}

/*------------------------------------------------------------------
 Procedure/Function Name: sendDataToCallerClass
 Created By: Pratik Prajapati
 Created Date: 27-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: This method is called after Parsing of response is done
 in background thread. It hides the Indicator and calls
 the method of Caller class to post data.
 ------------------------------------------------------------------*/

-(void)sendDataToCallerClass:(NSObject *)items
{
    DLog(@"Sending data with tag %i",requestTag);
    [self.delegate setItems:items errorMessage:nil error:nil withTag:requestTag];
    responseParsingDone = TRUE;
}

/*------------------------------------------------------------------
 Procedure/Function Name: showIndicatorWithText, hideIndicator
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: This method shows custom Loading indicator with provided
 text and the method following it has been used to hide
 the indicator.
 ------------------------------------------------------------------*/

-(void)showIndicatorWithText:(NSString *)text
{
    // Start Indicator...
    //    UIViewController *vc = (UIViewController *)self.delegate;
    //    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIView *viewToUse = [[[[UIApplication sharedApplication ] delegate] window] rootViewController].view;
    if(text == nil)
        [WebRequestActivityView activityViewForView:viewToUse withLabel:@"Please wait..." width:150]; // Pass '0' to set width dynamic based on Text.
    else
        [WebRequestActivityView activityViewForView:viewToUse withLabel:text width:0];
    [WebRequestActivityView currentActivityView].showNetworkActivityIndicator = YES;
}

-(void)hideIndicator
{
    // Stop Indicator...
    [WebRequestActivityView removeViewAnimated:YES];
}


#pragma mark
#pragma mark - XML Parsing methods

/*------------------------------------------------------------------
 Procedure/Function Name: initWithError
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: Constructor which initialize NSError object.
 ------------------------------------------------------------------*/

- (id)initWithError:(NSError **)error
{
    if (self = [super init]){
        errorPointer = error;
    }
    return self;
}

/*------------------------------------------------------------------
 Procedure/Function Name: dictionaryForXMLData
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: This method receives response in the form of NSData and
 parses it and returns it as a NSDictionary object.
 ------------------------------------------------------------------*/

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error
{
    WebAPIRequest *dynamicParser = [[WebAPIRequest alloc] initWithError:error];
    NSDictionary *rootDictionary = [dynamicParser objectWithData:data];
    [dynamicParser release];
    return rootDictionary;
}

/*------------------------------------------------------------------
 Procedure/Function Name: objectWithData
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: This method takes responsibility of parse the data using
 NSXMLParser class.
 ------------------------------------------------------------------*/

- (NSDictionary *)objectWithData:(NSData *)data
{
    dictionaryStack = [[NSMutableArray alloc] init] ;
    textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [dictionaryStack addObject:[NSMutableDictionary dictionary]];
        
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    Boolean success = [parser parse];
	[parser release];
    
    // Return the stack's root dictionary on success
    if (success){
        NSDictionary *resultDict = [dictionaryStack objectAtIndex:0];
        return resultDict;
    } else {
        DLog(@"Something did not get parsed...");
    }
    
    [dictionaryStack release]; // Calling these above crash app ...
    [textInProgress release];
    
    return nil;
}

# pragma mark
# pragma mark - NSXMLParserDelegate methods

/*------------------------------------------------------------------
 Procedure/Function Name: didStartElement
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: NSXMLParser delegate method called when any element has
 been found. Each time a new tag is encountered, a child
 dictionary is pushed onto the stack. Each time a tag is
 closed, the dictionary is popped off the stack.
 ------------------------------------------------------------------*/

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [dictionaryStack lastObject];
    
    // Create the child dictionary for the new element
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    
    // Initialize child dictionary with the attributes, prefixed with '@'
    for (NSString *key in attributeDict) {
        [childDict setValue:[attributeDict objectForKey:key]
                     forKey:key];
    }
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    
    if (existingValue){
        NSMutableArray *array = nil;
        
        if ([existingValue isKindOfClass:[NSMutableArray class]]){
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else{
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else{
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [dictionaryStack addObject:childDict];
}

/*------------------------------------------------------------------
 Procedure/Function Name: didEndElement
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: NSXMLParser delegate method called when any end tag has
 been found. It initialize our model objects from the XML
 as elements are popped in this method.
 ------------------------------------------------------------------*/

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [dictionaryStack lastObject];
    
    // Pop the current dict
    [dictionaryStack removeLastObject];
    
    // Set the text property
    if ([textInProgress length] > 0){
        if ([dictInProgress count] > 0){
            [dictInProgress setObject:textInProgress forKey:kXMLReaderTextNodeKey];
        }
        else{
            // Given that there will only ever be a single value in this dictionary, let's replace the dictionary with a simple string.
            NSMutableDictionary *parentDict = [dictionaryStack lastObject];
            id parentObject = [parentDict objectForKey:elementName];
            
            // Parent is an Array
            if ([parentObject isKindOfClass:[NSArray class]]){
                [parentObject removeLastObject];
                [parentObject addObject:textInProgress];
            }
            
            // Parent is a Dictionary
            else{
                [parentDict removeObjectForKey:elementName];
                [parentDict setObject:textInProgress forKey:elementName];
            }
        }
        
        // Reset the text
        [textInProgress release];
        textInProgress = [[NSMutableString alloc] init];
    }
    
    // If there was no value for the tag, and no attribute, then remove it from the dictionary.
    else if ([dictInProgress count] == 0){
        NSMutableDictionary *parentDict = [dictionaryStack lastObject];
        [parentDict removeObjectForKey:elementName];
    }
}

/*------------------------------------------------------------------
 Procedure/Function Name: foundCharacters
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: NSXMLParser delegate method which appends encountered
 characters to current NSString object which is in
 parsing progress.
 ------------------------------------------------------------------*/

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
//    DLog(@"%@",string);
//	[textInProgress appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [textInProgress appendString:string];
}

/*------------------------------------------------------------------
 Procedure/Function Name: parseErrorOccurred
 Created By: Pratik Prajapati
 Created Date: 26-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: NSXMLParser delegate method which is called in case of
 any error encountered during parsing.
 ------------------------------------------------------------------*/

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser's error object
    if (errorPointer) {
        errorPointer = parseError;
    }
}


//************************************************************************************************************************************//


# pragma mark
# pragma mark - WebRequest method

/*------------------------------------------------------------------
 Procedure/Function Name: initWithDelegate
 Created By: Pratik Prajapati
 Created Date: 10-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Constructor which sets Delegate object of current class.
 So that we can callback to that class when perticular
 event is done.
 ------------------------------------------------------------------*/

-(id)initWithDelegate:(id)aDelegate
{
    if(self=[super init])
    {
        self.delegate = aDelegate;
    }
    return self;
}

/*------------------------------------------------------------------
 Procedure/Function Name: webRequestWithUrl
 Created By: Pratik Prajapati
 Created Date: 23-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: Creates URL request using ASIFormDataRequest.'Get' in
 this case so we do not have to pass any parameter.
 ------------------------------------------------------------------*/

-(void)webRequestWithUrl:(NSURL *)url
{
    [self showIndicatorWithText:strMessage];
    
    ////DLog(@"GET Method");
    ASIHTTPRequest *WebRequest = [ASIHTTPRequest requestWithURL:url];
    [WebRequest setShouldPresentAuthenticationDialog:YES];
    [WebRequest setDelegate:self];
    [WebRequest startAsynchronous];
}

/*------------------------------------------------------------------
 Procedure/Function Name: webRequestWithUrl
 Created By: Pratik Prajapati
 Created Date: 23-Nov-2012
 Modified By: -
 Modified Date: -
 Purpose: Creates URL request using ASIFormDataRequest.'Post'
 in this case so we have to pass a Dictionary having
 all post parameters as 'key' and parameters values
 as 'value'. If it's nil, request will be 'Get'.
 ------------------------------------------------------------------*/

-(void)webRequestWithUrl:(NSURL *)url withPostValues:(NSDictionary *)postDic
{
    [self showIndicatorWithText:strMessage];
    
    if(postDic == nil){
        DLog(@"GET Method");
        ASIHTTPRequest *WebRequest = [ASIHTTPRequest requestWithURL:url];
        [WebRequest setShouldPresentAuthenticationDialog:YES];
        [WebRequest setDelegate:self];
        [WebRequest startAsynchronous];
    }
    
    else{
        DLog(@"POST Method");
        ASIFormDataRequest *WebRequest = [ASIFormDataRequest requestWithURL:url];
        for (id postKey in [postDic allKeys])
            [WebRequest setPostValue:[postDic objectForKey:postKey] forKey:postKey];
        [WebRequest setDelegate:self];
        [WebRequest startAsynchronous];
    }
}

/*------------------------------------------------------------------
 Procedure/Function Name: webRequestWithUrl
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Creates URL request using ASIFormDataRequest.This method
 may be called in case of Authentification required for
 accessing Server. Credentials are passed as parameters.
 ------------------------------------------------------------------*/

-(void)webRequestWithUrl:(NSURL *)url withUserName:(NSString *)userName withPassWord:(NSString *)passWord
{
    DLog(@"REQUEST 3");
    [self showIndicatorWithText:strMessage];
    
    WebRequestAuth = [ASIHTTPRequest requestWithURL:url];
    if(self.userAuthRequired){
        [WebRequestAuth setShouldPresentAuthenticationDialog:YES];
    }
    else{
        [WebRequestAuth setShouldPresentAuthenticationDialog:NO];
        [WebRequestAuth setUsername:userName];
        [WebRequestAuth setPassword:passWord];
    }
    [WebRequestAuth setDelegate:self];
    [WebRequestAuth startAsynchronous];
}

/*------------------------------------------------------------------
 Procedure/Function Name: webRequestWithUrl
 Created By: Pratik Prajapati
 Created Date: 12-Dec-2012
 Modified By: -
 Modified Date: -
 Purpose: Creates SOAP based request using ASIFormDataRequest.
 Accepts SOAP message and name of the Action to perform.
 ------------------------------------------------------------------*/

-(void)webRequestWithUrl:(NSURL *)url withSoapMessage:(NSString *)soapMessage withSoapAction:(NSString *)soapAction
{
//    DLog(@"Request : %@", soapMessage);
//    DLog(@"Request : %@", soapAction);
    
    NSString *msgLength = [NSString stringWithFormat:@"%d",[soapMessage length]];
    NSMutableData *data = (NSMutableData*)[soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCachePolicy:(ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy)];
    
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8;"];
    [request addRequestHeader:@"SOAPAction" value:soapAction];
    [request addRequestHeader:@"Content-Length" value:msgLength];
    [request setRequestMethod:@"POST"];
    [request setPostBody:data];
    [request setDelegate:self];
    
    [request setTimeOutSeconds:kRequestTimeout];
    [request startAsynchronous];
    
    responseParsingDone = FALSE;
    
    // This is causing shit with the UIScrollView's Paging mode ...
    if (![soapAction isEqualToString:kSoapActionBreakingNews])
    {
        // TODO : Loop to Wait
        NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        while (!responseParsingDone && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
        {
            //Keep alive the Thread
        }
    }
}

- (void)setProgress:(float)newProgress
{
    if (delegate && [delegate respondsToSelector:@selector(setProgess:withTag:)]) {
        [delegate setProgess:newProgress withTag:self.requestTag];
    }
}

-(void)webAsyncRequestWithUrl:(NSURL *)url withSoapMessage:(NSString *)soapMessage withSoapAction:(NSString *)soapAction withTimeout:(BOOL)withTimeout {
    
//    if (kVideo == requestTag) {
//        DLog(@"==========================================================================");
//        DLog(@"Request : %@", soapMessage);
//        DLog(@"Request : %@", soapAction);
//        DLog(@"Timeout : %hhd", withTimeout);
//        DLog(@"==========================================================================");
//    }
    
    NSString *msgLength = [NSString stringWithFormat:@"%d",[soapMessage length]];
    NSMutableData *data = (NSMutableData*)[soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCachePolicy:(ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy)];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [request addRequestHeader:@"SOAPAction" value:soapAction];
    [request addRequestHeader:@"Content-Length" value:msgLength];
    [request setRequestMethod:@"POST"];
    [request setPostBody:data];
    [request setDelegate:self];
    if (withTimeout) {
        [request setTimeOutSeconds:kRequestTimeout];
    }
    [request startAsynchronous];
    [self.requestArray addObject:request];
    responseParsingDone = FALSE;
}

-(void)webAsyncRequestWithUrl:(NSURL *)url withSoapMessage:(NSString *)soapMessage withSoapAction:(NSString *)soapAction withTimeout:(BOOL)withTimeout completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion
{
    NSString *msgLength = [NSString stringWithFormat:@"%d",[soapMessage length]];
    NSMutableData *data = (NSMutableData*)[soapMessage dataUsingEncoding:NSUTF8StringEncoding];
        
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCachePolicy:(ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy)];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [request addRequestHeader:@"SOAPAction" value:soapAction];
    [request addRequestHeader:@"Content-Length" value:msgLength];
    [request setRequestMethod:@"POST"];
    [request setPostBody:data];
    [request setDelegate:self];
    if (withTimeout) {
        [request setTimeOutSeconds:kRequestTimeout];
    }
    [request startAsynchronous];
    [self.requestArray addObject:request];
    responseParsingDone = FALSE;
    
//    if(withTimeout)
//    {
//        [self requestTimerCreate];
//    }
    
    if (completion)
    {
        [request setCompletionBlock:^{
            dispatch_async( dispatch_get_main_queue(), ^{
                completion(TRUE, request.error, request.rawResponseData);
            });
        }];
        
        [request setFailedBlock:^{
            dispatch_async( dispatch_get_main_queue(), ^{
                completion(FALSE, request.error, request.rawResponseData);
            });
        }];
    }
}


// Cancel all Requests in requestArray i.e. All requests generated by this instance of the WebAPIRequest
-(void)requestCancel
{
    DLog(@"Cancelling a request!!!");
    for(int i = 0; i < [self.requestArray count]; i++)    {
        ASIHTTPRequest *req = [self.requestArray objectAtIndex:i];
        [self.delegate requestCancel:nil errorMessage:nil withTag:requestTag];
        [req cancel];
        [req setDelegate:nil];
        [self.requestArray removeObject:req];
    }
}

// Cancel all Requests in ASIHTPRequest
-(void)requestCancelAll
{
    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations)
    {
        [self.delegate requestCancel:nil errorMessage:nil withTag:requestTag];
        [req cancel];
        [req setDelegate:nil];
        [self.requestArray removeObject:req];
    }
}

// Create one-off Timer to track Timeout
-(void)requestTimerCreate {
    NSDictionary *userInfo = @{ @"StartDate" : [NSDate date] };
    
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate
                                              interval:kRequestTimeout
                                                target:self
                                              selector:@selector(requestTimerUpdate:)
                                              userInfo:userInfo
                                               repeats:NO];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    
    DLog(@"Timer created for %d",requestTag);
}

// Check if Request has timed out before responseParsingDone is TRUE
-(void)requestTimerUpdate:(NSTimer *)timer {
    
    DLog(@"Check time out for %d",requestTag);
    
    if(responseParsingDone) {
        [timer invalidate];
        return;
    }
    
    // TODO test this shiz...
    DLog(@"TIMEOUT OCCURED!!! == %d",requestTag);
    
    [self requestCancel];
    [self.delegate errorHandler:@"timeout" title:kstrTimeout error:nil message:kstrTimeoutStartupMessage];
    [timer invalidate];
    
    return;
}

# pragma mark
# pragma mark - Memory management

- (void)dealloc {
    [dictionaryStack release];
    [textInProgress release];
    [super dealloc];
}

@end
