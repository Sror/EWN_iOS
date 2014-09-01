/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2012, Janrain, Inc.

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


 File:   JRCapture.h
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, January 31, 2012
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "JRCaptureTypes.h"
#import "JRCaptureApidInterface.h"

@class JRCaptureUser;
@class JRCaptureConfig;

#define engageSigninDialogDidFailToShowWithError engageAuthenticationDialogDidFailToShowWithError
#define engageSigninDidNotComplete engageAuthenticationDidCancel
#define engageSigninDidSucceedForUser engageAuthenticationDidSucceedForUser

#define captureAuthenticationDidSucceedForUser captureSignInDidSucceedForUser
#define captureAuthenticationDidFailWithError captureSignInDidFailWithError

#define JRCaptureSigninDelegate JRCaptureDelegate
#define JRCaptureSignInDelegate JRCaptureDelegate
#define startEngageSigninForDelegate startEngageSignInForDelegate

#define startEngageSigninDialogForDelegate startEngageSignInDialogForDelegate
#define startEngageSigninDialogOnProvider startEngageSignInDialogOnProvider
#define startCaptureConventionalSigninForUser startCaptureTraditionalSignInForUser
#define startEngageSignInDialogWithConventionalSignIn startEngageSignInDialogWithTraditionalSignIn
#define startEngageSigninDialogWithConventionalSignin startEngageSignInDialogWithTraditionalSignIn
#define withSigninType withSignInType

#define startCaptureConventionalSignInForUser startCaptureTraditionalSignInForUser

/**
 * @mainpage Janrain Capture for iOS
 *
 * <a href="http://developers.janrain.com/documentation/mobile-libraries/">
 * The Janrain User Management Platform (JUMP) for iOS</a> makes it easy to include third party authentication
 * <!--and sharing--> in your iPhone or iPad applications.  This Objective-C library includes the same key
 * features as our web version, as well as additional features created specifically for the mobile
 * platform. With Capture integration, you can create, authenticate, and update Capture user records.
 *
 * Your iOS application is unique, and so is the user-specific data you wish to collect. You can customize your Capture
 * instance, by changing your schema, to meet your application’s data needs. JUMP for iOS includes a Perl script which
 * processes your schema and generates Objective-C classes that represent your Capture user model and update themselves
 * on the Capture server.
 *
 * This library enables you to authenticate your users and seamlessly store a wealth of customized data on our
 * cloud-hosted database, both social profile data collected at sign-in as well as the users’ application-specific data
 * collected as they use your application.
 *
 * For directions on doing so, please see <a href="http://TODO">
 *   the Capture for iOS guide</a>
 * on our <a href="http://developers.janrain.com/documentation/mobile-libraries/">developers portal</a>.
 *
 * Before you begin, you need to have created a
 * <a href="https://rpxnow.com/signup_createapp_plus">Janrain Engage application</a>,
 * which you can do on <a href="http://rpxnow.com">http://rpxnow.com</a>
 *
 * Beyond what is needed for Engage for iOS, you will also need:
 *     - A Janrain Capture application, and your Capture APID domain, Capture UI domain, a Client ID, and Capture
 *       entity type name. Contact your deployment engineer for these details.
 *     - Your Capture schema. You can download this from the Capture dashboard, or contact your deployment engineer
 *       for a copy.
 *     - Perl and the JSON-2.53+ module. This is used to generate your Capture user record class structure from your
 *       schema.
 *
 * Some of the code must be generated from your Capture schema. You can easily generate the code yourself, using a
 * script provided with the JUMP library, or the generated code may have been provided to you by your
 * Janrain Deployment Engineer.
 *
 * It is best to <a href="http://TODO">
 *   generate</a> the code before adding the JUMP library to your Xcode project, but, if need be, you can
 * always <a href="http://TODO">
 *   add it later</a>.
 *
 * For an overview of how the library works and how you can take advantage of the library's
 * features, please see the <a href="http://TODO">
 *   Overview</a> section of our documentation.
 *
 * To begin using the SDK, please see the <a href="http://TODO">
 * Capture for iOS guide</a>.
 *
 * For more detailed documentation of the library's API, you can use
 * the <a href="http://janrain.github.com/jump.ios/gh_docs/engage/html/index.html">
 *   JREngage API</a> or <a href="http://janrain.github.com/jump.ios/gh_docs/capture/html/index.html">
 *   JRCapture API</a> documentation.
 **/

