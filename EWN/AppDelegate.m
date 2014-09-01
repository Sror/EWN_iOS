//
//  AppDelegate.m
//  EWN
//
//  Created by Macmini on 17/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "UAConfig.h"
#import "UAirship.h"
#import "UAPush.h"
#import "TestFlight.h"
#import "MainViewController.h"

#import <MediaPlayer/MediaPlayer.h>


@implementation AppDelegate
@synthesize window = _window;
@synthesize reachHost;
@synthesize background;
@synthesize viewControllerMain;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.bAppEnteredBackground = FALSE;
        
    // TestFlight
//    [TestFlight takeOff:@"b3cc1025-7b29-41a1-8a48-4439b7d7b225"];
   
    [self registerDefaultsValues];
    
    [Flurry startSession:kFLURRY_API_KEY];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:kUICOLOR_SIDEMNU_BACK];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kstrCurrentCategory] != nil)
    {
        [[WebserviceComunication sharedCommManager] setDictCurrentCategory:[[NSUserDefaults standardUserDefaults] objectForKey:kstrCurrentCategory]];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.height == 568)
        {
            viewControllerMain  = [[MainViewController alloc] initWithNibName:kstrMainViewController_iPhone5 bundle:nil];
        }
        else
        {
            viewControllerMain  = [[MainViewController alloc] initWithNibName:kstrMainViewController_iPhone bundle:nil];
        }
    }
    
    [self.window setRootViewController:viewControllerMain];
    [self.window makeKeyAndVisible];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EWNCache.sqlite"];
    [self addSkipBackupAttributeToItemAtURL:storeURL];
    
    // For iOS 7 - Initial solution, but programmatically adjusting the XIB's in ViewController now ... See if that works better
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        background = [[UIWindow alloc] initWithFrame: CGRectMake(0, 0, self.window.frame.size.width, 20)];
        float color = 225.0;
        background.backgroundColor = [UIColor colorWithRed:(color/255.0) green:(color/255.0) blue:(color/255.0) alpha:1.0];
        [background setHidden:NO];
    }
    
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    [[UAPush shared] setPushEnabled:YES];
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeNewsstandContentAvailability)];
    [UAPush shared].delegate = self;
    
    reachHost = [AReachability reachabilityWithHostName:@"www.google.com"];
    [reachHost startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NetworkReachabilityChanged:) name:kAReachabilityChangedNotification object:nil];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    /*UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:@"Error Registering Push Notifications" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertError show];*/
}

/**-----------------------------------------------------------------
 Function Name  : IsReachable
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 19-Apr-2013
 Purpose        : In this function, I check the network connection.
 ------------------------------------------------------------------*/

