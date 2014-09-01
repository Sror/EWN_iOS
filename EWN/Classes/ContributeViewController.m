//
//  ContributeViewController.m
//  EWN
//
//  Created by Dolfie Jay on 2014/04/08.
//
//

#import "ContributeViewController.h"
#import "MainViewController.h"

#import <AWSRuntime/AWSRuntime.h>

@interface ContributeViewController ()

@end

@implementation ContributeViewController

@synthesize formScroll;

@synthesize emailText;
@synthesize nameText;
@synthesize titleText;
@synthesize storyText;
@synthesize selectedText;
@synthesize attachButton;
@synthesize submitButton;
@synthesize termSwitch;
@synthesize title;
@synthesize termsLabel;
@synthesize termsTouchView;
@synthesize contributeKey;
@synthesize contributeKeyLoaded;
@synthesize currentKeyboardHeight;
@synthesize imagePickerContainer;
@synthesize imagePickerButtonContainer;
//@synthesize imageButtonAudio;
@synthesize imageButtonImage;
@synthesize imageButtonVideo;
@synthesize attachedMediaContainer;
@synthesize attachedMediaArray;
@synthesize attachedMediaOriginalArray;

@synthesize frameAttachButton;
@synthesize frameAttachedMediaContainer;
@synthesize frameFormScroll;
@synthesize frameSubmitButton;
@synthesize frameImagePickercontainer;

@synthesize placeholderColor;

@synthesize s3 = _s3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedTermsAndConditions) name:@"TERMS_REQUEST" object:nil];
        // CONTRIBUTEKEY_REQUEST
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedContributeKey) name:@"CONTRIBUTEKEY_REQUEST" object:nil];
        contributeKeyLoaded = NO;
        // CONTRIBUTESUBMISSION_REQUEST
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedContributeSubmission) name:@"CONTRIBUTESUBMISSION_REQUEST" object:nil];
        // Image Picker
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleImage:) name:@"CONTRIBUTE_IMAGE_PICKER" object:nil];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    if (!contributeKeyLoaded) {
        [[WebserviceComunication sharedCommManager] getContributeKey];
        [self showLoadingScreen:@"Checking the contribute service"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentKeyboardHeight = 0;
    
    [self initImagePicker];
    attachedMediaArray = [[NSMutableArray alloc] init];
    attachedMediaOriginalArray = [[NSMutableArray alloc] init];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHandler:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHandler:) name:UIKeyboardWillHideNotification object:nil];
    
    // register for alert notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validationAlertDismissed) name:@"CONTRIBUTE_VALIDATION_ALERT_DISMISSED" object:nil];
    
    placeholderColor = [UIColor darkGrayColor];
    UIColor *textBackgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
    
    [storyText setDelegate:self];
    storyText.layer.borderWidth = 1.0f;
    [storyText.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] CGColor]];
    storyText.layer.cornerRadius = 5;
    storyText.clipsToBounds = YES;
    storyText.text = @"Tell us your story*";
    [storyText setTextColor:placeholderColor];
    [storyText setBackgroundColor:textBackgroundColor];
    
    
    [emailText setDelegate:self];
    [emailText setBackgroundColor:textBackgroundColor];
    emailText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    
    [nameText setDelegate:self];
    [nameText setBackgroundColor:textBackgroundColor];
    nameText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    
    [titleText setDelegate:self];
    [titleText setBackgroundColor:textBackgroundColor];
    titleText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Story title" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    
    [attachButton setImage:[UIImage imageNamed:@"icon_upload_photo"] forState:UIControlStateNormal];
    [attachButton addTarget:self action:@selector(attachHandler) forControlEvents:UIControlEventTouchUpInside];
    [submitButton addTarget:self action:@selector(submitHandler) forControlEvents:UIControlEventTouchUpInside];
    [termSwitch addTarget:self action:@selector(termHandler) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    NSDictionary *attributes = @{NSUnderlineStyleAttributeName: @1};
    NSAttributedString *myString = [[NSAttributedString alloc] initWithString:@"terms and conditions" attributes:attributes];
    termsLabel.attributedText = myString;
    UITapGestureRecognizer *termRecognizer = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(fetchTerms)];
    [self.termsTouchView addGestureRecognizer:termRecognizer];
    
    [self setDefaultFrames];
    [self resizeFormScroll];
}