/**
 * @file
 * Main API for interacting with the Janrain Capture for iOS library
 *
 * If you wish to include third party authentication <!--and sharing--> in your iPhone or iPad
 * applications, you can use the JRCapture class to achieve this.
 **/

@class JRActivityObject;

/**
 * @brief
 * Protocol adopted to receive notifications when, and information about, a user that signs in to your application.
 *
 * This protocol will notify the delegate when authentications succeed or fail; it will provide the delegate
 * with the authenticated user's profile data as returned from the Engage and Capture servers.
 **/
@protocol JRCaptureDelegate <NSObject>
@optional
/**
 * @name Configuration
 * Messages sent by JRCapture during dialog launch/configuration of the Engage for iOS portion of the library
 **/
/*@{*/
/**
 * Sent if the application tries to show the Engage for iOS dialog and the dialog failed to show.  May
 * occur if the \c JREngage library failed to configure, or if the dialog is already being displayed, etc.
 *
 * @param error
 *   The error that occurred during configuration. Please see the list of \ref captureErrors "Capture Errors" and
 *   <a href="http://janrain.github.com/jump.ios/gh_docs/engage/html/group__engage_errors.html">Engage Errors</a>
 *   for more information
 *
 * @note
 * This message is only sent if your application tries to show a Engage for iOS dialog, and not necessarily
 * when an error occurs, if, say, the error occurred during the library's configuration. The reason
 * is based on the possibility that your application may preemptively configure Capture and Engage, but never
 * actually use it. If that is the case, then you won't get any error.
 **/
- (void)engageAuthenticationDialogDidFailToShowWithError:(NSError *)error;
/*@}*/

/**
 * @name Authentication
 * Messages sent by JRCapture during authentication
 **/
/*@{*/
/**
 * Sent if the authentication was canceled. I.e. the user hits the "Cancel" button, or the cancelAuthentication
 * message, is received.
 **/
- (void)engageAuthenticationDidCancel;

/**
 * The first message you will receive when Engage authentication has completed with the given provider. At this point,
 * the library will close the dialog and then complete authentication headlessly on Capture. This notification will
 * contain limited data which you can use to update the UI while you wait for Capture to complete authentication.
 *
 * @param engageAuthInfo
 *   An \e NSDictionary of fields containing all the information returned to Janrain Engage from the provider.
 *   Includes the field \c "profile" which contains the user's profile information. This information will be added
 *   to the Capture record once authentication reaches the Capture server.
 *
 * @param provider
 *   The name of the provider on which the user authenticated. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 *
 * @par Example:
 *   The structure of the auth_info dictionary (represented here in json) should look something like
 *   the following:
 * @code
 "auth_info":
 {
   "profile":
   {
     "displayName": "brian",
     "preferredUsername": "brian",
     "url": "http://brian.myopenid.com/",
     "providerName": "Other",
     "identifier": "http://brian.myopenid.com/"
   }
 }
 * @endcode
 *
 * @sa
 * For a full description of the dictionary and its fields, please see the
 * <a href="http://developers.janrain.com/documentation/api/auth_info/">auth_info response</a>
 * section of the Janrain Engage API documentation.
 *
 * @note
 * The information in the engageAuthInfo dictionary will be added to the Capture record once authentication reaches
 * the Capture server. It is returned at this step for your information only. You do not need to do anything with this
 * data accept perhaps update the UI while your user is waiting for authentication to complete.
 *
 * @note
 * If your user signs in to your server directly (traditional sign-in), this message is not sent to your delegate.
 **/
- (void)engageAuthenticationDidSucceedForUser:(NSDictionary *)engageAuthInfo forProvider:(NSString *)provider;

