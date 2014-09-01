/*------------------------------------------------------------------------
 File Name: CustomAlertView.m
 Created Date: 7-FEB-2013
 Purpose: To create Custom Alert.
 -------------------------------------------------------------------------*/

#import "CustomAlertView.h"
#import "UIView-AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

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
    
    // Retaining self is odd, but we do it to make this "fire and forget"
    [self retain];
    
    // We need to add it to the window, which we can get from the delegate
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self.view];
    
    // Make sure the alert covers the whole window
    self.view.frame = window.frame;
    self.view.center = window.center;
    
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
/*------------------------------------------------------------------------------
 Method Name:  ShowDetail
 Created Date: 7-FEB-2013
 Purpose:  To dismiss alertview.
 -------------------------------------------------------------------------------*/

- (IBAction)dismiss:(id)sender
{
    UIButton *btn =(UIButton *)sender;
    
    [UIView beginAnimations:nil context:nil];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(alertDidFadeOut) withObject:nil afterDelay:0.5];
    
    if ([delegate respondsToSelector:@selector(customAlertViewWasCancelled::)])
        [delegate customAlertViewWasCancelled:self :btn];
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
    [self autorelease];
}


@end
