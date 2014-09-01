//
//  CommentViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/24.
//
//

#import <UIKit/UIKit.h>

#import "Comments.h"
#import "CommentReplies.h"

@class EWNButton;

@protocol CommentViewControllerDelegate;

@interface CommentViewController : UIView
{
    
}

@property (nonatomic, strong) __block id<CommentViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *likeIconImageView;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) EWNButton *reportBtn;
@property (nonatomic, strong) EWNButton *likeBtn;
@property (nonatomic, strong) EWNButton *replyBtn;
@property (nonatomic, strong) __block Comments *commentObject;
@property (nonatomic, strong) __block CommentReplies *commentReplyObject;

-(void)update;
-(void)updateWithChildComment:(Comments *)commentObj;

- (void)reportButtonHandler:(id)sender;
- (void)likeButtonHandler:(id)sender;
- (void)replyButtonHandler:(id)sender;

@end




@protocol CommentViewControllerDelegate <NSObject>

@optional;
- (void)refreshCommentList;

@end