/**
 * Sent when authentication failed and could not be recovered by the library.
 *
 * @param error
 *   The error that occurred during authentication. Please see the lists of \ref captureErrors "Capture Errors" and
 *   <a href="http://janrain.github.com/jump.ios/gh_docs/engage/html/group__engage_errors.html">Engage Errors</a>
 *   for more information
 *
 * @param provider
 *   The name of the provider on which the user tried to authenticate. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 *
 * @note
 * This message is not sent if authentication was canceled. To be notified of a canceled authentication,
 * see engageSignInDidCancel
 **/
- (void)engageAuthenticationDidFailWithError:(NSError *)error forProvider:(NSString *)provider;

/**
 * Sent after authentication has successfully reached the Capture server. Capture will attempt to sign the user in,
 * using the rich data available from the provider, and send back a Capture user record and JRCaptureRecordStatus
 * indicating the result. One of three results will occur:
 *       - Returning User — The user’s record already exists on the Capture server. The record is retrieved from the
 *         Capture server and passed back to your application.
 *       - New User, Record Created — The user’s record does not already exist on the Capture server, but it is
 *         automatically created and passed back to your application.  Your application may wish to collect additional
 *         information about the user and push that information back to the Capture server.
 *       - New User, Record Not Created* — The user’s record was not automatically created because required information
 *         that was not available in the data returned by the social identity provider. (For example, your Capture
 *         instance may require an email address, but Twitter does not provide an email address, so the record cannot
 *         be automatically created on Capture when the user signs in with Twitter.)  An incomplete user record is
 *         passed back to your application, where it is your application’s responsibility to collect the missing
 *         required data and invoke the user record creation on Capture.
 *             - Your application should present UI to collect the missing information and any additional information
 *               you wish to collect
 *             - Your application should store this information in the user record object returned by Capture
 *             - Once the information is collected, your application needs to invoke record creation on Capture
 *
 * @param captureUser
 *   An object representing the Capture user, containing the data that was retrieved from this user's record on the
 *   Capture server and including the rich data returned from the social provider.
 *
 * @param captureRecordStatus
 *   A JRCaptureRecordStatus indicating the status of the captureUser record.
 *
 * * If your Capture instance does not require information such as an email address, this scenario should not occur.
 **/
- (void)captureSignInDidSucceedForUser:(JRCaptureUser *)captureUser
                                status:(JRCaptureRecordStatus)captureRecordStatus;

/**
 * Sent after authentication has successfully reached the Capture server.
 *
 * @param code
 *   A Capture OAuth Authentication Code, this short lived code can be used to get an Access Token for use with a
 *   server side application like the Capture Drupal plugin.
 */
- (void)captureDidSucceedWithCode:(NSString *)code;

/**
 * Sent when the call to the Capture server has failed.
 *
 * @param error
 *   The error that occurred during Capture authentication. Please see the list of \ref captureErrors "Capture Errors"
 *   for more information
 **/
- (void)captureSignInDidFailWithError:(NSError *)error;

/**
 * Sent when a registration has succeeded
 * @param registeredUser
 *   The newly registered user's model object
 */
- (void)registerUserDidSucceed:(JRCaptureUser *)registeredUser;

/**
 * Sent when a registration has failed
 * @param error
 *   The error causing the failure
 */
- (void)registerUserDidFailWithError:(NSError *)error;

/**
 * Sent when a user profile update has succeeded
 */
- (void)updateUserProfileDidSucceed;

/*
 * Sent when a user profile update has failed
 * @param error
 *   The error causing the failure
 */
- (void)updateUserProfileDidFailWithError:(NSError *)error;

/**
 * Sent when the access token has been successfully refreshed
 * @param context
 *   The context supplied when initiating the token refresh
 */
- (void)refreshAccessTokenDidSucceedWithContext:(id <NSObject>)context;

/**
 * Sent when the access token refresh fails
 * @param error
 *   The error that caused the failure.
 *
 * @param context
 *   The context supplied when initiating the token refresh
 */
- (void)refreshAccessTokenDidFailWithError:(NSError *)error context:(id <NSObject>)context;

/**
 * Sent when the forgotten password recovery flow is successfully initiated
 */
- (void)forgottenPasswordRecoveryDidSucceed;

