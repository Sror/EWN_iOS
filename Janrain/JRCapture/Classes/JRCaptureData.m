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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "JRCaptureData.h"
#import "SFHFKeychainUtils.h"
#import "JRCaptureConfig.h"
#import "NSDictionary+JRQueryParams.h"
#import "JREngageWrapper.h"
#import "JRCaptureFlow.h"

#define cJRCaptureKeychainIdentifier @"capture_tokens.janrain"
#define cJRCaptureKeychainUserName @"capture_user"

@implementation NSString (JRString_UrlWithDomain)
- (NSString *)urlStringFromBaseDomain
{
    if ([self hasPrefix:@"https://"])
        return self;

    if ([self hasPrefix:@"http://"])
        return [self stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];

    return [@"https://" stringByAppendingString:self];
}
@end

static NSString*appBundleDisplayNameAndIdentifier()
{
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoPlist objectForKey:@"CFBundleDisplayName"];
    NSString *identifier = [infoPlist objectForKey:@"CFBundleIdentifier"];

    return [NSString stringWithFormat:@"%@.%@", name, identifier];
}

typedef enum
{
    JRTokenTypeAccess,
    JRTokenTypeRefresh,
} JRTokenType;

static NSString *const FLOW_KEY = @"JR_capture_flow";

@interface JRCaptureData ()

@property(nonatomic, retain) NSString *accessToken;
@property(nonatomic, retain) NSString *refreshSecret;

@property(nonatomic, retain) NSString *captureBaseUrl;
@property(nonatomic, retain) NSString *clientId;
@property(nonatomic, retain) NSString *captureAppId;
@property(nonatomic, retain) NSString *captureRedirectUri;
@property(nonatomic, retain) NSString *passwordRecoverUri;

@property(nonatomic, retain) NSString *captureFlowName;
@property(nonatomic, retain) NSString *captureFlowVersion;
@property(nonatomic, retain) NSString *captureLocale;
@property(nonatomic, retain) NSString *captureTraditionalSignInFormName;
@property(nonatomic, retain) NSString *captureTraditionalRegistrationFormName;
@property(nonatomic, retain) NSString *captureSocialRegistrationFormName;
@property(nonatomic, retain) NSString *captureForgottenPasswordFormName;
@property(nonatomic, retain) NSString *captureEditProfileFormName;
@property(nonatomic, retain) NSString *resendEmailVerificationFormName;

//@property(nonatomic) JRTraditionalSignInType captureTradSignInType;
@property(nonatomic) BOOL captureEnableThinRegistration;

@property(nonatomic, retain) JRCaptureFlow *captureFlow;
@property(nonatomic, retain) NSArray *linkedProfiles;
@property(nonatomic) BOOL initialized;
@property(nonatomic) BOOL socialSignMode;
@end

@implementation JRCaptureData
static JRCaptureData *singleton = nil;

@synthesize clientId;
@synthesize captureBaseUrl;
@synthesize accessToken;
@synthesize refreshSecret;
@synthesize bpChannelUrl;
@synthesize captureLocale;
@synthesize captureTraditionalSignInFormName;
//@synthesize captureTradSignInType;
@synthesize captureFlowName;
@synthesize captureTraditionalRegistrationFormName;
@synthesize captureSocialRegistrationFormName;
@synthesize captureForgottenPasswordFormName;
@synthesize captureEditProfileFormName;
@synthesize resendEmailVerificationFormName;
@synthesize captureFlowVersion;
@synthesize captureAppId;
@synthesize captureFlow;
@synthesize captureRedirectUri;
@synthesize passwordRecoverUri;

- (JRCaptureData *)init
{
    if ((self = [super init]))
    {
        self.accessToken = [self readTokenForTokenName:@"access_token"];
        self.refreshSecret = [self readTokenForTokenName:@"refresh_secret"];
    }

    return self;
}

- (NSString *)readTokenForTokenName:(NSString *)tokenName
{
    return [SFHFKeychainUtils getPasswordForUsername:cJRCaptureKeychainUserName
                                      andServiceName:[JRCaptureData serviceNameForTokenName:tokenName]
                                               error:nil];
}

+ (JRCaptureData *)sharedCaptureData
{
    if (singleton == nil)
    {
        singleton = [((JRCaptureData*)[super allocWithZone:NULL]) init];
    }

    return singleton;
}

