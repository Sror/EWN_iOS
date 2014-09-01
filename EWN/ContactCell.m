//
//  ContactCell.m
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import "ContactCell.h"

@implementation ContactCell

@synthesize icon;
@synthesize divider;
@synthesize label;
@synthesize optionValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.icon = [[UIImageView alloc] init];
    [self.icon setFrame:CGRectMake(15, 7.5, 25, 25)];
    [self addSubview:self.icon];
    
    self.divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_separator"]];
    [self.divider setFrame:CGRectMake(0, 39, 310, 1)];
    [self addSubview:self.divider];
    
    self.label = [[UILabel alloc] init];
    [self.label setFrame:CGRectMake(55, 0, 275, 40)];
    [self.label setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:14]];
    [self.label setTextColor:[UIColor darkGrayColor]];
    [self.label setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.label];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    icon.image = nil;
    label.text = @"";
    optionValue = @"";
    
    [super prepareForReuse];
}

- (void)setImage:(NSString *)type
{
    NSString *imagePath = [NSString stringWithFormat:@"contact_icon_%@", type];
    [self.icon setImage:[UIImage imageNamed:imagePath]];
    
    // contact_icon_phone
}


@end