/**
 * Sent when the forgotten password recovery flow fails
 * @param error
 *   The error that caused the failure.
 */
- (void)forgottenPasswordRecoveryDidFailWithError:(NSError *)error;

/**
 * Sent when resending the email validation email succeeds
 */
- (void)resendVerificationEmailDidSucceed;

/**
 * Sent when resending the email validation email fails
 * @param error
 *    The error that caused the failure.
 */
- (void)resendVerificationEmailDidFailWithError:(NSError *)error;

/**
 * Sent when the Account is Linked Successfully
 */
- (void)linkNewAccountDidSucceed;

/**
 * Sent when the Account linking flow fails
 * @param error
 *   The error that caused the failure.
 */
- (void)linkNewAccountDidFailWithError:(NSError *)error;

/** Sent when the Account unlinking flow succeeds
 
 **/
- (void)accountUnlinkingDidSucceed;

/**
 * Sent when the Account unlinking flow fails
 * @param error
 *   The error that caused the failure.
 */
- (void)accountUnlinkingDidFailWithError:(NSError *)error;

@end

/**
 * @brief
 * Main API for interacting with the Janrain Capture for iOS library
 *
 * If you wish to include third party authentication in your iPhone or iPad
 * applications, you can use the JRCapture class to achieve this.
 **/
@interface JRCapture : NSObject

/**
 * @name Configuration
 * Configure the library with your Capture and Engage applications
 **/
/*@{*/

/**
 * Set the Backplane channel URL to which Capture will post identity/login messages to. For use with third party
 * integrations
 */
+ (void)setBackplaneChannelUrl:(NSString *)backplaneChannelUrl __unused;

/**
 * Method for configuring the library ot work with your Janrain Capture and Engage applications.
 *
 * @param config
 *   An instance of JRCaptureConfig that contains your configuration values.
 */
+ (void)setCaptureConfig:(JRCaptureConfig *)config;

/**
 * Set the Engage app id, this will force Engage to reload it's configuration data
 * @param engageAppId
 *   The new Engage app id
 */
+ (void)reconfigureWithEngageAppId:(NSString *)engageAppId;

/**
 * Set the Capture client id
 * @param captureClientId
 *   The new Capture client id
 */
+ (void)setCaptureClientId:(NSString *)captureClientId;

/**
 * Set the Capture Domain
 * @param captureDomain
 *   The new Capture domain
 */
+ (void)setCaptureDomain:(NSString *)captureDomain;

/**
 * Method for configuring the library to work with your Janrain Capture and Engage applications.
 *
 * @param engageAppId
 *   This is your 20-character application ID for Engage. You can find this on your application's Engage Dashboard
 *   on <a href="http://rpxnow.com">http://rpxnow.com</a>. <em>Please do not use your API key. The API key
 *   should never be stored on the device, in code or otherwise.</em>
 *
 * @param captureDomain
 *   The domain of your Capture app instance (e.g., \@"my-name.janraincapture.com")
 *
 * @param captureClientId
 *   This is your 32-character client ID for Capture. You can find this on your Capture Dashboard
 *   on <a href="http://janraincapture.com">https://janraincapture.com/home</a>. <em>Please do not use your client secret.
 *   The client secret should never be stored on the device, in code or otherwise.</em>
 *
 * @param captureLocale
 *   The locale to use when signing-in, from your Capture flow. Required. Follows ISO locale conventions. This locale
 *   must be defined by your Capture flow in its "translations" data structure.
 *
 * @param captureFlowName
 *   The name of the Capture sign-in flow your users will sign-in with. Optional. Pass nil to have Capture use the
 *   flow specified by the default_flow_name setting for your Capture app, specified in the Capture dashboard.
 *
 * @param captureFlowVersion
 *   Overrides the flow version loaded by the library. Use `nil` to have the library fetch the latest version of the
 *   flow.
 *
 * @param captureTraditionalSignInFormName
 *   The name of the sign-in form in the Capture flow your users will sign-in with. Required. Likely to be "signinForm"
 *
 * @param captureTraditionalSignInType
 *   The type of traditional sign-in your end-users will sign-in with.
 *
 * @param captureEnableThinRegistration
 *   Controls whether or not a social sign-in may result in a thin registration.
 *
 * @param customIdentityProviders
 *   Describes the configuration of custom identity providers. See `Engage Custom Provider Guide.md` for details
 *   configuring custom providers.
 *
 * @param captureTraditionalRegistrationFormName
 *   The name of the form (from your flow) used for traditional registration.
 *
 * @param captureSocialRegistrationFormName
 *   The name of the form (from your flow) used for social registration.
 *
 * @param captureAppId
 *   The application ID of your Capture app. This value can be retrieved from the "Settings" section of your Capture
 *   application's dashboard.
 *
 **/
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
                 captureFlowName:(NSString *)captureFlowName captureFlowVersion:(NSString *)captureFlowVersion
