//
//  CacheDataManager.m
//  EWN
//
//  Created by Arpit Jain on 4/29/13.
//
//

#import "CacheDataManager.h"
#import "AppDelegate.h"

AppDelegate *appDelegate;

@implementation CacheDataManager
@synthesize isExpireCategory;

/**-----------------------------------------------------------------
 Function Name  : sharedManager
 Created By     : Arpit Jain
 Created Date   : 1-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : for Shared object.
 ------------------------------------------------------------------*/
+ (id)sharedCacheManager {
    static WebserviceComunication *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


/**-----------------------------------------------------------------
 Function Name  : init
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Initialize all objects.
 ------------------------------------------------------------------*/

-(id)init
{
    if (self = [super init])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        numCategoryIndex = 1;
        numContentIndex = 1;
        numRelatedStoryIndex = 1;
    }
    return self;
}


- (BOOL)isMigrationNecessary
{
    NSPersistentStoreCoordinator *psc = appDelegate.persistentStoreCoordinator; /* get a coordinator */
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    NSString *sourceStoreType = NSSQLiteStoreType; /* type for the source store, or nil if not known */
    NSPersistentStore *persistantStore = [managedObjectContext.persistentStoreCoordinator.persistentStores lastObject];
    NSURL *sourceStoreURL = persistantStore.URL;/* URL for the source store */
    NSError *error = nil;
    
    NSDictionary *sourceMetadata =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:sourceStoreType
                                                               URL:sourceStoreURL
                                                             error:&error];
    
    if (sourceMetadata == nil) {
        // deal with error
    }
    
    NSString *configuration = persistantStore.configurationName; /* name of configuration, or nil */ ;
    NSManagedObjectModel *destinationModel = [psc managedObjectModel];
    BOOL pscCompatibile = [destinationModel
                           isConfiguration:configuration
                           compatibleWithStoreMetadata:sourceMetadata];
    
    if (pscCompatibile) {
        // no need to migrate
        return NO;
    }
    
    
    return YES;
}


-(NSMutableArray *)getContentsForArticleId:(NSString *)parentArticleId {
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    
    NSFetchRequest *requesty = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContentContents inManagedObjectContext:appDelegate.managedObjectContext];
    [requesty setEntity:entity];
    NSPredicate *requestyPredicate = [NSPredicate  predicateWithFormat:[NSString stringWithFormat:@"parentArticleId = '%@'", parentArticleId]];
    [requesty setPredicate:requestyPredicate];
    NSError *error;
    NSArray *contentContents = [[appDelegate.managedObjectContext executeFetchRequest:requesty error:&error] mutableCopy];
    NSMutableArray *articleIds = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < [contentContents count]; x++) {
        ContentContents *articleId = [contentContents objectAtIndex:x];
        [articleIds addObject:[articleId childArticleId]];
    }
    
    entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
    [requesty setEntity:entity];
    requestyPredicate = [NSPredicate predicateWithFormat:@"articleID IN %@", articleIds];
    [requesty setPredicate:requestyPredicate];
    articles = [[appDelegate.managedObjectContext executeFetchRequest:requesty error:&error] mutableCopy];
    
    return articles;
}

/**-----------------------------------------------------------------
 Function Name  : isExpireValidityOFContentType
 Created By     : Arpit Jain
 Created Date   : 1-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : Checks the validity of cacheData and returns true or false.
 ------------------------------------------------------------------*/

-(BOOL)hasCacheDataExpiredForContent:(NSString *)contentType
{
    
    if([contentType isEqualToString:kEntityCategory])
    {
        NSDate *dateAdded = [[NSUserDefaults standardUserDefaults] valueForKey:kDateForDeleteCategoryCache];
        if (dateAdded == nil) {
            return true;
        }
        double intevalInSeconds = [[NSDate date] timeIntervalSinceDate:dateAdded];
        
        if(intevalInSeconds > kExpireValidityOfCategory)
        {
            return TRUE;
        }
        else
        {
            return FALSE;
        }
    }
    if([contentType isEqualToString:kEntityInFocus])
    {
        NSDate *dateAdded = [[NSUserDefaults standardUserDefaults] valueForKey:kDateForDeleteInFocusCache];
        if (dateAdded == nil) {
            return true;
        }        
        double intervalInSeconds = [[NSDate date] timeIntervalSinceDate:dateAdded];
        
        if(intervalInSeconds > kExpireValidityOfInFocus)
        {
            return TRUE;
        }
        else
        {
            return FALSE;
        }
    }
    else
    {
        // check other content..
        if([[self getContents] count] > 0)
        {
            return  FALSE;
        }
        else
        {
            return  TRUE;
        }
    }
    
    return TRUE;
}
/**-----------------------------------------------------------------
 Function Name  : hasCacheDataExpiredForStory
 Created By     : Arpit Jain
 Created Date   : 3-June-2013
 Modified By    :
 Modified Date  :
 Purpose        : Checks the validity of cacheData for story time line and returns true or false.
 ------------------------------------------------------------------*/

-(BOOL)hasCacheDataExpiredForStory:(NSDate *)dateArticleType
{
    double intevalInSeconds = [[NSDate date] timeIntervalSinceDate:dateArticleType];
    
    if(intevalInSeconds > kExpireValidityOfStory)
    {
        // Expire story
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

/**-----------------------------------------------------------------
 Function Name  : getCatogery
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Get all categories from database and return array of it.
 ------------------------------------------------------------------*/

-(NSMutableArray *)getCatogery {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityCategory inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kstrCategoryIndex ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    if ([self hasCacheDataExpiredForContent:kEntityCategory])
    {
        DLog(@"Cache expired so what is it adding the predicate for?");
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"categoryId like '%@'", kstrKeyForAllNews]];
        [request setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        // Handle the error.
        DLog(@"NO CATEGORIES IN CACHE!!!!!!!!!!");
    }
    
    return mutableFetchResults;
}

/**-----------------------------------------------------------------
 Function Name  : getInFocusArray
 Created By     : Armpit Jane
 Created Date   : 09-Dec-2013
 Modified By    :
 Modified Date  :
 Purpose        : Return array of In Focus items
 ------------------------------------------------------------------*/
-(NSMutableArray *)getInFocusArray
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityInFocus inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    [request setFetchLimit:kIN_FOCUS_LIMIT];
    
    if ([self hasCacheDataExpiredForContent:kEntityInFocus])
    {
        DLog(@"do smething cache db!");
    }
    
    NSError *err = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&err] mutableCopy];
    if(mutableFetchResults == nil)
    {
        DLog(@":: Error retrieving InFocus items ...");
    }
    
    return mutableFetchResults;
}

/**-----------------------------------------------------------------
 Function Name  : addCategoriesWithItemArray
 Created By     : Arpit Jain
 Created Date   : 09-Dec-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method adds the items of category in database.
 ------------------------------------------------------------------*/

-(void)addCategoriesWithItemArray:(NSMutableArray *)arrItem
{
    for(int numIndex = 0; numIndex<[arrItem count];numIndex++)
    {
        Category_Items *addCategory = (Category_Items *)[NSEntityDescription insertNewObjectForEntityForName:kEntityCategory inManagedObjectContext:appDelegate.managedObjectContext];
        
        [addCategory setCategoryId:[[arrItem objectAtIndex:numIndex] objectForKey:kstrId]];
        [addCategory setCategoryName:[[arrItem objectAtIndex:numIndex] objectForKey:kstrName]];
        [addCategory setCategoryIndex:(int)[NSNumber numberWithInt:numCategoryIndex]];
        
        numCategoryIndex++;
        NSError *err;
        if (![appDelegate.managedObjectContext save:&err])
        {
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kDateForDeleteCategoryCache];
        }
        
    }
    numCategoryIndex = 1;
}

/**-----------------------------------------------------------------
 Function Name  : addCategoriesWithItemArray
 Created By     : Armpit Jane
 Created Date   : 09-Dec-2013
 Modified By    :
 Modified Date  :
 Purpose        : This method adds In Focus items to DB
 ------------------------------------------------------------------*/
