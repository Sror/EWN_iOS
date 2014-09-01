//
//  CustomPickerViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/22.
//
//

#import <UIKit/UIKit.h>

@interface CustomPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    
}

@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) NSInteger* itemSelected;

+(id)sharedInstance;

-(void)doneHandler:(id)sender;

@end