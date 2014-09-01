//
//  CommentModalViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/28.
//  Edited by André Riccardo Gomes (aka: iOS Guru)
//

#import <UIKit/UIKit.h>

@class EWNButton, Comments;


#if NS_BLOCKS_AVAILABLE
typedef void (^CommentModalCompletionBlock)(BOOL successful);
#endif


@interface CommentModalViewController : UIViewController
{
    
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *closeBtn;
@property (nonatomic, strong) IBOutlet UIView *modalView;
@property (nonatomic, strong) IBOutlet UIView *commentView;
@property (nonatomic, strong) IBOutlet UIImageView *commentImage;
@property (nonatomic, strong) IBOutlet UIImageView *commentHeading;
@property (nonatomic, strong) IBOutlet UILabel *commentName;
@property (nonatomic, strong) IBOutlet UILabel *commentDate;
@property (nonatomic, strong) IBOutlet UILabel *commentText;
@property (nonatomic, strong) IBOutlet UITextView *replyTextView;
@property (nonatomic, strong) IBOutlet EWNButton *submitBtn;
@property (nonatomic, strong) IBOutlet UIView *topContainerView;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIImageView *likeIconImageView;
@property (nonatomic, strong) Comments *commentObject;


- (void)close:(id)sender;

- (IBAction)submitButtonHandler:(EWNButton *)sender;

#if NS_BLOCKS_AVAILABLE
- (void)completionBlock:(CommentModalCompletionBlock)block;
#endif

@end
