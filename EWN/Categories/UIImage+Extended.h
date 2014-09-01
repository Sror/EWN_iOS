//
//  UIImage+Extended.h
//  OldMutualPrototype
//
//  Created by Andre Gomes on 2013/09/03.
//  Copyright (c) 2013 PrezenceDigital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extended)

+ (UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

+ (UIImage *) cropImage:(UIImage *)image forRect:(CGRect)rect;

+ (UIImage *) mergeImage:(UIImage *)topImage onTopOf:(UIImage *)bottomImage;

+ (UIImage *) scaleImage:(UIImage*)image toSize:(CGSize)newSize;

- (UIImage *) imageByScalingAndCroppingForSize:(CGSize)targetSize;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (UIImage *)imageCroppedToFitSize:(CGSize)targetSize fromImage:(UIImage *)imageToCrop;

@end
