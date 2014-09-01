//
//  StoryTimelineViewController.h
//  EWN
//
//  Created by Jainesh Patel on 5/1/13.
//
//
/**------------------------------------------------------------------------
 File Name      : CommonUtilities.h
 Created By     : Jainesh Patel.
 Created Date   :
 Purpose        : This class contains the common methods.
 -------------------------------------------------------------------------*/
#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"


@protocol StoryTimelineDelegate <NSObject>

@required
-(void)selectedArticleDetail: (NSMutableDictionary *)dicDetail;

@end


@interface StoryTimelineViewController : UIViewController<MNMBottomPullToRefreshManagerClient>
{
    IBOutlet UIScrollView *scrvwTimeLine;
    IBOutlet UIScrollView *scrvwRelatedStory;
    IBOutlet UIButton *btnTimeline;
    IBOutlet UIButton *btnRelated;
    MNMBottomPullToRefreshManager *pullToRefreshManagerForTimeline_;
    MNMBottomPullToRefreshManager *pullToRefreshManagerForRelatedStory_;
    IBOutlet UITableView *tblTimeLineLeft;
    IBOutlet UITableView *tblTimeLineRight;
    
    UIActivityIndicatorView *activityRelated;
    UIActivityIndicatorView *activityStorytime;
    
    IBOutlet UIImageView *imgvwTimelineBar;
    NSString *strSelfCurrentContentType;
    
    id<StoryTimelineDelegate> delegate;

    //NSMutableDictionary *dicArticleId;
    Contents *dicArticleId;
    UILabel *lblNostoryTimeline;
    UILabel *lblNoRelatedStory;

    int numNextX;
    int numNextY;
    int numTagCounter;
    int numTagForTimeline;
    
    IBOutlet UIView *vwScrollContent;
    
    NSThread *threadRelated;
    NSThread *threadStorytimeline;
}
@property (nonatomic, strong)IBOutlet UIView *relatedBackground;
@property (nonatomic, strong)IBOutlet UIButton *btnTimeline;
@property (nonatomic, strong)IBOutlet UIButton *btnRelated;
@property (nonatomic, strong) IBOutlet UIScrollView *scrvwTimeLine;
@property (nonatomic, strong) IBOutlet UIScrollView *scrvwRelatedStory;
@property (nonatomic, strong)IBOutlet UITableView *tblTimeLineLeft;
@property (nonatomic, strong)IBOutlet UITableView *tblTimeLineRight;
//@property (nonatomic, retain) NSMutableDictionary *dicArticleId;
@property (nonatomic, strong) Contents *dicArticleId;
@property (nonatomic, strong)NSString *strSelfCurrentContentType;
@property (nonatomic, strong)id<StoryTimelineDelegate> delegate;
@property (nonatomic, strong)MNMBottomPullToRefreshManager *pullToRefreshManagerForTimeline_;
@property (nonatomic, strong)MNMBottomPullToRefreshManager *pullToRefreshManagerForRelatedStory_;
@property (nonatomic, strong) NSMutableArray *arrStoryTimelineDataForLeft;
@property (nonatomic, strong) NSMutableArray *arrStoryTimelineDataForRight;
@property (nonatomic ,strong) IBOutlet UIImageView *imgvwTimelineBar;

@property (nonatomic, assign) bool bIsNoRealtedNews;
@property (nonatomic, assign) bool bIsNoStoryNews;
@property (nonatomic, assign) bool bIsFirstSwipe;

@property (nonatomic, assign) bool isOpen;

- (void)sortAndGroupArrayByDate;
- (IBAction)btnStoryTimelineCllick:(id)sender;
- (IBAction)btnRelatedStoryCllick:(id)sender;
- (void)showTimelineView;
- (void)showRelatedStoryView;
- (void)HideRelatedStoryBtn;
- (void)HideStoryTimeLineBtn;
- (void)allocateAndCreateRelatedStoryViews;

- (void)AddRelatedActivityInidicator;
- (void)RemoveRelatedActivityInidicator;

- (void)AddStoryActivityInidicator;
- (void)RemoveStoryActivityInidicator;


- (void)removeAllView;

- (void)initializeRelatedViews;
- (void)initializeStoryTimeView;
@end
