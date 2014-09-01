//
//  WeatherPageViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/15.
//
//

#import <UIKit/UIKit.h>
#import "CustomPickerViewController.h"

@interface WeatherPageViewController : UIViewController <UITextFieldDelegate>
{

}

@property (nonatomic, strong) CustomPickerViewController *myPicker;
@property (nonatomic, strong) IBOutlet UIView *cityView;
@property (nonatomic, strong) IBOutlet UITextField *cityText;

@property (nonatomic, strong) IBOutlet UIView *todayView;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *highLabel;
@property (nonatomic, strong) IBOutlet UILabel *lowLabel;
@property (nonatomic, strong) IBOutlet UIImageView *todayImageView;
@property (nonatomic, strong) IBOutlet UILabel *seperatorLabel;

@property (nonatomic, strong) IBOutlet UIView *forecastView;

@property (nonatomic) NSInteger selectedCity;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDictionary *weatherArray;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

-(UIView *)createForecastItem:(int)index;
-(void) setToday;
-(void) setForecast;
-(void) setSelectedCityForDefaults:(NSInteger) city;
-(NSInteger) getSelectedCityForWeather;
-(void) updateSelected;

@end