-(void)addInFocusWithItemArray:(NSMutableArray *)array
{
    for(int i = 0; i < [array count]; i++)
    {
        InFocus_Items *item = (InFocus_Items *)[NSEntityDescription insertNewObjectForEntityForName:kEntityInFocus inManagedObjectContext:appDelegate.managedObjectContext];
        
        [item setId:[[array objectAtIndex:i] objectForKey:kstrId]];
        [item setTitle:[[array objectAtIndex:i] objectForKey:kstrTitle]];
        [item setImageUrl:[[array objectAtIndex:i] objectForKey:kstrImageUrl]];
        
        NSError *err;
        if(![appDelegate.managedObjectContext save:&err])
        {
            DLog(@"Error saving InFocus_Item");
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kDateForDeleteInFocusCache];
        }
    }
}

/**-----------------------------------------------------------------
 Function Name  : deleteCachedataOfEntity
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method deletes Content items of category from database.
 ------------------------------------------------------------------*/
-(void)deleteCachedataOfEntity:(NSString *)strEntityName contentType:(NSString *)strContentType
{
    DLog(@"Removing %@",strEntityName);
    
    //delete from database....
    NSDate *currentDate = [NSDate date];
    
    NSDate *newDate = [currentDate dateByAddingTimeInterval:-(3*24*60*60)];

    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
    [request setPredicate:[NSPredicate predicateWithFormat:@"contentType = %@ and createdDate < %@",strContentType, newDate]];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    for (NSManagedObject *product in mutableFetchResults)
    {
        [appDelegate.managedObjectContext deleteObject:product];
    }
    DLog(@"Save 1");
    if (![appDelegate.managedObjectContext save:&error])
    {
        // Handle the error.
    }
}
/**-----------------------------------------------------------------
 Function Name  : deleteCachedataOfEntity
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method delets StoryTimeline and related story items from database.
 ------------------------------------------------------------------*/

-(void)deleteCachedataOfEntity:(NSString *)strEntityName articleID:(NSString *)strArticleID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:strEntityName inManagedObjectContext:appDelegate.managedObjectContext];
    if ([entity respondsToSelector:@selector(setArticleID:)])
    {
        [request setPredicate:[NSPredicate predicateWithFormat:@"articleID=%@",strArticleID]];
    }
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i = 0; i<[mutableFetchResults count]; i++)
    {
        [arr addObject:(RelatedStoryAndTimeline *)[mutableFetchResults objectAtIndex:i]];
    }
    
    for (NSManagedObject *product in mutableFetchResults)
    {
        [appDelegate.managedObjectContext deleteObject:product];
    }
    DLog(@"Save 2");
    if (![appDelegate.managedObjectContext save:&error])
    {
    }
}

/**-----------------------------------------------------------------
 Function Name  : deleteAllCategory
 Created By     : Arpit Jain
 Created Date   : 30-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method delets all items of category from database.
 ------------------------------------------------------------------*/

-(void)deleteCachedataOfEntity:(NSString *)strEntityName
{
    DLog(@"Deleting deleteCachedataOfEntity %@",strEntityName);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:strEntityName inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];

    // what is the sort descriptor for then? Dong
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kstrCategoryIndex ascending:YES];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    for (NSManagedObject *product in mutableFetchResults)
    {
        [appDelegate.managedObjectContext deleteObject:product];
    }
    
    if (![appDelegate.managedObjectContext save:&error])
    {
        // Handle the error.
        DLog(@"Save Error : %@", error.description);
    }
}

/**-----------------------------------------------------------------
 Function Name  : getContentsWithContentType
 Created By     : Arpit Jain
 Created Date   : 2-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : Get Contents by its type from database and return array of it.
 ------------------------------------------------------------------*/
-(NSMutableArray *)getContentsWithContentType:(NSString *)strContentType andCategoryId:(NSString *)strCategoryId
{
    // Fetch ActicleID from MasterContentCategory table
    
    NSFetchRequest *requestForMaster = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityMaster = [NSEntityDescription entityForName:kEntityMasterContentCategory inManagedObjectContext:appDelegate.managedObjectContext];
    if([strCategoryId isEqualToString:kstrKeyForAllNews])
    {
    }
    else
    {
        [requestForMaster setPredicate:[NSPredicate predicateWithFormat:@"categoryID like %@",strCategoryId]];
    }
    [requestForMaster setEntity:entityMaster];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResultsOFMaster = [[appDelegate.managedObjectContext executeFetchRequest:requestForMaster error:&error] mutableCopy];
    if (mutableFetchResultsOFMaster == nil)
    {
        // Handle the error.
    }
    
    // Prepare array of articleid from the fetched managedobjects
    
    NSMutableArray *arrArticleId = [[NSMutableArray alloc]init];
    
    for(int numIndex = 0; numIndex < [mutableFetchResultsOFMaster count];numIndex++)
    {
        [arrArticleId addObject:[[mutableFetchResultsOFMaster objectAtIndex:numIndex] contentID]];
    }
    
    // Fetch Articles from Contents table of these articleIds
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
    
    if([strCategoryId isEqualToString:kstrKeyForAllNews])
    {
        NSMutableString *strPredicate = [[NSMutableString alloc] initWithFormat:@"contentType like '%@'",strContentType];
        [request setPredicate:[NSPredicate predicateWithFormat:strPredicate]];
    }
    else
    {
        NSMutableString *strPredicate = [[NSMutableString alloc] initWithFormat:@"articleID IN {%@} AND contentType like '%@'",arrArticleId,strContentType];
        [strPredicate replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [strPredicate length])];
        [strPredicate replaceOccurrencesOfString:@")" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [strPredicate length])];
        [request setPredicate:[NSPredicate predicateWithFormat:strPredicate]];
    }
    
    if ([strContentType isEqualToString:@"newsarticle"] && ![strCategoryId isEqualToString:@"001-AllNews"]) {
        [request setFetchLimit:kDefaultBatchCountFirstPage];
    } else {
        [request setFetchLimit:kDefaultBatchCount];
    }
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        // Handle the error.
    }
    
    NSMutableArray *arrOfContent = [[NSMutableArray alloc]init];
    if ([strContentType isEqualToString:kcontentLatest])
    {
        DLog(@"So this is where we add for offline reference ...");
        [[WebserviceComunication sharedCommManager] setDictLeadingNews:[[NSUserDefaults standardUserDefaults] objectForKey:kstrLeadingNews]];
    }
    
    for (int numIndex = 0;numIndex <[mutableFetchResults count];numIndex++)
    {
        [arrOfContent addObject:[mutableFetchResults objectAtIndex:numIndex]];
    }

    NSSortDescriptor *sortDescriptorDate;
    sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:kstrPublishDate ascending:NO];
    NSArray *sortDescriptorsDate = [NSArray arrayWithObject:sortDescriptorDate];
    
    NSMutableArray *sortedArray;
    sortedArray = [NSMutableArray arrayWithArray:[arrOfContent sortedArrayUsingDescriptors:sortDescriptorsDate]];
    
    [requestForMaster release];
    [request release];
    [sortDescriptor release];
    [sortDescriptorDate release];

    return sortedArray;
}

