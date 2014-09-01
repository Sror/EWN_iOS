//
//  UIAlertView+Extended.m
//
//  Created by Andre Gomes on 2013/10/09.
//  Copyright (c) 2013 PrezenceDigital. All rights reserved.
//

#import "UIAlertView+Extended.h"
#import <objc/runtime.h>


@interface OMAlertView : NSObject <UIAlertViewDelegate>
@property (copy) void(^completionBlock)(UIAlertView *alertView, NSInteger buttonIndex);
@end

@implementation OMAlertView

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Alert Button Tap Index = [ %i ]", buttonIndex);
    
    if (self.completionBlock)
        self.completionBlock(alertView, buttonIndex);
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView
{
    // Just simulate a cancel button click
    if (self.completionBlock)
        self.completionBlock(alertView, alertView.cancelButtonIndex);
}

@end




static const char kOMAlertViewWrapper;

@implementation UIAlertView (Extended)

+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    return [[UIAlertView alloc] initWithTitle:title
                                      message:message
                                     delegate:nil
                            cancelButtonTitle:cancelButtonTitle
                            otherButtonTitles:nil];
}

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion
{
    OMAlertView *alertVew = [[OMAlertView alloc] init];
    alertVew.completionBlock = completion;
    self.delegate = alertVew;
    
    // Set the wrapper as an associated object
    objc_setAssociatedObject(self, &kOMAlertViewWrapper, alertVew, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Show the alert as normal
    [self show];
}

@end