-(BOOL)IsReachable
{
    if([[AReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN || [[AReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi)
    {
        return YES;
    }
    return NO;
}
/**-----------------------------------------------------------------
 Function Name  : NetworkReachabilityChanged
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 19-Apr-2013
 Purpose        : If reachability get changes in network connection this function will called
 ------------------------------------------------------------------*/
//Called by Reachability whenever status changes.
- (void) NetworkReachabilityChanged: (NSNotification* )note
{
    AReachability *networkReachability = [AReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        DLog(@"There IS NO internet connection");
    } else {
        DLog(@"There IS internet connection");
    }
    
	AReachability* reachCurrent = [note object];
	NSParameterAssert([reachCurrent isKindOfClass: [AReachability class]]);
    
    [self updateAlertWithReachability:reachCurrent];
    
}

/**-----------------------------------------------------------------
 Function Name  : updateAlertWithReachability
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 19-Apr-2013
 Purpose        : popup an alert with changed status of rechability
 ------------------------------------------------------------------*/

- (void) updateAlertWithReachability: (AReachability*) reachCurrent
{    
    if([self IsReachable] == NO)
    {
//        DLog(@"This claims we have no connection!!!");
        if(![[[WebserviceComunication sharedCommManager] alrtvwNotReachable].view isDescendantOfView:[[WebserviceComunication sharedCommManager] window]])
        {
            [[WebserviceComunication sharedCommManager] showAlertForNoConnection];
        }
    }
    else
    {
//        DLog(@"Apparently we are connected!!!");
        if([[WebserviceComunication sharedCommManager] isAlreadyOffLine] == [[WebserviceComunication sharedCommManager] isOnline]) {
            for (UIView *subView in self.window.subviews)
            {
                if ([[subView nextResponder] isKindOfClass:[CustomAlertView class]])
                {
                    [subView removeFromSuperview];
                }
            }
            
            if(![[[WebserviceComunication sharedCommManager] alrtvwReachable].view isDescendantOfView:[[WebserviceComunication sharedCommManager] window]]) {
                // This needs to be made easier!!!
                [[WebserviceComunication sharedCommManager] setIsOnline:YES];
                [[WebserviceComunication sharedCommManager] setIsAlreadyOffLine:![[WebserviceComunication sharedCommManager] isOnline]];
                [[WebserviceComunication sharedCommManager] setIsAlreadyOnline:[[WebserviceComunication sharedCommManager] isOnline]];
                
                [[WebserviceComunication sharedCommManager] setAlrtvwReachable:[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil]];
                [[[WebserviceComunication sharedCommManager]alrtvwReachable] show:YES ShowDetail:YES NumberOfButtons:2];
                [[WebserviceComunication sharedCommManager] alrtvwReachable].lblHeading.text=[NSString stringWithFormat:@"Connection Regained"];
                [[WebserviceComunication sharedCommManager] alrtvwReachable].lblDetail.text=[NSString stringWithFormat:kstrConnectionRegained];
                [[[WebserviceComunication sharedCommManager] alrtvwReachable].btn1 setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
                [[[WebserviceComunication sharedCommManager] alrtvwReachable].btn2 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
                [[[WebserviceComunication sharedCommManager] alrtvwReachable].view setTag:kALERT_TAG_ACTIVE_CONNECTION];
            }
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DLog(@":: App Delegate - Inactive!");
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog(@":: App Delegate - Background!");
    
    // Cancel any current active loads
//    [[WebserviceComunication sharedCommManager] requestCancel];
    
    self.bAppEnteredBackground = TRUE;
    
    [[NSUserDefaults standardUserDefaults] setObject:[[WebserviceComunication sharedCommManager] dictCurrentCategory] forKey:@"CurrentCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DLog(@":: App Delegate - Foreground!");
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [self registerDefaultsValues];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if ([self.window.rootViewController isKindOfClass:[MainViewController class]])
    {
        if([[AReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN || [[AReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi)
        {
            if([[[WebserviceComunication sharedCommManager]alrtvwNotReachable].view isDescendantOfView:[[WebserviceComunication sharedCommManager] window]])
            {
                [[[WebserviceComunication sharedCommManager]alrtvwNotReachable].view removeFromSuperview];
            }
            
            if([[WebserviceComunication sharedCommManager] isAllocateFirstTime])
            {
                [[WebserviceComunication sharedCommManager] setIsOnline:TRUE];
                [[WebserviceComunication sharedCommManager] setIsAlreadyOffLine:FALSE];
                [[WebserviceComunication sharedCommManager] setIsAlreadyOnline:TRUE];
                
                if([(MainViewController*)[self.window rootViewController] newsListViewController])
                {
                    DLog(@"Extra reload?");
                }
            }
            else
            {
//                [self.tmSceduler fire];
            }
        }
        else
        {
            [[WebserviceComunication sharedCommManager] showAlertForNoConnection];
        }
    }
}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    NSUInteger orientations = UIInterfaceOrientationMaskPortrait;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    UIViewController *viewController = [objMainView presentedViewController];
    
    if ([viewController isKindOfClass:[MPMoviePlayerViewController class]]) {
        orientations = UIInterfaceOrientationMaskAll;
    }
    
    return orientations;
}


- (void)saveContext {
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            DLog(@"Error Saving Context");
        }
    }
}
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (void)resetManagedObjectContext
{
    if ([managedObjectContext_ hasChanges])
    {
        NSError *err = nil;
        [managedObjectContext_ save:&err];
    }
    
    managedObjectContext_ = nil;
    
    [self managedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EWNCache" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EWNCache.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
    // Check if we already have a persistent store
    if ( [[NSFileManager defaultManager] fileExistsAtPath: [storeURL path]] ) {
        NSDictionary *existingPersistentStoreMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: NSSQLiteStoreType URL: storeURL error: &error];
        if ( !existingPersistentStoreMetadata ) {
            // Something *really* bad has happened to the persistent store
            [NSException raise: NSInternalInconsistencyException format: @"Failed to read metadata for persistent store %@: %@", storeURL, error];
        }
        
        if ( ![[self managedObjectModel] isConfiguration: nil compatibleWithStoreMetadata: existingPersistentStoreMetadata] ) {
            DLog(@"Store Not compatible - Delete");
            if ( ![[NSFileManager defaultManager] removeItemAtURL: storeURL error: &error] )
                DLog(@"*** Could not delete persistent store, %@", error);
        } // else the existing persistent store is compatible with the current model - nice!
    } // else no database file yet
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //DLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
    
    [self addSkipBackupAttributeToItemAtURL:storeURL];
    return persistentStoreCoordinator_;
}
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    // TODO
//    [UAirship land];
}

- (void)registerDefaultsValues
{
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
    [dictTemp setObject:kstrKeyForAllNews forKey:kstrId];
    [dictTemp setObject:kstrAllNews forKey:kstrName];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:dictTemp forKey:kstrCurrentCategory]];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSDictionary dictionary] forKey:kstrLeadingNews]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)applicationPrivateDocPath
{
    NSString *privateDocPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
    return privateDocPath;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

// URBAN AIRSHIP PROTOCAL METHODS
- (void)displayNotificationAlert:(NSString *)alertMessage {
    // we safely ignore this urban airship default behaviour
}

// This can be one of 2 things
// Either the app is woken up from the background in which case we can ignore it because didReceiveRemoteNotification will handle it
// Or the app is launched in which case we have to wait for the start up sequence to finish and then start acting
// we should only action this if the app is launched from scratch
- (void)launchedFromNotification:(NSDictionary *)notification {
    DLog(@"Notification from launch : %@",notification);
    // check if we were launched from scratch
    if (!self.bAppEnteredBackground) {
        DLog(@"Gotta wait for startup to finish before jazzing this...");
        DLog(@"I reckon save the dictionary to the mainviewController.");
        viewControllerMain.breakingNewsNotification = notification;
        DLog(@"Then after we received the latest news handle it like a boss");
    } else {
        DLog(@"Let the other method handle the notification");
    }
}

// ok sweet this does not happen if the app is launched
// only if its active or in the background
// either way it can be used straight away
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // call a method to handle this with the dictionary
    [viewControllerMain handleNotification:userInfo];
}

- (void) dealloc {
    [viewControllerMain release];
    [self.window release];
    [super dealloc];
}

@end
