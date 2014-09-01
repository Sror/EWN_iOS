/*------------------------------------------------------------------------
 File Name: UIView-AlertAnimations.h
 Created Date: 7-FEB-2013
 Purpose: category for AlertView Animation.
 -------------------------------------------------------------------------*/
#import <Foundation/Foundation.h>


@interface UIView(AlertAnimations)
- (void)doPopInAnimation;
- (void)doPopInAnimationWithDelegate:(id)animationDelegate;
- (void)doFadeInAnimation;
- (void)doFadeInAnimationWithDelegate:(id)animationDelegate;
@end

