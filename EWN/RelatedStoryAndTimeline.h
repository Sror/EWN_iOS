//
//  RelatedStoryAndTimeline.h
//  EWN
//
//  Created by Arpit Jain on 5/6/13.
//
//
/**------------------------------------------------------------------------
 File Name      : RelatedStoryAndTimeline.h
 Created By     : Arpit Jain
 Created Date   :
 Purpose        : The DataBase Entity file of Related And Timeline view.
 -------------------------------------------------------------------------*/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RelatedStoryAndTimeline : NSManagedObject

// This is going to replace things below
@property (nonatomic, strong) NSString * contentTitle; // relatedStoryTitle
@property (nonatomic, strong) NSString * thumbnilImageUrl; // imageThumbnailURL
@property (nonatomic, strong) NSString * thumbnilImageFile;
@property (nonatomic, strong) NSData * thumbnilImageUrlData; // imageThumbnailURLData
@property (nonatomic, strong) NSString * featuredImageFile;
@property (nonatomic, strong) NSData * featuredImageUrlData; // Doesn't exist!

@property (nonatomic, strong) NSNumber * isBreakingNews;
@property (nonatomic, strong) NSNumber * isLeadStory;
@property (nonatomic, strong) NSString * bodyText;
@property (nonatomic, strong) NSString * relatedStoryTitle;
@property (nonatomic, strong) NSString * articleID;
@property (nonatomic, strong) NSString * relatedStoryURL;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * publishDate;
@property (nonatomic, strong) NSString * featuredImageUrl;
@property (nonatomic, strong) NSString * introParagraph;
@property (nonatomic, strong) NSString * category;
@property (nonatomic, strong) NSString * categoryName;
@property (nonatomic, strong) NSString * hashtag;
@property (nonatomic, strong) NSString * peopleAlsoRead;
//@property (nonatomic, retain) NSString * imageThumbnailURL;
//@property (nonatomic, retain) NSData * imageThumbnailURLData;
@property (nonatomic, strong) NSString * imageLargeURL;
@property (nonatomic, strong) NSString * contentType;
@property (nonatomic, strong) NSString * dateAdded;
@property (nonatomic, strong) NSString * filename;
@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) NSString * captionShort;
@property (nonatomic, strong) NSNumber * preRoll;
@property (nonatomic, strong) NSNumber * postRoll;
@property (nonatomic, strong) NSNumber * cartoon;
@property (nonatomic, strong) NSNumber * flvOnly;
@property (nonatomic, strong) NSString * attachedMedia;
@property (nonatomic, strong) NSString * parentID;
@property (nonatomic, strong) NSNumber * storyIndex;
@property (nonatomic, strong) NSString * articleType;
@property (nonatomic, strong) NSDate * dateCreated;

@end
