/*------------------------------------------------------------------------
 File Name: CustomAlertView.m
 Created Date: 7-FEB-2013
 Purpose: To create Custom Alert.
 -------------------------------------------------------------------------*/

#import "CustomAlertView.h"
#import "UIView-AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "MainViewController.h"
#import "ContentDetailViewController.h"

MainViewController *objMainViewController;
AppDelegate *appDelegate;
@interface CustomAlertView()
- (void)alertDidFadeOut;
@end

@implementation CustomAlertView
@synthesize alertView;
@synthesize backgroundView;
@synthesize lblHeading,lblDetail;
@synthesize bgImage;
@synthesize btn1,btn2;
@synthesize delegate;
#pragma mark -
#pragma mark IBActions


/*------------------------------------------------------------------------------
 Method Name:  ShowDetail
 Created Date: 7-FEB-2013
 Purpose:  To display alertview.
 -------------------------------------------------------------------------------*/
- (IBAction)show :(BOOL)bHeading ShowDetail:(BOOL)bDeatil NumberOfButtons:(int)intNumber
{
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [[[WebserviceComunication sharedCommManager] window] addSubview:self.view];
    [[[WebserviceComunication sharedCommManager] window] bringSubviewToFront:self.view];
    
    // Make sure the alert covers the whole window
    self.view.frame = [[WebserviceComunication sharedCommManager] window].frame;
    self.view.center = [[WebserviceComunication sharedCommManager] window].center;
    
    [alertView.layer setCornerRadius:8.0f];
    
    if(bHeading)
        lblHeading.hidden = FALSE;
    else
        lblHeading.hidden = TRUE;
    
    if(bDeatil)
        lblDetail.hidden = FALSE;
    else
        lblDetail.hidden = TRUE;
    
    switch (intNumber) {
        case 0:
            btn1.hidden = TRUE;
            btn2.hidden = TRUE;
            [lblDetail setFrame:CGRectMake(lblDetail.frame.origin.x,lblDetail.frame.origin.y,lblDetail.frame.size.width,lblDetail.frame.size.height+btn1.frame.size.height)];
            break;
        case 1:
            btn1.hidden = FALSE;
            btn2.hidden = TRUE;
            int x = (alertView.frame.size.width-btn1.frame.size.width)/2;
            int y = lblDetail.frame.origin.y + lblDetail.frame.size.height + 5;
            btn1.frame=CGRectMake(x,y, btn1.frame.size.width, btn1.frame.size.height);
            break;
        case 2:
            btn1.hidden = FALSE;
            btn2.hidden = FALSE;
            int xBtn1 = (alertView.frame.size.width-(btn1.frame.size.width+btn2.frame.size.width))/3;
            
            int yBtn = lblDetail.frame.origin.y + lblDetail.frame.size.height + 2;
            btn1.frame=CGRectMake(xBtn1,yBtn, btn1.frame.size.width, btn1.frame.size.height);
            int xBtn2 = btn1.frame.origin.x+btn1.frame.size.width + xBtn1;
            btn2.frame=CGRectMake(xBtn2,yBtn, btn2.frame.size.width, btn2.frame.size.height);
            break;
            
        default:
            break;
    }
    // "Pop in" animation for alert
    [alertView doPopInAnimationWithDelegate:self];
    
    // "Fade in" animation for background
    [backgroundView doFadeInAnimation];
}

- (void)setAlertTitle:(NSString *)title message:(NSString *)description NumberOfButtons:(int)totalButtons
{
    // We need to add it to the window, which we can get from the delegate
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self.view];
    
    // Make sure the alert covers the whole window
    self.view.frame = window.frame;
    self.view.center = window.center;
    [alertView.layer setCornerRadius:8.0f];
    
    [lblHeading setText:title];
    [lblDetail setText:description];
    lblHeading.hidden = FALSE;
    lblDetail.hidden = FALSE;
    switch (totalButtons) {
        case 0:
            btn1.hidden = TRUE;
            btn2.hidden = TRUE;
            break;
        case 1:
            btn1.hidden = FALSE;
            btn2.hidden = TRUE;
            int x = (alertView.frame.size.width-btn1.frame.size.width)/2;
            int y = lblDetail.frame.origin.y + lblDetail.frame.size.height + 2;
            btn1.frame=CGRectMake(x,y, btn1.frame.size.width, btn1.frame.size.height);
            break;
        case 2:
            btn1.hidden = FALSE;
            btn2.hidden = FALSE;
            int xBtn1 = (alertView.frame.size.width-(btn1.frame.size.width+btn2.frame.size.width))/3;
            
            int yBtn = lblDetail.frame.origin.y + lblDetail.frame.size.height + 2;
            btn1.frame=CGRectMake(xBtn1,yBtn, btn1.frame.size.width, btn1.frame.size.height);
            int xBtn2 = btn1.frame.origin.x+btn1.frame.size.width + xBtn1;
            btn2.frame=CGRectMake(xBtn2,yBtn, btn2.frame.size.width, btn2.frame.size.height);
            break;
            
        default:
            break;
    }
    
    // "Pop in" animation for alert
    [alertView doPopInAnimationWithDelegate:self];
    
    // "Fade in" animation for background
    [backgroundView doFadeInAnimation];
}

