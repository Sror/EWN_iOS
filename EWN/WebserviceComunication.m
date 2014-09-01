//
//  WebserviceComunication.m
//  EWN
//
//  Created by Macmini on 23/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "WebserviceComunication.h"
#import "CustomAlertView.h"
#import "AppDelegate.h"
#import "Category_Items.h"
#import "LeadingNews.h"
#import "Comments.h"
#import "CommentReplies.h"
#import "NewsListViewController.h"





//completion:(void (^)(BOOL successful, NSError *error, NSArray *dataCollection)

#if NS_BLOCKS_AVAILABLE
typedef void (^WebserviceComunicationGetCommentsBlock)(BOOL successful, NSError *error, NSArray *dataCollection);
#endif


@interface WebserviceComunication ()
{
    __block WebserviceComunicationGetCommentsBlock getCommentsBlock;
}

@end

@implementation WebserviceComunication

@synthesize webApiRequest;
@synthesize dictAuthenticate;
@synthesize dictBulletins;
@synthesize dictMarkets;
@synthesize dictCommentPost;
@synthesize dictTraffic;
@synthesize dictWeather;
@synthesize arrCategories;
@synthesize arrInFocus;
@synthesize numPageNoForAllNews;
@synthesize alrtvwReachable;
@synthesize dictCurrentCategory;
@synthesize dictLeadingNews;
@synthesize strInFocusId;
@synthesize alrtvwNotReachable;
@synthesize arrLeadingNews;
@synthesize arrLatestNews;
@synthesize arrLatestNewsNew;
@synthesize window;
@synthesize dictLatestNews;
@synthesize dictAudio;
@synthesize dictVideo;
@synthesize dictImages;
@synthesize numPageNoForLatest;
@synthesize numPageNoForInFocus;
@synthesize numPageNoForVideo;
@synthesize numPageNoForAudio;
@synthesize numPageNoForImages;
@synthesize numPageNoForComments;
@synthesize arrAudio;
@synthesize arrAudioNew;
@synthesize arrVideo;
@synthesize arrVideoNew;
@synthesize arrImages;
@synthesize arrImagesNew;
@synthesize arrSearchNews;
@synthesize arrStoryTimeline;
@synthesize arrStoryTimelineNew;
@synthesize arrComments;
@synthesize dictRequest;
@synthesize dictSearchNews;
@synthesize dictRequestDate;
@synthesize numPageNoForSearchList;
@synthesize numPageNoForStoryTimeline;
@synthesize dictStoryTimeline;
@synthesize dictRelatedStory,numRelatedStory,arrRelatedStory,arrRelatedStoryNew;
@synthesize isOnline;
@synthesize dictBreakingNews;
@synthesize arrBreakingNews,arrLastRelatedStory,arrLastStoryTimeline;
@synthesize isAlreadyOnline;
@synthesize isAlreadyOffLine;
@synthesize isStartupComplete;
@synthesize isAllocateFirstTime;
@synthesize isLoadingComments;
@synthesize isInFocus;
@synthesize dictLikeComment;
@synthesize dictReportComment;
@synthesize dictReplyComment;
@synthesize contributeKey;
@synthesize contributeSubmissionSuccess;

AppDelegate *appDelegate;

/**-----------------------------------------------------------------
 Function Name  : sharedCommManager
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Makes this class shared.
 ------------------------------------------------------------------*/
+ (id)sharedCommManager {
    static WebserviceComunication *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
/**-----------------------------------------------------------------
 Function Name  : init
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Allocation of all variables and objects.
 ------------------------------------------------------------------*/
- (id)init {
    if (self = [super init])
    {
        self.numPageNoForImages = 0;
        self.isOnline = FALSE;
        self.isAlreadyOnline = self.isOnline;
        self.isAlreadyOffLine = self.isOnline;
        self.isStartupComplete = FALSE;
        NSMutableDictionary *dictTemp = [[[NSMutableDictionary alloc] init] autorelease];
        [dictTemp setObject:kstrKeyForAllNews forKey:kstrId];
        [dictTemp setObject:kstrAllNews forKey:kstrName];
        self.arrCategories = [[NSMutableArray alloc] initWithObjects:dictTemp, nil];
        self.arrInFocus = [[[NSMutableArray alloc] init] autorelease];
        self.dictAuthenticate = [[NSMutableDictionary alloc]init];
        self.dictCommentPost = [[NSMutableDictionary alloc]init];
        self.dictCurrentCategory = [[[NSMutableDictionary alloc]init]autorelease];
        self.dictRequest = [[NSMutableDictionary alloc] init];
        self.dictRequestDate = [[NSMutableDictionary alloc] init];
        self.dictWeather = [[NSMutableDictionary alloc] init];
        self.dictMarkets = [[NSMutableDictionary alloc] init];
        [self.dictCurrentCategory setObject:[self.arrCategories objectAtIndex:0] forKey:kstrCurrentCategory];
        self.arrLeadingNews = [[NSMutableArray alloc] init];
        self.arrLatestNews = [[NSMutableArray alloc] init];
        self.arrLatestNewsNew = [[NSMutableArray alloc] init];
        self.arrVideo = [[NSMutableArray alloc] init];
        self.arrVideoNew = [[NSMutableArray alloc] init];
        self.arrImages = [[NSMutableArray alloc] init];
        self.arrImagesNew = [[NSMutableArray alloc] init];
        self.arrAudio = [[NSMutableArray alloc] init];
        self.arrAudioNew = [[NSMutableArray alloc] init];
        self.arrSearchNews = [[NSMutableArray alloc] init];
        self.arrStoryTimeline = [[NSMutableArray alloc] init];
        self.arrStoryTimelineNew = [[NSMutableArray alloc] init];
        self.arrRelatedStory = [[NSMutableArray alloc] init];
        self.arrRelatedStoryNew = [[NSMutableArray alloc] init];
        self.arrBreakingNews = [[NSMutableArray alloc]init];
        self.arrLastRelatedStory =[[NSMutableArray alloc]init];
        self.arrComments = [[NSMutableArray alloc]init];
        self.arrLastStoryTimeline = [[NSMutableArray alloc]init];
        self.isInFocus = NO;
        strSearchText = [[NSString alloc]init];
        commentArticleId = [[NSString alloc]init];
        numcounterLeading = 0;
        numcounterLatest = 0;
        numPageNoForInFocus = 0;
        numcountervideo= 0;
        numcounterimages= 0;
        numcounterAudio= 0;
        numcounterSearch= 0;
        numcounterStoryLines= 0;
        numcounterRelatedStory= 0;
        numPageNoForAllNews = 0;
        numPageNoForComments = 1;
        isAllocateFirstTime = TRUE;
        strStoryTimeLineArticleID = [[NSString alloc]init];
        strRelatedStoryArticleID =[[NSString alloc]init];
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.window = [[[UIApplication sharedApplication] delegate] window];
        self.termsText = @"";
        [appDelegate registerDefaultsValues];
        
        // Breaking News Alerts
        [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(getBreakingNews) userInfo:nil repeats:YES];
    }
    return self;
}

-(void) dealloc {
    [self.arrCategories release];
    [self.arrInFocus release];
    [self.dictAuthenticate release];
    [self.dictCommentPost release];
    [self.dictCurrentCategory release];
    [self.dictRequest release];
    [self.dictRequestDate release];
    [self.dictWeather release];
    [self.dictMarkets release];
    [self.arrLeadingNews release];
    [self.arrLatestNews release];
    [self.arrLatestNewsNew release];
    [self.arrVideo release];
    [self.arrVideoNew release];
    [self.arrImages release];
    [self.arrImagesNew release];
    [self.arrAudio release];
    [self.arrAudioNew release];
    [self.arrSearchNews release];
    [self.arrStoryTimeline release];
    [self.arrStoryTimelineNew release];
    [self.arrRelatedStory release];
    [self.arrRelatedStoryNew release];
    [self.arrBreakingNews release];
    [self.arrLastRelatedStory release];
    [self.arrComments release];
    [self.arrLastStoryTimeline release];
    [strSearchText release];
    [commentArticleId release];
    [strStoryTimeLineArticleID release];
    [strRelatedStoryArticleID release];
    [appDelegate release];
    [self.window release];
    [self.termsText release];
    [super dealloc];
}

//================================================================================================================================
// Contribute
//================================================================================================================================

-(void) getContributeKey {
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kContributeKeyTag;
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kRequestContributeKey withSoapAction:kSoapActionContributeKey withTimeout:TRUE];
}

-(void) submitContributeText:(NSString *)contributeMessage {
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kContributeTag;
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:contributeMessage withSoapAction:kSoapActionContribute withTimeout:TRUE];
}

-(void) submitContributeFile:(NSString *)contributeFile {
    DLog(@"Submitting the following to EWN : %@",contributeFile);
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kContributeFileTag;
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:contributeFile withSoapAction:kSoapActionContributeFile withTimeout:FALSE];
}

/**-----------------------------------------------------------------
 Function Name  : ShowBreakingNews
 Created By     : Arpit Jain
 Created Date   : 2-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : Shows breaking news alert
 ------------------------------------------------------------------*/