+ (NSArray *)getLinkedProfiles {
    if(singleton) {
        return [singleton linkedProfiles];
    }
    return nil;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedCaptureData] retain];
}

- (id)copyWithZone:(__unused NSZone *)zone __unused
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release { }

- (id)autorelease
{
    return self;
}

+ (NSString *)captureTokenUrlWithMergeToken:(NSString *)mergeToken delegate:(id)delegate {
    JRCaptureData *captureData = [JRCaptureData sharedCaptureData];
    NSString *redirectUri = [singleton redirectUri];
    NSString *thinReg = [JRCaptureData sharedCaptureData].captureEnableThinRegistration ? @"true" : @"false";
    NSMutableDictionary *urlArgs = [NSMutableDictionary dictionaryWithDictionary:
            @{
                    @"client_id" : captureData.clientId,
                    @"locale" : captureData.captureLocale,
                    @"response_type" : [captureData responseType:delegate],
                    @"redirect_uri" : redirectUri,
                    @"thin_registration" : thinReg,
                    @"refresh_secret" : [self generateAndStoreRefreshSecret],
            }];

    if (captureData.captureFlowName) [urlArgs setObject:captureData.captureFlowName forKey:@"flow"];
    if ([captureData downloadedFlowVersion])
        [urlArgs setObject:[captureData downloadedFlowVersion] forKey:@"flow_version"];
    if (captureData.bpChannelUrl) [urlArgs setObject:captureData.bpChannelUrl forKey:@"bp_channel"];
    if (mergeToken) [urlArgs setObject:mergeToken forKey:@"merge_token"];
    if (captureData.captureSocialRegistrationFormName)
    {
        [urlArgs setObject:captureData.captureSocialRegistrationFormName forKey:@"registration_form"];
    }

    NSString *getParams = [urlArgs asJRURLParamString];
    return [NSString stringWithFormat:@"%@/oauth/auth_native?%@", captureData.captureBaseUrl, getParams];
}

+ (NSString *)generateAndStoreRefreshSecret
{
    #define RANDOM_BYTES 20

    uint8_t refreshSecret_[RANDOM_BYTES];
    int errCode = SecRandomCopyBytes(kSecRandomDefault, RANDOM_BYTES, refreshSecret_);
    if (errCode)
    {
        ALog(@"UNABLE TO GENERATE RANDOM REFRESH SECRET. ERRNO: %d", errno);
        return nil;
    }

    NSMutableString *buffer = [NSMutableString string];
    for (int i=0; i<RANDOM_BYTES; i++) [buffer appendFormat:@"%02hhx", refreshSecret_[i]];
    [buffer replaceCharactersInRange:NSMakeRange(0, 1) withString:@"a"];

    [JRCaptureData saveNewToken:[NSString stringWithString:buffer] ofType:JRTokenTypeRefresh];
    return [JRCaptureData sharedCaptureData].refreshSecret;
}

- (NSString *)downloadedFlowVersion
{
    id version = [captureFlow objectForKey:@"version"];
    if ([version isKindOfClass:[NSString class]]) return version;
    ALog(@"Error parsing flow version: %@", version);
    return nil;
}

- (NSString *)redirectUri
{
    if (captureRedirectUri) return captureRedirectUri;
    return [NSString stringWithFormat:@"%@/cmeu", singleton.captureBaseUrl];
}

