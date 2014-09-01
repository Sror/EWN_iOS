/*------------------------------------------------------------------------
 File Name: UIView-AlertAnimations.m
 Created Date: 7-FEB-2013
 Purpose:  category for AlertView Animation.
 -------------------------------------------------------------------------*/
#import "UIView-AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration  0.2555

@implementation UIView(AlertAnimations)

/*------------------------------------------------------------------------------
 Method Name:  doPopInAnimation
 Created Date: 7-FEB-2013
 Purpose: Called when displaying alert view.
 -------------------------------------------------------------------------------*/
- (void)doPopInAnimation
{
    [self doPopInAnimationWithDelegate:nil];
}
/*------------------------------------------------------------------------------
 Method Name:  doPopInAnimationWithDelegate
 Created Date: 7-FEB-2013
 Purpose: To give Pop-in animation while displaying Alertview.
 -------------------------------------------------------------------------------*/
- (void)doPopInAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    popInAnimation.duration = kAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.6],
                             [NSNumber numberWithFloat:1.1],
                             [NSNumber numberWithFloat:.9],
                             [NSNumber numberWithFloat:1],
                             nil];
    popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:1.0],
                               nil];
    popInAnimation.delegate = animationDelegate;
    
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scale"];
}

/*------------------------------------------------------------------------------
 Method Name:  doFadeInAnimation
 Created Date: 7-FEB-2013
 Purpose: Called when displaying alert view.
 -------------------------------------------------------------------------------*/
- (void)doFadeInAnimation
{
    [self doFadeInAnimationWithDelegate:nil];
}
/*------------------------------------------------------------------------------
 Method Name:  doFadeInAnimationWithDelegate
 Created Date: 7-FEB-2013
 Purpose: To give Fade-in animation to background while displaying Alertview.
 -------------------------------------------------------------------------------*/
- (void)doFadeInAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:0.5];
    fadeInAnimation.duration = kAnimationDuration;
    fadeInAnimation.delegate = animationDelegate;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
}
@end