// WAYNE
-(NSMutableArray *)getContentsWithContentType:(NSString *)strContentType andCategoryId:(NSString *)strCategoryId withLimit:(int)limit
{
    // Fetch ActicleID from MasterContentCategory table
    
    NSFetchRequest *requestForMaster = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityMaster = [NSEntityDescription entityForName:kEntityMasterContentCategory inManagedObjectContext:appDelegate.managedObjectContext];
    if([strCategoryId isEqualToString:kstrKeyForAllNews])
    {
    }
    else
    {
        [requestForMaster setPredicate:[NSPredicate predicateWithFormat:@"categoryID like %@",strCategoryId]];
    }
    [requestForMaster setEntity:entityMaster];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResultsOFMaster = [[appDelegate.managedObjectContext executeFetchRequest:requestForMaster error:&error] mutableCopy];
    if (mutableFetchResultsOFMaster == nil)
    {
        // Handle the error.
    }
    
    // Prepare array of articleid from the fetched managedobjects
    
    NSMutableArray *arrArticleId = [[NSMutableArray alloc]init];
    
    for(int numIndex = 0; numIndex < [mutableFetchResultsOFMaster count];numIndex++)
    {
        [arrArticleId addObject:[[mutableFetchResultsOFMaster objectAtIndex:numIndex] contentID]];
    }
    
    // Fetch Articles from Contents table of these articleIds
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];

    if([strCategoryId isEqualToString:kstrKeyForAllNews])
    {
        NSMutableString *strPredicate = [[NSMutableString alloc] initWithFormat:@"contentType = '%@'",strContentType];
        [request setPredicate:[NSPredicate predicateWithFormat:strPredicate]];
    }
    else
    {
        NSMutableString *strPredicate = [[NSMutableString alloc] initWithFormat:@"articleID IN {%@} AND contentType = '%@'",arrArticleId,strContentType];
        [strPredicate replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [strPredicate length])];
        [strPredicate replaceOccurrencesOfString:@")" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [strPredicate length])];
        [request setPredicate:[NSPredicate predicateWithFormat:strPredicate]];
    }
    
    [request setEntity:entity];
    [request setFetchLimit:limit];
    request.returnsObjectsAsFaults = YES;
    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kstrCreatedDate ascending:YES];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    
    NSMutableArray *arrOfContent = [[NSMutableArray alloc]init];
    if ([strContentType isEqualToString:kcontentLatest]) {
        [[WebserviceComunication sharedCommManager] setDictLeadingNews:[[NSUserDefaults standardUserDefaults] objectForKey:kstrLeadingNews]];
    }
    
    // Specify amount to return, as this could slow things down in future when db is larger ... ?
    for (int numIndex = 0;numIndex <[mutableFetchResults count];numIndex++) {
        [arrOfContent addObject:[mutableFetchResults objectAtIndex:numIndex]];
    }
    
    NSSortDescriptor *sortDescriptorDate;
    sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:kstrPublishDate ascending:NO];
    NSArray *sortDescriptorsDate = [NSArray arrayWithObject:sortDescriptorDate];
    
    NSMutableArray *sortedArray;
    sortedArray = [NSMutableArray arrayWithArray:[arrOfContent sortedArrayUsingDescriptors:sortDescriptorsDate]];
    
    return sortedArray;
}

-(NSMutableArray *)getContentsWithInFocusId:(NSString *)strInFocusId withLimit:(int)limit
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
    
    NSMutableString *strPredicate = [[NSMutableString alloc] initWithFormat:@"inFocusId like '%@'", strInFocusId];
    [request setPredicate:[NSPredicate predicateWithFormat:strPredicate]];
    
    [request setEntity:entity];
    [request setFetchLimit:limit];
    request.returnsObjectsAsFaults = YES;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        // Handle the error.
    }
    
    NSMutableArray *arrOfContent = [[NSMutableArray alloc]init];
    
    for (int numIndex = 0;numIndex <[mutableFetchResults count];numIndex++)
    {
        [arrOfContent addObject:[mutableFetchResults objectAtIndex:numIndex]];
    }
    
    // SORT
    NSSortDescriptor *sortDescriptorDate;
    sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:kstrPublishDate ascending:NO];
    NSArray *sortDescriptorsDate = [NSArray arrayWithObject:sortDescriptorDate];
    
    NSMutableArray *sortedArray;
    sortedArray = [NSMutableArray arrayWithArray:[arrOfContent sortedArrayUsingDescriptors:sortDescriptorsDate]];
    
    return sortedArray;
}

-(NSString *)getLastCreationDateWithContentType:(NSString *)strContentType andCategoryId:(NSString *)strCategoryId
{
    // Fetch ActicleID from MasterContentCategory table
    
    NSFetchRequest *requestForMaster = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityMaster = [NSEntityDescription entityForName:kEntityMasterContentCategory inManagedObjectContext:appDelegate.managedObjectContext];
    if([strCategoryId isEqualToString:kstrKeyForAllNews])
    {
    }
    else
    {
        [requestForMaster setPredicate:[NSPredicate predicateWithFormat:@"categoryID like %@",strCategoryId]];
    }
    [requestForMaster setEntity:entityMaster];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResultsOFMaster = [[appDelegate.managedObjectContext executeFetchRequest:requestForMaster error:&error] mutableCopy];
    if (mutableFetchResultsOFMaster == nil)
    {
        // Handle the error.
    }
    
    // Prepare array of articleid from the fetched managedobjects
    
    NSMutableArray *arrArticleId = [[NSMutableArray alloc]init];
    
    for(int numIndex = 0; numIndex < [mutableFetchResultsOFMaster count];numIndex++)
    {
        [arrArticleId addObject:[[mutableFetchResultsOFMaster objectAtIndex:numIndex] contentID]];
    }
    
    // Fetch Articles from Contents table of these articleIds
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
    
    if([strCategoryId isEqualToString:kstrKeyForAllNews])
    {
        NSMutableString *strPredicate = [[NSMutableString alloc] initWithFormat:@"contentType like '%@'",strContentType];
        [request setPredicate:[NSPredicate predicateWithFormat:strPredicate]];
    }
    else
    {
        NSMutableString *strPredicate = [[NSMutableString alloc] initWithFormat:@"articleID IN {%@} AND contentType like '%@'",arrArticleId,strContentType];
        [strPredicate replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [strPredicate length])];
        [strPredicate replaceOccurrencesOfString:@")" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [strPredicate length])];
        [request setPredicate:[NSPredicate predicateWithFormat:strPredicate]];
    }
    
    [request setEntity:entity];
    //[request setFetchLimit:1]; // NEW
    [request setFetchLimit:kDefaultBatchCount+1];
    
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kstrCreatedDate ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        // Handle the error.
    }
    
    // Magic happens here ...
    // Review for memory leaks
    
    NSDateFormatter *tempDateFormat = [[NSDateFormatter alloc] init];
    [tempDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    // e.g. 2013-07-10T15:29:47
    
    NSMutableString *dateString = [[NSMutableString alloc] init];
    
    // No no entries, also provide current date/time for Latest results
    //if([mutableFetchResults count] == 0)
    if([mutableFetchResults count] < kDefaultBatchCount+1)
    {
        [dateString appendString:kStartDate];
    } else {
        // Add one second to avoid duplicates in feed
        [dateString appendString:[[mutableFetchResults objectAtIndex:0] publishDate]];
        
        // This even necessary anymore?
//        if([dateString isEqual:@""])
//        {
//            NSString *tempString = [[mutableFetchResults objectAtIndex:0] publishDate];
//            //NSString *tempString = [[mutableFetchResults objectAtIndex:0] dateCreated];
//            DLog(@"Date Before : %@", tempString);
//            
//            NSDate *tempDate = [tempDateFormat dateFromString:tempString];
//            //NSTimeInterval addInterval = 60;
//            //tempDate = [tempDate dateByAddingTimeInterval:addInterval];
//            
//            [dateString appendString:[tempDateFormat stringFromDate:tempDate]];
//            DLog(@"Date After  : %@", dateString);
//        }
    }
    
    // Clean - If you don't release this You cause shiz later on stuff goes wrong
    
    return dateString;
}

/**-----------------------------------------------------------------
 Function Name  : getContents
 Created By     : Arpit Jain
 Created Date   : 6-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : Get Related Story of parent type from database and return array of it.
 ------------------------------------------------------------------*/

-(NSMutableArray *)getRelatedStoryWithParentId:(NSString *)strParentId andArticleType:(NSString *)strArticleType
{    
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityRelatedStory inManagedObjectContext:appDelegate.managedObjectContext];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parentID like %@",strParentId]];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kstrStoryIndex ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        // Handle the error.
    }
    
    NSMutableArray *arrOfContent = [[NSMutableArray alloc]init];
    
    for (int numIndex = 0;numIndex <[mutableFetchResults count];numIndex++)
    {
        if([[[mutableFetchResults objectAtIndex:numIndex] articleType] isEqualToString:strArticleType])
        {
            if([self hasCacheDataExpiredForStory:[[mutableFetchResults objectAtIndex:numIndex] dateCreated]])
            {
                [self deleteCachedataOfEntity:kEntityRelatedStory articleID:[[mutableFetchResults objectAtIndex:numIndex] articleID]];
            }
            
            [arrOfContent addObject:[mutableFetchResults objectAtIndex:numIndex]];
        }
    }
    
    return arrOfContent;
}

