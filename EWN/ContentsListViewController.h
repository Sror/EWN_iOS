//
//  ContentsListViewController.h
//  EWN
//
//  Created by Macmini on 23/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
/**------------------------------------------------------------------------
 File Name      : ContentsListViewController.h
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Purpose        : Desplay the news Articles in scroll view with dynamic content offset of scollview.
 -------------------------------------------------------------------------*/

#import <Foundation/Foundation.h>
#import "WebAPIRequest.h"
#import "MNMBottomPullToRefreshManager.h"
#import "ODRefreshControl.h"

@interface ContentsListViewController : UIViewController <WebAPIRequestDelegate, UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient, UIWebViewDelegate>
{
    UIView *progressView;
    UIToolbar *tlbListTop;
    UILabel *lblCurrentContent; 
    UILabel *lblNextContent;
    UILabel *lblLoadMore;
    NSString *strSelfCurrentContentType;
    UIScrollView *scrollView_;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    ODRefreshControl *refreshControl;

    /**
     * Reloads (for testing purposes)
     */
    NSUInteger reloads_;
    
    int numNextX;
    int numNextY;
    int numTagCounter;
    
    BOOL isCompleteReload;
    
    UIButton *retryButton;
}

@property (nonatomic, strong) UIViewController *mainView;

@property (nonatomic, strong) UIToolbar *tlbListTop;
@property (nonatomic, strong) UILabel *lblCurrentContent;
@property (nonatomic, strong) UILabel *lblNextContent;
@property (nonatomic, strong) IBOutlet UIScrollView *scrlvwContentList;
@property (nonatomic, strong) NSString *strSelfCurrentContentType;
@property (nonatomic, strong) UIButton *retryButton;
@property bool showAds; // this is set by common constants
@property bool displayAds; // this is to switch them off when running out of memory

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil CurrentContentType:(NSString *)strCurrentContentType NextContentType:(NSString *)strNextContentType;
- (void)allocateAndCreateViews;
- (void)removeWebServiceDictonary;
- (void)SaveThumbImageToDatabaseForArticle:(NSUInteger)articleTag;
- (UIImage *) captureScreen;

- (void) ReloadContentList;

- (void) AddSubviews;
- (void) RemoveSubviews;

- (void) addProgressViewWithMessage:(NSString *)strMessage;
- (void) addProgressViewForRefresh;
- (void) removeProgressView;

- (void) addNoResults:(NSString *)strMessage;
- (void) removeNoResults;

- (void) addRetryButton;
- (void) removeRetryButton;

+ (UIView *)createPod:(float)x
               yValue:(float)y
               wValue:(float)w
               hValue:(float)h
           tagCounter:(int)numTagCounter
          contentItem:(NSMutableArray*)arrContentItem
                index:(int) numIndex
          contentType:(NSString*)strContentType;

+ (UIImageView *)createPodImage:(float)w hValue:(float)h imageName:(UIImage *)iName;

-(void) setupForTwitter;

@end
