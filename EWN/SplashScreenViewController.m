//
//  SplashScreenViewController.m
//  EWN
//
//  Created by Macmini on 17/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SplashScreenViewController.h"
#include "CommanConstants.h"
#import "AppDelegate.h"

AppDelegate *appDelegate;

@implementation SplashScreenViewController
@synthesize imgvwLoading;
@synthesize imgBackground;
@synthesize imgLogo;
@synthesize bubbles;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
/**-----------------------------------------------------------------
 Function Name  : viewDidLoad
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : In this Function I allocate the Splash screen and the animation of Loading bar.
 ------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.imgvwLoading.hidden = YES;
    
    // For iOS 7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
    }
    else if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6)
    {
        int offsetY = 20; // Offset for status bar
        imgBackground.frame = CGRectMake(0, -offsetY, imgBackground.frame.size.width, imgBackground.frame.size.height + 20);
        imgLogo.frame = CGRectMake(imgLogo.frame.origin.x, (imgLogo.frame.origin.y - offsetY), imgLogo.frame.size.width, imgLogo.frame.size.height);
    }
    
    [self.view addSubview: self.imgvwLoading];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Bubble Animations
    bubbles = [[BubblesViewController alloc] init];
    bubbles.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [bubbles createBubbles];
    [self.view insertSubview:self.bubbles.view belowSubview:self.imgLogo];
    
    self.imgLogo.image = nil;
    self.imgLogo.maskImage = [UIImage imageNamed:@"splash_logo_mask"];
    self.imgLogo.loadImage = [UIImage imageNamed:@"splash_logo"];

    __weak SplashScreenViewController *bloackSafeSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_INIT_LOAD_PROGRESS
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {                                                      
                                                      NSNumber *progressNumber = note.object;
                                                      [bloackSafeSelf.imgLogo setProgress:progressNumber.floatValue animated:YES];
                                                  }];
}
/**-----------------------------------------------------------------
 Function Name  : afterViewDidLoad
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : In this function, I called notifire for network reachability, and add the newsListViewController view.
 ------------------------------------------------------------------*/
-(void) afterViewDidLoad
{
    if (![appDelegate IsReachable])
    {
        [appDelegate updateAlertWithReachability:nil];
    }
}

- (void)viewDidUnload
{	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_INIT_LOAD_PROGRESS object:nil];
    
    [bubbles killBubbles];
    bubbles = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
