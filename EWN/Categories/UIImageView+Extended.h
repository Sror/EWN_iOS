//
//  UIImageView+Extended.h
//  EWN
//
//  Created by Andre Gomes on 2013/12/04.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (Extended)

- (void)setImageForProgress:(CGFloat)progress
                 usingImage:(UIImage *)image
               andMaskImage:(UIImage *)maskImage
                   animated:(BOOL)animated
          animationDuration:(CGFloat)duration;

@end
