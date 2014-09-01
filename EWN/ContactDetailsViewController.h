//
//  ContactDetailsViewController.h
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import <UIKit/UIKit.h>

#import "ContactCell.h"
#import "CustomPickerViewController.h"
#import "CommonUtilities.h"

@interface ContactDetailsViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    int currentSection;
}

@property (nonatomic, strong) IBOutlet UIView *cityView;
@property (nonatomic, strong) IBOutlet UITextField *cityField;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *pickerArray;
@property (nonatomic, strong) NSMutableArray *tableArray;
@property (nonatomic, strong) NSMutableArray *ctArray;
@property (nonatomic, strong) NSMutableArray *jhbArray;

@property (nonatomic, strong) CustomPickerViewController *picker;

- (void)build;
- (void)addEntry:(NSString *)type Label:(NSString *)label Value:(NSString *)value;

@end
