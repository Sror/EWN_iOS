//
//  WebserviceComunication.h
//  EWN
//
//  Created by Macmini on 23/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
/**------------------------------------------------------------------------
 File Name      : WebserviceComunication.h
 Created By     : Arpit Jain
 Created Date   :
 Purpose        : In this class all webservice calling and response are created here. And database storing is also has been done here.
 -------------------------------------------------------------------------*/

/*
       .==.        .==.
      //`^\\      //^`\\
     // ^ ^\(\__/)/^ ^^\\
    //^ ^^ ^/6  6\ ^^ ^ \\
   //^ ^^ ^/( .. )\^ ^ ^ \\
  // ^^ ^/\| v”"v |/\^ ^ ^\\
 // ^^/\/ /  `~~`  \ \/\^ ^\\
 —————————–————————–————————–——
  THE CODE DRAGON IS WATCHING
 ——————–————————–————————–—————
 Tread lightly when changing code...
 ... PS: If I have gone missing, you now know why...
 
 
 
 */



#import <Foundation/Foundation.h>
#import <UIKit/UIAlertView.h>
#import "CommanConstants.h"
#import "WebAPIRequest.h"
#import "Category_Items.h"
#import "CustomAlertView.h"
#import "SettingsViewController.h"
#import "UIAlertView+Extended.h"


@interface WebserviceComunication : NSObject <WebAPIRequestDelegate>
{
//    WebAPIRequest *webApiRequest;
    
    NSMutableArray *arrCategories;
    NSMutableArray *arrInFocus;
    NSMutableDictionary *dictCurrentCategory;
    NSString *strInFocusId;
    NSString *strStoryTimeLineArticleID;
    NSString *strRelatedStoryArticleID;
    
    NSMutableDictionary *dictLeadingNews;
    NSMutableDictionary *dictLatestNews;
    NSMutableDictionary *dictVideo;
    NSMutableDictionary *dictImages;
    NSMutableDictionary *dictAudio;
    NSMutableDictionary *dictSearchNews;
    NSMutableDictionary *dictStoryTimeline;
    NSMutableDictionary *dictRelatedStory;
    NSMutableDictionary *dictBreakingNews;
    
    NSMutableDictionary *dictRequest; // Request WebAPIRequest
    NSMutableDictionary *dictRequestDate; // Request Date
        
    int numPageNoForLatest;
    int numPageNoForInFocus;
    int numPageNoForVideo;
    int numPageNoForImages;
    int numPageNoForAudio;
    int numPageNoForAllNews;
    int numPageNoForSearchList;
    int numPageNoForStoryTimeline;
    int numRelatedStory;
    
    CustomAlertView *alrtvwNotReachable;
    CustomAlertView *alrtvwReachable;
    NSTimer *callTimer;
    UIView *progressView;
    UIView *progresSubView;
    
    BOOL isAllocateFirstTime;
    
