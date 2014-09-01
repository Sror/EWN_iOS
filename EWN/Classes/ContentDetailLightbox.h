//
//  ContentDetailLightbox.h
//  EWN
//
//  Created by Dolfie Jay on 2014/04/22.
//
//

#import <UIKit/UIKit.h>

@interface ContentDetailLightbox : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) CGRect imageViewDefaultFrame;
@property (nonatomic) CGRect sizeFrame;
@property (nonatomic, strong) UIScrollView *scrolly;
@property (nonatomic, strong) UIView *titleBackground;
-(void)display:(NSString *) filePath title:(NSString *) titleString;

@end
