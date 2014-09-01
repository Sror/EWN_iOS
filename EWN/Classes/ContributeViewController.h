//
//  ContributeViewController.h
//  EWN
//
//  Created by Dolfie Jay on 2014/04/08.
//
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>

@interface ContributeViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, AmazonServiceRequestDelegate>

@property (nonatomic, strong) AmazonS3Client *s3;

@property (nonatomic, strong) IBOutlet UIScrollView *formScroll;
@property (nonatomic, strong) IBOutlet UITextField *emailText;
@property (nonatomic, strong) IBOutlet UITextField *titleText;
@property (nonatomic, strong) IBOutlet UITextField *nameText;
@property (nonatomic, strong) IBOutlet UITextView *storyText;
@property (nonatomic, strong) IBOutlet UILabel *termsLabel;
@property (nonatomic, strong) IBOutlet UIView *termsTouchView;
@property (nonatomic, strong) IBOutlet UISwitch *termSwitch;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet UIButton *attachButton;
@property (nonatomic, strong) UIView *selectedText;
@property (nonatomic) double currentKeyboardHeight;
@property (nonatomic, strong) NSString *contributeKey;
@property (nonatomic) bool contributeKeyLoaded;
@property (nonatomic, strong) IBOutlet UIView *imagePickerContainer;
@property (nonatomic, strong) IBOutlet UIView *imagePickerButtonContainer;
//@property (nonatomic, retain) IBOutlet UIButton *imageButtonAudio;
@property (nonatomic, strong) IBOutlet UIButton *imageButtonImage;
@property (nonatomic, strong) IBOutlet UIButton *imageButtonVideo;
@property (nonatomic, strong) IBOutlet UIView *attachedMediaContainer;
@property (nonatomic, strong) NSMutableArray *attachedMediaArray;
@property (nonatomic, strong) NSMutableArray *attachedMediaOriginalArray;
@property (nonatomic, strong) UIColor *placeholderColor;

// default frames for scrolling
@property (nonatomic) CGRect frameFormScroll;
@property (nonatomic) CGRect frameAttachedMediaContainer;
@property (nonatomic) CGRect frameSubmitButton;
@property (nonatomic) CGRect frameAttachButton;
@property (nonatomic) CGRect frameImagePickercontainer;

- (void)attachHandler;
- (void)clearForm;
- (void)fetchTerms;
- (void)dismissKeyboard;
- (void)displayTerms;
- (void)initImagePicker;
- (void)submitHandler;
- (void)submitTextfields;
- (void)termHandler;

- (void)showLoadingScreen:(NSString *)loadingMessage;
- (void)hideLoadingScreen;

-(void)selectImage;

@end