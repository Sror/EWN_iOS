/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2010, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
     list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation and/or
     other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
     contributors may be used to endorse or promote products derived from this
     software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 File:   JRUserLandingController.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "JRUserLandingController.h"
#import "JREngage+CustomInterface.h"
#import "JREngageError.h"
#import "JRUserInterfaceMaestro.h"
#import "JRWebViewController.h"
#import "debug_log.h"

#define frame_w(a) a.frame.size.width
#define frame_h(a) a.frame.size.height

@implementation JRUserLandingController
@synthesize myBackgroundView;
@synthesize myTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
   andCustomInterface:(NSDictionary *)theCustomInterface
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        sessionData = [JRSessionData jrSessionData];
        customInterface = theCustomInterface;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            iPad = YES;
        else
            iPad = NO;
    }

    return self;
}

- (void)viewDidLoad
{
    DLog(@"");
    [super viewDidLoad];

    myTableView.backgroundColor = [UIColor clearColor];

    /* If there is a UIColor object set for the background color, use this */
    if ([customInterface objectForKey:kJRAuthenticationBackgroundColor])
        myBackgroundView.backgroundColor = [customInterface objectForKey:kJRAuthenticationBackgroundColor];

    /* Weird hack necessary on the iPad, as the iPad table views have some background view that is always gray */
    if ([myTableView respondsToSelector:@selector(setBackgroundView:)])
        [myTableView setBackgroundView:nil];

    if (!infoBar)
    {
        infoBar = [[JRInfoBar alloc] initWithFrame:CGRectMake(0, frame_h(self.view) - 30, frame_w(self.view), 30)
                                          andStyle:((JRInfoBarStyle) [sessionData hidePoweredBy])];

        [self.view addSubview:infoBar];
    }

    if (!self.navigationController.navigationBar.backItem)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                     target:sessionData
                                     action:@selector(triggerAuthenticationDidCancel:)];

        self.navigationItem.rightBarButtonItem = cancelButton;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
    }
    else
    {
        self.navigationItem.backBarButtonItem.target = sessionData;
        self.navigationItem.backBarButtonItem.action = @selector(triggerAuthenticationDidStartOver:);
    }
}