captureTraditionalSignInFormName:(NSString *)captureSignInFormName
    captureTraditionalSignInType:(__unused JRTraditionalSignInType)captureTraditionalSignInType
   captureEnableThinRegistration:(BOOL)enableThinRegistration
               customIdentityProviders:(NSDictionary *)customProviders
captureTraditionalRegistrationFormName:(NSString *)captureTraditionalRegistrationFormName
     captureSocialRegistrationFormName:(NSString *)captureSocialRegistrationFormName
                          captureAppId:(NSString *)captureAppId;

/**
 * @deprecated
 */
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
                 captureFlowName:(NSString *)captureFlowName captureFlowVersion:(NSString *)captureFlowVersion
captureTraditionalSignInFormName:(NSString *)captureSignInFormName
   captureEnableThinRegistration:(BOOL)enableThinRegistration
          captureTraditionalSignInType:(__unused JRTraditionalSignInType)captureTraditionalSignInType
captureTraditionalRegistrationFormName:(NSString *)captureTraditionalRegistrationFormName
     captureSocialRegistrationFormName:(NSString *)captureSocialRegistrationFormName
                          captureAppId:(NSString *)captureAppId __attribute__((deprecated));

/**
 * @deprecated
 */
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
       captureFlowName:(NSString *)captureFlowName
              captureFlowVersion:(NSString *)captureFlowVersion
captureTraditionalSignInFormName:(NSString *)captureSignInFormName
    captureTraditionalSignInType:(__unused JRTraditionalSignInType)captureTraditionalSignInType
                    captureAppId:(NSString *)captureAppId customIdentityProviders:(NSDictionary *)customProviders
__attribute__((deprecated));

/**
 * @deprecated
 */
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
       captureFlowName:(NSString *)captureFlowName
             captureFormName:(NSString *)captureFormName
captureTraditionalSignInType:(JRTraditionalSignInType)captureTraditionalSignInType __attribute__((deprecated));

/**
 * @deprecated
 */
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
             captureFlowName:(NSString *)captureFlowName captureFormName:(NSString *)captureFormName
captureTraditionalSignInType:(JRTraditionalSignInType)captureTraditionalSignInType
     customIdentityProviders:(NSDictionary *)customProviders __attribute__((deprecated));

/**
 * @deprecated
 */
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
       captureFlowName:(NSString *)captureFlowName
 captureSignInFormName:(NSString *)captureFormName
captureEnableThinRegistration:(BOOL)enableThinRegistration
captureTraditionalSignInType:(JRTraditionalSignInType)captureTraditionalSignInType
    captureFlowVersion:(NSString *)captureFlowVersion
captureRegistrationFormName:(NSString *)captureRegistrationFormName
          captureAppId:(NSString *)captureAppId;

/**
 * Set the Capture access token for an authenticated user
 **/
+ (void)setAccessToken:(NSString *)newAccessToken __unused;

/**
 * Get the Capture access token
 */
+ (NSString *)getAccessToken __unused;

/**
 * Sets the "redirect URI" supplied Capture when registering and signing in.
 *
 * This parameter is used by Capture in the email-verification and password-reset emails sent by Capture.
 */
+ (void)setRedirectUri:(NSString *)redirectUri __unused;
/*@}*/

/**
 * @name Sign in with the Engage for iOS dialogs
 * Methods that initiate sign-in through the Engage for iOS dialogs
 **/
