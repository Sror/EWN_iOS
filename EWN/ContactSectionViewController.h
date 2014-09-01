//
//  ContactSectionViewController.h
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import <UIKit/UIKit.h>

@interface ContactSectionViewController : UIViewController
{
    
}

@property (nonatomic, strong) IBOutlet UIImageView *arrowImageOpen;
@property (nonatomic, strong) IBOutlet UIImageView *arrowImageClosed;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *sectionView;
@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, assign) CGRect sectionFrame;
@property (nonatomic, assign) int sectionId;
@property (nonatomic, assign) int zeroY;

- (void)config;
- (void)setPosition:(int)offset;
- (void)resetPosition:(BOOL)animated;
- (void)move:(int)offset;
- (void)toggle:(bool)value;

-(void)setArrowIndicatorClosed;
-(void)setArrowIndicatorOpen;

// NEW
- (void)method1;
- (void)method2:(int)offset;
- (void)method3:(int)offset;
- (void)showSection:(bool)value;

@end
