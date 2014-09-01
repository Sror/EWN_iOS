//
//  SplashScreenViewController.h
//  EWN
//
//  Created by Macmini on 17/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
/**------------------------------------------------------------------------
 File Name      : SplashScreenViewController.h
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Purpose        : Displays splash screen And check rechability of network.
 -------------------------------------------------------------------------*/
#import <UIKit/UIKit.h>
#import "NewsListViewController.h"

#import "BubblesViewController.h"
#import "EWNImageView.h"


@class Reachability;

@interface SplashScreenViewController : UIViewController
{
    IBOutlet UIImageView *imgvwLoading;
    IBOutlet UIImageView *imgBackground;
    IBOutlet EWNImageView *imgLogo;
    NewsListViewController *newsListViewController;
    
    BubblesViewController *bubbles;
}
@property (nonatomic, strong) IBOutlet UIImageView *imgvwLoading;
@property (nonatomic, strong) IBOutlet UIImageView *imgBackground;
@property (nonatomic, strong) IBOutlet __block EWNImageView *imgLogo;

@property (nonatomic, strong) BubblesViewController *bubbles;
-(void) afterViewDidLoad;
@end
