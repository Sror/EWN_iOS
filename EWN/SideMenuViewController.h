//
//  SideMenuViewController.h
//  EWN
//
//  Created by Pratik Prajapati on 4/24/13.
//
//
/**------------------------------------------------------------------------
 File Name      : SideMenuViewController.h
 Created By     : Jainesh Patel.
 Created Date   :
 Purpose        : This class shows the side Bar view which containts category to select and content type to select.
 -------------------------------------------------------------------------*/
#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "SearchNewsListViewController.h"
#import "SideMenuCell.h"
#import "EngageProtocol.h"

@interface SideMenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    IBOutlet UITableView *tblSideMenu;
}

@property (nonatomic, strong) IBOutlet UIButton *contactButton;
@property (nonatomic, strong) IBOutlet UIButton *contributeButton;
@property (nonatomic, strong) IBOutlet UIButton *settingsButton;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UILabel *loginLabel;
@property (nonatomic, strong) IBOutlet UIImageView *contributeImage;
//@property (nonatomic, retain) IBOutlet UITextField *tfSearch;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) EngageProtocol *engageProtocol;

@property (nonatomic, strong) NSDictionary *firstSectionDict;

- (void)closeSideMenu;
- (void)contributeButton:(id)sender;
- (void)settingsButton:(id)sender;
- (void)contactButton:(id)sender;

- (IBAction)searchButtonTapped:(id)sender;

@end
