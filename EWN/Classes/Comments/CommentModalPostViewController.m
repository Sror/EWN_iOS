//
//  CommentModalPostViewController.m
//  EWN
//
//  Created by Dolfie Jay on 2013/12/03.
//
//

#import "CommentModalPostViewController.h"
#import "EWNButton.h"
#import "AReachability.h"


@interface CommentModalPostViewController ()

@end




@implementation CommentModalPostViewController

@synthesize articleId;
@synthesize activityView;


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
    
    self.view.alpha = 0;
    
    [self.submitBtn addTarget:self action:@selector(submitButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         self.view.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         
                         // As soon as the view is presented, we allow the textView to be edited.
                         [self.commentTextView becomeFirstResponder];
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)close:(id)sender {
    [self.commentTextView resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"COMMENT_MODAL_CLOSED" object:nil];
    
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
        [self.commentTextView resignFirstResponder];
        NSString *messageString = @"Unable to connect to the internet, check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
    
    
    NSString *userId = self.userIdReturn;
    NSString *commentText = [self trimWhitespace:self.commentTextView.text];
    
    // validate the length
    int commentLenght = commentText.length;
    int minLength = 3;
    if (commentLenght < minLength) {
        [self.commentTextView resignFirstResponder];
        [[WebserviceComunication sharedCommManager] showAlert:@"Comments" message:@"Please enter at least 3 characters."]; // You have to have at least 3 characters to post.
        return;
    }
    
    // close the keyboard...
    [self.view endEditing:YES];
    
    // show an activity indicator
    activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    activityView.center = self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    // setup a receiver
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCommentCompleteHandler) name:kNOTIFICATION_POST_COMMENT object:nil];
    
    
    [sender shouldAnimate:YES];
    self.commentTextView.editable = NO;
    self.closeBtn.enabled = NO;
    self.submitBtn.enabled = NO;
    
    
    // kNOTIFICATION_POST_COMMENT
    
    // webservice request time
    // Creating the dictionary this way as we have more control on not inserting nil values
    // into dictionary which causes crash - Andre
    NSMutableDictionary *dictCommentPost = [NSMutableDictionary dictionary];
    
    if (articleId && articleId.length > 0)
        [dictCommentPost setValue:articleId forKey:@"articleId"];
    
    if (userId && userId.length > 0)
        [dictCommentPost setValue:userId forKey:@"userId"];
    
    if (commentText && commentText.length > 0)
        [dictCommentPost setValue:commentText forKey:@"commentText"];
    
    [[[WebserviceComunication sharedCommManager] dictCommentPost] addEntriesFromDictionary:dictCommentPost];
    [[WebserviceComunication sharedCommManager] postComment];
}

-(void)postCommentCompleteHandler {
    
    [self.submitBtn shouldAnimate:NO];
    self.commentTextView.editable = YES;
    self.closeBtn.enabled = YES;
    self.submitBtn.enabled = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_POST_COMMENT object:nil];
    
    NSDictionary *dictCommentPost = [[WebserviceComunication sharedCommManager] dictCommentPost];
    DLog(@"Got this : %@",dictCommentPost);
    [activityView.self removeFromSuperview];
    
    NSString *success = [dictCommentPost valueForKey:@"SubmitCommentResult"];
    
    DLog(@"success : %@",success);
    
    // handle error
    if ([success isEqualToString:@"false"]) {
        // alert that your comment was not posted
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Comments"
                              message: @"Your comment could not been submitted at this time. Please try again later."
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        // open the keyboard again
        [self.commentTextView becomeFirstResponder];
        return;
    }
    
    // success means the comments have to get called again...
    [[NSNotificationCenter defaultCenter] postNotificationName:@"COMMENT_MODAL_CLOSED" object:nil];
    
    // close the poppup
    [self close:nil];
}

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
        int padding = 10;
        int y = presentedFrame.origin.y - modalViewHeight - padding;
        
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


// return user id
-(NSString *) userIdReturn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"UserId"];
    if (userId == nil) {
        userId = @"";
    }
    return userId;
}

- (NSString *)trimWhitespace:(NSString *)stringToTrim {
    NSMutableString *mStr = [stringToTrim mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)mStr);
    NSString *result = [mStr copy];
    return result;
}

@end
