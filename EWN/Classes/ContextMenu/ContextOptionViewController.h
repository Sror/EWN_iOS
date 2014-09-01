//
//  ContextOptionViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/03.
//
//

#import <UIKit/UIKit.h>

@interface ContextOptionViewController : UIViewController
{
    CGRect initFrame;
    
    NSString *imagePath;
    NSString *imageRollPath;
}

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UIImageView *separator;
@property (nonatomic, strong) UIImageView *optionIcon;
@property (nonatomic, strong) UILabel *optionTitle;
@property (nonatomic, strong) UIImage *upImage;
@property (nonatomic, strong) UIImage *downImage;

@property (nonatomic, strong) UILabel *commentCount;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) NSString *optionType;
@property (nonatomic, assign) Boolean noImageStates;

-(id)initWithTitle:(NSString *)title;

-(void)setPosition:(int)index;

-(void)setImageIcon:(NSString*)imageUrl;

@end
