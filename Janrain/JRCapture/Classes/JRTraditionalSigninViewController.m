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

 File:   EmbeddedNativeSignInViewController.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, June 1, 2010
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "JRCaptureApidInterface.h"
#import "JRTraditionalSigninViewController.h"
#import "JREngage.h"
#import "JREngageWrapper.h"
#import "JRUserInterfaceMaestro.h"
#import "JRCaptureData.h"
#import "JRCapture.h"

typedef enum
{
    JRIncorrectUserOrPasswordAlertViewTag,
    JRForgotPasswordAlertViewTag
} JRUIViewTag;

@interface JREngageWrapper (JREngageWrapper_InternalMethods)
- (void)authenticationDidReachTokenUrl:(NSString *)tokenUrl withResponse:(NSURLResponse *)response
                            andPayload:(NSData *)tokenUrlPayload forProvider:(NSString *)provider;
@end

@interface JRTraditionalSignInViewController () <JRCaptureInternalDelegate, UIAlertViewDelegate,  JRCaptureDelegate>
@property (retain) NSString *titleString;
@property (retain) UIView   *titleView;
@property JRTraditionalSignInType signInType;
@property (retain) JREngageWrapper *wrapper;
@end

@implementation JRTraditionalSignInViewController
@synthesize signInType;
@synthesize titleString;
@synthesize titleView;
@synthesize wrapper;
@synthesize delegate;
@synthesize firstResponder;

- (id)initWithTraditionalSignInType:(JRTraditionalSignInType)theSignInType titleString:(NSString *)theTitleString
                          titleView:(UIView *)theTitleView
                      engageWrapper:(JREngageWrapper *)theWrapper
{
    if ((self = [super init]))
    {
        signInType = theSignInType;
        titleString = [theTitleString retain];
        titleView = [theTitleView retain];
        wrapper = [theWrapper retain];
    }

    return self;
}

+ (id)traditionalSignInViewController:(JRTraditionalSignInType)theSignInType titleString:(NSString *)theTitleString
                            titleView:(UIView *)theTitleView engageWrapper:(JREngageWrapper *)theWrapper
{
    return [[[JRTraditionalSignInViewController alloc]
            initWithTraditionalSignInType:theSignInType
                              titleString:theTitleString
                                titleView:theTitleView engageWrapper:theWrapper] autorelease];
}

- (void)loadView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 170) style:UITableViewStyleGrouped];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.scrollEnabled   = NO;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [button setFrame:CGRectMake(10, 2, 300, 40)];
    [button setBackgroundImage:[UIImage imageNamed:@"button_janrain_280x40.png"]
                      forState:UIControlStateNormal];

    [button setTitle:@"Sign In" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];

    button.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];

    [button addTarget:self
               action:@selector(signInButtonTouchUpInside:)
     forControlEvents:UIControlEventTouchUpInside];

    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    [footerView addSubview:button];

    myTableView.tableFooterView = footerView;
    myTableView.dataSource = self;
    myTableView.delegate = self;

    self.view = myTableView;

    [self.view setClipsToBounds:NO];

//    [self createLoadingView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [myTableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.titleView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.titleString;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (titleView)
        return titleView.frame.size.height;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return 40;
    } else {
        return 25;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

#define  NAME_TEXTFIELD_TAG 1000
#define  PWD_TEXTFIELD_TAG 2000

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    UITextField *textField;

    NSString *const cellId = indexPath.row == 0 ? @"cellForName" : @"cellForPwd";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];

        textField = [[[UITextField alloc] initWithFrame:CGRectMake(10, 7, 280, 26)] autorelease];

        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;

        [cell.contentView addSubview:textField];

        if (indexPath.row == 0)
        {
            NSString *const placedHolder = self.signInType == JRTraditionalSignInEmailPassword ?
                    @"Enter your email" :
                    @"Enter your username";
            textField.placeholder = placedHolder;
            textField.delegate = self;
            textField.tag = NAME_TEXTFIELD_TAG;
        }
        else
        {
            textField.placeholder = @"Enter your password";
            textField.secureTextEntry = YES;

            textField.delegate = self;
            textField.tag = PWD_TEXTFIELD_TAG;
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.firstResponder = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.firstResponder = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)signInButtonTouchUpInside:(UIButton*)button
{
    UITableViewCell *nameCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *pwdCell  = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSString *user = ((UITextField *) [nameCell viewWithTag:NAME_TEXTFIELD_TAG]).text;
    NSString *password = ((UITextField *) [pwdCell viewWithTag:PWD_TEXTFIELD_TAG]).text;
    if (!user) user = @"";
    if (!password) password = @"";

    NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:user, @"user",
                                                                           password, @"password", nil];

    [JRCaptureApidInterface signInCaptureUserWithCredentials:credentials forDelegate:self withContext:nil];

    [self.firstResponder resignFirstResponder];
    [self setFirstResponder:nil];

    [delegate showLoading];
}