/**-----------------------------------------------------------------
 Function Name  : getContents
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Get all Contents from database and return array of it.
 ------------------------------------------------------------------*/
-(NSMutableArray *)getContents
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kstrContentIndex ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        // Handle the error.
    }
    return mutableFetchResults;
}
/**-----------------------------------------------------------------
 Function Name  : UpdateContentByArticleId
 Created By     : Arpit Jain
 Created Date   : 15-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method update the item of Contents in database.
 ------------------------------------------------------------------*/
-(void)UpdateContentByArticleId:(Contents *)dictContent
{
    NSError *error = nil;
    // Fetch For ArticleID to check the article exist or not.
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    
    NSFetchRequest *requestForContent = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:newContext];
    [requestForContent setEntity:entityContent];
    
    NSPredicate *pdArticle = [NSPredicate predicateWithFormat:@"articleID like %@", [dictContent articleID]];
    
    [requestForContent setPredicate:pdArticle];
    
    NSMutableArray *mutableFetchResultsOFContent = [[newContext executeFetchRequest:requestForContent error:&error] mutableCopy];
    if ([mutableFetchResultsOFContent count] > 0)
    {
        Contents *addContents = (Contents*)[mutableFetchResultsOFContent objectAtIndex:0];
                
        // Store File and save File URL in db
        NSArray *imageArray = [[dictContent thumbnilImageUrl] componentsSeparatedByString:@"/"];
        NSString *imageName = [imageArray objectAtIndex:[imageArray count] - 1];
        [addContents setThumbnilImageFile:[self saveImage:[dictContent thumbnilImageUrlData] imgName:imageName]];
        [dictContent setThumbnilImageFile:[addContents thumbnilImageFile]];
        
        NSError *err;
        
        if (![newContext save:&err])
        {
            DLog(@"Error saving content! %@",err);
        }
    } else {
        // save the image to the array anyway
        // this is specifically for search
        NSArray *imageArray = [[dictContent thumbnilImageUrl] componentsSeparatedByString:@"/"];
        NSString *imageName = [imageArray objectAtIndex:[imageArray count] - 1];
        [dictContent setThumbnilImageFile:[self saveImage:[dictContent thumbnilImageUrlData] imgName:imageName]];
    }
    
}

-(void)UpdatefeaturedImage:(Contents *)dictContent {
    NSError *error = nil;
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    
    NSFetchRequest *requestForContent = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:newContext];
    [requestForContent setEntity:entityContent];
    
    NSPredicate *pdArticle = [NSPredicate predicateWithFormat:@"articleID like %@", [dictContent articleID]];
    
    [requestForContent setPredicate:pdArticle];
    
    NSMutableArray *mutableFetchResultsOFContent = [[newContext executeFetchRequest:requestForContent error:&error] mutableCopy];
    if ([mutableFetchResultsOFContent count] > 0)
    {
        Contents *addContents = (Contents*)[mutableFetchResultsOFContent objectAtIndex:0];
        
        // Store File and save File URL in db
        NSArray *imageArray = [[dictContent featuredImageUrl] componentsSeparatedByString:@"/"];
        NSString *imageName = [imageArray objectAtIndex:[imageArray count] - 1];
        [addContents setFeaturedImageFile:[self saveImage:[dictContent featuredImageUrlData] imgName:imageName]];
        [dictContent setFeaturedImageFile:[addContents featuredImageFile]];
        
        NSError *err;
        
        if (![newContext save:&err]) {
            DLog(@"Error saving content! %@",err);
        }
        
    } else {
        // save the image to the array anyway
        // this is specifically for search
        NSArray *imageArray = [[dictContent featuredImageUrl] componentsSeparatedByString:@"/"];
        NSString *imageName = [imageArray objectAtIndex:[imageArray count] - 1];
        [dictContent setFeaturedImageFile:[self saveImage:[dictContent featuredImageUrlData] imgName:imageName]];
    }

}


/**-----------------------------------------------------------------
 Function Name  : UpdateRelatedStoryAndTimeLineByArticleId
 Created By     : Arpit Jain
 Created Date   : 15-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method update the item of Contents in database.
 ------------------------------------------------------------------*/

-(void)UpdateRelatedStoryAndTimeLineByArticleId:(RelatedStoryAndTimeline *)dictNewArticle withCurrentContentType:(NSString *)strCurrentContentType {
    NSError *error = nil;
    // Fetch For ArticleID to check the article exist or not.
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    
    NSFetchRequest *requestForContent = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityRelatedStory inManagedObjectContext:newContext];
    [requestForContent setEntity:entityContent];
    
    NSPredicate *pdArticle = [NSPredicate predicateWithFormat:@"articleID like %@", [dictNewArticle articleID]];
    
    [requestForContent setPredicate:pdArticle];
    
    NSMutableArray *mutableFetchResultsOFContent = [[newContext executeFetchRequest:requestForContent error:&error] mutableCopy];
    if ([mutableFetchResultsOFContent count] > 0)
    {
        RelatedStoryAndTimeline *addContents = (RelatedStoryAndTimeline*)[mutableFetchResultsOFContent objectAtIndex:0];
        // Store File and save File URL in db
        NSArray *imageArray = [[dictNewArticle thumbnilImageUrl] componentsSeparatedByString:@"/"];
        NSString *imageName = [imageArray objectAtIndex:[imageArray count] - 1];
        [addContents setThumbnilImageFile:[self saveImage:[dictNewArticle thumbnilImageUrlData] imgName:imageName]];
        
        NSError *err;
        
        if (![newContext save:&err])
        {
        }
        else
        {
        }
    }
    
}

/**-----------------------------------------------------------------
 Function Name  : addContentsWithItemArray
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method adds the items of Contents in database.
 ------------------------------------------------------------------*/
