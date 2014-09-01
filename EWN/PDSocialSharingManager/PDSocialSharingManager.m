//
//  PDSocialSharingManager.m
//  EWN
//
//  Created by Andre Gomes on 2014/01/28.
//
//

#import "PDSocialSharingManager.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>
#import <Twitter/TWRequest.h>
#import <Twitter/TWTweetComposeViewController.h>

#import "EngageProtocol.h"
#import "JRActivityObject.h"



#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@interface PDSocialSharingManager () <JREngageSigninDelegate, JREngageSharingDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
    __block PDSocialSharingManager          *_blockSafeSelf;
    __block PDSocialSharingType             _selectedSocialSharingType;
    
    EngageProtocol                          *_engageProtocol;
    
    NSUserDefaults                          *_userDefaults;
    NSError *_error;
    
    id                                      _target;
    id                                      _userInfo;
    PDSocialSharingManagerCompletionBlock   _completionBlock;
}

@property (nonatomic, strong) UIActionSheet *actionSheet;

@end






@implementation PDSocialSharingManager

@synthesize actionSheet = _actionSheet;



#pragma mark - GETTERS

- (UIActionSheet *)actionSheet
{
    if (!_actionSheet) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sharing Options"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
        [_actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent]; // UIActionSheetStyleDefault
    }
    return _actionSheet;
}



#pragma mark - Lifecycle Methods

+ (PDSocialSharingManager *) sharedInstance;
{
//#ifndef DEBUG
//    // SEC_IS_BEING_DEBUGGED_RETURN_NIL() is a preprocessor macro found in an NSObject category. As the name suggests, it returns nil if the app is being debugged.
//    // Note that this macro is only available in release mode.
//    SEC_IS_BEING_DEBUGGED_RETURN_NIL();
//#endif
    
	// Persistent instance.
	static PDSocialSharingManager *_default = nil;
	
	// Small optimization to avoid wasting time after the
	// singleton being initialized.
	if (_default != nil)
	{
		return _default;
	}
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	// Allocates once with Grand Central Dispatch (GCD) routine.
	// It's thread safe.
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
				  {
					  _default = [[PDSocialSharingManager alloc] initSingleton];
				  });
#else
	// Allocates once using the old approach, it's slower.
	// It's thread safe.
	@synchronized([OMDataManager class])
	{
		// The synchronized instruction will make sure,
		// that only one thread will access this point at a time.
		if (_default == nil)
		{
			_default = [[PDSocialSharingManager alloc] initSingleton];
		}
	}
#endif
	return _default;
}

- (id) initSingleton
{
	if ((self = [super init]))
	{
		// Initialization code here.
        _blockSafeSelf = self;
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _selectedSocialSharingType = PDSocialSharingTypeNone;
	}
	
	return self;
}



#pragma mark - Public Methods

- (void)showSharingOptions:(id)userInfo target:(id)target callback:(PDSocialSharingManagerCompletionBlock)completed
{
    _target = target;
    _userInfo = userInfo;
    _completionBlock = [completed copy];
    _selectedSocialSharingType = PDSocialSharingTypeNone;
    
    if (NSClassFromString(@"UIActivityViewController"))
    {
        [self presentUIActivityViewController:userInfo];
    }
    else
    {
        [self presentActionSheetWithArray:userInfo];
    }
}

- (PDSocialSharingType)selectedSocialSharingType
{
    return _selectedSocialSharingType;
}



#pragma mark - Private Methods

