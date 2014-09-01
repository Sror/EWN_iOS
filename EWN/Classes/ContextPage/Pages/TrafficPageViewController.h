//
//  TrafficPageViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/17.
//
//

#import <UIKit/UIKit.h>

#import "AudioPlayerViewController.h"
#import "CustomPickerViewController.h"
@class ContextPageViewController;

@interface TrafficPageViewController : UIViewController <UITextFieldDelegate>
{
    AudioPlayerViewController *trafficPlayer;
}

@property (nonatomic, strong) CustomPickerViewController *myPicker;

@property (nonatomic, strong) IBOutlet UIView *textView;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UILabel *trafficLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *trafficScroll;

@property (nonatomic, strong) AudioPlayerViewController *trafficPlayer;

@property (nonatomic) NSInteger selectedCity;
@property (nonatomic, strong) NSDictionary *trafficArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, readwrite) BOOL isOpen;

-(void) setSelectedCityForTraffic:(NSInteger) city;
-(NSInteger) getSelectedCityForTraffic;

-(void)configure;
-(void)setTextReport;
-(void)resizeTrafficContainer;
-(void)updateSelected;

-(NSString*) getTrafficBulletinUrl;

@end
