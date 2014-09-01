//
//  SearchNewsListCell.m
//  EWN
//
//  Created by Dolfie on 2013/12/02.
//
//

#import "SearchNewsListCell.h"

@implementation SearchNewsListCell

@synthesize imgCellBg;
@synthesize headingLabel;
@synthesize lblNewsDesc;
@synthesize lblTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.textLabel.textColor = [UIColor grayColor];
        self.textLabel.font = [UIFont fontWithName:kFontOpenSansRegular size:12];
        self.textLabel.highlightedTextColor = [UIColor blackColor];
        
        imgCellBg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 100, 58)];
        imgCellBg.backgroundColor = [UIColor clearColor];
        imgCellBg.opaque = NO;
        imgCellBg.image = [UIImage imageNamed:kImgNameDefault];
        [self.contentView addSubview:imgCellBg];
        
        lblTime = [[UILabel alloc] initWithFrame:CGRectMake(7, ((imgCellBg.frame.origin.y + imgCellBg.frame.size.height) - 15), imgCellBg.frame.size.width, 15)];
        [lblTime setBackgroundColor:[UIColor clearColor]];
        [lblTime setTextColor:[UIColor whiteColor]];
        [lblTime setNumberOfLines:1];
        [lblTime setFont:[UIFont fontWithName:kFontOpenSansRegular size:10.0]];
        
        // Graident BG
        UIView *txtBackground = [[UIView alloc] initWithFrame:CGRectMake(imgCellBg.frame.origin.x, lblTime.frame.origin.y, lblTime.frame.size.width, lblTime.frame.size.height)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = txtBackground.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
        [txtBackground.layer insertSublayer:gradient atIndex:0];
        [txtBackground setAlpha:0.75];
        
        [self.contentView addSubview:txtBackground];
        [self.contentView addSubview:lblTime];
        
        headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, -5, 170, 45)];
        [headingLabel setBackgroundColor:[UIColor clearColor]];
        [headingLabel setNumberOfLines:2];
        [headingLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12.0]];
        [headingLabel setTextColor:[UIColor darkGrayColor]];
        [self.contentView addSubview:headingLabel];
        
        lblNewsDesc = [[UILabel alloc] initWithFrame:CGRectMake(115, 25, 170, 45)];
        [lblNewsDesc setBackgroundColor:[UIColor clearColor]];
        [lblNewsDesc setNumberOfLines:2];
        [lblNewsDesc setFont:[UIFont fontWithName:kFontOpenSansRegular size:10.0]];
        [lblNewsDesc setTextColor:[UIColor darkGrayColor]];
        [self.contentView addSubview:lblNewsDesc];
        
        self.textLabel.shadowColor = [UIColor blackColor];
        self.textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [imgCellBg removeFromSuperview];
    imgCellBg = nil;
    
    imgCellBg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 100, 58)];
    imgCellBg.backgroundColor = [UIColor clearColor];
    imgCellBg.opaque = NO;
    imgCellBg.image = [UIImage imageNamed:kImgNameDefault];
    [self.contentView insertSubview:imgCellBg atIndex:0];
    
    headingLabel.text = @"";
    lblNewsDesc.text = @"";
    lblTime.text = @"";
}

- (void)dealloc
{
    [imgCellBg removeFromSuperview];
    [headingLabel removeFromSuperview];
    [lblNewsDesc removeFromSuperview];
    [lblTime removeFromSuperview];
    [super dealloc];
}

@end
