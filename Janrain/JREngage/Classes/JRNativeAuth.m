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

 File:   JRActivityObject.h
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, August 24, 2010
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <objc/message.h>
#import "JRNativeAuth.h"
#import "debug_log.h"
#import "JRConnectionManager.h"
#import "JRSessionData.h"
#import "JREngageError.h"
#ifdef JR_FACEBOOK_SDK_TEST
#   import "FacebookSDK/FacebookSDK.h"
#endif

@implementation JRNativeAuth
static Class fbSession = nil;
static SEL activeSessionSel = nil;
static SEL stateSel = nil;
static SEL accessTokenDataSel = nil;
static SEL accessTokenSel = nil;
static SEL openActiveSessionWithReadPermissionsSel = nil;
static SEL appIdSel = nil;
static Class fbErrorUtilityClass = nil;
static SEL fbErrorCategoryForErrorSel = nil;

+ (void)initGlobals
{
    if (fbSession != nil) return;
    fbSession = NSClassFromString(@"FBSession");
    activeSessionSel = NSSelectorFromString(@"activeSession");
    stateSel = NSSelectorFromString(@"state");
    accessTokenDataSel = NSSelectorFromString(@"accessTokenData");
    accessTokenSel = NSSelectorFromString(@"accessToken");
    openActiveSessionWithReadPermissionsSel =
            NSSelectorFromString(@"openActiveSessionWithReadPermissions:allowLoginUI:completionHandler:");
    appIdSel = NSSelectorFromString(@"appID");
    fbErrorUtilityClass = NSClassFromString(@"FBErrorUtility");
    fbErrorCategoryForErrorSel = NSSelectorFromString(@"errorCategoryForError:");
}

+ (BOOL)canHandleProvider:(NSString *)provider
{
    [self initGlobals];
    if ([provider isEqual:@"facebook"] && fbSession != nil) return YES;
    return NO;
}

+ (id)fbSessionAppId
{
    return [fbSession performSelector:appIdSel];
}

+ (void)startAuthOnProvider:(NSString *)provider completion:(void (^)(NSError *))completion
{
    if ([provider isEqual:@"facebook"]) {
        [JRSessionData jrSessionData].authenticationFlowIsInFlight = YES;
        [self fbNativeAuthWithCompletion:completion];
        return;
    }

    [NSException raiseJRDebugException:@"unexpected native auth provider" format:provider];
}

+ (void)fbNativeAuthWithCompletion:(void (^)(NSError *))completion
{
    [self initGlobals];

    id fbActiveSession = [fbSession performSelector:activeSessionSel];
    int64_t fbState = (BOOL) [fbActiveSession performSelector:stateSel]; //[FBSession activeSession].state;

    //#define FB_SESSIONSTATEOPENBIT (1 << 9)
    if (fbState & (1 << 9))
    {
        id accessToken = [self getAccessToken:fbActiveSession];
        [self getAuthInfoTokenForAccessToken:accessToken onProvider:@"facebook" completion:completion];
    }
    else
    {
        void (^handler)(id, BOOL, NSError *) =
                ^(id session, BOOL status, NSError *error)
                {
                    DLog(@"session %@ status %i error %@", session, status, error);
                    //error.fberrorCategory == FBErrorCategoryUserCancelled
                    int t = (int) [fbErrorUtilityClass performSelector:fbErrorCategoryForErrorSel withObject:error];
                    //FBErrorCategoryUserCancelled                = 6,
                    if (t == 6)
                    {
                        NSError *err = [JREngageError errorWithMessage:@"native fb auth canceled"
                                                               andCode:JRAuthenticationCanceledError];
                        completion(err);
                    }
                    else
                    {
                        static id accessToken = nil;
                        id accessToken_ = [self getAccessToken:session];

                        // XXX horrible hack to avoid session.fbAccessTokenData being null for auth flows subsequent
                        // to the first. Seems to have something to do with caching.
                        if (accessToken_) accessToken = accessToken_;
                        else accessToken_ = accessToken;

                        [self getAuthInfoTokenForAccessToken:accessToken_ onProvider:@"facebook" completion:completion];
                    }
                };
        objc_msgSend(fbSession, openActiveSessionWithReadPermissionsSel, @[], YES, handler);
    }
}

+ (void)getAuthInfoTokenForAccessToken:(id)token onProvider:(NSString *)provider
                            completion:(void (^)(NSError *))completion
{
    DLog(@"token %@", token);
    if (![token isKindOfClass:[NSString class]])
    {
        id userInfo = @{@"description":@"invalid token", @"token":[NSValue valueWithPointer:token]};
        NSError *error = [NSError errorWithDomain:JREngageErrorDomain code:JRAuthenticationNativeAuthError
                                         userInfo:userInfo];
        DLog(@"Native auth error: %@", error);
        completion(error);
        return;
    }

    NSString *url = [[JRSessionData jrSessionData].baseUrl stringByAppendingString:@"/signin/oauth_token"];
    NSDictionary *params = @{@"token" : token, @"provider" : provider};

    void (^responseHandler)(id, NSError *) = ^(id result, NSError *error)
    {
        NSString *authInfoToken;
        if (error || ![result isKindOfClass:[NSDictionary class]]
                || ![[((NSDictionary *) result) objectForKey:@"stat"] isEqual:@"ok"]
                || ![authInfoToken = [((NSDictionary *) result) objectForKey:@"token"] isKindOfClass:[NSString class]])
        {
            NSObject *error_ = error; if (error_ == nil) error_ = [NSNull null];
            NSObject *result_ = result; if (result_ == nil) result_ = [NSNull null];
            NSError *nativeAuthError = [NSError errorWithDomain:JREngageErrorDomain
                                                           code:JRAuthenticationNativeAuthError
                                                       userInfo:@{@"result": result_, @"error": error_}];
            DLog(@"Native auth error: %@", nativeAuthError);
            completion(nativeAuthError);
            return;
        }

        JRSessionData *sessionData = [JRSessionData jrSessionData];
        [sessionData setCurrentProvider:[sessionData getProviderNamed:provider]];
        [sessionData triggerAuthenticationDidCompleteWithPayload:@{
                @"rpx_result" : @{
                        @"token" : authInfoToken,
                        @"auth_info" : @{}
                },
        }];

        completion(nil);
    };
    [JRConnectionManager jsonRequestToUrl:url params:params completionHandler:responseHandler];
}

+ (id)getAccessToken:(id)fbActiveSession
{
    id accessTokenData = [fbActiveSession performSelector:accessTokenDataSel];
    id accessToken = [accessTokenData performSelector:accessTokenSel];
    return accessToken;
}

@end