-(NSMutableArray *)addContentsWithItemArray:(NSMutableDictionary *)dictItem {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    NSMutableArray *arrItemNew;
    if([[[dictItem objectForKey:kstrContentItems] objectForKey:kstrContentItem] isKindOfClass:[NSArray class]]) {
        arrItemNew = [[NSMutableArray alloc]initWithArray:[[dictItem objectForKey:kstrContentItems] objectForKey:kstrContentItem]];
    } else {
        if([[[dictItem objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0) {
            arrItemNew = [NSMutableArray arrayWithObject:[[dictItem objectForKey:kstrContentItems] objectForKey:kstrContentItem]];
        } else {
            arrItemNew =  [NSMutableArray arrayWithArray:NULL];
        }
    }
    
    /// TEMP !!!!
    if([[dictItem objectForKey:kstrContentItem] isKindOfClass:[NSArray class]]) {
        arrItemNew = [[NSMutableArray alloc]initWithArray:[dictItem objectForKey:kstrContentItem]];
    }
    
    // we need an array of ID's here
    NSArray *ids = [arrItemNew valueForKey:kstrArticleId];
    
    NSError *error = nil;
    NSFetchRequest *requestForContent = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:newContext];
    [requestForContent setEntity:entityContent];
    NSPredicate *pdArticle = [NSPredicate predicateWithFormat:@"articleID IN %@", ids];
    [requestForContent setPredicate:pdArticle];
    NSMutableArray *mutableFetchResultsOFContent = [[newContext executeFetchRequest:requestForContent error:&error] mutableCopy];
    
    Boolean exists = NO;
    
    for(int numIndex = 0; numIndex<[arrItemNew count];numIndex++) {
        
        NSDictionary *dictNewArticle;
        dictNewArticle = [arrItemNew objectAtIndex:numIndex];
        exists = NO;
        Contents *addContents;
        
        for (int x = 0; x < [mutableFetchResultsOFContent count]; x++) {
            if ([[dictNewArticle valueForKey:kstrArticleId] isEqualToString:[(NSString *)[mutableFetchResultsOFContent objectAtIndex:x] valueForKey:@"articleID"]]) {
                exists = YES;
                addContents = (Contents*)[mutableFetchResultsOFContent objectAtIndex:x];
                [mutableFetchResultsOFContent removeObjectAtIndex:x];
                break;
            }
        }
        
        if (!exists) {
            addContents = (Contents *)[NSEntityDescription insertNewObjectForEntityForName:kEntityContents inManagedObjectContext:newContext];
        }
        
        // DO WE REALLY NEED THIS OVER HERE???
        if([[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] isKindOfClass:[NSArray class]]) {
            //add Master
            NSArray *arrNewCategories = [[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory];
            for(int numIndex1 = 0;numIndex1 < [arrNewCategories count];numIndex1++) {
                MasterContentCategory *addMaster = (MasterContentCategory *)[NSEntityDescription insertNewObjectForEntityForName:kEntityMasterContentCategory inManagedObjectContext:newContext];
                [addMaster setCategoryID:[[arrNewCategories objectAtIndex:numIndex1] objectForKey:kstrId]];
                [addMaster setContentID:[dictNewArticle objectForKey:kstrArticleId]];
            }
        } else {
            NSDictionary *dictNewCategories = [[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory];
            //add Master
            MasterContentCategory *addMaster = (MasterContentCategory *)[NSEntityDescription insertNewObjectForEntityForName:kEntityMasterContentCategory inManagedObjectContext:newContext];
            [addMaster setCategoryID:[dictNewCategories objectForKey:kstrId]];
            [addMaster setContentID:[dictNewArticle objectForKey:kstrArticleId]];
        }
        
        [self updateContents:addContents dictNewArticle:dictNewArticle];
        
        if (!exists) {
            [addContents setCreatedDate:[NSDate date]];
        }
        
        if ([dictNewArticle objectForKey:@"AttachedMedia"]) {
            [addContents setAttachedMedia:@"yes"];
            [self insertContentContents:newContext article:dictNewArticle];
        }
        
        [tempArray addObject:addContents];
    }
            
    NSError *err;
    if (![newContext save:&err]){
        DLog(@"CANNOT SAVE THE CONTEXT!!!");
    }
    
    return tempArray;
}

-(void)updateContents:(Contents *)addContents dictNewArticle:(NSDictionary *)dictNewArticle {
    if([[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] != nil) {
        if([[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] isKindOfClass:[NSArray class]]) {
            [addContents setCategory:[[[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] objectAtIndex:0]objectForKey:kstrId]];
            [addContents setCategory:[[[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] objectAtIndex:0]objectForKey:kstrName]];
        } else {
            [addContents setCategory:[[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrId]];
            [addContents setCategory:[[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrName]];
        }
    }
    
    [addContents setContentType:[[dictNewArticle objectForKey:kstrContentType] objectForKey:kstrName]];
    [addContents setBodyText:[dictNewArticle objectForKey:kstrBodyText]];
    [addContents setArticleID:[dictNewArticle objectForKey:kstrArticleId]];
    [addContents setCartoon:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrCartoon] boolValue]]];
    [addContents setDateAdded:[dictNewArticle objectForKey:kstrDateAdded]];
    [addContents setFilename:[dictNewArticle objectForKey:kstrFilename]];
    [addContents setFeaturedImageUrl:[dictNewArticle objectForKey:kstrFeaturedImageUrl]];
    [addContents setFlvOnly:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrFlvOnly] boolValue]]];
    [addContents setImageLargeURL:[dictNewArticle objectForKey:kstrImageLargeURL]];
    [addContents setIntroParagraph:[dictNewArticle objectForKey:kstrIntroParagraph]];
    [addContents setIsBreakingNews:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrIsBreakingNews] boolValue]]];
    [addContents setIsLeadStory:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrIsLeadStory] boolValue]]];
    [addContents setPostRoll:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrPostRoll] boolValue]]];
    [addContents setPublishDate:[dictNewArticle objectForKey:kstrPublishDate]];
    [addContents setContentTitle:[dictNewArticle objectForKey:kstrTitle]];
    [addContents setContentURL:[dictNewArticle objectForKey:kstrURL]];
    [addContents setPreRoll:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrPreRoll] boolValue]]];
    [addContents setThumbnilImageUrl:[dictNewArticle objectForKey:kstrImageThumbnailURL]];
    [addContents setAuthor:[dictNewArticle objectForKey:kstrAuthor]];
    [addContents setCaptionShort:[dictNewArticle objectForKey:kstrCaptionShort]];
    [addContents setCaption:[dictNewArticle objectForKey:kstrCaption]];
    [addContents setHashtag:[dictNewArticle objectForKey:kstrHashtag]];
    [addContents setAttachedMedia:@""];
}

-(void)insertUpdateContents:(NSManagedObjectContext *)newContext attachedArticle:(NSDictionary *)attachedArticle {
    NSError *error = nil;
    NSFetchRequest *requestForContent = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:newContext];
    [requestForContent setEntity:entityContent];
    NSPredicate *pdArticle = [NSPredicate predicateWithFormat:@"articleID = %@",[attachedArticle objectForKey:kstrArticleId]];
    [requestForContent setPredicate:pdArticle];
    NSMutableArray *mutableFetchResultsOFContent = [[newContext executeFetchRequest:requestForContent error:&error] mutableCopy];
    
    bool exists = NO;
    Contents *addContents;
    
    if ([mutableFetchResultsOFContent count] > 0) {
        exists = YES;
        addContents = (Contents*)[mutableFetchResultsOFContent objectAtIndex:0];
    }
    
    if (!exists) {
        addContents = (Contents *)[NSEntityDescription insertNewObjectForEntityForName:kEntityContents inManagedObjectContext:newContext];
    }
    
    [self updateContents:addContents dictNewArticle:attachedArticle];
    
    if (!exists) {
        [addContents setCreatedDate:[NSDate date]];
    }
}

-(void)insertContentContents:(NSManagedObjectContext *)newContext article:(NSDictionary *)dictNewArticle {
    NSMutableArray *attachedMediaArticles;
    if ([[[dictNewArticle objectForKey:@"AttachedMedia"] objectForKey:@"ContentItem"] isKindOfClass:[NSArray class]]) {
        attachedMediaArticles = [[dictNewArticle objectForKey:@"AttachedMedia"] objectForKey:@"ContentItem"];
    } else {
        attachedMediaArticles = [[NSMutableArray alloc] init];
        [attachedMediaArticles insertObject:[[dictNewArticle objectForKey:@"AttachedMedia"] objectForKey:@"ContentItem"] atIndex:0];
    }
    
    // DELETE from ContentContents WHERE parentArticleId = [dictNewArticle objectForKey:kstrArticleId]
    NSError *error = nil;
    NSFetchRequest *requestForContentContents = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityContentContents = [NSEntityDescription entityForName:kEntityContentContents inManagedObjectContext:newContext];
    [requestForContentContents setEntity:entityContentContents];
    NSPredicate *pdContentContents = [NSPredicate predicateWithFormat:@"parentArticleId = %@", [dictNewArticle objectForKey:kstrArticleId]];
    [requestForContentContents setPredicate:pdContentContents];
    NSMutableArray *mutableFetchResultsOfContentContents = [[newContext executeFetchRequest:requestForContentContents error:&error] mutableCopy];
    
    for (int i = 0; i < [mutableFetchResultsOfContentContents count]; i++) {
        ContentContents *delContentContents = (ContentContents*)[mutableFetchResultsOfContentContents objectAtIndex:i];
        [newContext deleteObject:delContentContents];
    }
    
    for (int i = 0; i < [attachedMediaArticles count]; i++) {
        NSDictionary *attachedArticle = [attachedMediaArticles objectAtIndex:i];
        
        [self insertUpdateContents:newContext attachedArticle:attachedArticle];
        
        ContentContents *contentContents = (ContentContents *)[NSEntityDescription insertNewObjectForEntityForName:kEntityContentContents inManagedObjectContext:newContext];
        [contentContents setParentArticleId:[dictNewArticle objectForKey:kstrArticleId]];
        [contentContents setChildArticleId:[[attachedMediaArticles objectAtIndex:i] objectForKey:kstrArticleId]];
    }
}