/*@{*/
/**
* Begin authentication. The Engage for iOS portion of the library will
* pop up a modal dialog and take the user through the sign-in process.
*
* @param delegate
*   The JRCaptureDelegate object that wishes to receive messages regarding user authentication
**/
+ (void)startEngageSignInDialogForDelegate:(id <JRCaptureDelegate>)delegate __unused;

/**
 * @deprecated
 */
+ (void)startEngageSignInForDelegate:(id <JRCaptureDelegate>)controller __attribute__((deprecated));

/**
 * Begin authentication for one specific provider. The library will
 * pop up a modal dialog, skipping the list of providers, and take the user straight to the sign-in
 * flow of the passed provider. The user will not be able to return to the list of providers.
 *
 * @param provider
 *   The name of the provider on which the user will authenticate. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 **/
+ (void)startEngageSignInDialogOnProvider:(NSString *)provider
                              forDelegate:(id <JRCaptureDelegate>)delegate __unused;

/**
 * Begin authentication. The Engage for iOS portion of the library will
 * pop up a modal dialog and take the user through the sign-in process.
 *
 * @param customInterfaceOverrides
 *   A dictionary of objects and properties, indexed by the set of
 *   \link customInterface pre-defined custom interface keys\endlink, to be used by the library to customize the
 *   look and feel of the user interface and/or add a native login experience
 **/
+ (void)startEngageSignInDialogWithCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                                forDelegate:(id <JRCaptureDelegate>)delegate __unused;

/**
 * Begin authentication for one specific provider. The library will
 * pop up a modal dialog, skipping the list of providers, and take the user straight to the sign-in
 * flow of the passed provider. The user will not be able to return to the list of providers.
 *
 * @param provider
 *   The name of the provider on which the user will authenticate. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 *
 * @param customInterfaceOverrides
 *   A dictionary of objects and properties, indexed by the set of
 *   \link customInterface pre-defined custom interface keys\endlink, to be used by the library to customize the look
 *   and feel of the user interface and/or add a native login experience
 **/
+ (void)startEngageSignInDialogOnProvider:(NSString *)provider
             withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                              forDelegate:(id <JRCaptureDelegate>)delegate __unused;

/**
 * Begin authentication for one specific provider. The library will
 * pop up a modal dialog, skipping the list of providers, and take the user straight to the sign-in
 * flow of the passed provider. The user will not be able to return to the list of providers.
 *
 * @param provider
 *   The name of the provider on which the user will authenticate. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 *
 * @param customInterfaceOverrides
 *   A dictionary of objects and properties, indexed by the set of
 *   \link customInterface pre-defined custom interface keys\endlink, to be used by the library to customize the look
 *   and feel of the user interface and/or add a native login experience
 *
 * @param mergeToken
 *   The merge token, retrieved from the merge flow error instance.
 **/
+ (void)startEngageSignInDialogOnProvider:(NSString *)provider
             withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                               mergeToken:(NSString *)mergeToken
                              forDelegate:(id <JRCaptureDelegate>)delegate;

/**
 * Begin authentication, adding the option for your users to log directly into Capture through
 * your traditional sign-in mechanism. By using this method to initiate sign-in, the library automatically adds
 * a direct login form, above the list of social providers, that allows your users to login with a username/password
 * or email/password combination.
 *
 * @param traditionalSignInType
 *   A JRTraditionalSignInType that tells the library to either prompt the user for their username/password
 *   combination or their email/password combination. This value must match what is configured for your Capture UI
 *   application. If you are unsure which one to use, try one, and if sign-in fails, try the other. If you pass in
 *   JRTraditionalSignInNone, this method will do exactly what the startEngageSignInDialogForDelegate:() method does
 *
 * @note
 * Depending on how your Capture application is configured, you pass to this method a
 * JRTraditionalSignInType of either JRTraditionalSignInUsernamePassword or JRTraditionalSignInEmailPassword.
 * Based on this argument, the dialog will prompt your user to either enter their username or email.
 **/
+ (void)startEngageSignInDialogWithTraditionalSignIn:(JRTraditionalSignInType)traditionalSignInType
                                         forDelegate:(id <JRCaptureDelegate>)delegate __unused;

