//
//  CommentViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/24.
//
//

#import "CommentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EWNButton.h"
#import "CommentModalViewController.h"
#import "MainViewController.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

// Public
@synthesize commentObject;
@synthesize commentReplyObject;
@synthesize delegate;

@synthesize imageView;
@synthesize nameLabel;
@synthesize likeIconImageView;
@synthesize likesLabel;
@synthesize dateLabel;
@synthesize commentLabel;
@synthesize reportBtn;
@synthesize likeBtn;
@synthesize replyBtn;

#pragma mark - Getters

- (UIImageView *)imageView
{
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_avatar"]];
        imageView.frame = CGRectMake(45, 5, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];        
        [imageView.layer setMasksToBounds:YES];
        [imageView.layer setCornerRadius:5.0f];
    }
    return imageView;
}

- (UILabel *)nameLabel
{
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor darkGrayColor];
        nameLabel.frame = CGRectMake(55, 5, 100, 15);
        [nameLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:11.0]];
        nameLabel.lineBreakMode = [UIDevice currentDevice].systemVersion.floatValue < 7 ? UILineBreakModeTailTruncation : NSLineBreakByTruncatingTail;
    }
    return nameLabel;
}

- (UIImageView *)likeIconImageView
{
    if (!likeIconImageView) {
        likeIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_like_icon"]];
        likeIconImageView.frame = CGRectMake(190, 5, 15, 13);
        likeIconImageView.backgroundColor = [UIColor clearColor];
    }
    return likeIconImageView;
}

- (UILabel *)likesLabel
{
    if (!likesLabel) {
        likesLabel = [[UILabel alloc] init];
        likesLabel.backgroundColor = [UIColor clearColor];
        likesLabel.textColor = [UIColor lightGrayColor];
        likesLabel.frame = CGRectMake(232, 5, 100, 15);
        [likesLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:11.0]];
        likesLabel.lineBreakMode = [UIDevice currentDevice].systemVersion.floatValue < 7 ? UILineBreakModeTailTruncation : NSLineBreakByTruncatingTail;
    }
    return likesLabel;
}

- (UILabel *)dateLabel
{
    if (!dateLabel) {
        dateLabel = [[UILabel alloc] init];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = [UIColor darkGrayColor];
        dateLabel.frame = CGRectMake(295, 5, 100, 15);
        [dateLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:11.0]];
        dateLabel.lineBreakMode = [UIDevice currentDevice].systemVersion.floatValue < 7 ? UILineBreakModeTailTruncation : NSLineBreakByTruncatingTail;
    }
    return dateLabel;
}

- (UILabel *)commentLabel
{
    if (!commentLabel) {
        commentLabel = [[UILabel alloc] init];
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.textColor = [UIColor lightGrayColor];
        commentLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, 25, 240, 25);
        [commentLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:11.0]];
        commentLabel.lineBreakMode = [UIDevice currentDevice].systemVersion.floatValue < 7 ? UILineBreakModeWordWrap : NSLineBreakByWordWrapping;
        [commentLabel setNumberOfLines:0];
    }
    return commentLabel;
}

