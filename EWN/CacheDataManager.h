//
//  CacheDataManager.h
//  EWN
//
//  Created by Arpit Jain on 4/29/13.
//
//
/**------------------------------------------------------------------------
 File Name      : CacheDataManager.h
 Created By     : Arpit Jain
 Created Date   : 29-Apr-2013
 Purpose        : Managed all database operation.
 -------------------------------------------------------------------------*/

#import <Foundation/Foundation.h>
#import "Category_Items.h"
#import "InFocus_Items.h"
#import "Contents.h"
#import "ContentContents.h"
#import "LeadingNews.h"
#import "MasterContentCategory.h"
#import "RelatedStoryAndTimeline.h"

@interface CacheDataManager : NSObject
{
    int numCategoryIndex;
    int numContentIndex;
    BOOL isExpireCategory;
    int numRelatedStoryIndex;
}
@property (nonatomic,readwrite) BOOL isExpireCategory;

- (id)init;
+ (id)sharedCacheManager;

- (BOOL)isMigrationNecessary;

-(NSMutableArray *)getCatogery;
-(NSMutableArray *)getInFocusArray;
-(void)addCategoriesWithItemArray:(NSMutableArray *)arrItem;
-(void)addInFocusWithItemArray:(NSMutableArray *)array;
-(void)deleteCachedataOfEntity:(NSString *)strEntityName contentType:(NSString *)strContentType;
-(void)deleteCachedataOfEntity:(NSString *)strEntityName;
-(void)deleteCachedataOfMasterEntity;

-(NSMutableArray *)getContents;
-(NSMutableArray *)getContentsForArticleId:(NSString *)parentArticleId;
-(NSMutableArray *)getContentsWithContentType:(NSString *)strContentType andCategoryId:(NSString *)strCategoryId;
-(NSMutableArray *)getContentsWithContentType:(NSString *)strContentType andCategoryId:(NSString *)strCategoryId withLimit:(int)limit;
-(NSMutableArray *)getContentsWithInFocusId:(NSString *)strCategoryId withLimit:(int)limit;
-(NSString *)getLastCreationDateWithContentType:(NSString *)strContentType andCategoryId:(NSString *)strCategoryId;
-(NSMutableArray *)getRelatedStoryWithParentId:(NSString *)strParentId andArticleType:(NSString *)strArticleID;

-(void)insertContentContents:(NSManagedObjectContext *)newContext article:(NSDictionary *)dictNewArticle;
-(void)insertUpdateContents:(NSManagedObjectContext *)newContext attachedArticle:(NSDictionary *)attachedArticle;
-(void)updateContents:(Contents *)addContents dictNewArticle:(NSDictionary *)dictNewArticle;

-(NSMutableArray *)addContentsWithItemArray:(NSMutableDictionary *)dictItem;
-(NSMutableArray *)addContentsWithItemArray:(NSMutableDictionary *)dictItem andInFocusId:(NSString *)strInFocusId;
-(NSMutableArray *)addRelatedStoryWithItemArray:(NSMutableDictionary *)dictItem andParentID:(NSString *)strParentID andArticleType:(NSString *)strArticleID;

-(BOOL)hasCacheDataExpiredForContent:(NSString *)contentType;
-(BOOL)hasCacheDataExpiredForStory:(NSDate *)dateArticleType;
-(void)UpdateContentByArticleId:(Contents *)dictContent;
-(void)UpdateRelatedStoryAndTimeLineByArticleId:(RelatedStoryAndTimeline *)dictNewArticle withCurrentContentType:(NSString *)strCurrentContentType;

// New
-(LeadingNews *)addLeadingNews:(NSMutableDictionary *)dictLeadingNews;
-(LeadingNews *)getLeadingNewsEntity;
-(void)updateLeadingNews:(Contents *)dictContent;

// Conversion
-(NSMutableArray *)convertContents:(NSMutableDictionary *)dictContent;

// Image Folder
-(NSString *)saveImage:(NSData *)imgData imgName:(NSString *)imgName;
-(NSString *)getImageFolder;

-(void)UpdatefeaturedImage:(Contents *)dictContent;

@end
