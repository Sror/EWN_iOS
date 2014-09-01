//
//  StoryTimelineCell.h
//  EWN
//
//  Created by Jainesh Patel on 5/2/13.
//
//
/**------------------------------------------------------------------------
 File Name      : StoryTimelineCell.h
 Created By     : Jainesh Patel.
 Created Date   :
 Purpose        : This class contains the Cell defination. It retuns the cell.
 -------------------------------------------------------------------------*/
#import <UIKit/UIKit.h>

@interface StoryTimelineCell : UITableViewCell
{
    UIView *vwContentBox;
    UIImageView *imgvwCOntentImage;
    UILabel *lblTitle;
}

@property (nonatomic, strong)  UIView *vwContentBox;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIImageView *imgvwCOntentImage;

@end
