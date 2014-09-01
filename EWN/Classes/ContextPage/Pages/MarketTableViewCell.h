//
//  MarketTableViewCell.h
//  EWN
//
//  Created by Dolfie Jay on 2014/04/24.
//
//

#import <UIKit/UIKit.h>

@interface MarketTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *indicatorLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIImageView *indicatorImage;

- (void)initValues:(NSDictionary *)rowValues;

@end