-(void)ShowBreakingNews
{
    if(self.isOnline == TRUE)
    {
        if(![alrtvwNotReachable.view isDescendantOfView:self.window] && [self.arrBreakingNews count] > 0)
        {
            //if([[[self.arrBreakingNews objectAtIndex:0] objectForKey:kstrIsBreakingNews] boolValue] == TRUE)
            if([[[self.arrBreakingNews objectAtIndex:0] isBreakingNews] boolValue] == TRUE)
            {
                alrtvwNotReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
                
                DLog(@"Wayne Breaking News : %@", [self.arrBreakingNews objectAtIndex:0]);
                
                //if([[self.arrBreakingNews objectAtIndex:0] objectForKey:kstrArticleId])
                if([[self.arrBreakingNews objectAtIndex:0] articleID])
                {
                    [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:2];
                    alrtvwNotReachable.lblHeading.text=[NSString stringWithFormat:kstrBREAKINGNEWS];
                    //alrtvwNotReachable.lblDetail.text = [self.dictBreakingNews objectForKey:kstrIntroParagraph];
                    alrtvwNotReachable.lblDetail.text = [[self.arrBreakingNews objectAtIndex:0] introParagraph];
                    [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
                    [alrtvwNotReachable.btn2 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
                    [alrtvwNotReachable.view setTag:kALERT_TAG_BREAKING_NEWS];
                }
                else
                {
                    [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:1];
                    alrtvwNotReachable.lblHeading.text=[NSString stringWithFormat:kstrBREAKINGNEWS];
                    //alrtvwNotReachable.lblDetail.text = [self.dictBreakingNews objectForKey:kstrIntroParagraph];
                    alrtvwNotReachable.lblDetail.text = [[self.arrBreakingNews objectAtIndex:0] introParagraph];
                    [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
                    [alrtvwNotReachable.view setTag:kALERT_TAG_BREAKING_NEWS];
                }
            }
        }
    }
}

// Get authenticated against ewns api
-(void)getAuthentication
{
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kAuthenticate; // Optional
    
    NSString *authId = [dictAuthenticate objectForKey:@"id"];
    
    NSString *yourMom = kSoapMessageAuthenticate;
    NSString *tmp = [NSString stringWithFormat:yourMom ,authId];
    
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:tmp withSoapAction:kSoapActionAuthenticate withTimeout:TRUE];
}

-(void)getContentItem:(NSString *)articleId {
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kContentItem;
    
    NSString *soapMessage = kSoapMessageContentItem;
    NSString *tmp = [NSString stringWithFormat:soapMessage , articleId];
    
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:tmp withSoapAction:kSoapActionGetContentItem withTimeout:TRUE];
}

/**-----------------------------------------------------------------
 Function Name  : getBreakingNews
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for breaking news.
 ------------------------------------------------------------------*/

-(void)getBreakingNews {
    DLog(@"CHECK FOR BREAKING NEWS!!!");
    // Check if Notifications are enabled
    if(![SettingsViewController CanReceiveAlerts]) {
        return;
    }
    
    [self.arrBreakingNews removeAllObjects];
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kBreakingNews; // Optional
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kSoapMessageBreakingNews withSoapAction:kSoapActionBreakingNews];
}

//======================================================================================
// Get the terms and conditions
//======================================================================================
-(void)getTerms {
    // Caching
    if (![self.termsText isEqualToString:@""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TERMS_REQUEST" object:self];
        return;
    }
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kTerms; // Optional
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kSoapMessageTerms withSoapAction:kSoapActionTerms withTimeout:YES];
}

/**-----------------------------------------------------------------
 Function Name  : getCategory
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for Category.
 ------------------------------------------------------------------*/
-(void)getCategory {
    if([[CacheDataManager sharedCacheManager] hasCacheDataExpiredForContent:kEntityCategory]) {
        // Category cache has expired so request it again
        webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
        webApiRequest.requestTag = kCategory; // Optional
        [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kSoapMessageCategory withSoapAction:kSoapActionCategory];
    } else {
        // Categories from cache pls
        self.arrCategories = [[CacheDataManager sharedCacheManager] getCatogery];
        
        if ([self.arrCategories count] == 0) {
            // Cache is empty. Try again
            webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
            webApiRequest.requestTag = kCategory; // Optional
            [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kSoapMessageCategory withSoapAction:kSoapActionCategory];
        }
    }
}
/**-----------------------------------------------------------------
 Function Name  : getInFocus
 Created By     : Armpit Jane
 Created Date   : 09-Dec-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for In Focus.
 ------------------------------------------------------------------*/
-(void)getInFocus {
    if([[CacheDataManager sharedCacheManager] hasCacheDataExpiredForContent:kEntityInFocus]) {
        // Requesting new in focus
        webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
        webApiRequest.requestTag = kInFocus; // Optional
        [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kSoapMessageInFocus withSoapAction:kSoapActionInFocus];
    } else {
        // Cached in focus
        self.arrInFocus = [[CacheDataManager sharedCacheManager] getInFocusArray];
        if ([self.arrInFocus count] == 0) {
            // Cache is empty. Try again
            webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
            webApiRequest.requestTag = kInFocus; // Optional
            [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kSoapMessageInFocus withSoapAction:kSoapActionInFocus];
        }
    }
}

/**-----------------------------------------------------------------
 Function Name  : getLeadingNews
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for LeadingNews.
 ------------------------------------------------------------------*/

-(void)getLeadingNews {
    webApiRequest = [[[WebAPIRequest alloc]initWithDelegate:self] autorelease];
    webApiRequest.requestTag = kLeadingNews; // Optional
    if (version2) {
        NSString *categoryId = [self.dictCurrentCategory valueForKey:kstrId];
        if ([categoryId isEqualToString:@"001-AllNews"]) {
            categoryId = @"";
        }
        [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageLeadingNewsForCategory,categoryId] withSoapAction:kSoapActionLeadingNews];
    } else {
        [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kSoapMessageLeadingNews withSoapAction:kSoapActionLeadingNews];
    }
}
/**-----------------------------------------------------------------
 Function Name  : getLatestNews
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for LatestNews.
 ------------------------------------------------------------------*/
-(void)getLatestNews {
    [self.arrLatestNewsNew removeAllObjects];
    
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    
    webApiRequest.requestTag = kLatestNews; // Optional
    
    int articleCount = kDefaultBatchCount;
    NSString *publishedBefore = kStartDate;
    
    if (0 == self.numPageNoForLatest) {
        articleCount = kDefaultBatchCountFirstPage;
    } else {
        if (version2) {
            // get the last article we have
            Contents *item = [self.arrLatestNews lastObject];
            publishedBefore = item.publishDate;
        }
    }

    if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews]) {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageAllNews,kstrNewsArticlesOnly,articleCount,self.numPageNoForLatest, kStartDate, publishedBefore] withSoapAction:kSoapActionAllNews withTimeout:TRUE];
    } else {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageLatestNews_Video_Images_Audio,[self.dictCurrentCategory valueForKey:kstrId],kstrNewsArticlesOnly,articleCount,self.numPageNoForLatest, kStartDate, publishedBefore] withSoapAction:kSoapActionLatestNews_Video_Images_Audio withTimeout:TRUE];
    }
    
    [self.dictRequest setObject:webApiRequest forKey:@"ARTICLES"];
    [webApiRequest release];
}

-(void)getLatestNewsInit
{
    [self setNumPageNoForLatest:0];
    if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews]) {
//        if (!version2) {
            [self getLeadingNews]; // Only fetch Leading News for All News
            [[WebserviceComunication sharedCommManager] setProgess:0.3f withTag:17];
//        }
    }
//    if (version2) {
//        [self getLeadingNews];
//        [[WebserviceComunication sharedCommManager] setProgess:0.3f withTag:17];
//    }
    [self getLatestNews];
}

- (void) notifyLatestNews:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LATEST" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ARTICLES object:nil];
}

/**-----------------------------------------------------------------
 Function Name  : getInFocusNews
 Created By     : Armpit Jane
 Created Date   : 09-Dec-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for In Focus
 ------------------------------------------------------------------*/

-(void)getInFocusNews {
    [self.arrLatestNewsNew removeAllObjects];
    
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kInFocusNews;
    
    if(self.numPageNoForInFocus == 0)
    {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageInFocusNews, self.strInFocusId, kDefaultBatchCountFirstPage, self.numPageNoForInFocus, kStartDate] withSoapAction:kSoapActionInFocusNews withTimeout:TRUE];
    }
    else
    {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageInFocusNews, self.strInFocusId, kDefaultBatchCount, self.numPageNoForInFocus, kStartDate] withSoapAction:kSoapActionInFocusNews withTimeout:TRUE];
    }
    
    [self.dictRequest setObject:webApiRequest forKey:@"ARTICLES"];
}

-(void)getInFocusNewsInit
{
    BOOL isRefresh = TRUE;
    
    if(isRefresh){
        [self setNumPageNoForInFocus:0];
        [self getInFocusNews];
    }
    else
    {
        self.arrLatestNewsNew = [[CacheDataManager sharedCacheManager] getContentsWithInFocusId:self.strInFocusId withLimit:kDefaultBatchCountFirstPage];
        [self.arrLatestNews addObjectsFromArray:self.arrLatestNewsNew];
        
        [self setNumPageNoForInFocus:self.numPageNoForInFocus + 1];
        [self performSelectorOnMainThread:@selector(notifyLatestNews:) withObject:nil waitUntilDone:YES]; // Hijack Latest News parsing
    }
}

/**-----------------------------------------------------------------
 Function Name  : getVedio
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for Vedio.
 ------------------------------------------------------------------*/
-(void)getVedio {    
    [self.arrVideoNew removeAllObjects];
    
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];

    NSString *publishedBefore = kStartDate;
    if (self.numPageNoForVideo > 0 && version2) {
        // get the last article we have
        Contents *item = [self.arrVideo lastObject];
        publishedBefore = item.publishDate;
    }

    webApiRequest.requestTag = kVideo; // Optional
    
    if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews]) {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageAllNews,kstrVideo,kDefaultBatchCount,self.numPageNoForVideo, kStartDate, publishedBefore] withSoapAction:kSoapActionAllNews withTimeout:TRUE];
    } else {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageLatestNews_Video_Images_Audio,[self.dictCurrentCategory objectForKey:kstrId],kstrVideo,kDefaultBatchCount,self.numPageNoForVideo, kStartDate, publishedBefore] withSoapAction:kSoapActionLatestNews_Video_Images_Audio withTimeout:TRUE];
    }
    
    [self.dictRequest setObject:webApiRequest forKey:@"VIDEO"];
}

-(void)getVedioInit {
    BOOL isRefresh = TRUE;
    
    if(isRefresh){
        [self setNumPageNoForVideo:0];
        [self getVedio];
    } else {
        self.arrVideoNew = [[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrVideo andCategoryId:[dictCurrentCategory valueForKey:kstrId] withLimit:kDefaultBatchCount];
        [self.arrVideo addObjectsFromArray:self.arrVideoNew];
        
        [self setNumPageNoForVideo:self.numPageNoForVideo + 1];
        [self performSelectorOnMainThread:@selector(notifyVideo:) withObject:nil waitUntilDone:YES];
    }
}

- (void) notifyVideo:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_VIDEOS object:nil];
}