/**-----------------------------------------------------------------
 Function Name  : addContentsWithItemArray
 Created By     : Armpit Jane
 Created Date   : 09-Dec-2013
 Modified By    :
 Modified Date  :
 Purpose        : This method adds InFocus Content to the DB according to Category Id
 ------------------------------------------------------------------*/
-(NSMutableArray *)addContentsWithItemArray:(NSMutableDictionary *)dictItem andInFocusId:(NSString *)strInFocusId
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    
    NSMutableArray *arrItemNew;
    if([[dictItem objectForKey:kstrContentItem] isKindOfClass:[NSArray class]])
    {
        arrItemNew = [[NSMutableArray alloc] initWithArray:[dictItem objectForKey:kstrContentItem]];
    }
    else
    {
        arrItemNew =  [NSMutableArray arrayWithArray:NULL];
    }
    
    for(int numIndex = 0; numIndex<[arrItemNew count];numIndex++)
    {
        NSDictionary *dictNewArticle;
        dictNewArticle = [arrItemNew objectAtIndex:numIndex];
        
        NSError *error = nil;
        NSFetchRequest *requestForContent = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:newContext];
        [requestForContent setEntity:entityContent];
        
        NSPredicate *pdArticle = [NSPredicate predicateWithFormat:@"articleID like %@", [dictNewArticle objectForKey:kstrArticleId]];
        
        [requestForContent setPredicate:pdArticle];
        
        NSMutableArray *mutableFetchResultsOFContent = [[newContext executeFetchRequest:requestForContent error:&error] mutableCopy];
        
        Contents *addContents;
        bool exists = false;
        
        if ([mutableFetchResultsOFContent count] == 0)
        {
            addContents = (Contents *)[NSEntityDescription insertNewObjectForEntityForName:kEntityContents inManagedObjectContext:newContext];
        }
        else
        {
            addContents = (Contents*)[mutableFetchResultsOFContent objectAtIndex:0];
            exists = true;
        }
        
        if([[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] isKindOfClass:[NSArray class]])
        {
            //add Master
            NSArray *arrNewCategories = [[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory];
            
            for(int numIndex1 = 0;numIndex1 < [arrNewCategories count];numIndex1++)
            {
                MasterContentCategory *addMaster = (MasterContentCategory *)[NSEntityDescription insertNewObjectForEntityForName:kEntityMasterContentCategory inManagedObjectContext:newContext];
                
                [addMaster setCategoryID:[[arrNewCategories objectAtIndex:numIndex1] objectForKey:kstrId]];
                [addMaster setContentID:[dictNewArticle objectForKey:kstrArticleId]];
            }
        }
        else
        {
            NSDictionary *dictNewCategories = [[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory];
            
            //add Master
            MasterContentCategory *addMaster = (MasterContentCategory *)[NSEntityDescription insertNewObjectForEntityForName:kEntityMasterContentCategory inManagedObjectContext:newContext];
            
            [addMaster setCategoryID:[dictNewCategories objectForKey:kstrId]];
            [addMaster setContentID:[dictNewArticle objectForKey:kstrArticleId]];
        }
        
//        if([[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] != nil)
//        {
//            if([[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] isKindOfClass:[NSArray class]])
//            {
//                [addContents setCategory:[[[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] objectAtIndex:0]objectForKey:kstrId]];
//                [addContents setCategory:[[[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] objectAtIndex:0]objectForKey:kstrName]];
//            }
//            else
//            {
//                [addContents setCategory:[[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrId]];
//                [addContents setCategory:[[[dictNewArticle objectForKey:kstrCategories] objectForKey:kstrCategory] objectForKey:kstrName]];
//            }
//        }
        
        [addContents setInFocusId:strInFocusId];
        [self updateContents:addContents dictNewArticle:dictNewArticle];
        if (!exists) {
            [addContents setCreatedDate:[NSDate date]];
        }
        
//        [addContents setContentType:[[dictNewArticle objectForKey:kstrContentType] objectForKey:kstrName]];
//        [addContents setBodyText:[dictNewArticle objectForKey:kstrBodyText]];
//        [addContents setArticleID:[dictNewArticle objectForKey:kstrArticleId]];
//        [addContents setCartoon:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrCartoon] boolValue]]];
//        [addContents setDateAdded:[dictNewArticle objectForKey:kstrDateAdded]];
//        [addContents setFilename:[dictNewArticle objectForKey:kstrFilename]];
//        [addContents setFeaturedImageUrl:[dictNewArticle objectForKey:kstrFeaturedImageUrl]];
//        [addContents setFlvOnly:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrFlvOnly] boolValue]]];
//        [addContents setImageLargeURL:[dictNewArticle objectForKey:kstrImageLargeURL]];
//        [addContents setIntroParagraph:[dictNewArticle objectForKey:kstrIntroParagraph]];
//        [addContents setIsBreakingNews:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrIsBreakingNews] boolValue]]];
//        [addContents setIsLeadStory:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrIsLeadStory] boolValue]]];
//        [addContents setPostRoll:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrPostRoll] boolValue]]];
//        [addContents setPublishDate:[dictNewArticle objectForKey:kstrPublishDate]];
//        [addContents setContentTitle:[dictNewArticle objectForKey:kstrTitle]];
//        [addContents setContentURL:[dictNewArticle objectForKey:kstrURL]];
//        [addContents setPreRoll:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrPreRoll] boolValue]]];
//        [addContents setThumbnilImageUrl:[dictNewArticle objectForKey:kstrImageThumbnailURL]];
//        [addContents setAuthor:[dictNewArticle  objectForKey:kstrAuthor]];
//        [addContents setCaptionShort:[dictNewArticle  objectForKey:kstrCaptionShort]];
//        [addContents setCaption:[dictNewArticle  objectForKey:kstrCaption]];
//        [addContents setHashtag:[dictNewArticle  objectForKey:kstrHashtag]];
//        [addContents setCreatedDate:[NSDate date]];
        
        [tempArray addObject:addContents];
    }
    
    NSError *err;
    if (![newContext save:&err])
    {
    }
    else
    {
    }
    
    return tempArray;
}

/**-----------------------------------------------------------------
 Function Name  : addControllerContextDidSave
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method merges two contexts.
 ------------------------------------------------------------------*/

