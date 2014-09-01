//
//  ContactViewController.h
//  EWN
//
//  Created by Dolfie on 2013/12/03.
//
//

#import <UIKit/UIKit.h>

#import "ContactDetailsViewController.h"
#import "ContactSocialMediaViewController.h"
#import "ContactFeedbackViewController.h"
#import "ContactSectionViewController.h"

@interface ContactViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    int posZeroY;
    int headingHeight;
    
    int currentSection;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet  UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *tableArray;
@property (nonatomic, strong) NSArray *sectionArray;

@property (nonatomic, strong) ContactSectionViewController *sectionOne;
@property (nonatomic, strong) ContactSectionViewController *sectionTwo;
@property (nonatomic, strong) ContactSectionViewController *sectionThree;

@property (nonatomic, strong) ContactDetailsViewController *contactDetails;
@property (nonatomic, strong) ContactSocialMediaViewController *socialMedia;
@property (nonatomic, strong) ContactFeedbackViewController *feedback;

- (void)addEntry:(NSString *)type Label:(NSString *)label Value:(NSString *)value;
- (void)sectionHandler:(id)sender;
- (void)currentSectionToTop;

@end