/**-----------------------------------------------------------------
 Function Name  : getStorytimelineByArticleId
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for Storytimeline.
 ------------------------------------------------------------------*/
-(void)getStorytimelineByArticleId : (NSString *)strArcticleid
{
    [self.arrStoryTimelineNew removeAllObjects];
    
    strStoryTimeLineArticleID = strArcticleid;
    
    if (webApiRequest.requestTag == kStoryTimeline)
    {
        [webApiRequest setDelegate:nil];
    }
    
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kStoryTimeline; // Optional
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageStoryTimeLineByArticleId,strArcticleid,kDefaultBatchCount,self.numPageNoForStoryTimeline] withSoapAction:kSoapActionStoryTimeline];
}
/**-----------------------------------------------------------------
 Function Name  : getRelatedStoryByArticleId
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for RelatedStory.
 ------------------------------------------------------------------*/
-(void)getRelatedStoryByArticleId : (NSString *)strArcticleid
{
    [self.arrRelatedStoryNew removeAllObjects];
    
    strRelatedStoryArticleID = strArcticleid;
    
    if (webApiRequest.requestTag == kRelatedStory)
    {
        [webApiRequest setDelegate:nil];
    }
    
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kRelatedStory; // Optional
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageRelatedStoryByArticleId,strArcticleid,kDefaultBatchCount,self.numRelatedStory] withSoapAction:kSoapActionRelatedStory];
}

/**-----------------------------------------------------------------
 Function Name  : getImages
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for Images.
 ------------------------------------------------------------------*/
-(void)getImages
{
    [self.arrImagesNew removeAllObjects];
    
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    
    webApiRequest.requestTag = kImages; // Optional
    
    NSString *publishedBefore = kStartDate;
    if (self.numPageNoForImages > 0 && version2) {
        // get the last article we have
        Contents *item = [self.arrImages lastObject];
        publishedBefore = item.publishDate;
    }
    
    if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews])
    {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageAllNews,kContentImages,kDefaultBatchCount,self.numPageNoForImages,kStartDate, publishedBefore] withSoapAction:kSoapActionAllNews withTimeout:TRUE];
    }
    else
    {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageLatestNews_Video_Images_Audio,[self.dictCurrentCategory objectForKey:kstrId],kContentImages,kDefaultBatchCount,self.numPageNoForImages, kStartDate, publishedBefore] withSoapAction:kSoapActionLatestNews_Video_Images_Audio withTimeout:TRUE];
    }
    
    [self.dictRequest setObject:webApiRequest forKey:@"IMAGES"];
}

-(void)getImagesInit
{
    BOOL isRefresh = TRUE;
    
    if(isRefresh){
        [self setNumPageNoForImages:0];
        [self getImages];
    }
    else
    {
        self.arrImagesNew = [[CacheDataManager sharedCacheManager] getContentsWithContentType:kContentImages andCategoryId:[dictCurrentCategory valueForKey:kstrId] withLimit:kDefaultBatchCount];
        [self.arrImages addObjectsFromArray:self.arrImagesNew];
        [self setNumPageNoForImages:self.numPageNoForImages + 1];
        [self performSelectorOnMainThread:@selector(notifyImages:) withObject:nil waitUntilDone:NO];
    }
}

- (void) notifyImages:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMAGES" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_IMAGES object:nil];
}

/**-----------------------------------------------------------------
 Function Name  : getAudio
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Call webservise request for Audio.
 ------------------------------------------------------------------*/
-(void)getAudio
{
    [self.arrAudioNew removeAllObjects];
    
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    
    webApiRequest.requestTag = kAudio; // Optional
    
    NSString *publishedBefore = kStartDate;
    if (self.numPageNoForAudio > 0 && version2) {
        // get the last article we have
        Contents *item = [self.arrAudio lastObject];
        publishedBefore = item.publishDate;
    }
    
    if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews])
    {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageAllNews,kstrAudio,kDefaultBatchCount,self.numPageNoForAudio,kStartDate, publishedBefore] withSoapAction:kSoapActionAllNews withTimeout:TRUE];
    }
    else
    {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageLatestNews_Video_Images_Audio,[self.dictCurrentCategory objectForKey:kstrId],kstrAudio,kDefaultBatchCount,self.numPageNoForAudio, kStartDate, publishedBefore] withSoapAction:kSoapActionLatestNews_Video_Images_Audio withTimeout:TRUE];
    }
    
    [self.dictRequest setObject:webApiRequest forKey:@"AUDIO"];
}

-(void)getAudioInit
{
    BOOL isRefresh = TRUE;
    
    if(isRefresh){
        [self setNumPageNoForAudio:0];
        [self getAudio];
    }
    else
    {
        self.arrAudioNew = [[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrAudio andCategoryId:[dictCurrentCategory valueForKey:kstrId] withLimit:kDefaultBatchCount];
        [self.arrAudio addObjectsFromArray:self.arrAudioNew];
        
        [self setNumPageNoForAudio:self.numPageNoForAudio + 1];
        [self performSelectorOnMainThread:@selector(notifyAudio:) withObject:nil waitUntilDone:YES];
    }
}

- (void) notifyAudio:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIO" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_AUDIO object:nil];
}

// TODO - Rename this (it's called from the AppDelegate, but gets confusing ...
-(void)requestCancel
{
    DLog(@"So what the devil is going on here?");
    [[PDBackgroundTaskManager sharedInstance] executeBackgroundTaskWithExpirationHandler:nil executionHandler:^(PDBackgroundTaskManager *manager, NSString *taskName) {
       
        WebAPIRequest *webRequest = [WebAPIRequest alloc];
        
        if([self.dictRequest objectForKey:@"ARTICLES"] != NULL)
        {
            webRequest = (WebAPIRequest *)[self.dictRequest objectForKey:@"ARTICLES"];
            //DLog(@"REQ - Articles : %d", [webRequest.requestArray count]);
            [webApiRequest requestCancel];
        }
        else if([self.dictRequest objectForKey:@"VIDEO"] != NULL)
        {
            webRequest = (WebAPIRequest *)[self.dictRequest objectForKey:@"VIDEO"];
            //DLog(@"REQ - Video : %d", [webRequest.requestArray count]);
            [webApiRequest requestCancel];
        }
        else if([self.dictRequest objectForKey:@"IMAGES"] != NULL)
        {
            webRequest = (WebAPIRequest *)[self.dictRequest objectForKey:@"IMAGES"];
            //DLog(@"REQ - Images : %d", [webRequest.requestArray count]);
            [webApiRequest requestCancel];
        }
        else if([self.dictRequest objectForKey:@"AUDIO"] != NULL)
        {
            webRequest = (WebAPIRequest *)[self.dictRequest objectForKey:@"AUDIO"];
            //DLog(@"REQ - Audio : %d", [webRequest.requestArray count]);
            [webApiRequest requestCancel];
        }
        else
        {
            for (WebAPIRequest *request in self.dictRequest)
            {
                [request requestCancel];
            }
        }
        
        
        [manager endBackgroundTask];
        
    }];
}

/**-----------------------------------------------------------------
 Function Name  : prepareURLForFile
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Prepare the file for video Streaming.
 ------------------------------------------------------------------*/
- (NSURL *)prepareURLForFile : (NSString *)fileName withContentType: (NSString *)contentype
{
    return [NSURL URLWithString:fileName];
}

/**-----------------------------------------------------------------
 Function Name  : searchNewsByText
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Search the news by given tag.
 ------------------------------------------------------------------*/
-(void)searchNewsByText:(NSString *)searchText
{
    strSearchText = searchText;
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kSearchNews; // Optional
    webApiRequest.strMessage = @"Searching News..."; // Optional
    
    if([[self.dictCurrentCategory objectForKey:kstrId] isEqualToString:kstrKeyForAllNews])
    {
        [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageNews_Search_All,searchText,kDefaultBatchCount,self.numPageNoForSearchList] withSoapAction:kSoapActionNews_SearchALL];
    }
    else
    {
        [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageNews_Search, [self.dictCurrentCategory objectForKey:kstrId],searchText,kDefaultBatchCount,self.numPageNoForSearchList] withSoapAction:kSoapActionNews_Search];
    }
}

-(NSString *)convertContentType:(NSString *)contentType {
    NSString *newType = contentType;
    if ([newType isEqualToString:@"Articles"]) {
        newType = @"NewsArticlesOnly";
    }
    return newType;
}

-(void)searchNewsByText:(NSString *)searchText ContentType:(NSString *)contentType
{
    DLog(@"Search");
    
    contentType = [self convertContentType:contentType];
    
    strSearchText = searchText;
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kSearchNews; // Optional
    webApiRequest.strMessage = @"Searching News..."; // Optional
    
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageNewsContentType_Search,
                                                                                      searchText,
                                                                                      contentType,
                                                                                      kDefaultBatchCount,
                                                                                      self.numPageNoForSearchList,
                                                                                      kStartDate]
                      withSoapAction:kSoapActionNewsContentType_Search];
}

-(void)searchNewsByText:(NSString *)searchText Category:(NSString *)category ContentType:(NSString *)contentType
{
    DLog(@"Search");
 
    contentType = [self convertContentType:contentType];
    
    strSearchText = searchText;
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kSearchNews; // Optional
    webApiRequest.strMessage = @"Searching News..."; // Optional
    
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kSoapMessageNewsCategoryAndContentType_Search,
                                                                                      category,
                                                                                      searchText,
                                                                                      contentType,
                                                                                      kDefaultBatchCount,
                                                                                      self.numPageNoForSearchList,
                                                                                      kStartDate]
                      withSoapAction:kSoapActionNewsCategoryAndContentType_Search];
}
/**-----------------------------------------------------------------
 Function Name  : gotURLCheckingResponse
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        :
 ------------------------------------------------------------------*/
-(void)gotURLCheckingResponse: (ASIHTTPRequest *)response
{
}

