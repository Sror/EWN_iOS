//
//  ArticleDetailMaster.h
//  EWN
//
//  Created by Arpit Jain on 6/12/13.
//
//
/**------------------------------------------------------------------------
 File Name      : ArticleDetailMaster.h
 Created By     : Arpit Jain
 Created Date   : 29-May-2013
 Purpose        : Article detail is the parent of detail view and story timeline view.
 -------------------------------------------------------------------------*/

#import <UIKit/UIKit.h>
#import "ContentDetailViewController.h"

@interface ArticleDetailMaster : UIViewController<UIScrollViewDelegate>
{
    IBOutlet UIScrollView *scrvwMasterDetail;
    ContentDetailViewController *vwFirstArticle;
    ContentDetailViewController *vwLastArticle;
    ContentDetailViewController *vwCenterArticle;
    
    int numPreviousTag;
    int numTotalAddedViews;
    int numTotalArticleCount;
    int numCurrentPage;
    int numTotalPages;
    
    NSString *strCurrentContentType;
    
    CGFloat numLastOffset;
}

@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrvwMasterDetail;

@property (nonatomic, retain) NSString *strCurrentArticleID;
@property (nonatomic, retain) NSString *strCurrentContentType;

@property (assign) BOOL isOpen;

@property (assign) CGPoint tapPoint;

//- (void)PrepareDetailView;
- (void)PrepareDetailViewForContentType:(NSString *)strContentType withCurrentArticle:(int)numCurrentArticle;
//- (void)PrepareDetailViewForContentType:(NSString *)strContentType;
- (void)PrepareDetailViewForOffline:(NSString *)strContentType andArticle:(NSString*)strArticleID;

- (void)updateProgress;

@end
