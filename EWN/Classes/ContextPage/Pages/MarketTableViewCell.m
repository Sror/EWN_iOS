//
//  MarketTableViewCell.m
//  EWN
//
//  Created by Dolfie Jay on 2014/04/24.
//
//

#import "MarketTableViewCell.h"

@implementation MarketTableViewCell

@synthesize indicatorLabel;
@synthesize indicatorImage;
@synthesize valueLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        int width = 306;
        int height = 44;
        [self setFrame:CGRectMake(0, 0, width, height)];
        
        indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, 100, 22)];
        indicatorImage = [[UIImageView alloc] initWithFrame:CGRectMake(142, 14, 20, 16)];
        valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(204, 11, 100, 22)];
        
        // set the fonts
        [indicatorLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
        [indicatorLabel setTextAlignment:NSTextAlignmentCenter];
        [valueLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
        [valueLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:indicatorLabel];
        [self addSubview:indicatorImage];
        [self addSubview:valueLabel];
        
        // seperators
        [self addSubview:[self seperatorLine:102]];
        [self addSubview:[self seperatorLine:204]];
        
        int bottomBorderOffset = (102 / 4)  / 2;
        for (int x = 0; x < 3; x++) {
            int xOffset = (x * 102) + bottomBorderOffset;
            [self addSubview:[self bottomBorder:xOffset]];
        }
    }
    return self;
}

- (void)initValues:(NSDictionary *)rowValues {
    [indicatorLabel setText:[rowValues objectForKey:@"Ticker"]];
    [valueLabel setText:[rowValues objectForKey:@"Price"]];
    NSString *searchForMe = @"-";
    NSRange range = [[rowValues objectForKey:@"Movement"] rangeOfString:searchForMe];
    UIImage *image;
    if (range.location != 0) {
        image = [UIImage imageNamed:@"markets_indicator_up.png"];
    } else {
        image = [UIImage imageNamed:@"markets_indicator_down.png"];
    }
    [indicatorImage setImage:image];
}

- (UIView *)seperatorLine:(int) x {
    UIView *bottomborder = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 1, 44)];
    [bottomborder setBackgroundColor:[UIColor lightGrayColor]];
    return bottomborder;
}

- (UIView *)bottomBorder:(int) x {
    int width = (102 / 4) * 3;
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(x, 43, width, 1)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    return seperator;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