- (IBAction)dismiss:(id)sender
{
    UIButton *btn =(UIButton *)sender;
    
    [UIView beginAnimations:nil context:nil];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
    
    if(self.view.tag == kALERT_TAG_NO_CONNECTION) {
        [[WebserviceComunication sharedCommManager] setDictCurrentCategory:[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentCategory"]];
        
        if([[WebserviceComunication sharedCommManager] isOnline]) {
            [[WebserviceComunication sharedCommManager] setIsOnline:FALSE];
            [[WebserviceComunication sharedCommManager] setIsAlreadyOnline:![[WebserviceComunication sharedCommManager] isOnline]];
            [[WebserviceComunication sharedCommManager] setIsAlreadyOffLine:[[WebserviceComunication sharedCommManager] isOnline]];
            
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] resetManagedObjectContext];
            
            // Delete All Data from database
            [[CacheDataManager sharedCacheManager] deleteCachedataOfEntity:kEntityContents contentType:kcontentLatest];
            [[CacheDataManager sharedCacheManager] deleteCachedataOfEntity:kEntityContents contentType:kstrVideo];
            [[CacheDataManager sharedCacheManager] deleteCachedataOfEntity:kEntityContents contentType:kContentImages];
            [[CacheDataManager sharedCacheManager] deleteCachedataOfEntity:kEntityContents contentType:kstrAudio];
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;

            MainViewController *objMainView = (MainViewController *)window.rootViewController;
            [objMainView btnRefresh_Pressed:nil];
        } else {
            [[WebserviceComunication sharedCommManager] setIsOnline:FALSE];
            [[WebserviceComunication sharedCommManager] setIsAlreadyOnline:![[WebserviceComunication sharedCommManager] isOnline]];
            [[WebserviceComunication sharedCommManager] setIsAlreadyOffLine:[[WebserviceComunication sharedCommManager] isOnline]];
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushNotificationName object:nil];
    }
    else if(self.view.tag == kALERT_TAG_BREAKING_NEWS)
    {
        if(btn.tag == 501)
        {
            
        }
        else  if([[[WebserviceComunication sharedCommManager] arrBreakingNews]count] > 0)
        {
            Contents *dicSelected = [[[WebserviceComunication sharedCommManager] arrBreakingNews] objectAtIndex:0];
            
            if([dicSelected articleID]) {
                [Flurry logEvent:KFlurryEventBreakingNewsRead withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[dicSelected contentTitle],kstrTitle,[dicSelected articleID],kstrArticleId, nil]];
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                MainViewController *objMainView = (MainViewController *)window.rootViewController;
                [objMainView.articleDetailMaster PrepareDetailViewForContentType:kstrBREAKINGNEWS withCurrentArticle:0];
                [objMainView.scrvwMainScroll setContentOffset:CGPointMake(0, 0) animated:NO];
            }
        }
    }
    else if(self.view.tag == kALERT_TAG_ACTIVE_CONNECTION)
    {
        if(btn.tag != 501) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            MainViewController *objMainView = (MainViewController *)window.rootViewController;
            [objMainView btnRefresh_Pressed:nil];
        }
    }
    else if(self.view.tag == kALERT_TAG_INTERNAL_SERVER_ERROR)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_INIT_LOAD_PROGRESS object:[NSNumber numberWithFloat:0.0]];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        [objMainView.newsListViewController FetchAllData];
        
    }
    else if(self.view.tag == kALERT_TAG_SIGN_OUT)
    {
        if(btn.tag == 501) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            MainViewController *objMainView = (MainViewController *)window.rootViewController;
            [objMainView userIdClear];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_SIGN_OUT object:[NSNumber numberWithFloat:0.0]];
        }
    } else if(self.view.tag == kALERT_TAG_BREAKING_NEWS_FROM_NOTIFICATION) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_BREAKING_NEWS_FROM_NOTIFICATION object:nil];        
    } else if (self.view.tag == kALERT_TAG_CONTRIBUTE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTRIBUTE_VALIDATION_ALERT_DISMISSED" object:nil];
    } else if (self.view.tag == kALERT_TAG_CONTRIBUTEKEY) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        [objMainView btnSideMenu_Pressed:nil];
    }
    
    [self performSelector:@selector(alertDidFadeOut) withObject:nil afterDelay:0.5];
}


#pragma mark -
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.alertView = nil;
    self.bgImage = nil;
    self.lblHeading = nil;
    self.lblDetail = nil;
    self.backgroundView = nil;
    self.btn1=nil;
    self.btn2=nil;
}
- (void)dealloc
{
    [alertView release];
    [bgImage release];
    [lblHeading release];
    [lblDetail release];
    [btn1 release];
    [btn2 release];
    [backgroundView release];
    [super dealloc];
}
#pragma mark -
#pragma mark Private Methods

/*------------------------------------------------------------------------------
 Method Name:  alertDidFadeOut
 Created Date: 7-FEB-2013
 Purpose:  To remove alertview.
 -------------------------------------------------------------------------------*/
- (void)alertDidFadeOut
{
    [self.view removeFromSuperview];
}


@end