- (void)presentUIActivityViewController:(NSArray *)array
{
    if (array && [_target isKindOfClass:[UIViewController class]])
    {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
        activityController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        NSMutableArray *exclusionActivityTypesArray = [NSMutableArray array];
        [exclusionActivityTypesArray addObject:UIActivityTypePrint];
        [exclusionActivityTypesArray addObject:UIActivityTypeCopyToPasteboard];
        [exclusionActivityTypesArray addObject:UIActivityTypeAssignToContact];
        [exclusionActivityTypesArray addObject:UIActivityTypeSaveToCameraRoll];
        [exclusionActivityTypesArray addObject:UIActivityTypeMessage];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
            [exclusionActivityTypesArray addObject:UIActivityTypeAddToReadingList];
            [exclusionActivityTypesArray addObject:UIActivityTypeAirDrop];
        }
        activityController.excludedActivityTypes = [exclusionActivityTypesArray copy];

        
        [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            
            if (_completionBlock && activityType && completed)
            {
                [_blockSafeSelf setSelectedSocialSharingType:activityType];
                _completionBlock(_blockSafeSelf, completed, nil);
            }
        }];
        
        
        if (activityController)
        {
            UIViewController *targetVC = (UIViewController *)_target;
            
            if ([targetVC respondsToSelector:@selector(presentViewController:animated:completion:)]) {
                [targetVC presentViewController:activityController animated:YES completion:nil];
            } else {
                [targetVC presentModalViewController:activityController animated:YES];
            }
        }
    }
}

- (void)presentActionSheetWithArray:(NSArray *)array
{
    if (array && [_target isKindOfClass:[UIViewController class]])
    {
        UIViewController *targetVC = (UIViewController *)_target;
        [self.actionSheet showFromRect:targetVC.view.frame inView:targetVC.view animated:YES];
    }
}



#pragma mark - Helper Methods

- (void)setSelectedSocialSharingType:(NSString *)sharingString
{
    if (sharingString && sharingString.length > 0)
    {
        sharingString = [sharingString lowercaseString];
        
        if ([sharingString rangeOfString:@"mail"].location != NSNotFound)
        {
            _selectedSocialSharingType = PDSocialSharingTypeMail;
        }
        else if ([sharingString rangeOfString:@"twitter"].location != NSNotFound)
        {
            _selectedSocialSharingType = PDSocialSharingTypeTwitter;
        }
        else if ([sharingString rangeOfString:@"facebook"].location != NSNotFound)
        {
            _selectedSocialSharingType = PDSocialSharingTypeFacebook;
        }
    }
    else
    {
        _selectedSocialSharingType = PDSocialSharingTypeNone;
    }
}


#pragma mark - Provider Methods

- (void)share:(NSArray *)array forProvider:(NSString *)provider
{
    if ([provider rangeOfString:@"mail"].location != NSNotFound)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            // Email Subject
            NSString *emailSubject = [array objectAtIndex:0];
            // Email Content
            NSString *messageBody = [NSString stringWithFormat:@"%@\n%@", [array objectAtIndex:0], [array objectAtIndex:1]];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailSubject];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            
//            [mc.navigationController.navigationBar setTintColor:
//             [UIColor colorWithRed:(10.0f/255.0f) green:(96.0f/255.0f) blue:(80.0f/255.0f) alpha:1.0f]];
            
            
            // Present mail view controller on screen
            UIViewController *targetVC = (UIViewController *)_target;
            
            if ([targetVC respondsToSelector:@selector(presentViewController:animated:completion:)]) {
                [targetVC presentViewController:mc animated:YES completion:nil];
            } else {
                [targetVC presentModalViewController:mc animated:YES];
            }
        }
        else
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Your email account is not configured on this device. Please configure before sending any emails." forKey:NSLocalizedDescriptionKey];
            [errorDetail setValue:@"Email account is not configured on this device." forKey:NSLocalizedFailureReasonErrorKey];
            [errorDetail setValue:@"Set up an email account on the device before continuing." forKey:NSLocalizedRecoveryOptionsErrorKey];
            
            NSError *tempError = [NSError errorWithDomain:@"EmailErrorDomain" code:0 userInfo:errorDetail];
            
            
            if (_completionBlock)
            {
                [_blockSafeSelf setSelectedSocialSharingType:@"email"];
                _completionBlock(_blockSafeSelf, NO, tempError);
            }
        }
    }
    else
    {
        if (_engageProtocol == nil) {
            _engageProtocol = [[EngageProtocol alloc]init];
            _engageProtocol.delegate = self;
        }
        
        NSString *appId = @"egbgbafpecbanbdmjhae";
        [JREngage setEngageAppId:appId tokenUrl:[JREngage tokenUrl] andDelegate:_engageProtocol.delegate];
        
        //    [JREngage showAuthenticationDialogForProvider:provider];
        
        
        NSString *actionString = [array objectAtIndex:0];
        NSString *urlString = [array objectAtIndex:1];
        
        JRActivityObject *activityObject = [JRActivityObject activityObjectWithAction:actionString
                                                                               andUrl:nil]; // urlString
        
        NSString *emailMessageString = [NSString stringWithFormat:@"%@\n%@", actionString, urlString];
        JREmailObject *emailObject = [JREmailObject emailObjectWithSubject:actionString andMessageBody:emailMessageString isHtml:NO andUrlsToBeShortened:NO];
        [activityObject setEmail:emailObject];
        
        [JREngage showSharingDialogWithActivity:activityObject];
    }
}



