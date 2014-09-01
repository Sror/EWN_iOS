//
//  ContactSocialMediaViewController.h
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import <UIKit/UIKit.h>

#import "ContactCell.h"

@interface ContactSocialMediaViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tableArray;

- (void)build;
- (void)addEntry:(NSString *)type Label:(NSString *)label Value:(NSString *)value;

@end
