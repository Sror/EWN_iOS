//
//  ContactCell.h
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell
{
    
}

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *divider;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *optionValue;

- (void)setImage:(NSString *)type;

@end
