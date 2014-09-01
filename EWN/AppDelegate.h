//
//  AppDelegate.h
//  EWN
//
//  Created by Macmini on 17/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertView.h"
#import <CoreData/CoreData.h>
#import "CommanConstants.h"
#import "AReachability.h"
#import <sys/xattr.h>

@class MainViewController;

@protocol UAPushNotificationDelegate
    - (void)displayNotificationAlert:(NSString *)alertMessage;
    - (void)launchedFromNotification:(NSDictionary *)notification;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, UAPushNotificationDelegate>
{
    AReachability *reachHost;

@private
	
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;

    
}
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) AReachability *reachHost;
//@property (nonatomic ,retain)     NSTimer *tmSceduler;
@property (nonatomic, strong) MainViewController *viewControllerMain;

@property (nonatomic, assign) BOOL bAppEnteredBackground;
@property (strong, nonatomic) UIWindow *background;

- (BOOL) IsReachable;
- (void) updateAlertWithReachability: (AReachability*) curReach;

- (void)saveContext;

- (void)registerDefaultsValues;

- (void)resetManagedObjectContext;

- (NSString*)applicationPrivateDocPath;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