- (NSString *)customTitle
{
    DLog(@"");
    if (!sessionData.currentProvider.requiresInput) return @"Welcome Back!";

    return sessionData.currentProvider.shortText;
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog(@"");
    [super viewWillAppear:animated];

    /* Load the custom background view, if there is one. */
    if ([customInterface objectForKey:kJRAuthenticationBackgroundImageView])
        [myBackgroundView addSubview:[customInterface objectForKey:kJRAuthenticationBackgroundImageView]];

    if (!sessionData.currentProvider)
    {
        NSString *message = @"There was an error authenticating with the selected provider.";
        NSError *error = [JREngageError errorWithMessage:message andCode:JRAuthenticationFailedError];
        [sessionData triggerAuthenticationDidFailWithError:error];

        return;
    }

    self.title = [self customTitle];

    if (titleView) {
        titleView.text = [NSString stringWithString:sessionData.currentProvider.friendlyName];
        self.navigationItem.titleView = titleView;
    } else {
        self.navigationItem.title = [NSString stringWithString:sessionData.currentProvider.friendlyName];
    }

    [myTableView reloadData];
    [self adjustTableViewFrame];
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"");
    [super viewDidAppear:animated];

    self.contentSizeForViewInPopover = self.view.frame.size;

    UITableViewCell *cell = [self getTableCell];
    UITextField *textField = [self getTextField:cell];

    // Only make the cell's text field the first responder (and show the keyboard) in certain situations
    if ([sessionData weShouldBeFirstResponder] && !textField.text)
        [textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DLog(@"");
    [super viewWillDisappear:animated];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

enum
{
    LOGO_TAG = 1,
    WELCOME_LABEL_TAG,
    TEXT_FIELD_TAG,
    SIGN_IN_BUTTON_TAG,
    BACK_TO_PROVIDERS_BUTTON_TAG,
    BIG_SIGN_IN_BUTTON_TAG
};

#define LOGO_FRAME                      10,     10,     280,    65
#define WELCOME_LABEL_FRAME             10,     90,     280,    25
#define TEXT_FIELD_FRAME                10,     85,     280,    35
#define BUTTON_SUBVIEW_FRAME            10,     130,    280,    40
#define BIG_SIGN_IN_BUTTON_FRAME        0,      0,      280,    40
#define BACK_TO_PROVIDERS_BUTTON_FRAME  0,      0,      135,    40
#define SMALL_SIGN_IN_BUTTON_FRAME      145,    0,      135,    40

- (UITableViewCell *)getTableCell
{
    return [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (UIImageView *)getLogo:(UITableViewCell *)cell
{
    if (cell)
        return (UIImageView *) [cell.contentView viewWithTag:LOGO_TAG];

    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(LOGO_FRAME)];

    logo.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleLeftMargin;

    logo.tag = LOGO_TAG;

    return logo;
}

- (UILabel *)getWelcomeLabel:(UITableViewCell *)cell
{
    if (cell)
        return (UILabel *) [cell.contentView viewWithTag:WELCOME_LABEL_TAG];

    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(WELCOME_LABEL_FRAME)];

    welcomeLabel.font = [UIFont boldSystemFontOfSize:20.0];

    welcomeLabel.adjustsFontSizeToFitWidth = YES;
    welcomeLabel.textColor = [UIColor blackColor];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleLeftMargin;

    welcomeLabel.tag = WELCOME_LABEL_TAG;

    return welcomeLabel;
}

- (UITextField *)getTextField:(UITableViewCell *)cell
{
    if (cell)
        return (UITextField *) [cell.contentView viewWithTag:TEXT_FIELD_TAG];

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(TEXT_FIELD_FRAME)];

    textField.font = [UIFont systemFontOfSize:15.0];

    textField.adjustsFontSizeToFitWidth = YES;
    textField.textColor = [UIColor blackColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearsOnBeginEditing = YES;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.keyboardType = UIKeyboardTypeURL;
    textField.returnKeyType = UIReturnKeyDone;
    textField.enablesReturnKeyAutomatically = YES;
    textField.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleLeftMargin;

    textField.delegate = self;
    textField.tag = TEXT_FIELD_TAG;

    [textField setHidden:YES];

    return textField;
}

- (UIButton *)getSignInButton:(UITableViewCell *)cell
{
    if (cell)
        return (UIButton *) [cell.contentView viewWithTag:SIGN_IN_BUTTON_TAG];

    UIButton *signInButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [signInButton setFrame:CGRectMake(SMALL_SIGN_IN_BUTTON_FRAME)];
    [signInButton setBackgroundImage:[UIImage imageNamed:@"button_iosblue_135x40.png"]
                            forState:UIControlStateNormal];

    [signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [signInButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [signInButton setTitleShadowColor:[UIColor grayColor]
                             forState:UIControlStateNormal];

    [signInButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];

    [signInButton addTarget:self
                     action:@selector(signInButtonTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];

    signInButton.tag = SIGN_IN_BUTTON_TAG;

    return signInButton;
}

- (UIButton *)getBackToProvidersButton:(UITableViewCell *)cell
{
    if (cell)
        return (UIButton *) [cell.contentView viewWithTag:BACK_TO_PROVIDERS_BUTTON_TAG];

    UIButton *backToProvidersButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [backToProvidersButton setFrame:CGRectMake(BACK_TO_PROVIDERS_BUTTON_FRAME)];
    [backToProvidersButton setBackgroundImage:[UIImage imageNamed:@"button_black_135x40.png"]
                                     forState:UIControlStateNormal];

    [backToProvidersButton setTitle:@"Switch Accounts" forState:UIControlStateNormal];
    [backToProvidersButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateNormal];
    [backToProvidersButton setTitleShadowColor:[UIColor grayColor]
                                      forState:UIControlStateNormal];

    [backToProvidersButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];

    [backToProvidersButton addTarget:self
                              action:@selector(backToProvidersTouchUpInside)
                    forControlEvents:UIControlEventTouchUpInside];

    backToProvidersButton.tag = BACK_TO_PROVIDERS_BUTTON_TAG;

    return backToProvidersButton;
}

- (UIButton *)getBigSignInButton:(UITableViewCell *)cell
{
    if (cell)
        return (UIButton *) [cell.contentView viewWithTag:BIG_SIGN_IN_BUTTON_TAG];

    UIButton *bigSignInButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [bigSignInButton setFrame:CGRectMake(BIG_SIGN_IN_BUTTON_FRAME)];
    [bigSignInButton setBackgroundImage:[UIImage imageNamed:@"button_iosblue_280x40.png"]
                               forState:UIControlStateNormal];

    [bigSignInButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [bigSignInButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
    [bigSignInButton setTitleShadowColor:[UIColor grayColor]
                                forState:UIControlStateNormal];

    [bigSignInButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];

    [bigSignInButton addTarget:self
                        action:@selector(signInButtonTouchUpInside:)
              forControlEvents:UIControlEventTouchUpInside];

    [bigSignInButton setHidden:YES];

    bigSignInButton.tag = BIG_SIGN_IN_BUTTON_TAG;
    return bigSignInButton;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"");

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cachedCell"];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cachedCell"];

        [cell.contentView setFrame:CGRectMake(10, 0, 300, 180)];

        UIView *buttonSubview = [[UIView alloc] initWithFrame:CGRectMake(BUTTON_SUBVIEW_FRAME)];

        [buttonSubview setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
                UIViewAutoresizingFlexibleLeftMargin];

        [buttonSubview addSubview:[self getSignInButton:nil]];
        [buttonSubview addSubview:[self getBackToProvidersButton:nil]];
        [buttonSubview addSubview:[self getBigSignInButton:nil]];

        [cell.contentView addSubview:[self getLogo:nil]];
        [cell.contentView addSubview:[self getWelcomeLabel:nil]];
        [cell.contentView addSubview:[self getTextField:nil]];

        [cell.contentView addSubview:buttonSubview];

        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSString *imagePath = [NSString stringWithFormat:@"logo_%@_280x65.png", sessionData.currentProvider.name];

    [self getLogo:cell].image = [UIImage imageNamed:imagePath];

    UITextField *textField = [self getTextField:cell];
    UIButton *bigSignInButton = [self getBigSignInButton:cell];
    UILabel *welcomeLabel = [self getWelcomeLabel:cell];

    /* If the provider requires input, we need to enable the textField, and set the text/placeholder text to the
    appropriate string */
    if (sessionData.currentProvider.requiresInput)
    {
        DLog(@"current provider requires input");

        if (sessionData.currentProvider.userInput)
        {
            [textField resignFirstResponder];
            [textField setText:[NSString stringWithString:sessionData.currentProvider.userInput]];
        }
        else
        {
            [textField setText:nil];
        }

        textField.placeholder = [NSString stringWithString:sessionData.currentProvider.placeholderText];

        [textField setHidden:NO];
        [textField setEnabled:YES];
        [welcomeLabel setHidden:YES];
        [bigSignInButton setHidden:NO];
    }
    else
    {
        /* If the provider doesn't require input, then we are here because this is the return experience screen and
        only for basic providers */
        DLog(@"current provider does not require input");

        [textField setHidden:YES];
        [textField setEnabled:NO];
        [welcomeLabel setHidden:NO];
        [bigSignInButton setHidden:YES];

        welcomeLabel.text = [sessionData authenticatedUserForProvider:sessionData.currentProvider].welcomeString;
    }

    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL b;
    if ([JRUserInterfaceMaestro sharedMaestro].canRotate)
        b = interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    else
        b = interfaceOrientation == UIInterfaceOrientationPortrait;
    DLog(@"%d", b);
    return b;
}

#define TABLE_VIEW_FRAME_LANDSCAPE_SMALL    0,  0,  self.view.frame.size.width,  120
#define TABLE_VIEW_FRAME_LANDSCAPE_BIG      0,  0,  self.view.frame.size.width,  268
// TABLE_VIEW_FRAME_PORTRAIT seems OK on 4" iPhone despite screen specific 416px spec
#define TABLE_VIEW_FRAME_PORTRAIT           0,  0,  self.view.frame.size.width,  416

- (void)shrinkTableViewLandscape
{
    [myTableView setFrame:CGRectMake(TABLE_VIEW_FRAME_LANDSCAPE_SMALL)];
    [myTableView scrollRectToVisible:CGRectMake(BUTTON_SUBVIEW_FRAME) animated:YES];
}

- (void)growTableViewLandscape
{
    [myTableView setFrame:CGRectMake(TABLE_VIEW_FRAME_LANDSCAPE_BIG)];
}

- (void)growTableViewPortrait
{
    [myTableView setFrame:CGRectMake(TABLE_VIEW_FRAME_PORTRAIT)];
}

- (void)adjustTableViewFrame
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && !iPad)
    {
        if ([[self getTextField:[self getTableCell]] isFirstResponder])
            [self shrinkTableViewLandscape];
        else
            [self growTableViewLandscape];
    }
    else
    {
        [self growTableViewPortrait];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self adjustTableViewFrame];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"");
    [self callWebView:textField];

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    DLog(@"");
    [self adjustTableViewFrame];
}

- (void)callWebView:(UITextField *)textField
{
    DLog(@"");
    DLog(@"user input: %@", textField.text);
    if (sessionData.currentProvider.requiresInput)
    {
        if (textField.text.length > 0)
        {
            [textField resignFirstResponder];
            [self adjustTableViewFrame];

            sessionData.currentProvider.userInput = [NSString stringWithString:textField.text];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input"
                                                             message:@"The input you have entered is not valid. Please "
                                                                     "try again."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
            return;
        }
    }

    [[JRUserInterfaceMaestro sharedMaestro] pushWebViewFromViewController:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DLog(@"");
    [textField resignFirstResponder];
    [self adjustTableViewFrame];
}

- (void)backToProvidersTouchUpInside
{
    DLog(@"");

    /* This should work, because this button will only be visible during the return experience of a basic provider */
    [sessionData forgetAuthenticatedUserForProvider:sessionData.currentProvider.name];

    [sessionData setCurrentProvider:nil];
    [sessionData clearReturningAuthenticationProvider];

    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)signInButtonTouchUpInside:(UIButton *)button
{
    DLog(@"");
    [self callWebView:[self getTextField:[self getTableCell]]];
}

- (void)userInterfaceWillClose
{
}

- (void)userInterfaceDidClose
{
}

- (void)dealloc
{
    DLog(@"");


}
@end
