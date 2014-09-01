/*------------------------------------------------------------------------
 File Name: CustomAlertView.h
 Created Date: 7-FEB-2013
 Purpose: To create Custom Alert.
 -------------------------------------------------------------------------*/

#import <UIKit/UIKit.h>

enum
{
    CustomAlertViewButtonTagOk = 1000,
    CustomAlertViewButtonTagCancel
};

@class CustomAlertView;

@protocol CustomAlertViewDelegate
@required

@optional
- (void) CustomAlertView:(CustomAlertView *)alert wasDismissedWithValue:(NSString *)value;
- (void) customAlertViewWasCancelled:(CustomAlertView *)alert :(UIButton *)btn;
@end


@interface CustomAlertView : UIViewController
{
    UIView                                  *alertView;
    UIView                                  *backgroundView;
    UIImageView                             *bgImage;
    UILabel                                 *lblHeading;
    UILabel                                 *lblDetail;
    UIButton                                *btn1;
    UIButton                                *btn2;
    
    id<NSObject, CustomAlertViewDelegate>   delegate;
}
@property (nonatomic, retain) IBOutlet  UIView *alertView;
@property (nonatomic, retain) IBOutlet  UIView *backgroundView;
@property (nonatomic, retain) IBOutlet  UIImageView *bgImage;
@property (nonatomic, retain) IBOutlet  UILabel *lblHeading;
@property (nonatomic, retain) IBOutlet  UILabel *lblDetail;
@property (nonatomic, retain) IBOutlet  UIButton *btn1;
@property (nonatomic, retain) IBOutlet  UIButton *btn2;
@property (nonatomic, assign) IBOutlet id<CustomAlertViewDelegate, NSObject> delegate;

- (IBAction)show :(BOOL)bHeading ShowDetail:(BOOL)bDeatil NumberOfButtons:(int)intNumber;
- (void) setAlertTitle:(NSString *)title message:(NSString *)description NumberOfButtons:(int)totalButtons;
- (IBAction)dismiss:(id)sender;
@end