- (void)addControllerContextDidSave:(NSNotification*)saveNotification
{
    [appDelegate.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
}
/**-----------------------------------------------------------------
 Function Name  : addRelatedStoryWithItemArray
 Created By     : Arpit Jain
 Created Date   : 6-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method adds the items of Contents in database.
 ------------------------------------------------------------------*/
-(NSMutableArray *)addRelatedStoryWithItemArray:(NSMutableDictionary *)dictItem andParentID:(NSString *)strParentID andArticleType:(NSString *)strArticleType {
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];

    NSMutableArray *arrItemNew;
    if([[[dictItem objectForKey:kstrContentItems] objectForKey:kstrContentItem] isKindOfClass:[NSArray class]]) {
        arrItemNew = [[NSMutableArray alloc] initWithArray:[[dictItem objectForKey:kstrContentItems] objectForKey:kstrContentItem]];
    } else {
        if([[[dictItem objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0) {
            arrItemNew = [NSMutableArray arrayWithObject:[[dictItem objectForKey:kstrContentItems] objectForKey:kstrContentItem]];
        } else {
            arrItemNew = [NSMutableArray arrayWithArray:NULL];
        }
    }
    
    // get the id's of the related articles
    NSArray *ids = [arrItemNew valueForKey:kstrArticleId];
    
    // query the database to get a list of them back
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    NSFetchRequest *requestForRelateStory = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityRelateStory = [NSEntityDescription entityForName:kEntityRelatedStory inManagedObjectContext:newContext];
    NSPredicate *pdArticle = [NSPredicate predicateWithFormat:@"articleID IN %@", ids];
    [requestForRelateStory setEntity:entityRelateStory];
    [requestForRelateStory setPredicate:pdArticle];
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[newContext executeFetchRequest:requestForRelateStory error:&error] mutableCopy];
    
    for (int numIndex = 0; numIndex<[arrItemNew count];numIndex++) {
        NSDictionary *dictNewArticle;
        dictNewArticle = [arrItemNew objectAtIndex:numIndex];
        BOOL isExists = FALSE;
        RelatedStoryAndTimeline *addContents = (RelatedStoryAndTimeline *)[NSEntityDescription insertNewObjectForEntityForName:kEntityRelatedStory inManagedObjectContext:newContext];
        
        // check if the article exists in the database
        for (int x = 0;x < [mutableFetchResults count]; x++) {
            if([[[mutableFetchResults objectAtIndex:x] articleID] isEqualToString:[dictNewArticle objectForKey:kstrArticleId]]) {
                addContents = [mutableFetchResults objectAtIndex:x];
                [mutableFetchResults removeObjectAtIndex:x];
                isExists = TRUE;
                break;
            }
        }
        
        if (!isExists) {
            addContents = (RelatedStoryAndTimeline *)[NSEntityDescription insertNewObjectForEntityForName:kEntityRelatedStory inManagedObjectContext:newContext];
        }
        
        [addContents setContentType:[[dictNewArticle objectForKey:kstrContentType] objectForKey:kstrName]];
        [addContents setStoryIndex:[NSNumber numberWithInt:numRelatedStoryIndex]];
        [addContents setBodyText:[dictNewArticle  objectForKey:kstrBodyText]];
        [addContents setArticleID:[dictNewArticle  objectForKey:kstrArticleId]];
        [addContents setCartoon:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrCartoon] boolValue]]];
        [addContents setDateAdded:[dictNewArticle objectForKey:kstrDateAdded]];
        [addContents setFilename:[dictNewArticle objectForKey:kstrFilename]];
        [addContents setFeaturedImageUrl:[dictNewArticle objectForKey:kstrFeaturedImageUrl]];
        [addContents setFlvOnly:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrFlvOnly] boolValue]]];
        [addContents setImageLargeURL:[dictNewArticle objectForKey:kstrImageLargeURL]];
        [addContents setIntroParagraph:[dictNewArticle objectForKey:kstrIntroParagraph]];
        [addContents setIsBreakingNews:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrIsBreakingNews] boolValue]]];
        [addContents setIsLeadStory:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrIsLeadStory] boolValue]]];
        [addContents setPostRoll:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrPostRoll] boolValue]]];
        [addContents setPublishDate:[dictNewArticle objectForKey:kstrPublishDate]];
        [addContents setContentTitle:[dictNewArticle objectForKey:kstrTitle]];
        [addContents setRelatedStoryURL:[dictNewArticle objectForKey:kstrURL]];
        [addContents setPreRoll:[NSNumber numberWithBool:[[dictNewArticle objectForKey:kstrPreRoll] boolValue]]];
        [addContents setThumbnilImageUrl:[dictNewArticle objectForKey:kstrImageThumbnailURL]];
        [addContents setAuthor:[dictNewArticle  objectForKey:kstrAuthor]];
        [addContents setHashtag:[dictNewArticle  objectForKey:kstrHashtag]];
        [addContents setPeopleAlsoRead:[dictNewArticle  objectForKey:kstrPeopleAlsoRead]];
        [addContents setCaption:[dictNewArticle  objectForKey:kstrCaption]];
        [addContents setCaptionShort:[dictNewArticle  objectForKey:kstrCaptionShort]];
        [addContents setAttachedMedia:@""];
        [addContents setParentID:strParentID];
        [addContents setArticleType:strArticleType];
        [addContents setDateCreated:[NSDate date]];
        
        numRelatedStoryIndex++;
        
        [tempArray addObject:addContents];
    }
    
    NSError *err;

    if ([newContext save:&err]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kDateForDeleteStoryCache];
    } else {
        DLog(@"ERROR SAVING RELATED TO THE DATABASE");
    }
    
    // Sort for return
    NSSortDescriptor *sortDescriptorDate;
    sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:kstrPublishDate ascending:NO];
    NSArray *sortDescriptorsDate = [NSArray arrayWithObject:sortDescriptorDate];
    NSMutableArray *sortedArray;
    sortedArray = [NSMutableArray arrayWithArray:[tempArray sortedArrayUsingDescriptors:sortDescriptorsDate]];
    return sortedArray;
}
/**-----------------------------------------------------------------
 Function Name  : deleteCachedataOfMasterEntity
 Created By     : Arpit Jain
 Created Date   : 6-May-2013
 Modified By    :
 Modified Date  :
 Purpose        : this method deletes the items of Contents in Master table.
 ------------------------------------------------------------------*/
-(void)deleteCachedataOfMasterEntity
{
    DLog(@"deleting the master db table");
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityMasterContentCategory inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i = 0; i<[mutableFetchResults count]; i++)
    {
        [arr addObject:(MasterContentCategory *)[mutableFetchResults objectAtIndex:i]];
    }
 
    for (NSManagedObject *product in arr)
    {
        [appDelegate.managedObjectContext deleteObject:product];
    }
    DLog(@"Save 4");
    if (![appDelegate.managedObjectContext save:&error])
    {
        // Handle the error.
    }
}

// Adds or Updates the LeadingNews
-(LeadingNews *)addLeadingNews:(NSMutableDictionary *)dictLeadingNews
{
    NSError *error = nil;

    // Create new Context
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    
    // Check if any LeadingNews exists, add/update
    // Currently only ever storing 1 LeadingNews item
    NSFetchRequest *requestForContent = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityLeadingNews inManagedObjectContext:newContext];
    [requestForContent setEntity:entityContent];
    
    NSMutableArray *mutableFetchResults = [[newContext executeFetchRequest:requestForContent error:&error] mutableCopy];
    
    //DLog(@"Leading News Count : %d", [mutableFetchResults count]);
    
    LeadingNews *leadingContents;
    
    if ([mutableFetchResults count] > 0)
    {
        if([[[mutableFetchResults objectAtIndex:0] articleID] isEqualToString:[dictLeadingNews objectForKey:kstrArticleId]])
        {
            leadingContents = [mutableFetchResults objectAtIndex:0];
        }
        else
        {
            //DLog(@"Leading exists, deleting");
            
            for (NSManagedObject *item in mutableFetchResults)
            {
                // If same article, update, don't delete. This retains the image data
                [newContext deleteObject:item];
            }
            
            leadingContents = (LeadingNews *)[NSEntityDescription insertNewObjectForEntityForName:kEntityLeadingNews inManagedObjectContext:newContext];
        }
    }
    else
    {
        //DLog(@"Leading Empty Adding");
        leadingContents = (LeadingNews *)[NSEntityDescription insertNewObjectForEntityForName:kEntityLeadingNews inManagedObjectContext:newContext];
    }
    
    [leadingContents setContentType:[[dictLeadingNews objectForKey:kstrContentType] objectForKey:kstrName]];
    [leadingContents setBodyText:[dictLeadingNews objectForKey:kstrBodyText]];
    [leadingContents setArticleID:[dictLeadingNews objectForKey:kstrArticleId]];
    [leadingContents setCartoon:[NSNumber numberWithBool:[[dictLeadingNews objectForKey:kstrCartoon] boolValue]]];
    [leadingContents setDateAdded:[dictLeadingNews objectForKey:kstrDateAdded]];
    [leadingContents setFilename:[dictLeadingNews objectForKey:kstrFilename]];
    [leadingContents setFeaturedImageUrl:[dictLeadingNews objectForKey:kstrFeaturedImageUrl]];
    [leadingContents setFlvOnly:[NSNumber numberWithBool:[[dictLeadingNews objectForKey:kstrFlvOnly] boolValue]]];
    [leadingContents setImageLargeURL:[dictLeadingNews objectForKey:kstrImageLargeURL]];
    [leadingContents setIntroParagraph:[dictLeadingNews objectForKey:kstrIntroParagraph]];
    [leadingContents setIsBreakingNews:[NSNumber numberWithBool:[[dictLeadingNews objectForKey:kstrIsBreakingNews] boolValue]]];
    [leadingContents setIsLeadStory:[NSNumber numberWithBool:[[dictLeadingNews objectForKey:kstrIsLeadStory] boolValue]]];
    [leadingContents setPostRoll:[NSNumber numberWithBool:[[dictLeadingNews objectForKey:kstrPostRoll] boolValue]]];
    [leadingContents setPublishDate:[dictLeadingNews objectForKey:kstrPublishDate]];
    [leadingContents setContentTitle:[dictLeadingNews objectForKey:kstrTitle]];
    [leadingContents setContentURL:[dictLeadingNews objectForKey:kstrURL]];
    [leadingContents setPreRoll:[NSNumber numberWithBool:[[dictLeadingNews objectForKey:kstrPreRoll] boolValue]]];
    [leadingContents setThumbnilImageUrl:[dictLeadingNews objectForKey:kstrImageThumbnailURL]];
    [leadingContents setAuthor:[dictLeadingNews  objectForKey:kstrAuthor]];
    [leadingContents setCaptionShort:[dictLeadingNews  objectForKey:kstrCaptionShort]];
    [leadingContents setCaption:[dictLeadingNews  objectForKey:kstrCaption]];
    [leadingContents setHashtag:[dictLeadingNews  objectForKey:kstrHashtag]];
    [leadingContents setAttachedMedia:@""];
    [leadingContents setCreatedDate:[NSDate date]];

    NSError *err;
    if (![newContext save:&err])
    {
//        DLog(@"LEADING Save Error");
    }
    else
    {
//        DLog(@"LEADING Saved");
    }
    
    return leadingContents;
}

