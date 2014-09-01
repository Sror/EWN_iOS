//
//  CommentReplies.h
//  EWN
//
//  Created by Andre Gomes on 2013/12/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comments;

@interface CommentReplies : NSManagedObject

@property (nonatomic, strong) NSString * commentId;
@property (nonatomic, strong) NSString * commentLikes;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) NSString * postedDate;
@property (nonatomic, strong) NSString * reported;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) Comments *comment;

@end