-(void)requestCancel:(NSObject *)items errorMessage:(NSString *)message withTag:(int)tag {
    DLog(@"WebService :: Request Cancelled : %@",message);
    DLog(@"WebService :: Tag : %d",tag);
}

-(void)errorHandler:(NSString *)errorType title:(NSString *)errorTitle error:(NSError *)error message:(NSString *)errorMessage {
    DLog(@"An error occurred!!! : %@", errorTitle);
    
    if([kErrorResponse isEqualToString:errorType]) {
        alrtvwNotReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:1];
        alrtvwNotReachable.lblHeading.text = errorTitle;
        alrtvwNotReachable.lblDetail.text = errorMessage;
        [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
        [alrtvwNotReachable.view setTag:kALERT_TAG_INTERNAL_SERVER_ERROR];
    } else if([kErrorTimeout isEqualToString:errorType]) {
        if (self.isStartupComplete) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RETRY" object:nil];
        } else {
            alrtvwNotReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
            [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:1];
            alrtvwNotReachable.lblHeading.text = errorTitle;
            alrtvwNotReachable.lblDetail.text = errorMessage;
            [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
            [alrtvwNotReachable.view setTag:kALERT_TAG_INTERNAL_SERVER_ERROR];
        }
    }
}

-(void)postComment {
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kPostCommentTag;
    
    NSString *articleId = [dictCommentPost valueForKey:@"articleId"];
    NSString *userId = [dictCommentPost valueForKey:@"userId"];
    NSString *commentText = [dictCommentPost valueForKey:@"commentText"];
    
    // the ide refuses to use the kPostComment straight...
    NSString *tmp = kPostComment;
    NSString *soapMessage = [NSString stringWithFormat:tmp, articleId, userId, commentText];
    
    DLog(@"Soap message %@", soapMessage);
    
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:soapMessage withSoapAction:kSoapActionPostComment withTimeout:TRUE];
}

-(void)reportCommentWithDict:(NSDictionary *)dictionary completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion
{
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kReportCommentTag;
    
    DLog(@"POST STUFF %@", dictionary);
    
    NSString *commentId = [dictionary valueForKey:@"commentId"];
    
    // the ide refuses to use the kPostComment straight...
    NSString *tmp = [[NSString alloc] initWithData:[kRequestReportComment dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
    NSString *soapMessage = [NSString stringWithFormat:tmp, commentId];
    
    DLog(@"Soap message %@", soapMessage);
    
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:soapMessage withSoapAction:kSoapActionReportComment withTimeout:TRUE completion:completion];
}

-(void)likeCommentWithDict:(NSDictionary *)dictionary completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion
{
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kLikeCommentTag;
    
    DLog(@"POST STUFF %@", dictionary);
    
    NSString *commentId = [dictionary valueForKey:@"commentId"];
    NSString *userId = [dictionary valueForKey:@"userId"];
    NSString *likeComment = [dictionary valueForKey:@"likeComment"];
    
    // the ide refuses to use the kPostComment straight...
    NSString *tmp = kRequestLikeComment;
    NSString *soapMessage = [NSString stringWithFormat:tmp, commentId, userId, likeComment];
    
    DLog(@"Soap message %@", soapMessage);
    
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:soapMessage withSoapAction:kSoapActionLikeComment withTimeout:TRUE completion:completion];
}

-(void)replyCommentWithDict:(NSDictionary *)dictionary completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion
{
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kReplyCommentTag;
    
    DLog(@"POST STUFF %@", dictionary);
    
    NSString *commentId = [dictionary valueForKey:@"commentId"];
    NSString *userId = [dictionary valueForKey:@"userId"];
    NSString *commentText = [dictionary valueForKey:@"commentText"];
    
    // the ide refuses to use the kPostComment straight...
    NSString *tmp = kRequestSubmitReply;
    NSString *soapMessage = [NSString stringWithFormat:tmp, commentId, userId, commentText];
    
    DLog(@"Soap message %@", soapMessage);
    
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:soapMessage withSoapAction:kSoapActionSubmitReply withTimeout:TRUE completion:completion];
}


-(void)postFeedback:(NSString *)messageString completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion
{
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kPostFeedbackTag;
    
    DLog(@"POST FEEDBACK %@", messageString);
    
    NSString *soapMessage = [NSString stringWithFormat:kPostFeedback, messageString];
    
    DLog(@"Soap message %@", soapMessage);
    
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:soapMessage withSoapAction:kSoapActionPostFeedback withTimeout:TRUE completion:completion];
}

/**-----------------------------------------------------------------
 Function Name  : getWeather
 Created By     : Wayne Langman
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Fetch detailed Weather Report for City
 ------------------------------------------------------------------*/
-(void)getWeather
{
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kWeatherTag;
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:kRequestWeather withSoapAction:kSoapActionWeather withTimeout:TRUE];
}

/**-----------------------------------------------------------------
 Function Name  : getBulletins
 Created By     : Wayne Langman
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Fetch Bulletins for all Regions
 ------------------------------------------------------------------*/
-(void)getBulletins
{
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kBulletinTag;
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kRequestBulletins] withSoapAction:kSoapActionBulletin withTimeout:TRUE];
}

/**-----------------------------------------------------------------
 Function Name  : getBulletins
 Created By     : Wayne Langman
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Fetch Traffic for all Cities
 ------------------------------------------------------------------*/
-(void)getTraffic
{
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kTrafficTag;
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kRequestTraffic] withSoapAction:kSoapActionTraffic withTimeout:FALSE];
}

-(void)getMarkets {
    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kMarketCurrencyTag;
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kRequestMarketCurrency] withSoapAction:kSoapActionMarketCurrency withTimeout:FALSE];

    webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    webApiRequest.requestTag = kMarketCommodityTag;
    [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kRequestMarketCommodity] withSoapAction:kSoapActionMarketCommodity withTimeout:FALSE];
}

/**-----------------------------------------------------------------
 Function Name  : getComments
 Created By     : Wayne Langman
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Fetch the Comments for specified articleId,itemsPerPage and pageNumber
 ------------------------------------------------------------------*/
-(void)getComments
{
    self.isLoadingComments = YES;
    
    [self.arrComments removeAllObjects];
    
    if([self.dictRequest objectForKey:@"COMMENTS"] == NULL)
    {
        webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
    }
    else
    {
        webApiRequest = (WebAPIRequest *)[self.dictRequest objectForKey:@"COMMENTS"];
    }
    
    webApiRequest.requestTag = kCommentsTag;
    
    if(self.numPageNoForComments == 1){
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kRequestComments, commentArticleId, kDefaultBatchCount, self.numPageNoForComments] withSoapAction:kSoapActionComments withTimeout:FALSE];
    } else {
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url] withSoapMessage:[NSString stringWithFormat:kRequestComments, commentArticleId, kDefaultBatchCount, self.numPageNoForComments] withSoapAction:kSoapActionComments withTimeout:FALSE];
    }
    
    [self.dictRequest setObject:webApiRequest forKey:@"COMMENTS"];
}

-(void)getCommentsInit:(NSString *)articleId
{
    getCommentsBlock = nil;
        
    [self getComments:articleId pageCount:1 batchSize:kDefaultBatchCount completion:nil];
    
    // DONG says : Interesting, it just freaking stops here...
    return;
    //////////////////////////////////////////////////////////////////////////////
    
    BOOL isRefresh = TRUE;
    
    commentArticleId = articleId;
    
    if(self.numPageNoForComments == 1)
    {
        NSDate *date = [self.dictRequestDate objectForKey:articleId];
//        DLog(@"Is Refresh : %@", date);
        
        if(date != NULL)
        {
//            DLog(@"Date : %@", date);
            double lastRequest = [[NSDate date] timeIntervalSinceDate:date];
//            DLog(@"Interval : %g", lastRequest);
//
//            DLog(@"Expire Last : %g", lastRequest);
//            DLog(@"Expire Limit : %d", kRequestCommentExpire);
            
            if(lastRequest < kRequestCommentExpire)
            {
                isRefresh = FALSE;
            }
        }
    }
    
    if(isRefresh){
        [self setNumPageNoForComments:1];
        [self getComments];
    }
    else
    {
        DLog(@"Comments Expire");
        [self setNumPageNoForComments:self.numPageNoForComments + 1];
    }
}

-(void)getComments:(NSString *)articleId pageCount:(NSInteger)count batchSize:(NSInteger)batchSize completion:(void (^)(BOOL successful, NSError *error, NSArray *dataCollection))completion
{
    if (articleId && articleId.length > 0) {
        commentArticleId = articleId;
    }
    
    self.numPageNoForComments = count;
    
    getCommentsBlock = [completion copy];
    
    if (commentArticleId && commentArticleId.length > 0)
    {
        self.isLoadingComments = YES;
        if([self.dictRequest objectForKey:@"COMMENTS"] == NULL)
        {
            webApiRequest = [[WebAPIRequest alloc] initWithDelegate:self];
        }
        else
        {
            webApiRequest = (WebAPIRequest *)[self.dictRequest objectForKey:@"COMMENTS"];
        }
        webApiRequest.requestTag = kCommentsTag;
        
        NSInteger commentBatchSize = batchSize && batchSize > 0 ? batchSize : kDefaultBatchCount;

        // clear the old comments if this is page 1
        if (self.numPageNoForComments == 1) {
            [self.arrComments removeAllObjects];
        }
        
        [webApiRequest webAsyncRequestWithUrl:[NSURL URLWithString:kLIVE_Url]
                              withSoapMessage:[NSString stringWithFormat:kRequestComments, commentArticleId, commentBatchSize, self.numPageNoForComments]
                               withSoapAction:kSoapActionComments
                                  withTimeout:FALSE
                                   completion:nil];
        
        [self.dictRequest setObject:webApiRequest forKey:@"COMMENTS"];
    }
}

/**-----------------------------------------------------------------
 Function Name  : setItems
 Created By     : Arpit Jain
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : get response of all requests and store it.
 ------------------------------------------------------------------*/