+ (void)setCaptureConfig:(JRCaptureConfig *)config
{
    JRCaptureData *captureDataInstance = [JRCaptureData sharedCaptureData];
    if (captureDataInstance.initialized)
    {
        [NSException raiseJRDebugException:@"JRCaptureDuplicateInitializationException" format:@"Repeated "
                "initialization of JRCapture is unsafe"];
    }
    captureDataInstance.initialized = YES;
    captureDataInstance.captureBaseUrl = [config.captureDomain urlStringFromBaseDomain];
    captureDataInstance.clientId = config.captureClientId;
    captureDataInstance.captureLocale = config.captureLocale;
    captureDataInstance.captureTraditionalSignInFormName = config.captureSignInFormName;
    captureDataInstance.captureFlowName = config.captureFlowName;
    captureDataInstance.captureEnableThinRegistration = config.enableThinRegistration;
    captureDataInstance.captureTraditionalRegistrationFormName = config.captureTraditionalRegistrationFormName;
    captureDataInstance.captureSocialRegistrationFormName = config.captureSocialRegistrationFormName;
    captureDataInstance.captureFlowVersion = config.captureFlowVersion;
    captureDataInstance.captureAppId = config.captureAppId;
    captureDataInstance.captureForgottenPasswordFormName = config.forgottenPasswordFormName;
    captureDataInstance.captureEditProfileFormName = config.editProfileFormName;
    captureDataInstance.passwordRecoverUri = config.passwordRecoverUri;
    captureDataInstance.resendEmailVerificationFormName = config.resendEmailVerificationFormName;

    if ([captureDataInstance.captureLocale length] &&
            [captureDataInstance.captureFlowName length] && [captureDataInstance.captureAppId length])
    {
        [captureDataInstance loadFlow];
        [captureDataInstance downloadFlow];
    }
}

- (void)loadFlow
{
    NSDictionary *flowDict =
            [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:FLOW_KEY]];
    self.captureFlow = [JRCaptureFlow flowWithDictionary:flowDict];
}

- (NSString *)getForgottenPasswordFieldName {
    if (!self.captureForgottenPasswordFormName) {
        [NSException raiseJRDebugException:@"JRCaptureMissingParameterException"
                                    format:@"Missing capture configuration setting forgottenPasswordFormName"];
    }

    return [self.captureFlow userIdentifyingFieldForForm:self.captureForgottenPasswordFormName];
}

- (void)downloadFlow
{
    NSString *flowVersion = self.captureFlowVersion ? self.captureFlowVersion : @"HEAD";

    NSString *flowUrlString =
            [NSString stringWithFormat:@"https://%@.cloudfront.net/widget_data/flows/%@/%@/%@/%@.json",
                                       self.flowUsesTestingCdn ? @"dlzjvycct5xka" : @"d1lqe9temigv1p",
                                       self.captureAppId, self.captureFlowName, flowVersion,
                                       self.captureLocale];
    NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:flowUrlString]];
    [downloadRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [NSURLConnection sendAsynchronousRequest:downloadRequest queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e)
                           {
                               if (e)
                               {
                                   ALog(@"Error downloading flow: %@", e);
                                   return;
                               }
                               DLog(@"Fetched flow URL: %@", flowUrlString);
                               [self processFlow:d response:(NSHTTPURLResponse *) r];
                           }];
}

- (void)processFlow:(NSData *)flowData response:(NSHTTPURLResponse *)response
{
    NSError *jsonErr = nil;
    NSObject *parsedFlow = [NSJSONSerialization JSONObjectWithData:flowData options:(NSJSONReadingOptions) 0
                                                             error:&jsonErr];

    if (jsonErr)
    {
        NSString *responseString = [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]];
        ALog(@"Error parsing flow JSON, response: %@", responseString);
        ALog(@"Error parsing flow JSON, err: %@", [jsonErr description]);
        return;
    }
    
    if (![parsedFlow isKindOfClass:[NSDictionary class]])
    {
        ALog(@"Error parsing flow JSON, top level object was not a hash...: %@", [parsedFlow description]);
        return;
    }

    self.captureFlow = [JRCaptureFlow flowWithDictionary:(NSDictionary *) parsedFlow];
    DLog(@"Parsed flow, version: %@", [self downloadedFlowVersion]);
    
    [self writeCaptureFlow];
}

- (void)writeCaptureFlow
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:[captureFlow dictionary]]
                                             forKey:FLOW_KEY];
}

+ (NSString *)serviceNameForTokenName:(NSString *)tokenName
{
    return [NSString stringWithFormat:@"%@.%@.%@.", cJRCaptureKeychainIdentifier, tokenName,
                     appBundleDisplayNameAndIdentifier()];
}

+ (void)deleteTokenNameFromKeychain:(NSString *)name
{
    [SFHFKeychainUtils deleteItemForUsername:cJRCaptureKeychainUserName
                              andServiceName:[JRCaptureData serviceNameForTokenName:name]
                                       error:nil];
}

