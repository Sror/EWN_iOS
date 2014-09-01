//
//  ContactFeedbackViewController.h
//  EWN
//
//  Created by Dolfie on 2013/12/05.
//
//

#import <UIKit/UIKit.h>

@protocol ContactFeedbackViewControllerDelegate;


@interface ContactFeedbackViewController : UIViewController
{
    
}

@property (nonatomic, strong) id<ContactFeedbackViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextView *feedbackText;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;

- (IBAction)submitHandler:(id)sender;
- (void)postCompleteHandler;

@end



@protocol ContactFeedbackViewControllerDelegate <NSObject>

- (void)textView:(ContactFeedbackViewController *)target firstResponder:(BOOL)isFirstResponder;

@end