//
//  PDBackgroundTaskManager.h
//  EWN
//
//  Created by Andre Gomes on 2014/02/03.
//
//

#import <Foundation/Foundation.h>

@interface PDBackgroundTaskManager : NSObject


#if NS_BLOCKS_AVAILABLE
typedef void (^PDBackgroundTaskExecutionBlock)(PDBackgroundTaskManager *manager, NSString *taskName);
typedef void (^PDBackgroundTaskExpirationHandlerBlock)(PDBackgroundTaskManager *manager, NSString *taskName);
#endif



// Instantiation method for singleton.
+ (PDBackgroundTaskManager *) sharedInstance;

// This creates a weak reference.
+ (PDBackgroundTaskManager *) backgroundTaskManager;



// Public Methods
- (UIBackgroundTaskIdentifier )backgroundTask;

- (void)endBackgroundTask;

#if NS_BLOCKS_AVAILABLE
- (void)executeBackgroundTask:(NSString *)taskName
            expirationHandler:(PDBackgroundTaskExpirationHandlerBlock)expirationBlock
             executionHandler:(PDBackgroundTaskExecutionBlock)executionBlock NS_AVAILABLE_IOS(7_0);

- (void)executeBackgroundTaskWithExpirationHandler:(PDBackgroundTaskExpirationHandlerBlock)expirationBlock
                                  executionHandler:(PDBackgroundTaskExecutionBlock)executionBlock;
#endif

@end
