//
//  CommentModalViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/28.
//
//

#import "CommentModalViewController.h"
#import "EWNButton.h"
#import "Comments.h"
#import "AReachability.h"



@interface CommentModalViewController ()
{
    __block CommentModalCompletionBlock completionBlock;
}
@end

@implementation CommentModalViewController

@synthesize commentObject;
@synthesize likesLabel;
@synthesize likeIconImageView;

#pragma mark - GETTERS

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

- (UIImageView *)likeIconImageView
{
    if (!likeIconImageView) {
        likeIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_like_icon"]];
        likeIconImageView.frame = CGRectMake(190, 5, 15, 13);
        likeIconImageView.backgroundColor = [UIColor clearColor];
    }
    return likeIconImageView;
}

#pragma mark - Lifecycle Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:18.0]];
    
    [self.commentName setFont:[UIFont fontWithName:kFontOpenSansRegular size:11.0]];
    [self.commentDate setFont:[UIFont fontWithName:kFontOpenSansRegular size:11.0]];
    [self.commentText setFont:[UIFont fontWithName:kFontOpenSansRegular size:11.0]];
    
    [self.replyTextView setFont:[UIFont fontWithName:kFontOpenSansRegular size:11.0]];
    
    [self.submitBtn.titleLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:11.0]];
    
    [self.closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.topContainerView addSubview:self.likesLabel];
    [self.topContainerView addSubview:self.likeIconImageView];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotificationHandler:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotificationHandler:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self.likesLabel sizeToFit];
    [self.commentDate sizeToFit];
    
    self.commentDate.frame = CGRectMake(self.modalView.frame.size.width - self.commentDate.frame.size.width - 15.0f,
                                        self.commentDate.frame.origin.y,
                                        self.commentDate.frame.size.width,
                                        self.commentDate.frame.size.height);
    
    self.likesLabel.frame = CGRectMake(self.commentDate.frame.origin.x - self.likesLabel.frame.size.width - 5.0f,
                                       self.commentDate.frame.origin.y, // self.likesLabel.frame.origin.y,
                                       self.likesLabel.frame.size.width,
                                       self.likesLabel.frame.size.height);
    
    if (self.likesLabel.text.length > 0)
    {
        self.likeIconImageView.hidden = NO;
        self.likeIconImageView.frame = CGRectMake(self.likesLabel.frame.origin.x - self.likeIconImageView.frame.size.width - 2.0f,
                                                  self.likeIconImageView.frame.origin.y,
                                                  self.likeIconImageView.frame.size.width,
                                                  self.likeIconImageView.frame.size.height);
        
        self.commentName.frame = CGRectMake(self.commentName.frame.origin.x,
                                            self.commentName.frame.origin.y,
                                            self.likeIconImageView.frame.origin.x - self.commentName.frame.origin.x - 5.0f,
                                            self.commentName.frame.size.height);
    }
    else
    {
        self.likeIconImageView.hidden = YES;
        self.commentName.frame = CGRectMake(self.commentName.frame.origin.x,
                                            self.commentName.frame.origin.y,
                                            self.likesLabel.frame.origin.x - self.commentName.frame.origin.x - 5.0f,
                                            self.commentName.frame.size.height);
    }

    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         self.view.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         
                         // As soon as the view is presented, we allow the textView to be edited.
                         [self.replyTextView becomeFirstResponder];
                     }];
    
    
    // Lazy load the avatar image asynchroniously
    dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
    dispatch_async(myQueue, ^{
        
        if (commentObject)
            [self.commentImage setImageAsynchronouslyFromUrl:[commentObject imageUrl] animated:YES];
        
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma markk - Public Methods

-(void)close:(id)sender
{
    [self.replyTextView resignFirstResponder];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                     }];
}

- (void)submitButtonHandler:(EWNButton *)sender
{
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        [self.replyTextView resignFirstResponder];
        NSString *messageString = @"Unable to connect to the internet, check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
    
    [self.replyTextView resignFirstResponder];
    
    if (self.replyTextView.text.length >= 3)
    {
        if (self.commentObject == nil) {
#ifdef DEBUG
            [[WebserviceComunication sharedCommManager] showAlert:@"DEBUG" message:@"Cannot perform the request.\n\nReason: commentObject == nil"];
#endif
            return;
        }
        
        [sender shouldAnimate:YES];
        self.closeBtn.enabled = NO;
        self.replyTextView.editable = NO;
        
        // Creating the dictionary this way as we have more control on not inserting nil values
        // into dictionary which causes crash - Andre
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        if (commentObject.commentId && commentObject.commentId.length > 0)
            [dictionary setValue:commentObject.commentId forKey:@"commentId"];
        
        if (commentObject.userId && commentObject.userId.length > 0)
            [dictionary setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"] forKey:@"userId"];
        
        if (commentObject.text && commentObject.text.length > 0)
            [dictionary setValue:self.replyTextView.text forKey:@"commentText"];
        
        
        
        CommentModalViewController *blockSafeSelf = self;
        
        [[WebserviceComunication sharedCommManager] replyCommentWithDict:dictionary completion:^(BOOL successful, NSError *error, NSData *data) {
            
            [sender shouldAnimate:NO];
            blockSafeSelf.closeBtn.enabled = YES;
            blockSafeSelf.replyTextView.editable = YES;
            
            if (completionBlock) {
                completionBlock(successful);
            }            
            
            NSString *titleString = @"Comments";
            NSString *messageString = nil;
            
            if (successful && error == nil) {
                messageString = @"Your reply has been submitted.";
                [blockSafeSelf close:nil];
            } else {
                messageString = @"Your reply could not been submitted at this time. Please try again later.";
                [blockSafeSelf.replyTextView becomeFirstResponder];
            }
            
            [[WebserviceComunication sharedCommManager] showAlert:titleString message:messageString];
        }];
    }
    else
    {
        [[WebserviceComunication sharedCommManager] showAlert:@"Comment" message:@"Please enter at least 3 characters."];
    }
}

- (void)completionBlock:(CommentModalCompletionBlock)block
{
    completionBlock = [block copy];
}



#pragma mark - Keyboard Notification Handlers

-(void)keyboardNotificationHandler:(NSNotification *)notif
{
    NSDictionary* userInfo = [notif userInfo];
    
    // resize the modalView
    CGRect viewFrame = self.modalView.frame;
    // I need the entire view height
    int totalHeight = self.view.frame.size.height;
    // as well as my views height
    int modalViewHeight = self.modalView.frame.size.height;
    
    if ([notif.name isEqualToString:UIKeyboardWillShowNotification])
    {
        CGRect presentedFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        int padding = 0.0f;
        int y = 0.0f;
        
        if ([[UIScreen mainScreen] bounds].size.height > 480)
        {
            padding = 10;
            y = presentedFrame.origin.y - modalViewHeight - padding;
        }
        else
        {
            padding = 5;
            y = presentedFrame.origin.y - modalViewHeight + padding;
        }
        
        viewFrame.origin.y = y;
    }
    else if ([notif.name isEqualToString:UIKeyboardWillHideNotification])
    {
        int y = (totalHeight - modalViewHeight) / 2;
        viewFrame.origin.y = y;
    }
    
    double animationDuration = ((NSNumber *)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]).floatValue;
    UIViewAnimationCurve animationCurve =  ((NSNumber *)[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]).integerValue;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.modalView setFrame:viewFrame];
    [UIView commitAnimations];
}

@end
