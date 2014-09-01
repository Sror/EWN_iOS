//
//  ContextPageViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/04.
//
//

#import <UIKit/UIKit.h>

#import "WeatherPageViewController.h"
#import "BulletinPageViewController.h"
#import "TrafficPageViewController.h"
#import "CommentsPageViewController.h"
#import "MarketPageViewController.h"

@class EWNCloseButton;

@interface ContextPageViewController : UIViewController {
    CGRect initFrame;
    NSString *mType;
    WeatherPageViewController *weatherPage;
    BulletinPageViewController *bulletinPage;
    TrafficPageViewController *trafficPage;
    CommentsPageViewController *commentsPage;
    MarketPageViewController *marketsPage;
}

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UIImageView *titleBackground;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) EWNCloseButton *closeButton;

@property (nonatomic, strong) WeatherPageViewController *weatherPage;
@property (nonatomic, strong) NSDictionary *dictWeather;
@property (nonatomic, strong) BulletinPageViewController *bulletinPage;
@property (nonatomic, strong) NSDictionary *dictBulletin;
@property (nonatomic, strong) TrafficPageViewController *trafficPage;
@property (nonatomic, strong) NSDictionary *dictMarkets;
@property (nonatomic, strong) MarketPageViewController *marketsPage;
@property (nonatomic, strong) NSDictionary *dictTraffic;
@property (nonatomic, strong) CommentsPageViewController *commentsPage;

// article id for commenting
@property (nonatomic, strong) NSString *articleId;
// sharing parameters
@property (nonatomic, strong) NSString *sharingText;
@property (nonatomic, strong) NSString *sharingUrl;
-(void)setSharingValues:(NSString*)text shareUrl:(NSString*)url;

@property (nonatomic, readwrite) BOOL isOpening;
@property (nonatomic, readwrite) BOOL isClosing;

- (void)closeHandler:(id)sender;

- (void)displayContextPage:(BOOL)display WithOffset:(float)offset;
- (void)removeContextPage;

-(NSString*)getAudioTrafficUrl:(int) trafficCity;

- (void)setWeatherArray;
- (void)setBulletinArray;
- (void)setTrafficArray;
- (void)setMarketData;

- (void)displayWeather;
- (void)displayBulletin;
- (void)displayTraffic;
- (void)displayComments;
- (void)displayShare;
- (void)displayMarkets;

@end