- (void)setDefaultFrames {
    frameFormScroll = formScroll.frame;
    frameFormScroll.size.height = self.view.frame.size.height;
    
    frameAttachedMediaContainer = attachedMediaContainer.frame;
    frameAttachButton = attachButton.frame;
    frameSubmitButton = submitButton.frame;
    frameImagePickercontainer = imagePickerContainer.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {

}

- (void)clearForm {
    [titleText setText:@""];
    [storyText setText:@"Tell us your story*"];
    [storyText setTextColor:placeholderColor];
    [nameText setText:@""];
    [emailText setText:@""];
    [[WebserviceComunication sharedCommManager] getContributeKey];
    [self showLoadingScreen:@"Checking the contribute service"];
    [termSwitch setOn:NO animated:YES];
    [attachedMediaArray removeAllObjects];
    [attachedMediaOriginalArray removeAllObjects];
    [self drawAttachedMediaItems];
    [formScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)dismissKeyboard {
    for (UIView * txt in self.formScroll.subviews) {
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
            break;
        }
        if ([txt isKindOfClass:[UITextView class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
            break;
        }
    }
    [imagePickerContainer setHidden:YES];
}

- (void)validationAlertDismissed {
    [selectedText becomeFirstResponder];
}

- (void)showLoadingScreen:(NSString *)loadingMessage {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView showBreakingLoadingScreen:loadingMessage];
}

- (void)hideLoadingScreen {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView hideBreakingLoadingScreen];
}

//===========================================================================
// Terms and Conditions
//===========================================================================

- (void)termHandler {
    [self dismissKeyboard];
}

- (void)fetchTerms {
    [self dismissKeyboard];
    // bring up a loading screen
    [self showLoadingScreen:@"Fetching terms and conditions"];
    // make the api call
    [[WebserviceComunication sharedCommManager] getTerms];
}

- (void)displayTerms {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView displayContributeTerms];
}

- (void)receivedTermsAndConditions {
    [self hideLoadingScreen];
    // error handling
    if ([[[WebserviceComunication sharedCommManager] termsText] isEqualToString:@""]) {
        [[WebserviceComunication sharedCommManager] showAlert:@"Contribute" message:@"The terms and conditions are not available at this time.\nPlease try again later."];
    } else {
        // display the modal with the details
        [self displayTerms];
    }
}

//===========================================================================
// Contribute Submission
//===========================================================================

- (void)submitHandler {
    [self dismissKeyboard];
    
    // ok validation time
    // all we have is to check the text for Story Title and Description
    NSString *validationMessage = @"";
    if ([titleText.text length] < 3) {
        validationMessage = [validationMessage stringByAppendingString:@"\u2022 Supply a title.\n"];
    }
    if ([storyText.text length] < 10 || [storyText.text isEqualToString:@"Tell us your story*"]) {
        validationMessage = [validationMessage stringByAppendingString:@"\u2022 Supply a story.\n"];
    }
    if (![termSwitch isOn]) {
        validationMessage = [validationMessage stringByAppendingString:@"\u2022 Please accept the terms and conditions."];
    }
    
    if (![validationMessage isEqualToString:@""]) {
        NSString *messageToDisplay = [@"Please correct the following errors to submit your report:\n\n" stringByAppendingString:validationMessage];
        [[WebserviceComunication sharedCommManager] showAlert:@"Contribute" message:messageToDisplay];
        [[[WebserviceComunication sharedCommManager] alrtvwNotReachable].lblDetail setTextAlignment:NSTextAlignmentLeft];
        [[[WebserviceComunication sharedCommManager] alrtvwNotReachable].view setTag:kALERT_TAG_CONTRIBUTE];
        if ([titleText.text length] < 3) {
            selectedText = titleText;
        } else {
            if ([storyText.text length] < 10) {
                selectedText = storyText;
            }
        }
    } else {
        // actual submission over here
        // submit the images
        // now submit the rest
        [self submitTextfields];
    }
}

