//
//  ContextMenuViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/03.
//
//

#import <UIKit/UIKit.h>

#import "ContextOptionViewController.h"
#import "ContextPageViewController.h"

@interface ContextMenuViewController : UIViewController
{
    UIView *searchView;
    
    NSString *lastType;
    
    int contextMenuY;
}

@property (nonatomic, strong) ContextPageViewController *contextPage;

@property (nonatomic, strong) UIView *background;

@property (nonatomic, strong) ContextOptionViewController *weatherOption;
@property (nonatomic, strong) ContextOptionViewController *bulletinOption;
@property (nonatomic, strong) ContextOptionViewController *trafficOption;
@property (nonatomic, strong) ContextOptionViewController *marketOption;
@property (nonatomic, strong) ContextOptionViewController *searchOption;
@property (nonatomic, strong) ContextOptionViewController *shareOption;
@property (nonatomic, strong) ContextOptionViewController *commentsOption;

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UITextField *searchText;
@property (nonatomic, strong) NSDictionary *dictWeather;
@property (nonatomic, strong) NSMutableDictionary *dictMarkets;
@property int marketDataReceivedCount;

@property (nonatomic, readwrite) BOOL isInit;
@property (nonatomic, readwrite) BOOL isEnabled;
@property (nonatomic, readwrite) BOOL isSearch;

-(void)updateContextMenu:(NSString *)mType;
-(void)removeOptions;

-(void)displayContextMenu:(BOOL)display;

-(void)resetContextMenu;
-(void)reloadContextData;
-(void)weatherChanged;
-(void)bulletinCompleteHandler:(NSNotification *)notification;
-(void)weatherCompleteHandler:(NSNotification *)notification;
-(void)marketsCompleteHandler:(NSNotification *)notification;
-(void)weatherChangedHandler:(NSNotification *)notification;
-(void)commentsCompleteHandler:(NSNotification *)notification;

-(void)optionNotReady:(NSString *)message heading:(NSString *)heading;

-(void)updateComments:(NSString *)string;

-(NSInteger) getSelectedCityForWeather;
-(NSInteger) getSelectedCityForBulletins;

-(void)setLastType:(NSString *)mType;
//- (void)tapHandler:(id)sender;

@end