- (void)signInCaptureUserDidSucceedWithResult:(NSString *)result context:(NSObject *)context
{
    [delegate hideLoading];

    [wrapper authenticationDidReachTokenUrl:@"/oath/auth_native_traditional" withResponse:nil
                                 andPayload:[result dataUsingEncoding:NSUTF8StringEncoding] forProvider:nil];

    [delegate authenticationDidComplete];
}

- (void)signInCaptureUserDidFailWithResult:(NSError *)error context:(NSObject *)context
{
    DLog(@"error: %@", [error description]);
    NSString const *type = self.signInType == JRTraditionalSignInEmailPassword ? @"Email" : @"Username";
    NSString *title = [NSString stringWithFormat:@"Incorrect %@ or Password", type];
    //NSString *const message = [result objectForKey:@"error"];
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title
                                                         message:nil // MOB-73
                                                        delegate:self
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:@"Forgot Password", nil] autorelease];
    alertView.tag = JRIncorrectUserOrPasswordAlertViewTag;
    [alertView show];

    [delegate hideLoading];
    // XXX hack to skirt the side effects thrown off by the client's sign-in APIs:
    [JREngage updateTokenUrl:[JRCaptureData captureTokenUrlWithMergeToken:nil delegate:self]];
}

- (void)showForgottenPasswordAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Your Email Address"
                                                        message:@"We'll send you a link to create a new password."
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Send", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = JRForgotPasswordAlertViewTag;

    UITableViewCell *nameCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *nameOrEmail = ((UITextField *) [nameCell viewWithTag:NAME_TEXTFIELD_TAG]).text;

    if (nameOrEmail && ![nameOrEmail isEqualToString:@""]) {
        [alertView textFieldAtIndex:0].text = nameOrEmail;
    } else {
        JRCaptureData *data = [JRCaptureData sharedCaptureData];
        NSString *fieldName = [data getForgottenPasswordFieldName];
        NSDictionary *field = [[data.captureFlow objectForKey:@"fields"] objectForKey:fieldName];
        NSString *placeholder = [field objectForKey:@"placeholder"];
        if (!placeholder) placeholder =  self.signInType == JRTraditionalSignInEmailPassword ? @"email" : @"username";

        [alertView textFieldAtIndex:0].placeholder = [NSString stringWithFormat:@"Enter your %@", placeholder];
    }

    [alertView show];
    [alertView autorelease];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == JRIncorrectUserOrPasswordAlertViewTag && buttonIndex == 1) {
        [self showForgottenPasswordAlert];
    } else if (alertView.tag == JRForgotPasswordAlertViewTag && buttonIndex == 1) {
        [delegate showLoading];
        [JRCapture startForgottenPasswordRecoveryForField:[alertView textFieldAtIndex:0].text
                                               recoverUri:nil delegate:self];
    }
}

- (void)forgottenPasswordRecoveryDidSucceed
{
    [delegate hideLoading];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset Password email Sent" message:@"" delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
    [alertView autorelease];
}

- (void)forgottenPasswordRecoveryDidFailWithError:(NSError *)error
{
    [delegate hideLoading];
    NSString *errorMessage = [error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could Not Reset Password"
                                                        message:errorMessage delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
    [alertView autorelease];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    } else if (@selector(captureDidSucceedWithCode:) == aSelector) {
        return [[JREngageWrapper getDelegate] respondsToSelector:aSelector];
    }
    return NO;
}

- (void)dealloc
{
    [myTableView release];
    [delegate release];
    [titleView release];
    [titleString release];
    [firstResponder release];

    [wrapper release];
    [super dealloc];
}
@end

