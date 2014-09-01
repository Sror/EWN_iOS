//
//  EWNImageView.h
//  EWN
//
//  Created by Andre Gomes on 2013/12/05.
//
//

#import <UIKit/UIKit.h>

@interface EWNImageView : UIImageView

@property (nonatomic, readonly) CGFloat progress;                   // Use this to read the current porgress value of the loader.
@property (nonatomic, strong)   UIImage * maskImage;                // Use this to set the masked image which sits above the loadImage.
@property (nonatomic, strong)   UIImage * loadImage;                // Use this to set the load image which sits below the maskImage.
@property (nonatomic, assign)   CGFloat animationTimeinterval;      // If set, it will dictate the duration of the load animation, otherwise it will use the default timeInterval.

// You can call this to action the progress of the loader with or without an animation.
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
