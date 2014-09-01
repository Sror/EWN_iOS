//
//  UIImage+Extended.m
//  OldMutualPrototype
//
//  Created by Andre Gomes on 2013/09/03.
//  Copyright (c) 2013 PrezenceDigital. All rights reserved.
//

#import "UIImage+Extended.h"

@implementation UIImage (Extended)

+ (UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
    CGImageRef imageReference = image.CGImage;
    CGImageRef maskReference = maskImage.CGImage;
    
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                             CGImageGetHeight(maskReference),
                                             CGImageGetBitsPerComponent(maskReference),
                                             CGImageGetBitsPerPixel(maskReference),
                                             CGImageGetBytesPerRow(maskReference),
                                             CGImageGetDataProvider(maskReference), NULL, YES);
    
    CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
    CGImageRelease(imageMask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
    CGImageRelease(maskedReference);
    
    return maskedImage;
}

+ (UIImage *) cropImage:(UIImage *)image forRect:(CGRect)rect
{
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

+ (UIImage *) mergeImage:(UIImage *)topImage onTopOf:(UIImage *)bottomImage
{
    // URL REF: http://iphoneincubator.com/blog/windows-views/image-processing-tricks
    // URL REF: http://stackoverflow.com/questions/1309757/blend-two-uiimages?answertab=active#tab-top
    // URL REF: http://www.waterworld.com.hk/en/blog/uigraphicsbeginimagecontext-and-retina-display
    
    int width = bottomImage.size.width;
    int height = bottomImage.size.height;
    
    CGSize newSize = CGSizeMake(width, height);
    static CGFloat scale = -1.0;
    
    if (scale<0.0)
    {
        UIScreen *screen = [UIScreen mainScreen];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
        {
            scale = [screen scale];
        }
        else
        {
            scale = 0.0;    // Use the standard API
        }
    }
    
    if (scale>0.0)
    {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    }
    else
    {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    [topImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize
{
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma mark -
#pragma mark Scale and crop image

- (UIImage *) imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = 0.0f; // (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = 0.0f; // (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        DLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (UIImage *)imageCroppedToFitSize:(CGSize)targetSize fromImage:(UIImage *)imageToCrop {
    
    UIImage *image = nil;
    NSInteger originX = 0;
    NSInteger originY = 0;
    NSInteger resizedWidth = targetSize.width  ;
    NSInteger resizedHeight = targetSize.height;
    targetSize = CGSizeMake(resizedWidth, resizedHeight);
    
    if (imageToCrop.size.width > imageToCrop.size.height) {
        
        if (imageToCrop.size.height < targetSize.height) resizedHeight = targetSize.height;
        resizedWidth = resizedHeight /imageToCrop.size.height *imageToCrop.size.width;
        
        // Check the resized width is at least the target width
        if (resizedWidth < targetSize.width) {
            
            resizedWidth = targetSize.width;
            resizedHeight = resizedWidth /imageToCrop.size.width *imageToCrop.size.height;
        }
    }
    else {
        
        if (imageToCrop.size.width < targetSize.width) resizedWidth = targetSize.width;
        resizedHeight = resizedWidth /imageToCrop.size.width *imageToCrop.size.height;
        
        // Check the resized height is at least the target height
        if (resizedHeight < targetSize.height) {
            
            resizedHeight = targetSize.height;
            resizedWidth = resizedHeight /imageToCrop.size.height *imageToCrop.size.width;
        }
    }
    
    originX = (targetSize.width -resizedWidth) /2;
    originY = 0.0f; // (targetSize.height -resizedHeight) /2; *************** CUSTOM VALUE
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    [imageToCrop drawInRect:CGRectMake(originX, originY, resizedWidth, resizedHeight)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