/**
 * Begin authentication, adding the option for your users to log directly into Capture through
 * your traditional sign-in mechanism. By using this method to initiate sign-in, the library automatically adds
 * a direct login form, above the list of social providers, that allows your users to login with a username/password
 * or email/password combination.
 *
 * @param traditionalSignInType
 *   A JRTraditionalSignInType that tells the library to either prompt the user for their username/password
 *   combination or their email/password combination. This value must match what is configured for your Capture UI
 *   application. If you are unsure which one to use, try one, and if sign-in fails, try the other.
 *
 * @param customInterfaceOverrides
 *   A dictionary of objects and properties, indexed by the set of
 *   \link customInterface pre-defined custom interface keys\endlink, to be used by the library to customize the
 *   look and feel of the user interface and/or add a native login experience
 *
 * @note
 * Depending on how your Capture application is configured, you pass to this method a
 * JRTraditionalSignInType of either JRTraditionalSignInUsernamePassword or JRTraditionalSignInEmailPassword.
 * Based on this argument, the dialog will prompt your user to either enter their username or email.
 **/
+ (void)startEngageSignInDialogWithTraditionalSignIn:(JRTraditionalSignInType)traditionalSignInType
                         andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                         forDelegate:(id <JRCaptureDelegate>)delegate;

/**
 * Signs a user in via traditional (username/email and password) authentication on Capture.
 *
 * Requires that the flow name and Capture app ID be configured.
 *
 * @param user
 *  The username or the email address
 * @param password
 *  The password
 * @param mergeToken
 *  The Engage token to merge with, retrieved from the merge error, or nil for none
 */
+ (void)startCaptureTraditionalSignInForUser:(NSString *)user withPassword:(NSString *)password
                                  mergeToken:(NSString *)mergeToken
                                 forDelegate:(id <JRCaptureDelegate>)delegate;

/**
 * @deprecated
 * Use +[JRCapture startCaptureTraditionalSignInForUser:withPassword:mergeToken:forDelegate:] instead
 */
+ (void)startCaptureTraditionalSignInForUser:(NSString *)user withPassword:(NSString *)password
                              withSignInType:(JRTraditionalSignInType)traditionalSignInTypeSignInType
                                  mergeToken:(NSString *)mergeToken
                                 forDelegate:(id <JRCaptureDelegate>)delegate __attribute__((deprecated));

/**
 * @deprecated
 * Use +[JRCapture startCaptureTraditionalSignInForUser:withPassword:mergeToken:forDelegate:] instead
 */
+ (void)startCaptureTraditionalSignInForUser:(NSString *)user withPassword:(NSString *)password
                              withSignInType:(JRTraditionalSignInType)traditionalSignInTypeSignInType
                                 forDelegate:(id <JRCaptureDelegate>)delegate __attribute__((deprecated));

/**
 * Refreshes the signed-in user's access token
 */
+ (void)refreshAccessTokenForDelegate:(id <JRCaptureDelegate>)delegate context:(id <NSObject>)context __unused;

/**
 * Registers a new user.
 *
 * WARNING: Only attributes that are part of the registration form configured in your Capture flow file are set in the
 *          new user's record. Any other attributes (those that are not part of the registration form) will not be set.
 *
 * @param newUser
 *  The user record with which (and in conjunction with your registration form in accordance with the above warning,)
 *  the new user's Capture record will be created.
 * @param socialRegistrationToken
 *  The registration token, used for two-step social registration. The token may be retrieved from the initial (failed)
 *  social sign-in by retrieving it from the JRCaptureError object returned on the event of that same failure.
 *  If nil then a traditional registration is performed, not a social registration.
 * @param delegate
 *  Your JRCaptureDelegate. This delegate will receive callbacks regarding the success or failure of sign-in
 *  events. (A successful registration is considered a sign-in, and results in a valid client-server session.)
 */
+ (void)registerNewUser:(JRCaptureUser *)newUser socialRegistrationToken:(NSString *)socialRegistrationToken
            forDelegate:(id <JRCaptureDelegate>)delegate __unused;