// Added Entity to name because it was conflicting with method in WebserviceCommunication for some reason ...
-(LeadingNews *)getLeadingNewsEntity {
    NSError *error = nil;
    
    // Create new Context
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    
    // Currently only ever retrieving 1 LeadingNews item
    NSFetchRequest *requestForContent = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityLeadingNews inManagedObjectContext:newContext];
    [requestForContent setEntity:entityContent];
    
    NSMutableArray *mutableFetchResults = [[[newContext executeFetchRequest:requestForContent error:&error] mutableCopy] autorelease];
        
    if([mutableFetchResults count] > 0) {
        return [mutableFetchResults objectAtIndex:0];
    } else {
        return nil;
    }
}

-(void)updateLeadingNews:(Contents *)dictContent
{
    NSError *error = nil;

    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
    [newContext setPersistentStoreCoordinator:[appDelegate.managedObjectContext persistentStoreCoordinator]];
    
    NSFetchRequest *requestForContent = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityContent = [NSEntityDescription entityForName:kEntityLeadingNews inManagedObjectContext:newContext];
    [requestForContent setEntity:entityContent];
            
    NSMutableArray *mutableFetchResults = [[newContext executeFetchRequest:requestForContent error:&error] mutableCopy];
    if ([mutableFetchResults count] > 0)
    {
        LeadingNews *addContents = (LeadingNews*)[mutableFetchResults objectAtIndex:0];        
        // Store File and save File URL in db
        NSArray *imageArray = [[dictContent thumbnilImageUrl] componentsSeparatedByString:@"/"];
        NSString *imageName = [imageArray objectAtIndex:[imageArray count] - 1];
        [addContents setThumbnilImageFile:[self saveImage:[dictContent thumbnilImageUrlData] imgName:imageName]];
        [dictContent setThumbnilImageFile:[addContents thumbnilImageFile]];
    }
    
    NSError *err;
    
    if (![newContext save:&err])
    {
    }
    else
    {
    }
}

-(NSMutableArray *)convertContents:(NSMutableDictionary *)dictContent
{
    DLog(@"Converting Dictionary to Contents");
    
    // First convert the dictionary (dictContent) to array
    NSMutableArray *dictArray = [[NSMutableArray alloc] init];
    
    if([[[dictContent objectForKey:kstrContentItems] objectForKey:kstrContentItem] isKindOfClass:[NSArray class]])
    {
        dictArray = [[NSMutableArray alloc]initWithArray:[[dictContent objectForKey:kstrContentItems] objectForKey:kstrContentItem]];
    }
    else
    {
        if([[[dictContent objectForKey:kstrContentItems] objectForKey:kstrContentItem] count] > 0)
        {
            dictArray = [NSMutableArray arrayWithObject:[[dictContent objectForKey:kstrContentItems] objectForKey:kstrContentItem]];
        }
        else
        {
            dictArray =  [NSMutableArray arrayWithArray:NULL];
        }
    }
    
    // Create emtpy
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityContents inManagedObjectContext:appDelegate.managedObjectContext];
    
    for(int i = 0; i < [dictArray count]; i++)
    {
        NSDictionary *article;
        article = [dictArray objectAtIndex:i];
        
        Contents *content = (Contents *)[[Contents alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
        
        [content setContentType:[[article objectForKey:kstrContentType] objectForKey:kstrName]];
        [content setBodyText:[article objectForKey:kstrBodyText]];
        [content setArticleID:[article objectForKey:kstrArticleId]];
        [content setCartoon:[NSNumber numberWithBool:[[article objectForKey:kstrCartoon] boolValue]]];
        [content setDateAdded:[article objectForKey:kstrDateAdded]];
        [content setFilename:[article objectForKey:kstrFilename]];
        [content setFeaturedImageUrl:[article objectForKey:kstrFeaturedImageUrl]];
        [content setFlvOnly:[NSNumber numberWithBool:[[article objectForKey:kstrFlvOnly] boolValue]]];
        [content setImageLargeURL:[article objectForKey:kstrImageLargeURL]];
        [content setIntroParagraph:[article objectForKey:kstrIntroParagraph]];
        [content setIsBreakingNews:[NSNumber numberWithBool:[[article objectForKey:kstrIsBreakingNews] boolValue]]];
        [content setIsLeadStory:[NSNumber numberWithBool:[[article objectForKey:kstrIsLeadStory] boolValue]]];
        [content setPostRoll:[NSNumber numberWithBool:[[article objectForKey:kstrPostRoll] boolValue]]];
        [content setPublishDate:[article objectForKey:kstrPublishDate]];
        [content setContentTitle:[article objectForKey:kstrTitle]];
        [content setContentURL:[article objectForKey:kstrURL]];
        [content setPreRoll:[NSNumber numberWithBool:[[article objectForKey:kstrPreRoll] boolValue]]];
        [content setThumbnilImageUrl:[article objectForKey:kstrImageThumbnailURL]];
        //[content setThumbnilImageUrlData:[article objectForKey:kstrImageThumbnailURLData]];
        //[content setFeaturedImageUrlData:[article objectForKey:kstrFeaturedImageUrlData]];
        [content setAuthor:[article  objectForKey:kstrAuthor]];
        [content setCaptionShort:[article  objectForKey:kstrCaptionShort]];
        [content setCaption:[article  objectForKey:kstrCaption]];
        [content setHashtag:[article  objectForKey:kstrHashtag]];
        //[content setPeopleAlsoRead:[article  objectForKey:kstrPeopleAlsoRead]];
        [content setCreatedDate:[NSDate date]];
        
        [returnArray addObject:content];
    }
    
    return returnArray;
}

-(NSString *)saveImage:(NSData *)imgData imgName:(NSString *)imgName
{
    NSString *imagePath = [self getImageFolder];
    NSString *fullPath = [imagePath stringByAppendingPathComponent:imgName]; // add our image to the path
    [imgData writeToFile:fullPath atomically:YES];
    
    return fullPath;
}

-(NSString *)getImageFolder
{
    // Create IMAGES Folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:kImageFolder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        NSError *error;
        if([[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error])
        {
            DLog(@"Folder Created : %@", dataPath);
        }
        else
        {
            DLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
    
    return dataPath;
}

@end
