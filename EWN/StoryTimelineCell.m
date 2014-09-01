//
//  StoryTimelineCell.m
//  EWN
//
//  Created by Jainesh Patel on 5/2/13.
//
//

#import "StoryTimelineCell.h"

@implementation StoryTimelineCell
@synthesize vwContentBox;
@synthesize lblTitle;
@synthesize imgvwCOntentImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        vwContentBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 100)];
        vwContentBox.layer.cornerRadius = 2;
        vwContentBox.backgroundColor = [UIColor darkGrayColor];
        
        imgvwCOntentImage =[[UIImageView alloc]initWithFrame:CGRectMake(5,3,100, 60)];
        [imgvwCOntentImage setImage:[UIImage imageNamed:kImgNameDefault]];
        imgvwCOntentImage.contentMode = UIViewContentModeScaleToFill;
        imgvwCOntentImage.backgroundColor =[UIColor clearColor];
        [vwContentBox addSubview:imgvwCOntentImage];
        
        lblTitle =[[UILabel alloc]initWithFrame:CGRectMake(5, imgvwCOntentImage.frame.origin.y+imgvwCOntentImage.frame.size.height, 102, 40)];
        lblTitle.textAlignment = UITextAlignmentLeft;
        lblTitle.text = @"NPA confirms Winnie murder probe";
        lblTitle.numberOfLines = 2;
        lblTitle.minimumFontSize = 8;
        
        lblTitle.font =[UIFont fontWithName:kFontOpenSansRegular size:10];
        lblTitle.textColor =[UIColor whiteColor];
        lblTitle.backgroundColor =[UIColor clearColor];
        [vwContentBox addSubview:lblTitle];
        
        [self.contentView addSubview:vwContentBox];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
