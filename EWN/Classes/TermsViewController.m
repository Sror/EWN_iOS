//
//  TermsViewController.m
//  EWN
//
//  Created by Dolfie Jay on 2014/04/10.
//
//

#import "TermsViewController.h"

@interface TermsViewController ()

@end

@implementation TermsViewController

@synthesize termButton;
@synthesize termLabel;
@synthesize termScroll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    termLabel.text = [[WebserviceComunication sharedCommManager] termsText];
    [termLabel sizeToFit];
    CGSize contentSize = CGSizeMake(termLabel.frame.size.width, termLabel.frame.size.height + 15);
    [termScroll setContentSize:contentSize];
    [termButton addTarget:self action:@selector(closeContributeTermsModal) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeContributeTermsModal {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_CLOSE_CONTRIBUTE_TERMS object:nil];
}

@end
