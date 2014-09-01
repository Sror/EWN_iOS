//
//  PDBackgroundTaskManager.m
//  EWN
//
//  Created by Andre Gomes on 2014/02/03.
//
//

#import "PDBackgroundTaskManager.h"


#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@interface PDBackgroundTaskManager ()
{
    __block NSString                                *_taskName;
    __block PDBackgroundTaskExecutionBlock          _executionBlock;
    __block PDBackgroundTaskExpirationHandlerBlock  _expirationBlock;
    __block UIBackgroundTaskIdentifier              _backgroundTask;
    
    __block PDBackgroundTaskManager                 *_blockSafeSelf;
    __block UIApplication                           *_application;
}
@end






@implementation PDBackgroundTaskManager


#pragma mark - Lifecycle Methods

+ (PDBackgroundTaskManager *) sharedInstance
{
    //#ifndef DEBUG
    //    // SEC_IS_BEING_DEBUGGED_RETURN_NIL() is a preprocessor macro found in an NSObject category. As the name suggests, it returns nil if the app is being debugged.
    //    // Note that this macro is only available in release mode.
    //    SEC_IS_BEING_DEBUGGED_RETURN_NIL();
    //#endif
    
	// Persistent instance.
	static PDBackgroundTaskManager *_default = nil;
	
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
					  _default = [[PDBackgroundTaskManager alloc] initSingleton];
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
			_default = [[PDBackgroundTaskManager alloc] initSingleton];
		}
	}
#endif
	return _default;
}

+ (PDBackgroundTaskManager *) backgroundTaskManager
{    
    return [[[self class] alloc] init];
}

- (id)init
{
    if (self = [super init]) {
        [self initalize];
    }
    return self;
}

- (id) initSingleton
{
	if ((self = [super init])) {
		[self initalize];
	}
	return self;
}

- (void)initalize
{
    // Initialization code here.
    _blockSafeSelf = self;
    _taskName = nil;
    _backgroundTask = UIBackgroundTaskInvalid;
    _application = [UIApplication sharedApplication];
}

#pragma mark - Public Methods

- (UIBackgroundTaskIdentifier )backgroundTask
{
    return _backgroundTask;
}

- (void)endBackgroundTask
{
    [_application endBackgroundTask:_backgroundTask]; //End the task so the system knows that you are done with what you need to perform
    _backgroundTask = UIBackgroundTaskInvalid; //Invalidate the background_task
}

- (void)executeBackgroundTask:(NSString *)taskName
            expirationHandler:(PDBackgroundTaskExpirationHandlerBlock)expirationBlock
             executionHandler:(PDBackgroundTaskExecutionBlock)executionBlock
{
    
    [self startBackgroundTask:taskName expirationHandler:expirationBlock executionHandler:executionBlock];
}

- (void)executeBackgroundTaskWithExpirationHandler:(PDBackgroundTaskExpirationHandlerBlock)expirationBlock
                                  executionHandler:(PDBackgroundTaskExecutionBlock)executionBlock
{
    [self startBackgroundTask:nil expirationHandler:expirationBlock executionHandler:executionBlock];
}



#pragma mark - Private Methods

- (void)startBackgroundTask:(NSString *)taskName
          expirationHandler:(PDBackgroundTaskExpirationHandlerBlock)expirationBlock
           executionHandler:(PDBackgroundTaskExecutionBlock)executionBlock
{
    // Check if our iOS version supports multitasking I.E iOS 4.
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        // Check if device supports mulitasking.
        if ([[UIDevice currentDevice] isMultitaskingSupported])
        {
            _expirationBlock = [expirationBlock copy];
            _executionBlock = [executionBlock copy];
            _backgroundTask = [_application beginBackgroundTaskWithExpirationHandler: ^ {
                _expirationBlock(_blockSafeSelf, _taskName);
                [_application endBackgroundTask:_backgroundTask]; // Tell the system that we are done with the tasks.
                _backgroundTask = UIBackgroundTaskInvalid; // Set the task to be invalid.
                // System will be shutting down the app at any point in time now
            }];
            
//            DLog(@"\n*\n*\nExecuting backgroundTask for %i [%f]\n*\n*\n", _backgroundTask, _application.backgroundTimeRemaining);
            
            //Background tasks require you to use asyncrous tasks
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _executionBlock(_blockSafeSelf, _taskName);
//                [_application endBackgroundTask:_backgroundTask]; //End the task so the system knows that you are done with what you need to perform
//                _backgroundTask = UIBackgroundTaskInvalid; //Invalidate the background_task
            });
        }
    }
}

@end