- (void)submitTextfields {
    NSString *titleString = titleText.text;
    NSString *storyString = storyText.text;
    NSString *nameString = nameText.text;
    NSString *emailString = emailText.text;
    
    NSString *submissionString = [NSString stringWithFormat:kRequestContribute,self.contributeKey,titleString,storyString,nameString,emailString];
    
    [self showLoadingScreen:@"Submitting your contribution"];
    [[WebserviceComunication sharedCommManager] submitContributeText:submissionString];
}

- (void)receivedContributeSubmission {
    [self hideLoadingScreen];
    if ([[WebserviceComunication sharedCommManager] contributeSubmissionSuccess]) {
        // wahey!!!
        [[WebserviceComunication sharedCommManager] showAlert:@"Contribute" message:@"Thank you for your submission."];
        // pass the stuff off in the background
        [self submitFilesToAws];
        // reset the form
        [self clearForm];
    } else {
        // boo
        [[WebserviceComunication sharedCommManager] showAlert:@"Contribute" message:@"Something has gone wrong with your submission, please try again later."];
    }
}

//===========================================================================
// Contribute Key
//===========================================================================

- (void)receivedContributeKey {
    [self hideLoadingScreen];
    self.contributeKey = [[WebserviceComunication sharedCommManager] contributeKey];
    if ([self.contributeKey isEqualToString:@""]) {
        [[WebserviceComunication sharedCommManager] showAlert:@"Contribute" message:@"The contribution service is currently unavailable.\nPlease try again later."];
        [[[WebserviceComunication sharedCommManager] alrtvwNotReachable].view setTag:kALERT_TAG_CONTRIBUTEKEY];
        return;
    }
    contributeKeyLoaded = YES;
}

//===========================================================================
// Image Picker
//===========================================================================

- (void)attachHandler {
    [self dismissKeyboard];
    // bring up a selector for image, audio or video
    if ([imagePickerContainer isHidden]) {
        [imagePickerContainer setHidden:NO];
    } else {
        [imagePickerContainer setHidden:YES];
    }
}

- (void)initImagePicker {
    [imagePickerButtonContainer setBackgroundColor:[UIColor colorWithHexString:@"383536"]];
    [imagePickerButtonContainer addSubview:[self createImageSeperator:39]];
//    [imagePickerButtonContainer addSubview:[self createImageSeperator:79]];
    [imagePickerButtonContainer.layer setCornerRadius:5];
    
//    [imageButtonAudio.titleLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:16.0]];
//    [imageButtonAudio addTarget:self action:@selector(selectAudio) forControlEvents:UIControlEventTouchUpInside];
    [imageButtonImage.titleLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:16.0]];
    [imageButtonImage addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    [imageButtonVideo.titleLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:16.0]];
    [imageButtonVideo addTarget:self action:@selector(selectVideo) forControlEvents:UIControlEventTouchUpInside];
}

- (UIView *)createImageSeperator:(int) y {
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, y, 130, 2)];
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 1)];
    [top setBackgroundColor:[UIColor blackColor]];
    [seperator addSubview:top];
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 1, 130, 1)];
    [bottom setBackgroundColor:[UIColor colorWithHexString:@"5f5d5e"]];
    [seperator addSubview:bottom];
    return seperator;
}

- (void)selectAudio {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView presentAudioPicker];
}

- (void)selectVideo {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView presentVideoPicker];
}

- (void)selectImage {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView presentImagePicker];
}

