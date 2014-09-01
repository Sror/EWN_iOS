//
//  ContentDetailViewController.h
//  EWN
//
//  Created by Jainesh Patel on 4/30/13.
//
//
/**------------------------------------------------------------------------
 File Name      : ContentDetailViewController.h
 Created By     : Jainesh Patel.
 Created Date   :
 Purpose        : This class shows the detail view of Article.
 -------------------------------------------------------------------------*/

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "StoryTimelineViewController.h"
#import "CustomAlertView.h"
#import "WebAPIRequest.h"
#import "PullableView.h"
#import "RelatedScrollerViewController.h"
#import "TouchDownGestureRecognizer.h"
#import "DragHandleImage.h"
#import "ContentDetailImageview.h"

typedef enum {
    
    ParentContentTypeLatestNews = 0,
    ParentContentTypeAudio = 1,
    ParentContentTypeVideo = 2,
    ParentContentTypeImages = 3,
    ParentContentTypeStoryTimeline = 4,
    ParentContentTypeRelatedStory = 5,
    ParentContentTypeSearchedNews = 6,
    ParentContentTypeLeadingNews = 7
    
} ParentContentType;


@class EWNDragHandleView;


@interface ContentDetailViewController : UIViewController <StoryTimelineDelegate, WebAPIRequestDelegate, PullableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    Contents *dicArticleDetail;
    MPMoviePlayerViewController *theMovie;
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblTime;
    IBOutlet UILabel *lblDescription;
    IBOutlet UIButton *btnNext;
    IBOutlet UIButton *btnPrevoius;
    IBOutlet UITextView *txtvwDescription;
    IBOutlet UIScrollView *scrvwMainView;
    IBOutlet UIScrollView *scrvwContentDetail;
    IBOutlet UIView *vwContentDetail;
    
    ContentDetailImageview *imgvwContentImage;
    UIImageView *imgvwContentType;
    UIImageView *imgvwScreenShot;
    
    RelatedScrollerViewController *thumbView;
    
    PullableView *dragDownView;
    
    WebAPIRequest *objWebAPIRequest;
    NSURL *urlFile;
    
    StoryTimelineViewController *objStoryTimelineView;
    ATBannerView *bannerView;
    
    CGPoint closedCenter;
    CGPoint openedCenter;
    CGPoint startPos;
    CGPoint minPos;
    CGPoint maxPos;
    BOOL verticalAxis;
    float scrollOffset_X;
    float scrollOffset_Y;
    CGPoint prvContOff;
    UISwipeGestureRecognizer *leftRecognizer;
    
    UIButton *relatedButton;
    
    BOOL isUpdate;
    BOOL isRelatedOpen;
    
    bool bFlurryReported;
}

@property bool showAds; // this is set by common constants
@property bool displayAds; // this is to switch them off when running out of memory

@property (nonatomic, strong) IBOutlet UIScrollView *scrvwMainView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrvwContentDetail;
@property (nonatomic, strong) IBOutlet UIButton *relatedButton;

@property (nonatomic, strong) EWNDragHandleView *dragHandleView;

@property (nonatomic, strong) NSString *contentTypeString;
@property (nonatomic, strong) Contents *dicArticleDetail;
@property (nonatomic, strong) StoryTimelineViewController *objStoryTimelineView;
@property (nonatomic, readwrite) ParentContentType parentContentType;
@property (nonatomic, strong) CustomAlertView *alrtvwReachable;

@property (nonatomic, strong) RelatedScrollerViewController *thumbView;

@property (nonatomic) float contentAndRelatedWidth;

@property (nonatomic, assign) CGPoint tapPoint;

- (IBAction)btnPreviousClick:(id)sender;
- (IBAction)btnNextClick:(id)sender;
- (NSMutableArray *)getDataByContentType;

- (void)displayAllDetails;

- (void)initializeRelatedStoryView;

- (void)showStoryTimelineView:(BOOL)isVisible;
- (void)showStoryTimelineViewNoAnimation;

- (void)showLoader:(NSString *)message;
- (void)hideLoader;
- (void)downloadFeaturedImage;

@end