-(void)setItems:(NSObject *)items errorMessage:(NSString *)message error:(NSError *)error withTag:(int)tag
{
    // This is how you can identify request.
    if(tag == kURLChecking)
    {
        if(message)
        {
        }
        return;
    }
    
    if([message length]==0)
    {
        if(tag==kCategory)
        {
            NSDictionary *dicCategory = (NSDictionary *)items;
            
            // delete all items of category from database..
            [[CacheDataManager sharedCacheManager] deleteCachedataOfEntity:kEntityCategory];
            
            [self.arrCategories removeAllObjects];
            
            NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
            arrTemp =[dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetCategoriesResponse.GetCategoriesResult.Category"];
            
            for(int numIndex = 0;numIndex<=[arrTemp count]; numIndex++)
            {
                if(numIndex == 0)
                {
                    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
                    [dictTemp setObject:kstrKeyForAllNews forKey:kstrId];
                    [dictTemp setObject:kstrAllNews forKey:kstrName];
                    [self.arrCategories addObject:dictTemp];
                }
                else
                {
                    [self.arrCategories addObject:[arrTemp objectAtIndex:numIndex-1]];
                }
            }
            
            DLog(@"category count = %d",[self.arrCategories count]);
            DLog(@"dictCurrentCategory count = %d",[self.dictCurrentCategory count]);
            
            if ([self.arrCategories count] > 1)
            {
                if([self.dictCurrentCategory count] == 0)
                {
                    self.dictCurrentCategory = [self.arrCategories objectAtIndex:0];
                }
                
                [[CacheDataManager sharedCacheManager] addCategoriesWithItemArray:self.arrCategories];
                
                self.isOnline = TRUE;
                self.isAlreadyOnline = self.isOnline;
            }
            
            self.arrCategories = [[CacheDataManager sharedCacheManager] getCatogery];
        }
        else if (tag == kInFocus)
        {
            NSDictionary *dickInFocus = (NSDictionary *)items;
                        
            // Delete In Focus items from DB
            [[CacheDataManager sharedCacheManager] deleteCachedataOfEntity:kEntityInFocus];
            [self.arrInFocus removeAllObjects];
            
            // Get the in focus items
            NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
            arrTemp = [dickInFocus retrieveForPath:@"soap:Envelope.soap:Body.GetInfocusItemsResponse.GetInfocusItemsResult.InFocusItem"];
            
            NSMutableArray *inFocusArray = [[NSMutableArray alloc]init];
            // get the key at item 0 to see if we have more than a single in focus item
            
            // if the item's key is infocus we know we have more than 1
            if ([arrTemp isKindOfClass:[NSArray class]]) {
                inFocusArray = arrTemp;
            } else {
                if (arrTemp != nil) {
                    [inFocusArray addObject:arrTemp];
                }
            }
            
            if (inFocusArray != nil)
            {
                [[CacheDataManager sharedCacheManager] addInFocusWithItemArray:inFocusArray];
            }
            
            self.arrInFocus = [[CacheDataManager sharedCacheManager] getInFocusArray];
            
        }
        //////////////////////
        // Post Comment
        //////////////////////
        else if (tag == kPostCommentTag) {
            NSDictionary *dickPostComment = (NSDictionary *)items;
            self.dictCommentPost = [dickPostComment retrieveForPath:@"soap:Envelope.soap:Body.SubmitCommentResponse"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_POST_COMMENT object:nil];
        }
        
        //////////////////////
        // Post Feedback
        //////////////////////
        else if (tag == kPostFeedbackTag) {
            NSDictionary *dickPostComment = (NSDictionary *)items;
            self.dictCommentPost = [dickPostComment retrieveForPath:@"soap:Envelope.soap:Body.SubmitFeedbackResponse"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_POST_FEEDBACK object:nil];
        }
        
        //////////////////////
        // Authenticate
        //////////////////////
        else if (tag == kAuthenticate) {
            NSDictionary *dickAuthenticate = (NSDictionary *)items;            
            self.dictAuthenticate = [dickAuthenticate retrieveForPath:@"soap:Envelope.soap:Body.AuthenticateUserByTokenResponse"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_AUTHENTICATE object:[NSNumber numberWithBool:YES]];
        }
        
        else if(tag == kLeadingNews)
        {
            [self.arrLeadingNews removeAllObjects];
            
            NSDictionary *dicCategory = (NSDictionary *)items;
                        
            self.dictLeadingNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLeadingNewsResponse.GetLeadingNewsResult"];
            
            [self.arrLeadingNews addObject:[[CacheDataManager sharedCacheManager] addLeadingNews:self.dictLeadingNews]];
        }
        //////////////////////
        // LATEST NEWS
        //////////////////////
        else if(tag == kLatestNews) {
            NSDictionary *dicCategory = (NSDictionary *)items;
            
            if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews]) {
                self.dictLatestNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByContentTypeResponse.GetLatestNewsByContentTypeResult"];
            } else {
                self.dictLatestNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByCategoryAndContentTypeResponse.GetLatestNewsByCategoryAndContentTypeResult"];
            }
            
            // Fill results from CoreData
            int dictCount;
            if([[[self.dictLatestNews objectForKey:kstrContentItems] objectForKey:kstrContentItem] isKindOfClass:[NSArray class]]) {
                dictCount = [[[self.dictLatestNews objectForKey:kstrContentItems] objectForKey:kstrContentItem] count];
            } else {
                if([[[self.dictLatestNews objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0) {
                    dictCount = 1;
                } else {
                    dictCount = 0;
                }
            }
            
            if (dictCount == 0) {
                DLog(@"No results for news!!!");
                DLog(@"Items = %@",items);
            }
            
            if (self.numPageNoForLatest == 0 && dictCount < kDefaultBatchCountFirstPage) {
                int addCount;
                
//                if([[self.dictCurrentCategory objectForKey:kstrId] isEqualToString:kstrKeyForAllNews] || version2) {
                if([[self.dictCurrentCategory objectForKey:kstrId] isEqualToString:kstrKeyForAllNews]) {
                    addCount = kDefaultBatchCountFirstPage - 1;
                } else {
                    addCount = kDefaultBatchCountFirstPage;
                }
                
                [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictLatestNews];
                self.arrLatestNewsNew = [[CacheDataManager sharedCacheManager] getContentsWithContentType:kcontentLatest andCategoryId:[dictCurrentCategory valueForKey:kstrId] withLimit:addCount];
                [self.arrLatestNews addObjectsFromArray:self.arrLatestNewsNew];
            } else {
//                if([[self.dictCurrentCategory objectForKey:kstrId] isEqualToString:kstrKeyForAllNews] || version2) {
                if([[self.dictCurrentCategory objectForKey:kstrId] isEqualToString:kstrKeyForAllNews]) {
                    // Check if article exists in current page and remove, otherwise pop off the last article in the list
                    if(self.numPageNoForLatest == 0) {
                        [[[self.dictLatestNews objectForKey:kstrContentItems] objectForKey:kstrContentItem] removeLastObject];
                    }
                }
                if([[[self.dictLatestNews objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0) {
                    self.arrLatestNewsNew = [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictLatestNews];
                    [self.arrLatestNews addObjectsFromArray:self.arrLatestNewsNew];
                }
            }
            
            if(self.numPageNoForLatest == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LATEST" object:nil];
            }
            
            [self setNumPageNoForLatest:numPageNoForLatest + 1];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ARTICLES object:nil];
            
            [self.dictRequestDate setObject:[NSDate date] forKey:[kcontentLatest stringByAppendingString:[self.dictCurrentCategory valueForKey:kstrId]]];
        } else if(tag == kInFocusNews) {
            DLog(@"Infocus");
            NSDictionary *dicCategory = (NSDictionary *)items ;
            
            self.dictLatestNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByInfocusItemResponse.GetLatestNewsByInfocusItemResult"];
            
            // Fill results from CoreData
            int dictCount;
            if([[self.dictLatestNews objectForKey:kstrContentItem] isKindOfClass:[NSArray class]])
            {
                dictCount = [[self.dictLatestNews objectForKey:kstrContentItem] count];
            }
            else
            {
                if([[self.dictLatestNews objectForKey:kstrContentItem] count] > 0)
                {
                    dictCount = 1;
                }
                else
                {
                    dictCount = 0;
                }
            }
            
            if(self.numPageNoForInFocus == 0 && dictCount < kDefaultBatchCountFirstPage)
            {
                int addCount = kDefaultBatchCountFirstPage;
                
                [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictLatestNews andInFocusId:self.strInFocusId];
                self.arrLatestNewsNew = [[CacheDataManager sharedCacheManager] getContentsWithInFocusId:self.strInFocusId withLimit:addCount];
                
                [self.arrLatestNews addObjectsFromArray:self.arrLatestNewsNew];
            }
            else
            {
                if([[self.dictLatestNews objectForKey:kstrContentItem] count] > 0)
                {
                    self.arrLatestNewsNew = [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictLatestNews];
                    [self.arrLatestNews addObjectsFromArray:self.arrLatestNewsNew];
                }
            }
            
            if(self.numPageNoForInFocus == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LATEST" object:nil];
            }
            
            [self setNumPageNoForInFocus:numPageNoForInFocus + 1];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ARTICLES object:nil];
            
            [self.dictRequestDate setObject:[NSDate date] forKey:[kcontentLatest stringByAppendingString:self.strInFocusId]];
        }
        //
        //////////////////////
        // VIDEO
        //////////////////////
        else if(tag == kVideo) {
            NSDictionary *dicCategory = (NSDictionary *)items;

            if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews])
            {
                self.dictVideo = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByContentTypeResponse.GetLatestNewsByContentTypeResult"];
            }
            else
            {
                self.dictVideo = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByCategoryAndContentTypeResponse.GetLatestNewsByCategoryAndContentTypeResult"];
            }
            
            // Fill results from CoreData
            int dictCount;
            if([[[self.dictVideo objectForKey:kstrContentItems] objectForKey:kstrContentItem] isKindOfClass:[NSArray class]])
            {
                dictCount = [[[self.dictVideo objectForKey:kstrContentItems] objectForKey:kstrContentItem] count];
            }
            else
            {
                if([[[self.dictVideo objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0)
                {
                    dictCount = 1;
                }
                else
                {
                    dictCount = 0;
                }
            }
            
            self.arrVideoNew = [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictVideo];
            [self.arrVideo addObjectsFromArray:self.arrVideoNew];

//            if(self.numPageNoForVideo == 0 && dictCount < kDefaultBatchCount)
//            {
//                int addCount = kDefaultBatchCount;
//                
//                [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictVideo];
//                self.arrVideoNew = [[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrVideo andCategoryId:[dictCurrentCategory valueForKey:kstrId] withLimit:addCount];
//                [self.arrVideo addObjectsFromArray:self.arrVideoNew];
//            }
//            else
//            {
//                if([[[self.dictVideo objectForKey:kstrContentItems] objectForKey:kstrContentItem] count]  > 0)
//                {
//                    self.arrVideoNew = [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictVideo];
//                    [self.arrVideo addObjectsFromArray:self.arrVideoNew];
//                }
//            }
            
            if(self.numPageNoForVideo == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO" object:nil];
            }
            
            [self setNumPageNoForVideo:self.numPageNoForVideo + 1];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_VIDEOS object:nil];
        }
        ///////////////////////
        // IMAGES
        ///////////////////////
        else if(tag == kImages)
        {
            NSDictionary *dicCategory = (NSDictionary *)items ;
            if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews])
            {
                self.dictImages = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByContentTypeResponse.GetLatestNewsByContentTypeResult"];
            }
            else
            {
                self.dictImages = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByCategoryAndContentTypeResponse.GetLatestNewsByCategoryAndContentTypeResult"];
            }
            
            // Fill results from CoreData
            int dictCount;
            if([[[self.dictImages objectForKey:kstrContentItems] objectForKey:kstrContentItem] isKindOfClass:[NSArray class]])
            {
                dictCount = [[[self.dictImages objectForKey:kstrContentItems] objectForKey:kstrContentItem] count];
            }
            else
            {
                if([[[self.dictImages objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0)
                {
                    dictCount = 1;
                }
                else
                {
                    dictCount = 0;
                }
            }
            
//            if(self.numPageNoForImages == 0 && dictCount < kDefaultBatchCount)
//            {
//                int addCount = kDefaultBatchCount;
//                
//                [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictImages];
//                self.arrImagesNew = [[CacheDataManager sharedCacheManager] getContentsWithContentType:kContentImages andCategoryId:[dictCurrentCategory valueForKey:kstrId] withLimit:addCount];
//                
//                [self.arrImages addObjectsFromArray:self.arrImagesNew];
//            }
//            else
//            {
//                if([[[self.dictImages objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0)
//                {
//                    self.arrImagesNew = [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictImages];
//                    [self.arrImages addObjectsFromArray:self.arrImagesNew];
//                }
//            }
            
            self.arrImagesNew = [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictImages];
            [self.arrImages addObjectsFromArray:self.arrImagesNew];
            
            if(self.numPageNoForImages == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"IMAGES" object:nil];
            }
            
            [self setNumPageNoForImages:numPageNoForImages + 1];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_IMAGES object:nil];
            
            [self.dictRequestDate setObject:[NSDate date] forKey:[kContentImages stringByAppendingString:[self.dictCurrentCategory valueForKey:kstrId]]];
        }
        ///////////////////////
        // AUDIO
        ///////////////////////
        else if(tag == kAudio) {
            NSDictionary *dicCategory = (NSDictionary *)items ;
            if([[self.dictCurrentCategory valueForKey:kstrId] isEqualToString:kstrKeyForAllNews])
            {
                self.dictAudio = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByContentTypeResponse.GetLatestNewsByContentTypeResult"];
            }
            else
            {
                self.dictAudio = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByCategoryAndContentTypeResponse.GetLatestNewsByCategoryAndContentTypeResult"];
            }
            
            // Fill results from CoreData
            int dictCount;
            if([[[self.dictAudio objectForKey:kstrContentItems] objectForKey:kstrContentItem] isKindOfClass:[NSArray class]])
            {
                dictCount = [[[self.dictAudio objectForKey:kstrContentItems] objectForKey:kstrContentItem] count];
            }
            else
            {
                if([[[self.dictAudio objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0)
                {
                    dictCount = 1;
                }
                else
                {
                    dictCount = 0;
                }
            }
            
//            if(self.numPageNoForAudio == 0 && dictCount < kDefaultBatchCount)
//            {
//                int addCount = kDefaultBatchCount;
//                
//                [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictAudio];
//                self.arrAudioNew = [[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrAudio andCategoryId:[dictCurrentCategory valueForKey:kstrId] withLimit:addCount];
//                
//                [self.arrAudio addObjectsFromArray:self.arrAudioNew];
//            }
//            else
//            {
//                if([[[self.dictAudio objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0)
//                {
//                    self.arrAudioNew = [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictAudio];
//                    [self.arrAudio addObjectsFromArray:self.arrAudioNew];
//                }
//            }
            
            self.arrAudioNew = [[CacheDataManager sharedCacheManager] addContentsWithItemArray:self.dictAudio];
            [self.arrAudio addObjectsFromArray:self.arrAudioNew];
            
            if(self.numPageNoForAudio == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIO" object:nil];
            }
            
            [self setNumPageNoForAudio:numPageNoForAudio + 1];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_AUDIO object:nil];
            
            [self.dictRequestDate setObject:[NSDate date] forKey:[kstrAudio stringByAppendingString:[self.dictCurrentCategory valueForKey:kstrId]]];
        }
        
        else if(tag == kSearchNews)
        {
            NSDictionary *dicCategory = (NSDictionary *)items;
            
            if([[self.dictCurrentCategory objectForKey:kstrId] isEqualToString:kstrKeyForAllNews])
            {
                self.dictSearchNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByKeywordResponse.GetLatestNewsByKeywordResult"];
            }
            else
            {
                self.dictSearchNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByKeywordAndCategoryResponse.GetLatestNewsByKeywordAndCategoryResult"];
            }
            
            // ContentType
            if(dictSearchNews == nil)
            {
                self.dictSearchNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByKeywordAndContentTypeResponse.GetLatestNewsByKeywordAndContentTypeResult"];
            }
            
            // Category and ContentType
            if(dictSearchNews == nil)
            {
                self.dictSearchNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetLatestNewsByKeywordAndCategoryAndContentTypeResponse.GetLatestNewsByKeywordAndCategoryAndContentTypeResult"];
            }
            
            if ([[self.dictSearchNews objectForKey:kstrContentItems] objectForKey:kstrContentItem] != nil)
            {
                [self.arrSearchNews addObjectsFromArray:[[CacheDataManager sharedCacheManager] convertContents:self.dictSearchNews]];
            }
                        
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"REFRESH_SEARCH" object:nil];
            
        }
        else if(tag == kStoryTimeline)
        {
            NSDictionary *dicCategory = (NSDictionary *)items;
            self.dictStoryTimeline = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetStoryTimelineByArticleIdResponse.GetStoryTimelineByArticleIdResult"];
                        
            NSMutableArray *storyArray = [[CacheDataManager sharedCacheManager] addRelatedStoryWithItemArray:self.dictStoryTimeline andParentID:strStoryTimeLineArticleID andArticleType:kstrTimeline];
            
            if([storyArray count] > 0)
            {
                [self.arrStoryTimeline addObjectsFromArray:storyArray];
            }
            
            // TODO - Remove arrStoryTimelineNew, since it doesn't work the same as Related or main Sections
            
            if (self.numPageNoForStoryTimeline == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_INIT_STORYTIME object:nil];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_RELOAD_STORYTIME object:nil];
            }
            
            [self setNumPageNoForStoryTimeline:numPageNoForStoryTimeline + 1];
        }
        else if(tag == kRelatedStory)
        {
            NSDictionary *dicCategory = (NSDictionary *)items ;
            self.dictRelatedStory = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetRelatedStoriesByArticleIdResponse.GetRelatedStoriesByArticleIdResult"];
            
            self.arrRelatedStoryNew = [[CacheDataManager sharedCacheManager] addRelatedStoryWithItemArray:self.dictRelatedStory andParentID:strRelatedStoryArticleID andArticleType:kstrRelated];
            [self.arrRelatedStory addObjectsFromArray:self.arrRelatedStoryNew];
            
            if (self.numRelatedStory == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_INIT_RELATED object:nil];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_RELOAD_RELATED object:nil];
            }
            
            [self setNumRelatedStory:numRelatedStory + 1];
            
        }
        else if(tag == kBreakingNews)
        {
            NSDictionary *dicCategory = (NSDictionary *)items ;
            self.dictBreakingNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetBreakingNewsResponse.GetBreakingNewsResult"];
            
            if ([[self.dictBreakingNews valueForKey:kstrIsBreakingNews] boolValue] == TRUE)
            {
                // TODO - Parse in CacheDataManager             
                NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
                Contents *breakingContents = (Contents *)[[Contents alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
                
                [breakingContents setArticleID:[self.dictBreakingNews objectForKey:kstrArticleId]];
                
                // TODO - If this is an Array, does it break the app? I think, first check if it's null, or whatever, then just grab the Categories instead
                DLog(@"BREAKING NEWS CATEGORIES : %@", [self.dictBreakingNews objectForKey:kstrCategories]);
                DLog(@"BREAKING NEWS CATEGORIES : %@", [[[self.dictBreakingNews objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrId]);
                
                if([[self.dictBreakingNews objectForKey:kstrCategories] isKindOfClass:[NSArray class]])
                {
                    [breakingContents setCategory:[[[[self.dictBreakingNews objectForKey:kstrCategories] objectAtIndex:0]objectForKey:kstrCategory] objectForKey:kstrId]];
                }
                else
                {
                    [breakingContents setCategory:[[[self.dictBreakingNews objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrId]];
                }
                
                [breakingContents setCategory:[[[self.dictBreakingNews objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrId]];
                [breakingContents setCategoryName:[[[self.dictBreakingNews objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrName]];
                [breakingContents setFeaturedImageUrl:[self.dictBreakingNews objectForKey:kstrFeaturedImageUrl]];
                [breakingContents setImageLargeURL:[self.dictBreakingNews objectForKey:kstrImageLargeURL]];
                [breakingContents setThumbnilImageUrl:[self.dictBreakingNews objectForKey:kstrImageThumbnailURL]];
                [breakingContents setIntroParagraph:[self.dictBreakingNews objectForKey:kstrIntroParagraph]];
                [breakingContents setIsBreakingNews:[NSNumber numberWithBool:[[self.dictBreakingNews objectForKey:kstrIsBreakingNews] boolValue]]];
                [breakingContents setIsLeadStory:[NSNumber numberWithBool:[[self.dictBreakingNews objectForKey:kstrIsLeadStory] boolValue]]];
                [breakingContents setPublishDate:[self.dictBreakingNews objectForKey:kstrPublishDate]];
                [breakingContents setContentTitle:[self.dictBreakingNews objectForKey:kstrTitle]];
                [breakingContents setContentURL:[self.dictBreakingNews objectForKey:kstrURL]];
                
                [self.arrBreakingNews addObject:breakingContents];
                [self ShowBreakingNews];
            }
        /* Content Item */
        } else if (tag == kContentItem) {
            
            // Let's treat it exactly as breaking news and hope for the best...
            
            NSDictionary *dicCategory = (NSDictionary *)items;
            self.dictBreakingNews = [dicCategory retrieveForPath:@"soap:Envelope.soap:Body.GetContentItemResponse.GetContentItemResult"];
                                     
            NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
            Contents *breakingContents = (Contents *)[[Contents alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
            
            [breakingContents setArticleID:[self.dictBreakingNews objectForKey:kstrArticleId]];
            
            if([[self.dictBreakingNews objectForKey:kstrCategories] isKindOfClass:[NSArray class]])
            {
                [breakingContents setCategory:[[[[self.dictBreakingNews objectForKey:kstrCategories] objectAtIndex:0]objectForKey:kstrCategory] objectForKey:kstrId]];
            }
            else
            {
                [breakingContents setCategory:[[[self.dictBreakingNews objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrId]];
            }
            
            [breakingContents setCategory:[[[self.dictBreakingNews objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrId]];
            [breakingContents setCategoryName:[[[self.dictBreakingNews objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrName]];
            [breakingContents setFeaturedImageUrl:[self.dictBreakingNews objectForKey:kstrFeaturedImageUrl]];
            [breakingContents setImageLargeURL:[self.dictBreakingNews objectForKey:kstrImageLargeURL]];
            [breakingContents setThumbnilImageUrl:[self.dictBreakingNews objectForKey:kstrImageThumbnailURL]];
            [breakingContents setIntroParagraph:[self.dictBreakingNews objectForKey:kstrIntroParagraph]];
            [breakingContents setIsBreakingNews:[NSNumber numberWithBool:[[self.dictBreakingNews objectForKey:kstrIsBreakingNews] boolValue]]];
            [breakingContents setIsLeadStory:[NSNumber numberWithBool:[[self.dictBreakingNews objectForKey:kstrIsLeadStory] boolValue]]];
            [breakingContents setPublishDate:[self.dictBreakingNews objectForKey:kstrPublishDate]];
            [breakingContents setContentTitle:[self.dictBreakingNews objectForKey:kstrTitle]];
            [breakingContents setContentURL:[self.dictBreakingNews objectForKey:kstrURL]];
            
            [self.arrBreakingNews removeAllObjects];
            [self.arrBreakingNews addObject:breakingContents];
            
            // Post a notification to show this guy
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_BREAKING_NEWS_FROM_NOTIFICATION_DISPLAY object:self];
            [[NSNotificationCenter defaultCenter] removeObserver:kNOTIFICATION_BREAKING_NEWS_FROM_NOTIFICATION_DISPLAY];
            
        }
        /* Context Menu Requests */
        else if(tag == kWeatherTag)
        {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.GetWeatherFeedResponse.GetWeatherFeedResult"];
            self.dictWeather = [dic objectForKey:@"Reports"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WEATHER_REQUEST" object:self];
        }
        else if(tag == kMarketCurrencyTag)
        {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.GetCurrenciesDataResponse.GetCurrenciesDataResult.Data"];
            int amount = [[dic objectForKey:@"CurrenciesDataResponseRecord"] count];
            NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
            for (int x = 0; x < amount; x++) {
                [arrTmp addObject:[[dic objectForKey:@"CurrenciesDataResponseRecord"] objectAtIndex:x]];
            }
            [self.dictMarkets setObject:arrTmp forKey:@"Currencies"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MARKETS_REQUEST" object:self];
        }
        else if(tag == kMarketCommodityTag)
        {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.GetCommoditiesDataResponse.GetCommoditiesDataResult.Data"];
            int amount = [[dic objectForKey:@"CommoditiesDataResponseRecord"] count];
            NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
            for (int x = 0; x < amount; x++) {
                [arrTmp addObject:[[dic objectForKey:@"CommoditiesDataResponseRecord"] objectAtIndex:x]];
            }
            self.dictMarkets[@"Commodities"] = arrTmp;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MARKETS_REQUEST" object:self];
        }
        else if (tag == kBulletinTag)
        {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.GetAudioBulletinsResponse.GetAudioBulletinsResult.Bulletins.Types"];
            // let us fix the format right fudging here
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
            int amount = [[dic objectForKey:@"BulletinType"] count];
            for (int x = 0; x < amount; x++) {
                NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
                NSString *type = [[[dic objectForKey:@"BulletinType"] objectAtIndex:x] objectForKey:@"Type"];
                int bulletinCount = [[[[[dic objectForKey:@"BulletinType"] objectAtIndex:x] objectForKey:@"Bulletins"] objectForKey:@"Bulletin"] count];
                for (int y = 0; y < bulletinCount; y++) {
                    [arrTmp addObject:[[[[[dic objectForKey:@"BulletinType"] objectAtIndex:x] objectForKey:@"Bulletins"] objectForKey:@"Bulletin"]  objectAtIndex:y]];
                }
                [mDic setObject:arrTmp forKey:type];
            }
            self.dictBulletins = mDic;
            DLog(@"Bulletins %@",mDic);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BULLETIN_REQUEST" object:self];
        }
        else if (tag == kTrafficTag)
        {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.GetTrafficFeedResponse.GetTrafficFeedResult.Reports"];
            // let us fix the format right fudging here
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
            int amount = [[dic objectForKey:@"TrafficForCity"] count];
            NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
            for (int x = 0; x < amount; x++) {
                [arrTmp addObject:[[dic objectForKey:@"TrafficForCity"] objectAtIndex:x]];
            }
            [mDic setObject:arrTmp forKey:@"Traffic"];
            self.dictTraffic = mDic;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TRAFFIC_REQUEST" object:self];
        }
        else if (tag == kCommentsTag)
        {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.GetAllCommentsResponse.GetAllCommentsResult"];
            
            
            // ******************************************************************** //
            // This gets the comment count for the current article in the response. //
            // ******************************************************************** //
            if ([dic objectForKey:@"CommentCount"]) {
                self.articleCommentCount = ((NSNumber *)[dic objectForKey:@"CommentCount"]).intValue;
            } else {
                self.articleCommentCount = 0;
            }
            // ******************************************************************** //
            
            
            NSMutableArray *array;
            
            if([[[dic objectForKey:@"Comments"] objectForKey:@"ArticleComment"] isKindOfClass:[NSArray class]])
            {
                array = [[NSMutableArray alloc] initWithArray:[[dic objectForKey:@"Comments"] objectForKey:@"ArticleComment"]];
            }
            else
            {
                array = [[NSMutableArray alloc] initWithObjects:[[dic objectForKey:@"Comments"] objectForKey:@"ArticleComment"], nil];
            }
            
            if (array && array.count > 0)
            {
                if (getCommentsBlock )
                {
                    
                }
                else if (self.numPageNoForComments <= 1)
                {
                    // Parse Comments - TODO - Move this to the CachedDataManager and return array after inserting into CoreData
                    [self.arrComments removeAllObjects];
                }
                
                
                for(int i = 0; i < [array count]; i++)
                {
                    NSMutableDictionary *commentDic = [array objectAtIndex:i];
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityComments inManagedObjectContext:appDelegate.managedObjectContext];
                    Comments *comment = (Comments *)[[Comments alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
                    
                    [comment setCommentId:[commentDic objectForKey:@"CommentId"]];
                    [comment setCommentLikes:[commentDic objectForKey:@"CommentLikes"]];
                    [comment setImageUrl:[commentDic objectForKey:@"ImageUrl"]];
                    [comment setPostedDate:[commentDic objectForKey:@"PostedDate"]];
                    [comment setReported:[commentDic objectForKey:@"Reported"]];
                    [comment setText:[commentDic objectForKey:@"Text"]];
                    [comment setUserId:[commentDic objectForKey:@"UserId"]];
                    [comment setUserName:[commentDic objectForKey:@"Username"]];
                    
                    // Comment Replies Handled
                    if ([commentDic objectForKey:@"Replies"])
                    {
                        NSArray *commentRepliesArray = nil;
                        
                        if([[[commentDic objectForKey:@"Replies"] objectForKey:@"ArticleComment"] isKindOfClass:[NSArray class]]) {
                            commentRepliesArray = [[NSMutableArray alloc] initWithArray:[[commentDic objectForKey:@"Replies"] objectForKey:@"ArticleComment"]];
                        } else {
                            commentRepliesArray = [[NSMutableArray alloc] initWithObjects:[[commentDic objectForKey:@"Replies"] objectForKey:@"ArticleComment"], nil];
                        }
                        
                        if (commentRepliesArray && commentRepliesArray.count > 0)
                        {
                            NSMutableArray *replyArray = [NSMutableArray array];
                            
                            for (NSDictionary *commentReplyDic in commentRepliesArray)
                            {
                                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kEntityCommentReplies inManagedObjectContext:appDelegate.managedObjectContext];
                                CommentReplies *commentReply = [[CommentReplies alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
                                
                                [commentReply setCommentId:[commentReplyDic objectForKey:@"CommentId"]];
                                [commentReply setCommentLikes:[commentReplyDic objectForKey:@"CommentLikes"]];
                                [commentReply setImageUrl:[commentReplyDic objectForKey:@"ImageUrl"]];
                                [commentReply setPostedDate:[commentReplyDic objectForKey:@"PostedDate"]];
                                [commentReply setReported:[commentReplyDic objectForKey:@"Reported"]];
                                [commentReply setText:[commentReplyDic objectForKey:@"Text"]];
                                [commentReply setUserId:[commentReplyDic objectForKey:@"UserId"]];
                                [commentReply setUserName:[commentReplyDic objectForKey:@"Username"]];
                                
                                commentReply.comment = comment;
                                
                                [replyArray addObject:commentReply];
                            }
                            comment.commentReplyArray = [NSArray arrayWithArray:replyArray];
                        }
                    }
                    
                    
                    [self.arrComments addObject:comment];
                }
            }
            
            
            [self.dictRequestDate setObject:[NSDate date] forKey:commentArticleId];
            
            self.isLoadingComments = FALSE;
            
            if (getCommentsBlock)
            {
                getCommentsBlock(YES, nil, self.arrComments);
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"COMMENTS_REQUEST" object:nil];
            }
        } else if (tag == kTerms) {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.GetTermsAndConditionsResponse"];
            self.termsText = [dic objectForKey:@"GetTermsAndConditionsResult"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TERMS_REQUEST" object:self];
        } else if (tag == kContributeKeyTag) {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.GetSubmissionSessionKeyResponse"];
            self.contributeKey = [dic objectForKey:@"GetSubmissionSessionKeyResult"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRIBUTEKEY_REQUEST" object:self];
        } else if (tag == kContributeTag) {
            NSDictionary *dic = (NSDictionary *)items;
            dic = [dic retrieveForPath:@"soap:Envelope.soap:Body.PostSubmissionResponse"];
            // do a bool for the success here
            if ([[dic objectForKey:@"PostSubmissionResult"] isEqualToString:@"OK"]) {
                self.contributeSubmissionSuccess = YES;
            } else {
                self.contributeSubmissionSuccess = NO;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRIBUTESUBMISSION_REQUEST" object:self];
        } else if (tag == kContributeFileTag) {
            DLog(@"GREAT BLOODY SUCCESS!!! %@",items);
        }
    }
    else
    {
        // BIG MASSIVE TODO OVER HERE...
        DLog(@"\n\n");
        DLog(@"###############################################################");
        DLog(@"###############################################################");
        DLog(@"HANDLE AN API ERROR FOR %d",tag);
        DLog(@"error message = %@",message);
        DLog(@"error = %@", error);
        DLog(@"###############################################################");
        DLog(@"###############################################################\n\n");
        
        if(tag==kCategory)
        {
            DLog(@"No categories!");
            self.arrCategories = [[CacheDataManager sharedCacheManager] getCatogery];
        } else if (tag == kTerms) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TERMS_REQUEST" object:self];
        } else if (tag == kContributeKeyTag) {
            self.contributeKey = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRIBUTEKEY_REQUEST" object:self];
        } else if (tag == kContributeTag) {
            self.contributeSubmissionSuccess = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRIBUTESUBMISSION_REQUEST" object:self];
        }
        else if(tag == kInFocus)
        {
            DLog(@"No in focus!");
            self.arrInFocus = [[CacheDataManager sharedCacheManager] getInFocusArray];
        }
        else if(tag == kAuthenticate)
        {
            [self showAlert:@"Sign In" message:@"We are unable to sign you in at this time. Please try again later."];
        }
        else if(tag == kBulletinTag)
        {
            // TODO handle error
            DLog(@"Error from EWN for the bulletins!!!");
        }
        else if(tag == kLeadingNews)
        {
            DLog(@"No leading news!");
            // [self showAlert:nil message:@"Unable to retrieve the latest news. Please try again later."];
        }
        else if(tag == kLatestNews)
        {
            if(self.numPageNoForLatest == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LATEST" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RETRY" object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ARTICLES object:nil];
        }
        else if(tag == kInFocusNews)
        {
            DLog(@"No IN FOCUS!!!");
            if(self.numPageNoForInFocus == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LATEST" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RETRY" object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ARTICLES object:nil];
        }
        else if(tag == kVideo)
        {
            DLog(@"No VIDEOS!!!");
            if(self.numPageNoForVideo == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO" object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_VIDEOS object:nil];
        }
        else if(tag == kImages)
        {
            DLog(@"No IMAGES!!!");
            if(self.numPageNoForImages == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"IMAGES" object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_IMAGES object:nil];
        }
        else if(tag == kAudio)
        {
            DLog(@"No AUDIO!!!");
            if(self.numPageNoForAudio == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIO" object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_AUDIO object:nil];
        }
        else if(tag == kSearchNews)
        {
            DLog(@"NO SEARCH RESULTS");
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"REFRESH_SEARCH" object:nil];
        }
        else if(tag == kStoryTimeline)
        {
            if (self.numPageNoForStoryTimeline == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_INIT_STORYTIME object:nil];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_RELOAD_STORYTIME object:nil];
            }
        }
        else if(tag == kRelatedStory)
        {
            if (self.numRelatedStory == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_INIT_RELATED object:nil];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_RELOAD_RELATED object:nil];
            }
        } else if(tag == kMarketCurrencyTag || tag == kMarketCommodityTag) {
            DLog(@"RETRY THE MARKET INFO OR SOMETHING!!!");
        } else {
            DLog(@"Unkown request error!");
        }
    }
}

-(void)setProgess:(CGFloat)progress withTag:(int)tag
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_INIT_LOAD_PROGRESS object:[NSNumber numberWithFloat:progress]];
}

/**-----------------------------------------------------------------
 Function Name  : showAlertForNoConnection
 Created By     : Arpit Jain
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : shows an alert for no internet connection.
 ------------------------------------------------------------------*/
-(void) showAlertForNoConnection
{
    if([[CacheDataManager sharedCacheManager] hasCacheDataExpiredForContent:kEntityContents])
    {
        if(![alrtvwNotReachable.view isDescendantOfView:self.window])
        {
            alrtvwNotReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
            [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:0];
            alrtvwNotReachable.lblHeading.text=[NSString stringWithFormat:kstrConnectionError];
            alrtvwNotReachable.lblDetail.text=[NSString stringWithFormat:kstrNoConnectionMessage];
        }
    }
    else
    {
        if(![alrtvwNotReachable.view isDescendantOfView:self.window])// && self.isOnline)
        {
            if(self.isAlreadyOnline == self.isOnline)
            {
                alrtvwNotReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
                [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:1];
                alrtvwNotReachable.lblHeading.text=[NSString stringWithFormat:kstrConnectionError];
                alrtvwNotReachable.lblDetail.text=[NSString stringWithFormat:kstrNoConnectionButHaveCacheDataMessage];
                [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
                [alrtvwNotReachable.view setTag:kALERT_TAG_NO_CONNECTION];
            }
            else
            {
            }
        }
    }
}

-(void)showAlert:(NSString *)titleString message:(NSString *)messageString
{
    if(![alrtvwNotReachable.view isDescendantOfView:self.window])// && self.isOnline)
    {
        alrtvwNotReachable = [[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwNotReachable show:YES ShowDetail:YES NumberOfButtons:1];
        alrtvwNotReachable.lblHeading.text = titleString;
        alrtvwNotReachable.lblDetail.text = messageString;
        [alrtvwNotReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
    }
}

/******************************************************************
 *  Function       : addProgressViewWithMessage                   *
 *  Purpose        : Displaying the Progress view on the window.  *
 *  Created By     : Arpit Jain                                   *
 *  Created On     : N/A                                          *
 *  Last Modified  : N/A                                          *
 *****************************************************************/
- (void)addProgressViewWithMessage:(NSString*)strMessage
{
    // TODO - Add this to the ContentsListView Class, and just trigger a method to display it when necessary ...
    progressView = [[UIView alloc] initWithFrame:appDelegate.window.frame];
	[progressView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.45]];
	[progressView setUserInteractionEnabled:TRUE];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [progressView setFrame:CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y - 20, progressView.frame.size.width, progressView.frame.size.height + 20)];
    }
    
    float viewHeight, viewWidth;
    
    viewWidth = progressView.frame.size.width;
    viewHeight = progressView.frame.size.height;
    
    UILabel *titleLabel;
    UIActivityIndicatorView *showProcessIndicator;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        showProcessIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [showProcessIndicator setFrame:CGRectMake((viewWidth/2)-18, (viewHeight/2)-150, 30, 30)];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (viewHeight/2)-100, viewWidth-40, 50)];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        showProcessIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [showProcessIndicator setFrame:CGRectMake((viewWidth/2)-15, (viewHeight/2)-60, 30, 30)];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (progressView.frame.size.height/2)-25, 280, 30)];
        [titleLabel setMinimumFontSize:10.0f];
        [titleLabel setAdjustsFontSizeToFitWidth:TRUE];
    }
    
    [showProcessIndicator setTag:3];
    [showProcessIndicator setCenter:[progressView center]];
    [progressView addSubview:showProcessIndicator];
    [showProcessIndicator startAnimating];
    
    [titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:18.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTag:1];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setText:strMessage];
    [appDelegate.window addSubview:progressView];
}

/****************************************************************
 *  Function       : closeProgressView                          *
 *  Purpose        : Close the ProgressView and remove from the *
 *                 : window.                                    *
 *  Created By     : Sharvin Shah                               *
 *  Created On     : N/A                                        *
 *  Last Modified  : N/A                                        *
 ***************************************************************/
- (void)closeProgressView
{
    [progressView removeFromSuperview];
}

/****************************************************************
 *  Function       : resetDictRequestDateForCategoryType        *
 *  Purpose        : Reset the selected Date to allow a Refresh *
 ***************************************************************/
-(void)resetDictRequestDateFor:(NSString *)CategoryType
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    [self.dictRequestDate setObject:date forKey:[CategoryType stringByAppendingString:[self.dictCurrentCategory valueForKey:kstrId]]];
}

@end
