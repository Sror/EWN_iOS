//
//  UIImageView+Extended.m
//  EWN
//
//  Created by Andre Gomes on 2013/12/04.
//
//

#import "UIImageView+Extended.h"
#import "UIImage+Extended.h"


@implementation UIImageView (Extended)

- (void)setImageForProgress:(CGFloat)progress
                 usingImage:(UIImage *)image
               andMaskImage:(UIImage *)maskImage
                   animated:(BOOL)animated
          animationDuration:(CGFloat)duration
{
    if (animated == NO)
    {
        if (progress == 1)
        {
            self.image = image;
            return;
        }
        
        if (maskImage)
            self.image = maskImage;
    }
    else
    {
        if (progress == 1)
        {
            self.image = image;
//            return;
        }
        else if (maskImage)
        {
            self.image = maskImage;
        }
        
        
        [UIView animateWithDuration:duration
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                         }
                         completion:^(BOOL finished) {
                             
                             if (progress == 1.0)
                             {
                                 [UIView animateWithDuration:0.35f
                                                       delay:0.0f
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
                                                      
                                                      self.frame = CGRectMake(self.superview.frame.size.width,
                                                                              self.frame.origin.y,
                                                                              self.frame.size.width,
                                                                              self.frame.size.height);
                                                      self.alpha = 0.2;
                                                  }
                                                  completion:nil];
                             }
                         }];
    }
    
    
    
    
//    // Set Avatar
//    UIImage *avatarImage = [self image];
//
//    // Set Mask Image
//    UIImage *avatarMaskImage = [UIImage imageNamed:@"avatar_mask"];
//    
//    // Scale image to mask size first before cropping, then masking, then blending.
//    //    avatarImage =  [avatarImage imageByScalingAndCroppingForSize:avatarMaskImage.size]; // [UIImage scaleImage:avatarImage toSize:avatarMaskImage.size];
//    
//    // Crop Section of image...
//    //    CGRect cropRect = CGRectMake(0.0f, 0.0f, avatarMaskImage.size.width, avatarMaskImage.size.height);
//    //    UIImage *croppedAvatarImage = [UIImage cropImage:avatarImage forRect:cropRect];
//    
//    UIImage *croppedAvatarImage = [UIImage imageCroppedToFitSize:maskImage.size fromImage:image]; //  [avatarImage imageByScalingAndCroppingForSize:avatarMaskImage.size];
//    
//    // Masked Image (OUTPUT)
//    UIImage *maskedImage = [UIImage maskImage:croppedAvatarImage withMask:maskImage];
//    
//    // Merge to form final Image.
//    UIImage *finalImage = [UIImage mergeImage:maskImage onTopOf:image];
    
//    self.image = finalImage;
}

@end
