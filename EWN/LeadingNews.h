//
//  LeadingNews.h
//  EWN
//
//  Created by Wayne Langman on 2013/09/08.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LeadingNews : NSManagedObject

@property (nonatomic, strong) NSString * category;
@property (nonatomic, strong) NSString * categoryName;
@property (nonatomic, strong) NSString * contentType;
@property (nonatomic, strong) NSString * bodyText;
@property (nonatomic, strong) NSString * thumbnilImageUrl;
@property (nonatomic, strong) NSString * thumbnilImageFile;
@property (nonatomic, strong) NSData * thumbnilImageUrlData;
@property (nonatomic, strong) NSNumber * contentIndex;
@property (nonatomic, retain) NSString * articleID;
@property (nonatomic, strong) NSNumber *cartoon;
@property (nonatomic, strong) NSString * dateAdded;
@property (nonatomic, strong) NSString * filename;
@property (nonatomic, strong) NSString * featuredImageUrl;
@property (nonatomic, strong) NSString * featuredImageFile;
@property (nonatomic, strong) NSData * featuredImageUrlData;
@property (nonatomic, strong) NSNumber * flvOnly;
@property (nonatomic, strong) NSString * imageLargeURL;
@property (nonatomic, strong) NSString * introParagraph;
@property (nonatomic, strong) NSNumber * isBreakingNews;
@property (nonatomic, strong) NSNumber * isLeadStory;
@property (nonatomic, strong) NSNumber * postRoll;
@property (nonatomic, strong) NSString * publishDate;
@property (nonatomic, strong) NSString *contentTitle;
@property (nonatomic, strong) NSString *contentURL;
@property (nonatomic, strong) NSNumber * preRoll;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *captionShort;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *hashtag;
@property (nonatomic, strong) NSString *peopleAlsoRead;
@property (nonatomic, strong) NSString *attachedMedia;
@property (nonatomic, strong) NSDate *createdDate;

@end
