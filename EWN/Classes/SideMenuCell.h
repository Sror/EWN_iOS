//
//  SideMenuCell.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/23.
//
//

#import <UIKit/UIKit.h>

@interface SideMenuCell : UITableViewCell
{
    
}

-(void)addSeperatorView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *seperator;

@end
