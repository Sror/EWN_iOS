//
//  ContactFeedbackViewController.m
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import "ContactFeedbackViewController.h"
#import "EWNButton.h"
#import "AReachability.h"


#define kFeedback_PlaceHolder_Text      @"Tell us your story"



@interface ContactFeedbackViewController () <UITextViewDelegate>

@end



@implementation ContactFeedbackViewController

@synthesize delegate;


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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    self.feedbackText.delegate = self;
    [self.feedbackText setFont:[UIFont fontWithName:kFontOpenSansRegular size:14]];
    [self.feedbackText setTextColor:[UIColor grayColor]];
    self.feedbackText.text = kFeedback_PlaceHolder_Text;
    [self.feedbackText.layer setCornerRadius:5.0f];
    
    
    [self.submitButton.titleLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:14]];
    [self.submitButton.titleLabel setTextColor:[UIColor darkGrayColor]];
    [self.submitButton addTarget:self action:@selector(submitHandler:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitHandler:(id)sender
{
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        if (self.feedbackText)
            [self.feedbackText resignFirstResponder];
        
        NSString *messageString = @"Unable to connect to the internet, check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
    
    NSString *feedbackString = [self.feedbackText.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    if (feedbackString.length < 3 || [feedbackString isEqualToString:@"Tell us your story"])
    {
        [self.feedbackText resignFirstResponder];
        self.feedbackText.text = @"";
        [[WebserviceComunication sharedCommManager] showAlert:@"Feedback" message:@"Please enter at least 3 characters."];
        return;
    }
    
    if ([sender isKindOfClass:[EWNButton class]])
        [sender shouldAnimate:YES];
    
    self.feedbackText.editable = NO;
    
    ContactFeedbackViewController *blockSafeSelf = self;
    
    [[WebserviceComunication sharedCommManager] postFeedback:self.feedbackText.text completion:^(BOOL successful, NSError *error, NSData *data) {
        
        if ([sender isKindOfClass:[EWNButton class]])
            [sender shouldAnimate:NO];
        
        blockSafeSelf.feedbackText.editable = YES;
        
        if (successful && [[WebserviceComunication sharedCommManager] webApiRequest])
        {
            [[WebserviceComunication sharedCommManager] showAlert:@"Feedback" message:@"Your feedback was successfully submitted."];
            
            if ([blockSafeSelf.feedbackText.text isEqualToString:kFeedback_PlaceHolder_Text] == NO)
                blockSafeSelf.feedbackText.text = kFeedback_PlaceHolder_Text;
            
            blockSafeSelf.feedbackText.textColor = [UIColor grayColor];
            [blockSafeSelf.feedbackText setNeedsDisplay];
        }
        else
        {
            [[WebserviceComunication sharedCommManager] showAlert:@"Feedback" message:@"Your feedback was not submitted. Please try again later."];
        }
    }];
}

- (void)postCompleteHandler
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_POST_FEEDBACK object:nil];
    [self.feedbackText setText:@"... success, thanks! ;D"];
}


#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (delegate && [delegate respondsToSelector:@selector(textView:firstResponder:)])
        [delegate textView:self firstResponder:YES];
    
    if ([textView.text isEqualToString:kFeedback_PlaceHolder_Text])
        textView.text = @"";
    
    textView.textColor = [UIColor darkTextColor];
    
    [textView setNeedsDisplay];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (delegate && [delegate respondsToSelector:@selector(textView:firstResponder:)])
        [delegate textView:self firstResponder:NO];
    
    
    if (textView.text.length == 0 || [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        textView.text = kFeedback_PlaceHolder_Text;
        textView.textColor = [UIColor grayColor];
    }
    

    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    
//    if ([textView.text isEqualToString:kFeedback_PlaceHolder_Text] == NO)
//        textView.text = kFeedback_PlaceHolder_Text;
//
//    textView.textColor = [UIColor grayColor];
}

@end