    int numcounterCategory;
    int numcounterLeading;
    int numcounterLatest;
    int numcountervideo;
    int numcounterimages;
    int numcounterAudio;
    int numcounterSearch;
    int numcounterStoryLines;
    int numcounterRelatedStory;
    NSString *strSearchText;
    NSString *commentArticleId;
}
@property (nonatomic, strong) WebAPIRequest *webApiRequest;
@property (nonatomic, strong) NSMutableDictionary *dictAuthenticate;
@property (nonatomic, strong) NSMutableArray *arrCategories;
@property (nonatomic, strong) NSMutableArray *arrInFocus;
@property (nonatomic, strong) NSMutableDictionary *dictCurrentCategory;
@property (nonatomic, strong) NSString *strInFocusId;
@property (nonatomic, strong) NSString *termsText;
@property (nonatomic, readwrite) int numPageNoForLatest;
@property (nonatomic, readwrite) int numPageNoForInFocus;
@property (nonatomic, readwrite) int numPageNoForVideo;
@property (nonatomic, readwrite) int numPageNoForImages;
@property (nonatomic, readwrite) int numPageNoForAudio;
@property (nonatomic, readwrite) int numPageNoForSearchList;
@property (nonatomic, readwrite) int numPageNoForStoryTimeline;
@property (nonatomic, readwrite) int numPageNoForComments;
@property (nonatomic, readwrite) int numRelatedStory;
@property (nonatomic, readwrite) int numPageNoForAllNews;
@property (nonatomic, readwrite) int articleCommentCount;
@property (nonatomic, readwrite) BOOL isOnline;
@property (nonatomic, readwrite) BOOL isAlreadyOnline;
@property (nonatomic, readwrite) BOOL isAlreadyOffLine;
@property (nonatomic, readwrite) BOOL isStartupComplete;
@property (nonatomic, readwrite) BOOL isAllocateFirstTime;
@property (nonatomic, readwrite) BOOL isLoadingComments;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CustomAlertView *alrtvwNotReachable;
@property (nonatomic, strong) CustomAlertView *alrtvwReachable;
@property (nonatomic, strong) NSMutableDictionary *dictCommentPost;
@property (nonatomic, strong) NSMutableDictionary *dictLeadingNews;
@property (nonatomic, strong) NSMutableDictionary *dictLatestNews;
@property (nonatomic, strong) NSMutableDictionary *dictStoryTimeline;
@property (nonatomic, strong) NSMutableDictionary *dictRelatedStory;
@property (nonatomic, strong) NSMutableDictionary *dictBreakingNews;
@property (nonatomic, strong) NSMutableDictionary *dictRequest;
@property (nonatomic, strong) NSMutableDictionary *dictRequestDate;
@property (nonatomic, strong) NSMutableDictionary *dictWeather;
@property (nonatomic, strong) NSMutableDictionary *dictBulletins;
@property (nonatomic, strong) NSMutableDictionary *dictMarkets;
@property (nonatomic, strong) NSMutableDictionary *dictTraffic;
@property (nonatomic, strong) NSMutableArray *arrLeadingNews;
@property (nonatomic, strong) NSMutableArray *arrLatestNews;
@property (nonatomic, strong) NSMutableArray *arrLatestNewsNew;
@property (nonatomic, strong) NSMutableArray *arrVideo;
@property (nonatomic, strong) NSMutableArray *arrVideoNew;
@property (nonatomic, strong) NSMutableArray *arrImages;
@property (nonatomic, strong) NSMutableArray *arrImagesNew;
@property (nonatomic, strong) NSMutableArray *arrAudio;
@property (nonatomic, strong) NSMutableArray *arrAudioNew;
@property (nonatomic, strong) NSMutableArray *arrStoryTimeline;
@property (nonatomic, strong) NSMutableArray *arrStoryTimelineNew;
@property (nonatomic, strong) NSMutableArray *arrRelatedStory;
@property (nonatomic, strong) NSMutableArray *arrRelatedStoryNew;
@property (nonatomic, strong) NSMutableArray *arrBreakingNews;
@property (nonatomic, strong) NSMutableArray *arrLastStoryTimeline;
@property (nonatomic, strong) NSMutableArray *arrLastRelatedStory;
@property (nonatomic, strong) NSMutableArray *arrSearchNews;
@property (nonatomic, strong) NSMutableArray *arrComments;
@property (nonatomic, strong) NSMutableDictionary *dictSearchNews;
@property (nonatomic, strong) NSMutableDictionary *dictVideo;
@property (nonatomic, strong) NSMutableDictionary *dictImages;
@property (nonatomic, strong) NSMutableDictionary *dictAudio;
@property (nonatomic, strong) NSMutableDictionary *dictLikeComment;
@property (nonatomic, strong) NSMutableDictionary *dictReportComment;
@property (nonatomic, strong) NSMutableDictionary *dictReplyComment;
@property (nonatomic, strong) NSString *contributeKey;
@property (nonatomic, assign) BOOL isInFocus;
@property (nonatomic, assign) BOOL contributeSubmissionSuccess;

// Contribute
-(void)getContributeKey;
-(void)submitContributeText:(NSString *)contributeMessage;
-(void)submitContributeFile:(NSString *)contributeFile;

-(void)getAuthentication;
-(void)getCategory;
-(void)getInFocus;
-(void)getLeadingNews;
-(void)getLatestNews;
-(void)getInFocusNews;
-(void)getVedio;
-(void)getImages;
-(void)getAudio;
-(void)getMarkets;
-(void)getContentItem:(NSString *)articleId;
-(void)getTerms;
-(void)getBreakingNews;
-(void)searchNewsByText:(NSString *)searchText;
-(void)searchNewsByText:(NSString *)searchText ContentType:(NSString *)contentType;
-(void)searchNewsByText:(NSString *)searchText Category:(NSString *)category ContentType:(NSString *)contentType;
-(void)showAlertForNoConnection;
-(void)showAlert:(NSString *)titleString message:(NSString *)messageString;

-(void)getLatestNewsInit;
-(void)getInFocusNewsInit;
-(void)getVedioInit;
-(void)getImagesInit;
-(void)getAudioInit;
-(void)getStorytimelineByArticleId : (NSString *)strArcticleid;
-(void)getRelatedStoryByArticleId : (NSString *)strArcticleid;
-(void)requestCancel;

/* COMMENTS */
-(void)postComment;
-(void)reportCommentWithDict:(NSDictionary *)dictionary completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion;
-(void)likeCommentWithDict:(NSDictionary *)dictionary completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion;
-(void)replyCommentWithDict:(NSDictionary *)dictionary completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion;

-(NSString *)convertContentType:(NSString *)contentType;

-(void)postFeedback:(NSString *)messageString completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion;

/* Context Menu */
-(void)getWeather;
-(void)getBulletins;
-(void)getTraffic;
-(void)getComments;
-(void)getCommentsInit:(NSString *)articleId;
-(void)getComments:(NSString *)articleId pageCount:(NSInteger)count batchSize:(NSInteger)batchSize completion:(void (^)(BOOL successful, NSError *error, NSArray *dataCollection))completion;

- (NSURL *)prepareURLForFile : (NSString *)fileName withContentType: (NSString *)contentype;

+ (id)sharedCommManager;

- (id)init;
- (void)ShowBreakingNews;
- (void)addProgressViewWithMessage:(NSString*)strMessage;
- (void)closeProgressView;
- (void)resetDictRequestDateFor:(NSString *)CategoryType;

//- (void)addProgressSubViewWithMessage:(NSString*)strMessage;
//- (void)updateProgressBar;

@end
