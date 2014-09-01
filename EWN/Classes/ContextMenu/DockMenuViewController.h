//
//  DockMenuViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/24.
//
//

#import <UIKit/UIKit.h>
//#import "MainViewController.h"

@interface DockMenuViewController : UIViewController
{
    
}

@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, strong) IBOutlet UIButton *loginBtn;
@property (nonatomic, strong) IBOutlet UIButton *minBtn;
@property (nonatomic, strong) IBOutlet UIButton *viewBtn;
@property (nonatomic, strong) IBOutlet UIButton *postBtn;

@property (nonatomic, assign) BOOL isViewAll;

-(NSString *) userIdReturn;
-(void)update;

@end
