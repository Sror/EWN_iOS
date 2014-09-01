//
//  Comments.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/24.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CommentReplies;

@interface Comments : NSManagedObject

@property (nonatomic, strong) NSString * commentId;
@property (nonatomic, strong) NSString * commentLikes;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) NSString * postedDate;
@property (nonatomic, strong) NSString * reported;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSSet * commentReplies;
@property (nonatomic, strong) NSArray * commentReplyArray;

@end


@interface Comments (CoreDataGeneratedAccessors)

- (void)addCommentRepliesObject:(CommentReplies *)value;
- (void)removeCommentRepliesObject:(CommentReplies *)value;
- (void)addCommentReplies:(NSSet *)values;
- (void)removeCommentReplies:(NSSet *)values;

@end
