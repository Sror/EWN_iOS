//
//  SideMenuCell.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/23.
//
//

#import "SideMenuCell.h"

@implementation SideMenuCell

@synthesize iconView;
@synthesize textLabel;
@synthesize seperator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake(0, 0, 320, 40)];
        [self setBackgroundColor:kUICOLOR_SIDEMNU_BACK];
        
        UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        [selectedBackgroundView setBackgroundColor:kUICOLOR_SIDEMNU_BACK_HIGHLIGHT]; // set color here
        [self setSelectedBackgroundView:selectedBackgroundView];
        
        self.iconView = [[UIImageView alloc] init];
        [self.iconView setFrame:CGRectMake(20, (self.frame.size.height / 2) - 15, 30, 30)];
        [self addSubview:self.iconView];
        
        self.textLabel = [[UILabel alloc] init];
        [self.textLabel setText:@"test"];
        [self.textLabel setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
        [self.textLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:15]];
        [self.textLabel setFrame:CGRectMake(60, (self.frame.size.height / 2) - 10, 150, 20)];
        [self addSubview:self.textLabel];
    }
    return self;
}

-(void)addSeperatorView {
    self.seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator_horizontal.png"]];
    [self.seperator setFrame:CGRectMake(0, (self.frame.size.height - 2), self.seperator.frame.size.width, 2)];
    [self addSubview:self.seperator];
}


@end
