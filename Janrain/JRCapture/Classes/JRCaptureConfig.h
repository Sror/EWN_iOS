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

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "JRCaptureTypes.h"

/**
 * @brief
 * Capture configuration object for storing Capture settings.
 **/
@interface JRCaptureConfig : NSObject

/*@{*/
/**
 *   This is your 20-character application ID for Engage. You can find this on your application's Engage Dashboard
 *   on http://rpxnow.com">http://rpxnow.com. Please do not use your API key. The API key
 *   should never be stored on the device, in code or otherwise.
 **/
@property (nonatomic, retain) NSString *engageAppId;
/**
 *   The domain of your Capture app instance (e.g., \@"my-name.janraincapture.com")
 **/
@property (nonatomic, retain) NSString *captureDomain;
/**
 *   This is your 32-character client ID for Capture. You can find this on your Capture Dashboard
 *   on http://janraincapture.com">https://janraincapture.com/home. Please do not use your client secret.
 *   The client secret should never be stored on the device, in code or otherwise.
 **/
@property (nonatomic, retain) NSString *captureClientId;
/**
 *   The locale to use when signing-in, from your Capture flow. Required. Follows ISO locale conventions. This locale
 *   must be defined by your Capture flow in its "translations" data structure.
 **/
@property (nonatomic, retain) NSString *captureLocale;
/**
 *   The name of the Capture sign-in flow your users will sign-in with. Optional. Pass nil to have Capture use the
 *   flow specified by the default_flow_name setting for your Capture app, specified in the Capture dashboard.
 **/
@property (nonatomic, retain) NSString *captureFlowName;
/**
 *   Overrides the flow version loaded by the library. Use `nil` to have the library fetch the latest version of the
 *   flow.
 **/
@property (nonatomic, retain) NSString *captureFlowVersion;
/**
 *   The name of the sign-in form in the Capture flow your users will sign-in with. Required. Likely to be "signinForm"
 **/
@property (nonatomic, retain) NSString *captureSignInFormName;
/**
 *   The type of traditional sign-in your end-users will sign-in with.
 **/
@property JRTraditionalSignInType captureTraditionalSignInType;
/**
 *   Controls whether or not a social sign-in may result in a thin registration.
 **/
@property bool enableThinRegistration;
/**
 *   Describes the configuration of custom identity providers. See `Engage Custom Provider Guide.md` for details
 *   configuring custom providers.
 **/
@property (nonatomic, retain) NSDictionary *customProviders;
/**
 *   The name of the form (from your flow) used for traditional registration.
 **/
@property (nonatomic, retain) NSString *captureTraditionalRegistrationFormName;
/**
 *   The name of the form (from your flow) used for social registration.
 **/
@property (nonatomic, retain) NSString *captureSocialRegistrationFormName;
/**
 *   The application ID of your Capture app. This value can be retrieved from the "Settings" section of your Capture
 *   application's dashboard.
 **/
@property (nonatomic, retain) NSString *captureAppId;
/**
 *   The name of the form (from your flow) used for recovering forgotten passwords
 **/
@property (nonatomic, retain) NSString *forgottenPasswordFormName;
/**
 *  The base uri for creating the link in a password recovery email.
 */
@property (nonatomic, retain) NSString *passwordRecoverUri;
/**
 *  The name of the form (from your flow) used for editing the user profile
 */
@property (nonatomic, retain) NSString *editProfileFormName;

/**
 *  The name of the form (from your flow) used for resending the email validation email
 */
@property (nonatomic, retain) NSString *resendEmailVerificationFormName;

/**
 *  Your Google+ client id. Must be for the same google application that is configured in Engage.
 */
@property (nonatomic, retain) NSString *googlePlusClientId;

/**
 *  Your Twitter consumer secret. Must match the value in your Engage Dashboard.
 *  This is required for native Twitter authentication
 */
@property (nonatomic, retain) NSString *twitterConsumerSecret;

/**
 *  Your Twitter consumer key. Must match the value in your Engage Dashboard.
 *  This is required for native Twitter authentication
 */
@property (nonatomic, retain) NSString *twitterConsumerKey;

/**
 *   Get an empty Capture Configuration
 */
+ (JRCaptureConfig *)emptyCaptureConfig;
/*@}*/

@end
