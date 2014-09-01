//
//  MarketPageViewController.h
//  EWN
//
//  Created by Dolfie Jay on 2014/04/02.
//
//

#import <UIKit/UIKit.h>
#import "MarketTableViewCell.h"

@interface MarketPageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *marketArray;
@property (nonatomic, strong) IBOutlet UITableView *marketTable;

@end
