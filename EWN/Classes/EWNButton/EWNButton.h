//
//  EWNButton.h
//  EWN
//
//  Created by Andre Gomes on 2014/01/08.
//
//
//


#import <UIKit/UIKit.h>

@interface EWNButton : UIButton

@property (nonatomic, assign) float yOffset;
@property (nonatomic, readonly) BOOL isAnimating;

- (void)shouldAnimate:(BOOL)animate;

@end