#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Facebook"])
    {
        [self share:_userInfo forProvider:@"facebook"];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Twitter"])
    {
        [self share:_userInfo forProvider:@"twitter"];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Email"])
    {
        [self share:_userInfo forProvider:@"email"];
    }
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}



#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
//    __block UIAlertView *alertView = nil;
    __block BOOL completed = NO;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            completed = YES;
            break;
        case MFMailComposeResultSent:
            completed = YES;
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    [_blockSafeSelf setSelectedSocialSharingType:@"email"];
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:^{
        
        if (_completionBlock && (result != MFMailComposeResultSaved && result != MFMailComposeResultCancelled))
        {
            _completionBlock(_blockSafeSelf, completed, error);
        }
    }];
}




#pragma mark - JREngageSigninDelegate Methods

- (void) engageDialogDidFailToShowWithError: (NSError *) error
{
    if (_completionBlock)
        _completionBlock(_blockSafeSelf, FALSE, error);
}

//- (void) authenticationDidNotComplete {}

- (void) authenticationDidSucceedForUser:(NSDictionary *) authInfo forProvider:(NSString *)	provider
{
    if ([provider isEqualToString:@"facebook"])
    {
        NSArray *array = (NSArray *)_userInfo;
        
        NSString *actionString = [array objectAtIndex:0];
        NSString *urlString = [array objectAtIndex:1];
        
        JRActivityObject *activityObject = [JRActivityObject activityObjectWithAction:actionString
                                                                               andUrl:nil];
        //    [activityObject setUrl:urlString];
        
        
        NSString *emailMessageString = [NSString stringWithFormat:@"%@\n%@", actionString, urlString];
        JREmailObject *emailObject = [JREmailObject emailObjectWithSubject:actionString andMessageBody:emailMessageString isHtml:NO andUrlsToBeShortened:NO];
        [activityObject setEmail:emailObject];
        
        [JREngage showSharingDialogWithActivity:activityObject];
    }
    else if ([provider isEqualToString:@"twitter"])
    {
        
    }

}

- (void) authenticationDidFailWithError:(NSError *) error forProvider:(NSString *) provider
{
    if (_completionBlock)
    {
        [_blockSafeSelf setSelectedSocialSharingType:provider];
        _completionBlock(_blockSafeSelf, FALSE, error);
    }
}
//- (void) authenticationDidReachTokenUrl:(NSString *) tokenUrl withResponse:(NSURLResponse *) response andPayload:(NSData *) tokenUrlPayload forProvider:(NSString *) provider {}
//- (void) authenticationCallToTokenUrl:(NSString *) tokenUrl didFailWithError:(NSError *) error forProvider:(NSString *) provider {}


#pragma mark - JREngageSharingDelegate Methods

- (void) sharingDidNotComplete {}

- (void) sharingDidComplete {}

- (void) sharingDidSucceedForActivity:(JRActivityObject *) activity forProvider:(NSString *) provider
{
    if (_completionBlock)
    {
        [_blockSafeSelf setSelectedSocialSharingType:provider];
        _completionBlock(_blockSafeSelf, TRUE, nil);
    }
}

- (void) sharingDidFailForActivity:	(JRActivityObject *) activity withError:(NSError *) error forProvider:(NSString *) provider
{
    if (_completionBlock)
    {
        [_blockSafeSelf setSelectedSocialSharingType:provider];
        _completionBlock(_blockSafeSelf, FALSE, error);
    }
}


@end