/**
 * Updates the profile for a given user
 */
+ (void)updateProfileForUser:(JRCaptureUser *)user delegate:(id <JRCaptureDelegate>)delegate;

/**
 * Signs the currently-signed-in user, if any, out.
 */
+ (void)clearSignInState __unused;

/**
 *  Starts the forgotten password flow for a user.
 *
 *  A successful call will cause an email to be sent to the provided email address with instructions to create a new
 *  password. The existing password will not be changed until the steps outlined in the email have been completed.
 *
 *  @param emailAddress
 *    The email address of the user who has forgotten their password
 *  @param redirectUri
 *    The redirect URI that will be used in the emails generated as a consequence of the forgotten password API call.
 *  @param delegate
 *    The JRCaptureDelegate object that wishes to receive messages regarding user authentication.
 */
+ (void)startForgottenPasswordRecoveryForField:(NSString *)fieldValue recoverUri:(NSString *)recoverUri
                                      delegate:(id <JRCaptureDelegate>)delegate;

/**
 * Resend the email verification email
 *
 * A successful call will cause an email to be sent to the provided email address containing a "resend" link. The link
 * will use the "verify_email_url" Capture setting as a base and includes a "verification_code" parameter that can be
 * used to verify the email address.
 *
 * @param emailAddress
 *   The email address of the user that needs to be verified
 * @param delegate
 *   The JRCaptureDelegate object that wishes to receive messages regarding user authentication.
 */
+ (void)resendVerificationEmail:(NSString *)emailAddress delegate:(id <JRCaptureDelegate>)delegate;

/**
 * Link new account for existing user
**/
+ (void)startAccountLinkingSignInDialogForDelegate:(id<JRCaptureDelegate>)delegate
                                 forAccountLinking:(BOOL)linkAccount
                                   withRedirectUri:(NSString *)redirectUri;

+ (void)startLinkNewAccountFordelegate:(id<JRCaptureDelegate>)delegate
                           redirectUri:(NSString *)redirectUri
                          withAuthInfo:(NSDictionary *)authInfo;

/**
 *  Starts the Account unlink flow for a signed-user.
 *
 *  A successful call will unlink a linked account from the Exisiting account.
 *
 *  @param identifier
 *    The identifier of the linked account
 *  @param delegate
 *    The JRCaptureDelegate object that wishes to receive messages regarding user account unlinking.
 */
+ (void)startAccountUnLinking:(id <JRCaptureDelegate>)delegate forProfileIdentifier:(NSString *)identifier;

+ (void)startActualAccountUnLinking:(id <JRCaptureDelegate>)delegate forProfileIdentifier:(NSString *)identifier;


/**
 * JRCapture URL handler
 */
+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

@end

/**
 * @page Providers
 *
@htmlonly
<!-- Script to resize the iFrames; Only works because iFrames origin is on same domain and iFrame
      code contains script that calls this script -->
<script type="text/javascript">
    function resize(width, height, id) {
        var iframe = document.getElementById(id);
        iframe.width = width;
        iframe.height = height + 50;
        iframe.scrolling = false;
        console.log(width);
        console.log(height);
    }
</script>
@endhtmlonly

@anchor authenticationProviders
@htmlonly
<!-- Redundant attributes to force scrolling to work across multiple browsers -->
<iframe id="basic" src="https://rpxnow.com/docs/mobile_providers?list=basic&device=iphone" width="100%" height="100%"
    style="border:none; overflow:hidden;" frameborder="0" scrolling="no">
  Your browser does not support iFrames.
  <a href="https://rpxnow.com/docs/mobile_providers?list=basic&device=iphone">List of Providers</a>
</iframe></p>
@endhtmlonly

@anchor sharingProviders
@htmlonly
<iframe id="social" src="https://rpxnow.com/docs/mobile_providers?list=social&device=iphone" width="100%" height="100%"
    style="border:none; overflow:hidden;" frameborder="0" scrolling="no">
  Your browser does not support iFrames.
  <a href="https://rpxnow.com/docs/mobile_providers?list=social&device=iphone">List of Social Providers</a>
</iframe></p>
@endhtmlonly
 *
 **/