- (void)handleImage:(NSNotification *)info {
    [imagePickerContainer setHidden:YES];
    
    if ([info.object objectForKey:@"VideoImage"]) {
        // its a video
        [attachedMediaArray addObject:[info.object objectForKey:@"VideoImage"]];
        [attachedMediaOriginalArray addObject:[info.object objectForKey:@"VideoUrl"]];
    }
    
    if ([info.object objectForKey:@"TagNumber"]) {
        NSNumber *tagNumber = [info.object objectForKey:@"TagNumber"];
        int tagInt = tagNumber.intValue;
        UIImage *croppedImage = [[info.object objectForKey:@"CroppedImage"] copy];
        UIImage *originalImage = [[info.object objectForKey:@"OriginalImage"] copy];
        if (99 == tagInt) {
            [attachedMediaArray addObject:croppedImage];
            [attachedMediaOriginalArray addObject:originalImage];
        } else {
            [attachedMediaArray replaceObjectAtIndex:tagNumber.integerValue withObject:croppedImage];
            [attachedMediaOriginalArray replaceObjectAtIndex:tagNumber.integerValue withObject:originalImage];
        }
    }
    
    [self drawAttachedMediaItems];
}

//===========================================================================
// Attached media display
//===========================================================================

- (void)resizeFormScroll {
    float rowNumber = [attachedMediaArray count];
    float height = ceil(rowNumber / 2) * 89;
    
    [self.attachedMediaContainer setFrame:CGRectMake(0, self.attachedMediaContainer.frame.origin.y, self.attachedMediaContainer.frame.size.width, height)];
    if ([attachedMediaArray count] > 0) {
        // also have to move the buttons
        [attachButton setFrame:CGRectMake(frameAttachButton.origin.x, attachedMediaContainer.frame.origin.y + attachedMediaContainer.frame.size.height + 5, frameAttachButton.size.width, frameAttachButton.size.height)];
        [submitButton setFrame:CGRectMake(frameSubmitButton.origin.x, attachedMediaContainer.frame.origin.y + attachedMediaContainer.frame.size.height + 5, frameSubmitButton.size.width, frameSubmitButton.size.height)];
        [imagePickerContainer setFrame:CGRectMake(frameImagePickercontainer.origin.x, attachButton.frame.origin.y - 10 - frameImagePickercontainer.size.height,frameImagePickercontainer.size.width, frameImagePickercontainer.size.height)];
        // resize the from scrolly guy
        [formScroll setContentSize:CGSizeMake(frameFormScroll.size.width, submitButton.frame.origin.y + submitButton.frame.size.height + 10)];
    } else {
        // reset the whole thing
        [formScroll setContentSize:frameFormScroll.size];
        [attachedMediaContainer setFrame:frameAttachedMediaContainer];
        [attachButton setFrame:frameAttachButton];
        [submitButton setFrame:frameSubmitButton];
        [imagePickerContainer setFrame:frameImagePickercontainer];
    }
}

- (void)drawAttachedMediaItems {
    // first remove all of them
    for (UIView *subView in self.attachedMediaContainer.subviews) {
        [subView removeFromSuperview];
    }
    
    // resize the holder
    [self resizeFormScroll];
    
    for (int x = 0; x < [attachedMediaArray count]; x++) {
        if ([[attachedMediaOriginalArray objectAtIndex:x] isKindOfClass:[UIImage class]]) {
            // draw an image
            UIImageView *attachedMediaItem = [self attachedMediaImageHolder:[attachedMediaArray objectAtIndex:x] indexNumber:x];
            
            // now add the recrop image
            UIImage *scaleImage = [UIImage imageNamed:@"crop.png"];
            UIImageView *scaleImageView = [[UIImageView alloc] initWithImage:scaleImage];
            scaleImageView.tag = x;
            [scaleImageView setFrame:CGRectMake(5, attachedMediaItem.frame.size.height - 17, 12, 12)];
            [scaleImageView setUserInteractionEnabled:YES];
            
            UILabel *cropLabel = [[UILabel alloc] init];
            cropLabel.tag = x;
            [cropLabel setText:@"Crop"];
            [cropLabel setTextColor:[UIColor whiteColor]];
            [cropLabel setFrame:CGRectMake(7 + scaleImageView.frame.size.width, attachedMediaItem.frame.size.height - 17, 40, 12)];
            [cropLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12.0]];
            [cropLabel setBackgroundColor:[UIColor clearColor]];
            [cropLabel setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *scaleImageRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(scaleItem:)];
            UITapGestureRecognizer *scaleLabelRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(scaleItem:)];
            
            [scaleImageView addGestureRecognizer:scaleImageRecognizer];
            [cropLabel addGestureRecognizer:scaleLabelRecognizer];
            
            [attachedMediaItem addSubview:cropLabel];
            [attachedMediaItem addSubview:scaleImageView];
        }
        if ([[attachedMediaOriginalArray objectAtIndex:x] isKindOfClass:[NSURL class]]) {
            // draw an image
            UIImageView *attachedMediaItem = [self attachedMediaImageHolder:[attachedMediaArray objectAtIndex:x] indexNumber:x];
            // add the video button overlay
            [self createImageOverlay:@"btn-play-video.png" imageParent:attachedMediaItem];
        }
    }
    
}

