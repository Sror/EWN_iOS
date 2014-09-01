//
//  SearchNewsListViewController.h
//  EWN
//
//  Created by Pratik Prajapati on 4/26/13.
//
//
/**------------------------------------------------------------------------
 File Name      : SearchNewsListViewController.h
 Created By     : Jainesh Patel.
 Created Date   :
 Purpose        : This class shows the Search view to search the article.
 -------------------------------------------------------------------------*/

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "CustomPickerViewController.h"
#import "SearchNewsListCell.h"

@interface SearchNewsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MNMBottomPullToRefreshManagerClient, UITextFieldDelegate>
{
    NSString *searchText;
    IBOutlet UILabel *lblSearchText;
    IBOutlet UITableView *tblSearchResults;
    
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    
    UIView *progressView;
}

@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) IBOutlet UITableView *tblSearchResults;
@property (nonatomic, strong) CustomPickerViewController *categoryPicker;
@property (nonatomic, strong) CustomPickerViewController *contentPicker;

@property (nonatomic, strong) IBOutlet UIView *categoryView;
@property (nonatomic, strong) IBOutlet UITextField *categoryText;

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UITextField *contentText;

@property (nonatomic) NSInteger selectedCategory;
@property (nonatomic) NSInteger selectedContent;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) NSMutableArray *contentArray;
@property (nonatomic, readwrite) BOOL isOpen;

- (void)addProgressView;
- (void)closePickers;
- (void)loadSearchNews;
- (void)load;
- (void)refreshSearchNews;

- (void)addProgressViewWithMessage:(NSString *)strMessage;
- (void)removeProgressView;
- (void)addNoResults:(NSString *)strMessage;
- (void)removeNoResults;
+ (UIImageView *)createPodImageOverlay:(NSString*)overlayImage imageParent:(UIImageView*)iName;

@end
