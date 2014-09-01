//
//  DockMenuViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/24.
//
//

#import "DockMenuViewController.h"

@interface DockMenuViewController ()

@end



@implementation DockMenuViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // isLogin - Post + View All/Minimize
    // !isLogin - Login + ViewAll/Minimize
}

-(void)update
{
    [self.view setHidden:NO];
    
    NSString *mode = [[NSString alloc] initWithString:@"login"];
    
    // check the login state here to see if we are logged in or not
    NSString *userId = [self userIdReturn];
    if ([userId isEqualToString:@""]) {
        mode = @"logout";
    }
    
    if([mode isEqualToString:@"login"])
    {
        [self.loginBtn setHidden:YES];
        [self.minBtn setHidden:YES];
        [self.viewBtn setHidden:NO];
        [self.postBtn setHidden:NO];
    }
    
    if([mode isEqualToString:@"logout"])
    {
        [self.loginBtn setHidden:NO];
        [self.minBtn setHidden:NO];
        [self.viewBtn setHidden:YES];
        [self.postBtn setHidden:YES];
    }
    
    if(!self.isViewAll)
    {
        [self.minBtn setHidden:YES];
        
        if (self.commentCount > 0)
        {
            [self.viewBtn setHidden:NO];
            
            // If minimized, position View All button based on whether the user is logged in or not ...
            CGRect newFrame = self.viewBtn.frame;
            newFrame.origin.x = ([mode isEqualToString:@"login"]) ? (self.postBtn.frame.origin.x - self.viewBtn.frame.size.width - 5) : (self.loginBtn.frame.origin.x - self.viewBtn.frame.size.width - 2);
            [self.viewBtn setFrame:newFrame];
        }
        else
        {
            [self.viewBtn setHidden:YES];
        }
    }
    else
    {
        [self.minBtn setHidden:NO];
        [self.viewBtn setHidden:YES];
        
        // If expanded, position View All button based on whether the user is logged in or not ...
        CGRect newFrame = self.viewBtn.frame;
        newFrame.origin.x = ([mode isEqualToString:@"login"]) ? (self.postBtn.frame.origin.x - self.minBtn.frame.size.width - 5) : (self.loginBtn.frame.origin.x - self.minBtn.frame.size.width - 2);
        [self.minBtn setFrame:newFrame];
    }
}

// return user id
-(NSString *) userIdReturn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"UserId"];
    if (userId == nil) {
        userId = @"";
    }
    return userId;
}

@end