- (UIImageView *)attachedMediaImageHolder:(UIImage *)image indexNumber:(int)index {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    // total width = 275
    // if we make the gap 9
    // leaves us with 266
    // width of 133
    // height of 80
    
    CGRect frame;
    float x = 0; // 142
    float y = 0; // height + 5
    int width = 133; // 520
    int height = 80; // 311
    float rowNumber = 0;
    
    index++;
    if (index % 2 == 0) {
        x = 142;
    }
    
    index--;
    rowNumber = index;
    rowNumber = floor(rowNumber / 2);
    y = rowNumber * (height + 5);
    
    frame = CGRectMake(x, y, width, height);
    [imageView setFrame:frame];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setBackgroundColor:[UIColor lightGrayColor]];
    
    // now add the delete button
    UIImage *deleteImage = [UIImage imageNamed:@"attachment_close_btn.png"];
    UIImageView *deleteImageView = [[UIImageView alloc] initWithImage:deleteImage];
    [deleteImageView setFrame:CGRectMake(frame.size.width - 27.5, 5, 22.5, 24)];
    deleteImageView.tag = index;
    [deleteImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *delRecognizer = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(deleteItem:)];
    [deleteImageView addGestureRecognizer:delRecognizer];
    [imageView addSubview:deleteImageView];
    
    [imageView setUserInteractionEnabled:YES];
    [self.attachedMediaContainer addSubview:imageView];
    
    return imageView;
}

- (void)createImageOverlay:(NSString*)overlayImage imageParent:(UIImageView*)iName {
    UIImage *image = [UIImage imageNamed:overlayImage];
    float x = (iName.frame.size.width / 2) - image.size.width;
    float y = (iName.frame.size.height / 2) - image.size.height;
    UIImageView *imgVwForButton = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, image.size.width, image.size.height)];
    [imgVwForButton setContentMode:UIViewContentModeCenter];
    [imgVwForButton setImage:image];
    [iName addSubview:imgVwForButton];
}

- (void)deleteItem:(UITapGestureRecognizer *)sender {
    [attachedMediaArray removeObjectAtIndex:sender.view.tag];
    [attachedMediaOriginalArray removeObjectAtIndex:sender.view.tag];
    [self drawAttachedMediaItems];
}

- (void)scaleItem:(UITapGestureRecognizer *)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView recropImage:[attachedMediaOriginalArray objectAtIndex:sender.view.tag] tagNumber:sender.view.tag];
}

//===========================================================================
// Text View protocol methods
//===========================================================================

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([storyText.text isEqualToString:@"Tell us your story*"]) {
        storyText.text = @"";
        [storyText setTextColor:[UIColor blackColor]];
    }
    [textView becomeFirstResponder];
    [formScroll setContentOffset:CGPointMake(0, titleText.frame.origin.y - 5) animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([storyText.text isEqualToString:@""]) {
        [storyText setTextColor:placeholderColor];
        storyText.text = @"Tell us your story*";
    }
    [storyText resignFirstResponder];
}