+ (void)storeTokenInKeychain:(NSString *)token name:(NSString *)name
{
    NSError *error = nil;

    [SFHFKeychainUtils storeUsername:cJRCaptureKeychainUserName andPassword:token
                      forServiceName:[JRCaptureData serviceNameForTokenName:name]
                      updateExisting:YES error:&error];

    if (error)
    {
        ALog (@"Error storing device token in keychain: %@", [error localizedDescription]);
    }
}

+ (void)saveNewToken:(NSString *)token ofType:(JRTokenType)tokenType
{
    NSString *name = tokenType == JRTokenTypeAccess ? @"access_token" : @"refresh_secret";
    [JRCaptureData deleteTokenNameFromKeychain:name];

    if (tokenType == JRTokenTypeAccess)
    {
        [JRCaptureData sharedCaptureData].accessToken = token;
    }
    else if (tokenType == JRTokenTypeRefresh)
    {
        [JRCaptureData sharedCaptureData].refreshSecret = token;
    }

    [JRCaptureData storeTokenInKeychain:token name:name];
}

+ (void)setCaptureRedirectUri:(NSString *)captureRedirectUri
{
    [JRCaptureData sharedCaptureData].captureRedirectUri = captureRedirectUri;
}

+ (void)setAccessToken:(NSString *)token
{
    [JRCaptureData saveNewToken:token ofType:JRTokenTypeAccess];
}

+ (NSString *)captureBaseUrl __unused
{
    return [[JRCaptureData sharedCaptureData] captureBaseUrl];
}

+ (void)setCaptureClientId:(NSString*)captureClientId {
    [JRCaptureData sharedCaptureData].clientId = captureClientId;
}

+ (void)setCaptureBaseUrl:(NSString*)baseUrl {
    [JRCaptureData sharedCaptureData].captureBaseUrl = [baseUrl urlStringFromBaseDomain];
}

+ (NSString *)clientId __unused
{
    return [[JRCaptureData sharedCaptureData] clientId];
}

- (void)dealloc
{
    [clientId release];
    [accessToken release];
    [captureBaseUrl release];
    [captureFlowName release];
    [captureLocale release];
    [captureTraditionalSignInFormName release];
    [bpChannelUrl release];
    [captureTraditionalRegistrationFormName release];
    [captureFlowVersion release];
    [captureTraditionalRegistrationFormName release];
    [captureFlowVersion release];
    [captureAppId release];
    [captureAppId release];
    [captureFlow release];
    [refreshSecret release];
    [captureRedirectUri release];
    [passwordRecoverUri release];
    [captureSocialRegistrationFormName release];
    [captureForgottenPasswordFormName release];
    [captureEditProfileFormName release];
    [resendEmailVerificationFormName release];
    [super dealloc];
}

+ (void)clearSignInState
{
    [JRCaptureData deleteTokenNameFromKeychain:@"access_token"];
    [JRCaptureData deleteTokenNameFromKeychain:@"refresh_secret"];
    [JRCaptureData sharedCaptureData].accessToken = nil;
    [JRCaptureData sharedCaptureData].refreshSecret = nil;
}

+ (NSMutableURLRequest *)requestWithPath:(NSString *)path
{
    JRCaptureData *data = [JRCaptureData sharedCaptureData];
    NSString *urlString = [[data captureBaseUrl] stringByAppendingString:path];
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
}

+ (void)setBackplaneChannelUrl:(NSString *)bpChannelUrl __unused
{
    [JRCaptureData sharedCaptureData].bpChannelUrl = bpChannelUrl;
}

+ (void)setLinkedProfiles:(NSArray *)profileData {
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    if([profileData count] > 0) {
        for(NSDictionary *dict in profileData) {
            
            NSDictionary *tempDict = @{
                   @"verifiedEmail" : ([dict objectForKey:@"verifiedEmail"] ? [dict objectForKey:@"verifiedEmail"] : @""),
                   @"identifier" : [dict objectForKey:@"identifier"],
            };
            [returnArray addObject:tempDict];
        }
    }
    [JRCaptureData sharedCaptureData].linkedProfiles = profileData;
    [returnArray release];
}
- (NSString *)responseType:(id)delegate {
    SEL captureDidSucceedWithCode = sel_registerName("captureDidSucceedWithCode:");
    if ([delegate respondsToSelector:captureDidSucceedWithCode]) {
        return @"code_and_token";
    }
    return @"token";
}
@end
