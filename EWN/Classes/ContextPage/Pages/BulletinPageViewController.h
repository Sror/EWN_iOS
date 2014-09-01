//
//  BulletinPageViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/17.
//
//

#import <UIKit/UIKit.h>

#import "AudioPlayerViewController.h"

#import "CustomPickerViewController.h"

@interface BulletinPageViewController : UIViewController <UITextFieldDelegate>
{
    AudioPlayerViewController *newsPlayer;
    AudioPlayerViewController *trafficPlayer;
}

@property (nonatomic, strong) CustomPickerViewController *myPicker;
@property (nonatomic, strong) IBOutlet UIView *textView;
@property (nonatomic, strong) IBOutlet UIView *textViewArea;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@property (nonatomic, strong) AudioPlayerViewController *newsPlayer;
@property (nonatomic, strong) AudioPlayerViewController *trafficPlayer;

@property (nonatomic) NSInteger selectedCity;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDictionary *bulletinArray;

-(void)configure;
-(void)startEditing;
-(void)updateSelected;

@end