//===========================================================================
// Text Field protocol methods
//===========================================================================

// This helps position the form so that what you are editing is not underneath the keyboard
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    int scrollTo = 0;
    if ([textField isEqual:nameText]) {
        scrollTo = nameText.frame.origin.y - nameText.frame.size.height;
    }
    if ([textField isEqual:emailText]) {
        scrollTo = nameText.frame.origin.y;
    }
    if ([textField isEqual:titleText]) {
        scrollTo = emailText.frame.origin.y;
    }
    [formScroll setContentOffset:CGPointMake(0, scrollTo - 5) animated:YES];
}

// This manages the done button. Makes the focus jump to the next field
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:nameText]) {
        [emailText becomeFirstResponder];
    }
    if ([textField isEqual:emailText]) {
        [titleText becomeFirstResponder];
    }
    if ([textField isEqual:titleText]) {
        [storyText becomeFirstResponder];
    }
    return false;
}

-(void)keyboardHandler:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    currentKeyboardHeight = kbSize.height;
    
    [formScroll setContentSize:CGSizeMake(formScroll.frame.size.width, formScroll.frame.size.height + currentKeyboardHeight)];
    
    if([[notification name] isEqualToString:UIKeyboardWillHideNotification]) {
        // hide the keyboard
        [formScroll setContentOffset:CGPointMake(0, 0) animated:YES];
        [self resizeFormScroll];
    } else {
        [imagePickerContainer setHidden:YES];
    }
}

//===========================================================================
// AWS Submission
//===========================================================================

- (void)submitFilesToAws {
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAIXVFYSCOCNFYBC3Q" withSecretKey:@"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"];
    
    for (int x = 0; x < [attachedMediaArray count]; x++) {
        
        NSDateFormatter *formatter;
        NSString *dateString;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd_MM_yyyy_HH_mm"];
        dateString = [formatter stringFromDate:[NSDate date]];
        
        if ([[attachedMediaOriginalArray objectAtIndex:x] isKindOfClass:[UIImage class]]) {
            UIImage *image = [attachedMediaArray objectAtIndex:x];
            NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image,100)];
            NSString *imageName = [NSString stringWithFormat:@"contribute_ios_image_%d_%@.%@",x , dateString, [self contentTypeForImageData:imageData]];
            [self submitFile:imageData fileName:imageName];
        }
        
        if ([[attachedMediaOriginalArray objectAtIndex:x] isKindOfClass:[NSURL class]]) {
            NSURL *mediaUrl = [attachedMediaOriginalArray objectAtIndex:x];
            NSData *mediaData = [NSData dataWithContentsOfURL:mediaUrl];
            NSString *extension = [mediaUrl pathExtension];
            NSString *videoName = [NSString stringWithFormat:@"contribute_ios_video_%d_%@.%@",x , dateString, extension];
            [self submitFile:mediaData fileName:videoName];
        }
    }
}

- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0x42:
            return @"bmp";
        case 0xFF:
            return @"jpg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
    }
    return nil;
}

- (void)submitFile:(NSData *)fileData fileName:(NSString *)fileName {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:fileName inBucket:@"ewn-apps"];
        por.data = fileData;
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(putObjectResponse.error != nil) {
                DLog(@"Error: %@", putObjectResponse.error);
            } else {
                // get the url!!!
                S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
                S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
                gpsur.key = fileName;
                gpsur.bucket = @"ewn-apps";
                gpsur.responseHeaderOverrides = override;
                gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600 * 24 * 7]; // 1 week
                NSURL *url = [self.s3 getPreSignedURL:gpsur];
                NSString *urlString = [NSString stringWithFormat:@"%@%@%@",@"<![CDATA[",[url absoluteString],@"]]>"];
                NSString *contributeFileMessage = [NSString stringWithFormat:kRequestContributeFile,urlString,self.contributeKey];
                [[WebserviceComunication sharedCommManager] submitContributeFile:contributeFileMessage];
            }
        });
    });
}

@end
