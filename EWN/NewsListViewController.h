//
//  NewsListViewController.h
//  EWN
//
//  Created by Sumit Kumar on 4/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
/**------------------------------------------------------------------------
 File Name      : NewsListViewController.h
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Purpose        : Prepare the base for desplay the news by scrolling.
 -------------------------------------------------------------------------*/
#import <UIKit/UIKit.h>
#import "ContentsListView.h"
#import "ContentsListViewController.h"
#import "SearchNewsListViewController.h"
#import "ArticleDetailMaster.h"
#import "MNMBottomPullToRefreshView.h"

typedef enum {
    
    DragDownViewContentTypeLatest = 0,
    DragDownViewContentTypeAudio = 1,
    DragDownViewContentTypeVideo = 2,
    DragDownViewContentTypeImages = 3
    
} DragDownViewContentType;

@interface NewsListViewController : UIViewController<WebAPIRequestDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
    NSString *strXibContentList;
    NSString *strXibSearchContentList;
    
    BOOL isCompleteAnimation;
    IBOutlet UIScrollView *scrlvwNewsContent;
    ContentsListViewController *latestContentsView;
    ContentsListViewController *videoContentsView;
    ContentsListViewController *imagesContentsView;
    ContentsListViewController *audioContentsView;
    ContentsListViewController *twitterContentsView;
    UISwipeGestureRecognizer *recognizer;
    ArticleDetailMaster *articleDetailMaster;
    
    float numLastContentOffset;
    
    BOOL bIsRunningReload;
    BOOL isStartupComplete;
    BOOL bIsSearchNewsVisible;
    BOOL isInFocus;
    CGFloat currentX;
    double lastOffset;
    
    NSMutableArray *yourPagesArray;
    int numVisiblePages;
}

@property (nonatomic, strong) UIToolbar *tlbListTop;
@property (nonatomic, strong) IBOutlet UIScrollView *scrlvwNewsContent;
@property (nonatomic, strong) ContentsListViewController *latestContentsView;
@property (nonatomic, strong) ContentsListViewController *videoContentsView;
@property (nonatomic, strong) ContentsListViewController *imagesContentsView;
@property (nonatomic, strong) ContentsListViewController *audioContentsView;
@property (nonatomic, strong) ContentsListViewController *twitterContentsView;
@property (nonatomic, strong) SearchNewsListViewController *searchView;
@property (nonatomic, strong) UIImageView *topBackground;
@property (nonatomic) int pages;

@property (nonatomic, readwrite)DragDownViewContentType dragDownContentType;

-(Boolean)getIsInFocus;

- (void)animateScrollviewleft;
- (void)animateScrollviewright;

- (void)ReloadAllData;
- (void)RefreshAllData;
- (void)ResetAllData;
- (void)FetchAllData;

- (void)ReloadInFocus;

- (void)EnableSearchView:(NSString*)strKeyword;
- (void)DisabelSearchView;

- (void)enableInFocus;
- (void)disableInFocus;

//- (void)enableSettingsView;
//- (void)disableSettingsView;
//
//- (void)enableContactPage;
//- (void)disableContactPage;

- (void)completeLatestNews;
- (void)completeVideo;
- (void)completeImages;
- (void)completeAudio;
- (void)retryLatestNews;

- (void)updateTitles;

@end
