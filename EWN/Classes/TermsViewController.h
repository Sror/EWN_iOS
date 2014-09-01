//
//  TermsViewController.h
//  EWN
//
//  Created by Dolfie Jay on 2014/04/10.
//
//

#import <UIKit/UIKit.h>

@interface TermsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *termButton;
@property (nonatomic, strong) IBOutlet UILabel *termLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *termScroll;

- (void)closeContributeTermsModal;

@end
