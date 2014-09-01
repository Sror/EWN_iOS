//
//  ContactSectionViewController.m
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import "ContactSectionViewController.h"

@interface ContactSectionViewController ()

@end

@implementation ContactSectionViewController

@synthesize button;
@synthesize sectionView;
@synthesize initialFrame;
@synthesize sectionFrame;
@synthesize sectionId;

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
    // Do any additional setup after loading the view from its nib.
    
    // This button's tap will be managed in parent i.e. ContactViewController
    self.button = [[UIButton alloc] init];
    [self.button setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.button];
    
    [self.titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:14.0]];
    
//    [self setArrowIndicatorOpen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)config
{
    [self setInitialFrame:self.view.frame];
    [self setSectionFrame:self.sectionView.frame];
    [self.sectionView setHidden:YES];
}

- (void)setPosition:(int)offset
{
    int offsetY = (self.view.frame.origin.y + offset);
    [self move:offsetY];
}

- (void)resetPosition:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration: 0.4f
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self setSectionFrame:self.sectionView.frame];
                             [self.view setFrame:initialFrame];
                         }
                         completion:^(BOOL finished){
                             [self.sectionView setHidden:YES];
                         }];
    }
    else
    {
         [self setSectionFrame:self.sectionView.frame];
         [self.view setFrame:initialFrame];
         [self.sectionView setHidden:YES];
    }
    
}

- (void)move:(int)offset
{
    [UIView animateWithDuration: 0.5f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect animFrame = self.view.frame;
                         animFrame.origin.y = offset;
                         self.view.frame = animFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
}

- (void)toggle:(bool)value
{
    [self.sectionView setHidden:!value];
    
    if(value)
    {
        CGRect collapse = CGRectMake(self.sectionFrame.origin.x, self.sectionFrame.origin.y, self.sectionFrame.size.width, 0);
        self.sectionView.frame = collapse;
        
        [UIView animateWithDuration: 0.5f
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.sectionView.frame = sectionFrame;
                         }
                         completion:^(BOOL finished){
                             [self setArrowIndicatorOpen];
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"SCROLL_CONTACT_TO_CURRENT" object:nil];
                         }
         ];
    } else {
        [self setArrowIndicatorClosed];
    }
}

-(void)setArrowIndicatorClosed {
    [self.arrowImageClosed setHidden:NO];
    [self.arrowImageOpen setHidden:YES];
}

-(void)setArrowIndicatorOpen {
    [self.arrowImageClosed setHidden:YES];
    [self.arrowImageOpen setHidden:NO];
}

// ==============================================================================================================================
// NEW
// ==============================================================================================================================

- (void)method1
{
    // Collapse View
    [self showSection:NO];
    
    // Reposition View
    
    // Reposition Header
}

- (void)method2:(int)offset
{
    // Expand View
    [self showSection:YES];
    
    // Reposition View
    
    // Reposition Header

}

- (void)method3:(int)offset
{
    // Collapse View
    [self showSection:NO];
    
    // Reposition View
    
    // Reposition Header
}

- (void)showSection:(bool)value
{
    [self.sectionView setHidden:!value];
    
    if(value)
    {
        CGRect collapse = CGRectMake(self.sectionFrame.origin.x, self.sectionFrame.origin.y, self.sectionFrame.size.width, 0);
        self.sectionView.frame = collapse;
        
        [UIView animateWithDuration: 0.5f
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.sectionView.frame = sectionFrame;
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
    }
}

@end