- (EWNButton *)reportBtn
{
    if (!reportBtn)
    {
        reportBtn = [EWNButton buttonWithType:UIButtonTypeCustom];
        [reportBtn.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [reportBtn setTitle:@"Report" forState:UIControlStateNormal];
        [reportBtn setBackgroundImage:[UIImage imageNamed:@"comment_like_btn"] forState:UIControlStateNormal];
        [reportBtn addTarget:self action:@selector(reportButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [reportBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        reportBtn.frame = CGRectMake(120, 55, 55, 20);
    }
    return reportBtn;
}

- (EWNButton *)likeBtn
{
    if (!likeBtn)
    {
        likeBtn = [EWNButton buttonWithType:UIButtonTypeCustom];
        [likeBtn.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [likeBtn setTitle:@"Like" forState:UIControlStateNormal];
        [likeBtn setBackgroundImage:[UIImage imageNamed:@"comment_like_btn"] forState:UIControlStateNormal];
        [likeBtn addTarget:self action:@selector(likeButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [likeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        likeBtn.frame = CGRectMake(180, 55, 55, 20);
    }
    return likeBtn;
}

- (EWNButton *)replyBtn
{
    if (!replyBtn)
    {
        replyBtn = [EWNButton buttonWithType:UIButtonTypeCustom];
        [replyBtn.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [replyBtn setTitle:@"Reply" forState:UIControlStateNormal];
        [replyBtn setBackgroundImage:[UIImage imageNamed:@"comment_like_btn"] forState:UIControlStateNormal];
        [replyBtn addTarget:self action:@selector(replyButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [replyBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        replyBtn.frame = CGRectMake(240, 55, 55, 20);
    }
    return replyBtn;
}



#pragma mark - Lifecycle Methods

- (id)init
{
    if (self = [super init])
    {
        if (!(self = [self initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 80.0f)])) return nil;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setCornerRadius:5.0];
        [self.layer setBorderColor:kUICOLOR_LIGHT_GRAY.CGColor];
        [self.layer setBorderWidth:1.0];
        
        [self addSubview:self.nameLabel];
        [self addSubview:self.imageView];
        [self addSubview:self.likeIconImageView];
        [self addSubview:self.likesLabel];
        [self addSubview:self.dateLabel];
        [self addSubview:self.commentLabel];
        [self addSubview:self.reportBtn];
        [self addSubview:self.likeBtn];
        [self addSubview:self.replyBtn];
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (commentReplyObject)
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 270.0f, 80.0f);
    else
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 300.0f, 80.0f);
}


#pragma mark - Public Methods

- (void)update
{
    CGSize commentTextConstraint = commentReplyObject ? CGSizeMake(210, 20000) : CGSizeMake(235, 20000);

    [self layoutIfNeeded];
    
    
    [self.imageView setFrame:CGRectMake(5, 5, 40, 40)];
    
    // Update Menu

    // Resize Comment
    CGSize textSize = [self.commentLabel.text sizeWithFont:self.commentLabel.font
                                         constrainedToSize:commentTextConstraint
                                             lineBreakMode:self.commentLabel.lineBreakMode]; // [UIDevice currentDevice].systemVersion.floatValue < 7 ? UILineBreakModeWordWrap : NSLineBreakByWordWrapping
    
    CGRect commentFrame = CGRectMake(self.commentLabel.frame.origin.x,
                                     self.commentLabel.frame.origin.y,
                                     textSize.width, textSize.height);
    self.commentLabel.frame = commentFrame;
    
    [self.likesLabel sizeToFit];
    [self.dateLabel sizeToFit];
    
    self.dateLabel.frame = CGRectMake(self.frame.size.width - self.dateLabel.frame.size.width - 10.0f,
                                      self.dateLabel.frame.origin.y,
                                      self.dateLabel.frame.size.width,
                                      self.dateLabel.frame.size.height);
    
    self.likesLabel.frame = CGRectMake(self.dateLabel.frame.origin.x - self.likesLabel.frame.size.width - 5.0f,
                                     self.likesLabel.frame.origin.y,
                                     self.likesLabel.frame.size.width,
                                     self.likesLabel.frame.size.height);
    
    if (self.likesLabel.text.length > 0)
    {
        self.likeIconImageView.hidden = NO;
        self.likeIconImageView.frame = CGRectMake(self.likesLabel.frame.origin.x - self.likeIconImageView.frame.size.width - 2.0f,
                                                  self.likeIconImageView.frame.origin.y,
                                                  self.likeIconImageView.frame.size.width,
                                                  self.likeIconImageView.frame.size.height);
        
        self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x,
                                          self.nameLabel.frame.origin.y,
                                          self.likeIconImageView.frame.origin.x - self.nameLabel.frame.origin.x - 5.0f,
                                          self.nameLabel.frame.size.height);
    }
    else
    {
        self.likeIconImageView.hidden = YES;
        self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x,
                                          self.nameLabel.frame.origin.y,
                                          self.likesLabel.frame.origin.x - self.nameLabel.frame.origin.x - 5.0f,
                                          self.nameLabel.frame.size.height);
    }
    
    // Reposition Buttons - Hide if not logged in
    BOOL isLogin = [self userIdReturn];
    
    if(!isLogin)
    {
        [self.reportBtn setHidden:YES];
        [self.likeBtn setHidden:YES];
        [self.replyBtn setHidden:YES];
    }
    else
    {
        int posY = self.commentLabel.frame.origin.y + self.commentLabel.frame.size.height + 10;
        
        if (commentReplyObject)
        {
            [self.replyBtn setHidden:YES];
            [self.reportBtn setFrame:CGRectMake(self.likeBtn.frame.origin.x - 10, posY, self.reportBtn.frame.size.width, self.reportBtn.frame.size.height)];
            [self.likeBtn setFrame:CGRectMake(self.replyBtn.frame.origin.x - 10, posY, self.likeBtn.frame.size.width, self.likeBtn.frame.size.height)];
        }
        else
        {
            [self.replyBtn setFrame:CGRectMake(self.replyBtn.frame.origin.x, posY, self.replyBtn.frame.size.width, self.replyBtn.frame.size.height)];
            [self.reportBtn setFrame:CGRectMake(self.reportBtn.frame.origin.x, posY, self.reportBtn.frame.size.width, self.reportBtn.frame.size.height)];
            [self.likeBtn setFrame:CGRectMake(self.likeBtn.frame.origin.x, posY, self.likeBtn.frame.size.width, self.likeBtn.frame.size.height)];
        }
    }
    
    
    // Resize Comment Container
    float newHeight;
    
    if(!isLogin) {
        newHeight = self.commentLabel.frame.origin.y + self.commentLabel.frame.size.height + 10;
    } else {
        newHeight = self.likeBtn.frame.origin.y + self.likeBtn.frame.size.height + 10;
    }
    
    if (newHeight < 50) {
        newHeight = 50;
    }
    
    // HANDLE REPLIES
    if (commentObject.commentReplyArray && commentObject.commentReplyArray.count > 0)
    {
        for (CommentReplies *commentReply in commentObject.commentReplyArray)
        {
            CommentViewController *commentReplyView = [[CommentViewController alloc] init];
            
            commentReplyView.delegate = self.delegate;
            commentReplyView.commentReplyObject = commentReply;
            [commentReplyView.nameLabel setText:[commentReply userName]];
            [commentReplyView.likesLabel setText:[[CommonUtilities sharedManager] formatCommentLikeString:[commentReply commentLikes]]];
            [commentReplyView.dateLabel setText:[[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[commentReply postedDate]]];
            [commentReplyView.commentLabel setText:[commentReply text]];
            
            [self addSubview:commentReplyView];
            
            float yOffSet = newHeight + 5.0f;
            
            CGRect commentFrame = CGRectMake(5, yOffSet, commentReplyView.frame.size.width + 20, commentReplyView.frame.size.height);
            [commentReplyView setFrame:commentFrame];
            
            [commentReplyView update];
            
            if (commentReply == commentObject.commentReplyArray.lastObject) {
                newHeight = yOffSet + commentReplyView.frame.size.height + 10.0f;
            } else {
                newHeight = yOffSet + commentReplyView.frame.size.height;
            }
            
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight)];
        }
    }
    else
    {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight)];
    }
    
    [self.layer setNeedsLayout];
    [self.layer setNeedsDisplay];
    
    // Lazy load the avatar image asynchroniously
    dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
    dispatch_async(myQueue, ^{
        if (commentReplyObject) {
            [self.imageView setImageAsynchronouslyFromUrl:[commentReplyObject imageUrl] animated:YES];
        } else if (commentObject) {
            [self.imageView setImageAsynchronouslyFromUrl:[commentObject imageUrl] animated:YES];
        }
        
    });
}

-(void)updateWithChildComment:(Comments *)commentObj
{
    commentObject = commentObj;
    
    DLog(@"Adding Child Comment : %@", commentObj);
    
    CommentViewController *comment = [[CommentViewController alloc] init];
    
    int newHeight = self.replyBtn.frame.origin.y + self.replyBtn.frame.size.height + 5;
    CGRect commentFrame = CGRectMake(10, newHeight, comment.frame.size.width, comment.frame.size.height);
    [comment setFrame:commentFrame];
    
    comment.commentObject = commentObj;
    [comment.nameLabel setText:[commentObj userName]];
    [comment.likesLabel setText:[[CommonUtilities sharedManager] formatCommentLikeString:[commentObj commentLikes]]];
    [comment.dateLabel setText:[[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[commentObj postedDate]]];
    [comment.commentLabel setText:[commentObj text]];
    
    [self addSubview:comment];
    
    [comment update];
}


#pragma mark - Private Methods

- (BOOL) userIdReturn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"UserId"];
    
    if (userId != nil && userId.length > 0)
        return YES;
    
    return NO;
}



#pragma mark - UIButton Handlers

- (void)reportButtonHandler:(EWNButton *)sender
//- (void)reportButtonHandler:(id)sender
{
    if (sender.isAnimating)
        return;
    
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        NSString *messageString = @"Unable to connect to the internet, check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
    
    // Creating the dictionary this way as we have more control on not inserting nil values
    // into dictionary which causes crash - Andre
    NSMutableDictionary *dictReportComment = [NSMutableDictionary dictionary];
    
    
    if (commentObject)
    {
        if (commentObject.commentId && commentObject.commentId.length > 0)
            [dictReportComment setValue:commentObject.commentId forKey:@"commentId"];
    }
    if (commentReplyObject)
    {
        if (commentReplyObject.commentId && commentReplyObject.commentId.length > 0)
            [dictReportComment setValue:commentReplyObject.commentId forKey:@"commentId"];
    }
    
    
    [sender shouldAnimate:YES];
    
    [[WebserviceComunication sharedCommManager] reportCommentWithDict:dictReportComment completion:^(BOOL successful, NSError *error, NSData *data) {
        
        [sender shouldAnimate:NO];
        
        NSString *titleString = @"Comments";
        NSString *messageString = nil;
        
        if (successful)
        {
            messageString = @"Your report has been submitted.";
        }
        else
        {
            messageString = @"Your report could not been submitted at this time. Please try again later.";
        }
        
        [[WebserviceComunication sharedCommManager] showAlert:titleString message:messageString];
    }];
}

- (void)likeButtonHandler:(EWNButton *)sender
{
    if (sender.isAnimating)
        return;
    
    
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        NSString *messageString = @"Unable to connect to the internet, check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
    
    
    // Creating the dictionary this way as we have more control on not inserting nil values
    // into dictionary which causes crash - Andre
    NSMutableDictionary *dictLikeComment = [NSMutableDictionary dictionary];
    
    if (commentObject)
    {
        if (commentObject.commentId && commentObject.commentId.length > 0)
            [dictLikeComment setValue:commentObject.commentId forKey:@"commentId"];
        
            [dictLikeComment setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"] forKey:@"userId"];
            [dictLikeComment setValue:@"true" forKey:@"likeComment"];
    }
    if (commentReplyObject)
    {
        if (commentReplyObject.commentId && commentReplyObject.commentId.length > 0)
            [dictLikeComment setValue:commentReplyObject.commentId forKey:@"commentId"];
        
            [dictLikeComment setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"] forKey:@"userId"];
            [dictLikeComment setValue:@"true" forKey:@"likeComment"];
    }
    
    [sender shouldAnimate:YES];
    
    [[WebserviceComunication sharedCommManager] likeCommentWithDict:dictLikeComment completion:^(BOOL successful, NSError *error, NSData *data) {
        
        [sender shouldAnimate:NO];
        
        NSString *titleString = @"Comments";
        NSString *messageString = nil;
        
        if (successful)
        {
            messageString = @"Your ‘Like’ has been submitted.";
            if (delegate && [delegate respondsToSelector:@selector(refreshCommentList)])
            {
                [delegate refreshCommentList];
            }
        }
        else
        {
            messageString = @"Your ‘Like’ could not been submitted at this time. Please try again later.";
        }
        
        [[WebserviceComunication sharedCommManager] showAlert:titleString message:messageString];
    }];
}

- (void)replyButtonHandler:(EWNButton *)sender
{
    if (commentObject)
    {
        if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
        {
            NSString *messageString = @"Your connection is offline and you won't be able to post a reply to this comment. Check your connection and try again later.";
            [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
            return;
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MainViewController *objMainView = (MainViewController *)window.rootViewController;
        
        // instantiate
        CommentModalViewController *commentModal = [[CommentModalViewController alloc] init];
        commentModal.view.alpha = 0;
        
        NSString *titleString = commentObject.userName && commentObject.userName.length > 0 ? commentObject.userName : @"comment" ;
        
        commentModal.commentObject = commentObject;
        commentModal.titleLabel.text = [NSString stringWithFormat:@"Reply to %@", titleString];
        commentModal.commentName.text = commentObject.userName;
        commentModal.commentText.text = commentObject.text;
        commentModal.likesLabel.text = [[CommonUtilities sharedManager] formatCommentLikeString:[commentObject commentLikes]];
        commentModal.commentDate.text = [[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[commentObject postedDate]];
        
        [objMainView.view addSubview:commentModal.view];
        
        
        [commentModal completionBlock:^(BOOL successful) {
            
            if (delegate && [delegate respondsToSelector:@selector(refreshCommentList)])
            {
                [delegate refreshCommentList];
            }
        }];
    }
}

#pragma mark - Memory Management Methods


@end
