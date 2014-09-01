//
//  mainViewController.h
//  EWN
//
//  Created by Pratik Prajapati on 4/24/13.
//
//
/**------------------------------------------------------------------------
 File Name      : mainViewController.h
 Created By     : Arpit Jain.
 Created Date   :
 Purpose        : This class shows the Main controller which handles the navigation, and it contains news view controller.
 -------------------------------------------------------------------------*/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "DropDownView.h"
#import "NewsListViewController.h"
#import "AppDelegate.h"
#import "SideMenuViewController.h"
#import "ContentDetailViewController.h"
#import "ArticleDetailMaster.h"
#import "SearchNewsListViewController.h"
#import "SplashScreenViewController.h"
#import "ContextMenuViewController.h"
#import "ContextPageViewController.h"
#import "SettingsViewController.h"
#import "ContactViewController.h"
#import "ContributeViewController.h"
#import "CommentModalViewController.h"
#import "CommentModalPostViewController.h"
#import "TermsViewController.h"
#import "ContentDetailLightbox.h"
#import "UAPush.h"

#import "PECropViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@class SideMenuViewController;

@interface MainViewController : UIViewController <DropDownViewDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, ATBannerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate, MPMediaPickerControllerDelegate>
{
    DropDownView *dropDownCategories;
    
    NSMutableArray *arrCategories;
    
    IBOutlet UIView *viewTop;
    IBOutlet UIImageView *viewBackground;
    IBOutlet UIButton *btnSideMenu;
    IBOutlet UIButton *btnRefresh;
    IBOutlet UIButton *btnPlus;
    IBOutlet UIScrollView *scrvwMainScroll;
    IBOutlet UILabel *lblCurrentCategory;
    
    SplashScreenViewController *splashScreenViewController;
    NewsListViewController *newsListViewController;
    ContextMenuViewController *contextMenu;
    ContextPageViewController *contextPage;
    //SearchNewsListViewController *searchView;
    
    BOOL isSideViewOpen;
    BOOL isCategoryOpen;
    BOOL isArticleDetailOpen;
    BOOL isSearchOpen;
    BOOL bIsSearchNewsVisible;
    
    BOOL isSettingsOpen;
    BOOL isContactOpen;
    
    NSString* __weak searchString;
    
    AppDelegate *appDelegate;

    CGFloat numPan_First_X, numPan_First_Y;
    CGFloat numPan_MIN_X, numPan_MAX_X;
    
    NSString *strXibSettings;
    NSString *strXibContact;
    NSString *strXibContribute;
}

@property (nonatomic, strong) NewsListViewController *newsListViewController;
@property (nonatomic, strong) ArticleDetailMaster *articleDetailMaster;
@property (nonatomic, strong) ContextMenuViewController *contextMenu;
@property (nonatomic, strong) ContextPageViewController *contextPage;
@property (nonatomic, strong) SideMenuViewController *sideMenuViewController;

// PAGES
@property (nonatomic, strong) ContributeViewController *contributeView;
@property (nonatomic, strong) TermsViewController *termsViewController;
@property (nonatomic, strong) SettingsViewController *settingsView;
@property (nonatomic, strong) ContactViewController *contactView;

@property (nonatomic, assign) BOOL isSideViewOpen;
@property (nonatomic, assign) BOOL isArticleDetailOpen;
@property (nonatomic, assign) BOOL isSearchOpen;

@property (nonatomic, weak) NSString* searchString;
@property (nonatomic, weak) NSString* prevCategory;

@property (nonatomic, strong) IBOutlet UILabel *lblCurrentCategory;
@property (nonatomic, strong) IBOutlet UIScrollView *scrvwMainScroll;

@property (nonatomic, strong) UIView *vwSideMenuHandler;

@property (nonatomic, strong) ATAdtechAdConfiguration *config;

// This is for the breaking news alert if we started the app from scratch
@property (nonatomic, strong) NSDictionary *breakingNewsNotification;

@property (nonatomic, strong) NSString *currentInFocusName;

- (void)openDropDownOfCategories;
- (void)btnSideMenu_Config:(NSString*)strType;
- (IBAction)btnSideMenu_Pressed:(id)sender;
- (IBAction)btnRefresh_Pressed:(id)sender;
- (IBAction)btnPlus_Pressed:(id)sender;
- (void)addNewsListView;

- (void)contextMenuInit;

- (void)openSearchViewWithKeyword:(NSString*)strKeyword;
- (void)closeSearchNewsView;

- (void)enableArticleView;
- (void)disableArticleView;

- (void)closeContributeTerms;
- (void)enableContributeView;
- (void)disableContributeView;
- (void)displayContributeTerms;

- (void)enableSearchView;
- (void)disableSearchView;

- (void)enableSettingsView;
- (void)disableSettingsView;

- (void)enableContactView;
- (void)disableContactView;

- (void)resetCurrentCategoryLabel;

- (void)hidePages;

- (ATBannerView *)createAd;

@property (nonatomic, strong) CommentModalPostViewController *commentModal;
-(void)postCommentModal:(NSString*) articleId;

-(void)createNotificationObservers;
@property (nonatomic, strong) NSString *notificationArticleId;
-(void)checkForPendingBreakingNews;
-(void)handleNotification:(NSDictionary *)userInfo;
-(void)getBreakingNewsFromNotification;

-(void) userIdClear;
-(NSString*) userIdReturn;
-(void) userIdSave:(NSString *)userId;
-(void) userIdSave:(NSString *)userId showMessage:(BOOL) showM;

- (Boolean) netWorkAvailable;

- (void)phoneWithNumber:(NSString *)number;
- (void)openEmailComposer:(NSString *)rec;
- (void)openMessageComposer:(NSString *)rec;

@property (nonatomic, strong) UIView *loadingScreen;
-(void)showBreakingLoadingScreen;
-(void)showBreakingLoadingScreen:(NSString *) message;
-(void)hideBreakingLoadingScreen;

@property (nonatomic, strong) ContentDetailLightbox *contentDetailLightbox;
-(void)showLightBoxImageView:(NSString *) filePath title:(NSString *) titleString;
@property (nonatomic, strong) UIScrollView *lightBoxScroll;
-(void)showMultipleLightBoxImages:(NSArray *) filePaths titles:(NSArray *) titleStrings index:(int) selectedIndex;

- (void)presentAudioPicker;
- (void)presentVideoPicker;
- (void)presentImagePicker;
- (void)recropImage:(UIImage *)imageToCrop tagNumber:(int)tag;

@end
