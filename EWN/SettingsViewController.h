//
//  SettingsViewController.h
//  EWN
//
//  Created by Dolfie on 2013/12/03.
//
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate>
{

}

@property (nonatomic, strong) IBOutlet UILabel *heading;
@property (nonatomic, strong) IBOutlet UILabel *optionOne;
@property (nonatomic, strong) IBOutlet UILabel *optionTwo;
@property (nonatomic, strong) IBOutlet UILabel *optionDiv;
@property (nonatomic, strong) IBOutlet UISwitch *switchOne;
@property (nonatomic, strong) IBOutlet UISwitch *switchTwo;
@property (nonatomic, strong) IBOutlet UITextField *minText;
@property (nonatomic, strong) IBOutlet UITextField *maxText;

@property (nonatomic, strong) IBOutlet UILabel *aboutText;
@property (nonatomic, strong) IBOutlet UILabel *versionText;
@property (nonatomic, strong) IBOutlet UIImageView *logo;

@property (nonatomic, strong) IBOutlet UIView *pickerView;
@property (nonatomic, strong) IBOutlet UIDatePicker *picker;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pickerButton;

- (void)update;

- (void)setState:(id)sender;
- (void)pickerValueChanged:(id)sender;
- (void)pickerButtonHandler:(id)sender;

+ (BOOL)CanReceiveAlerts;

@end
