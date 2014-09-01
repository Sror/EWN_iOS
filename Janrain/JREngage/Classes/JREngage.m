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

 File:   JRAuthenticate.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, June 1, 2010
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "JREngage.h"
#import "JRSessionData.h"
#import "JRUserInterfaceMaestro.h"
#import "JREngageError.h"
#import "JRNativeAuth.h"

@interface JREngage () <JRSessionDelegate>
/** \internal Class that handles customizations to the library's UI */
@property (nonatomic, retain) JRUserInterfaceMaestro *interfaceMaestro;

/** \internal Holds configuration and state for the JREngage library */
@property (nonatomic, retain) JRSessionData          *sessionData;

/** \internal Array of JREngageDelegate objects */
@property (nonatomic, retain) NSMutableArray         *delegates;
@end

@implementation JREngage
@synthesize interfaceMaestro;
@synthesize sessionData;
@synthesize delegates;

static JREngage* singleton = nil;

- (id)init
{
    if ((self = [super init]))
    {
    }

    return self;
}

+ (JREngage *)singletonInstance
{
    if (singleton == nil) {
        singleton = [((JREngage *)[super allocWithZone:NULL]) init];
    }

    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self singletonInstance] retain];
}

- (void)setEngageAppID:(NSString *)appId tokenUrl:(NSString *)tokenUrl andDelegate:(id<JREngageSigninDelegate>)delegate
{
    ALog (@"Initialize JREngage library with appID: %@, and tokenUrl: %@", appId, tokenUrl);

    if (!delegates)
        self.delegates = [NSMutableArray arrayWithObjects:delegate, nil];
    else
        [delegates addObject:delegate];

    if (!sessionData)
        self.sessionData = [JRSessionData jrSessionDataWithAppId:appId tokenUrl:tokenUrl andDelegate:self];
    else
        [sessionData reconfigureWithAppId:appId tokenUrl:tokenUrl];

    if (!interfaceMaestro)
        interfaceMaestro = [JRUserInterfaceMaestro jrUserInterfaceMaestroWithSessionData:sessionData];
}

+ (void)setEngageAppId:(NSString *)appId tokenUrl:(NSString *)tokenUrl andDelegate:(id<JREngageSigninDelegate>)delegate
{
    [[JREngage singletonInstance] setEngageAppID:appId tokenUrl:tokenUrl andDelegate:delegate];
}

+ (JREngage *)jrEngageWithAppId:(NSString *)appId andTokenUrl:(NSString *)tokenUrl
                       delegate:(id <JREngageSigninDelegate>)delegate {
    [JREngage setEngageAppId:appId tokenUrl:tokenUrl andDelegate:delegate];

    return [JREngage singletonInstance];
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

- (void)addDelegate:(id<JREngageSigninDelegate>)delegate
{
    if (![delegates containsObject:delegate])
        [delegates addObject:delegate];
}

+ (void)addDelegate:(id<JREngageSigninDelegate>)delegate
{
    [[JREngage singletonInstance] addDelegate:delegate];
}

- (void)removeDelegate:(id<JREngageSigninDelegate>)delegate
{
    [delegates removeObject:delegate];
}

+ (void)removeDelegate:(id<JREngageSigninDelegate>)delegate
{
    [[JREngage singletonInstance] removeDelegate:delegate];
}

- (void)engageDidFailWithError:(NSError *)error
{
    ALog (@"JREngage failed to load with error: %@", [error localizedDescription]);

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSigninDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(engageDialogDidFailToShowWithError:)])
            [delegate engageDialogDidFailToShowWithError:error];
    }
}

- (void)showAuthenticationDialogForProvider:(NSString *)provider
                            customInterface:(NSDictionary *)customInterfaceOverrides
{
    ALog (@"");

    /* If there was error configuring the library, sessionData.error will not be null. */
    if (sessionData.error)
    {
        // Since configuration should happen long before the user attempts to use the library and because the user may
        // not attempt to use the library at all, we shouldn't notify the calling application of the error until the
        // library is actually needed.  Additionally, since many configuration issues could be temporary (e.g., network
        // issues), a subsequent attempt to reconfigure the library could end successfully.  The calling application
        // could alert the user of the issue (with a pop-up dialog, for example) right when the user wants to use it
        // (and not before). This gives the calling application an ad hoc way to reconfigure the library, and doesn't
        // waste the limited resources by trying to reconfigure itself if it doesn't know if it’s actually needed.

        if (sessionData.error.code / 100 == ConfigurationError)
        {
            [self engageDidFailWithError:[[sessionData.error copy] autorelease]];
            [sessionData tryToReconfigureLibrary];

            return;
        }
        else
        {
            // TODO: The session data error doesn't get reset here.  When will this happen and what will be the
            // expected behavior?
            [self engageDidFailWithError:[[sessionData.error copy] autorelease]];
            return;
        }
    }

    if (sessionData.authenticationFlowIsInFlight)
    {
        [self engageDidFailWithError:
                      [JREngageError errorWithMessage:@"The dialog failed to show because there is already a JREngage "
                              "dialog loaded."
                                              andCode:JRDialogShowingError]];
        return;
    }

    if (provider && ![sessionData.allProviders objectForKey:provider])
    {
        NSString *message =
                @"You tried to authenticate on a specific provider, but this provider has not yet been configured.";
        [self engageDidFailWithError:[JREngageError errorWithMessage:message andCode:JRProviderNotConfiguredError]];
        return;
    }

    if ([JRNativeAuth canHandleProvider:provider])
    {
        [self startNativeAuthWithCustomInterface:customInterfaceOverrides provider:provider];
    }
    else
    {
        [interfaceMaestro startWebAuthWithCustomInterface:customInterfaceOverrides provider:provider];
    }
}

- (void)startNativeAuthWithCustomInterface:(NSDictionary *)customInterfaceOverrides provider:(NSString *)provider
{
    [JRNativeAuth startAuthOnProvider:provider completion:^(NSError *error)
    {
        if (!error) return;
        if ([error.domain isEqualToString:JREngageErrorDomain] && error.code == JRAuthenticationCanceledError)
        {
            [self authenticationDidCancel];
        }
        else
        {
            [interfaceMaestro startWebAuthWithCustomInterface:customInterfaceOverrides provider:provider];
        }
    }];
}

//- (void)showAuthenticationDialogForProvider:(NSString *)provider
//               withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
//{
//    [self showAuthenticationDialogWithCustomInterfaceOverrides:customInterfaceOverrides
//                            orAuthenticatingOnJustThisProvider:provider];
//}

+ (void)showAuthenticationDialogForProvider:(NSString *)provider
               withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides __unused
{
    [[JREngage singletonInstance] showAuthenticationDialogForProvider:provider
                                                      customInterface:customInterfaceOverrides];
}

//- (void)showAuthenticationDialogWithCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
//{
//    [self showAuthenticationDialogWithCustomInterfaceOverrides:customInterfaceOverrides
//                            orAuthenticatingOnJustThisProvider:nil];
//}

+ (void)showAuthenticationDialogWithCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides __unused
{
    [[JREngage singletonInstance] showAuthenticationDialogForProvider:nil
                                                      customInterface:customInterfaceOverrides];
}

//- (void)showAuthenticationDialogForProvider:(NSString *)provider
//{
//    [self showAuthenticationDialogWithCustomInterfaceOverrides:nil
//                            orAuthenticatingOnJustThisProvider:provider];
//}

+ (void)showAuthenticationDialogForProvider:(NSString *)provider
{
    [[JREngage singletonInstance] showAuthenticationDialogForProvider:provider
                                                      customInterface:nil ];
}

- (void)showAuthenticationDialog
{
    [self showAuthenticationDialogForProvider:nil customInterface:nil ];
}

+ (void)showAuthenticationDialog __unused
{
    [[JREngage singletonInstance] showAuthenticationDialog];
}

- (void)showSharingDialogWithActivity:(JRActivityObject *)activity
         withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
{
    ALog (@"");

    /* If there was error configuring the library, sessionData.error will not be null. */
    if (sessionData.error)
    {

    /* Since configuration should happen long before the user attempts to use the library and because the user may not
        attempt to use the library at all, we shouldn't notify the calling application of the error until the library
        is actually needed.  Additionally, since many configuration issues could be temporary (e.g., network issues),
        a subsequent attempt to reconfigure the library could end successfully.  The calling application could alert the
        user of the issue (with a pop-up dialog, for example) right when the user wants to use it (and not before).
        This gives the calling application an ad hoc way to reconfigure the library, and doesn't waste the limited
        resources by trying to reconfigure itself if it doesn't know if it’s actually needed. */

        if (sessionData.error.code / 100 == ConfigurationError)
        {
            [self engageDidFailWithError:[[sessionData.error copy] autorelease]];
            [sessionData tryToReconfigureLibrary];

            return;
        }
        else
        {
            [self engageDidFailWithError:[[sessionData.error copy] autorelease]];
            return;
        }
    }

    if (sessionData.authenticationFlowIsInFlight)
    {
        [self engageDidFailWithError:
                      [JREngageError errorWithMessage:@"The dialog failed to show because there is already a JREngage "
                              "dialog loaded."
                                              andCode:JRDialogShowingError]];
        return;
    }

    if (!activity)
    {
        [self engageDidFailWithError:
                      [JREngageError errorWithMessage:@"Activity object can't be nil."
                                              andCode:JRPublishErrorActivityNil]];
        return;
    }

    sessionData.activity = activity;
    [interfaceMaestro showPublishingDialogForActivityWithCustomInterface:customInterfaceOverrides];
}

//- (void)showSocialPublishingDialogWithActivity:(JRActivityObject *)activity
//                   andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
//{
//    [self showSharingDialogWithActivity:activity withCustomInterfaceOverrides:customInterfaceOverrides];
//}

+ (void)showSharingDialogWithActivity:(JRActivityObject *)activity
         withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides __unused
{
    [[JREngage singletonInstance] showSharingDialogWithActivity:activity 
                                   withCustomInterfaceOverrides:customInterfaceOverrides];
}

- (void)showSharingDialogWithActivity:(JRActivityObject *)activity
{
    [self showSharingDialogWithActivity:activity withCustomInterfaceOverrides:nil];
}

+ (void)showSharingDialogWithActivity:(JRActivityObject *)activity __unused
{
    [[JREngage singletonInstance] showSharingDialogWithActivity:activity];
}

- (void)authenticationDidRestart
{
    DLog (@"");
    [interfaceMaestro authenticationRestarted];
}

- (void)authenticationDidCancel
{
    DLog (@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSigninDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidNotComplete)])
            [delegate authenticationDidNotComplete];
    }

    [interfaceMaestro authenticationCanceled];
}

- (void)authenticationDidCompleteForUser:(NSDictionary *)profile forProvider:(NSString *)provider
{
    ALog (@"Signing complete for %@", provider);

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSigninDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidSucceedForUser:forProvider:)])
            [delegate authenticationDidSucceedForUser:profile forProvider:provider];
    }

    [interfaceMaestro authenticationCompleted];
}

- (void)authenticationDidFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    ALog (@"Sign in failed for %@ with error: %@", provider, [error localizedDescription]);

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSigninDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidFailWithError:forProvider:)])
            [delegate authenticationDidFailWithError:error forProvider:provider];
    }

    [interfaceMaestro authenticationFailed];
}

- (void)authenticationDidReachTokenUrl:(NSString *)tokenUrl withResponse:(NSURLResponse *)response
                            andPayload:(NSData *)tokenUrlPayload forProvider:(NSString *)provider;
{
    ALog (@"Token URL reached for %@: %@", provider, tokenUrl);

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSigninDelegate> delegate in delegatesCopy)
    {
        SEL selector = @selector(authenticationDidReachTokenUrl:withResponse:andPayload:forProvider:);
        if ([delegate respondsToSelector:selector])
            [delegate authenticationDidReachTokenUrl:tokenUrl withResponse:response andPayload:tokenUrlPayload 
                                         forProvider:provider];
    }
}

- (void)authenticationCallToTokenUrl:(NSString *)tokenUrl didFailWithError:(NSError *)error
                         forProvider:(NSString *)provider
{
    ALog (@"Token URL failed for %@: %@", provider, tokenUrl);

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSigninDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationCallToTokenUrl:didFailWithError:forProvider:)])
            [delegate authenticationCallToTokenUrl:tokenUrl didFailWithError:error forProvider:provider];
    }
}

//- (void)publishingDidRestart
//{
//    DLog (@"");
//    [interfaceMaestro publishingRestarted];
//}

- (void)publishingDidCancel
{
    DLog(@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSharingDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(sharingDidNotComplete)])
            [delegate sharingDidNotComplete];
    }

    [interfaceMaestro publishingCanceled];
}

- (void)publishingDidComplete
{
    DLog(@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSharingDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(sharingDidComplete)])
            [delegate sharingDidComplete];
    }

    [interfaceMaestro publishingCompleted];
}

- (void)publishingActivityDidSucceed:(JRActivityObject *)activity forProvider:(NSString *)provider
{
    ALog (@"Activity shared on %@", provider);

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSharingDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(sharingDidSucceedForActivity:forProvider:)])
            [delegate sharingDidSucceedForActivity:activity forProvider:provider];
    }
}

- (void)publishingActivity:(JRActivityObject *)activity didFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    ALog (@"Sharing activity failed for %@", provider);

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JREngageSharingDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(sharingDidFailForActivity:withError:forProvider:)])
            [delegate sharingDidFailForActivity:activity withError:error forProvider:provider];
    }
}

- (void)clearSharingCredentialsForProvider:(NSString *)provider
{
    DLog(@"");
    [sessionData forgetAuthenticatedUserForProvider:provider];
}

+ (void)clearSharingCredentialsForProvider:(NSString *)provider
{
    [[JREngage singletonInstance] clearSharingCredentialsForProvider:provider];
}

- (void)clearSharingCredentialsForAllProviders __unused
{
    DLog(@"");
    [sessionData forgetAllAuthenticatedUsers];
}

+ (void)clearSharingCredentialsForAllProviders
{
    [[JREngage singletonInstance] clearSharingCredentialsForAllProviders];
}

- (void)alwaysForceReauthentication:(BOOL)force
{
    [sessionData setAlwaysForceReauth:force];
}

+ (void)alwaysForceReauthentication:(BOOL)force
{
    [[JREngage singletonInstance] alwaysForceReauthentication:force];
}

- (void)cancelAuthentication
{
    DLog(@"");
    [sessionData triggerAuthenticationDidCancel];
}

+ (void)cancelAuthentication
{
    [[JREngage singletonInstance] cancelAuthentication];
}

- (void)cancelSharing
{
    DLog(@"");
    [sessionData triggerPublishingDidCancel];
}

+ (void)cancelSharing
{
    [[JREngage singletonInstance] cancelSharing];
}

- (void)updateTokenUrl:(NSString *)newTokenUrl
{
    DLog(@"new token URL: %@", newTokenUrl);
    [sessionData setTokenUrl:newTokenUrl];
}

+ (NSString *)tokenUrl
{
    return [JREngage singletonInstance].sessionData.tokenUrl;
}

+ (void)updateTokenUrl:(NSString *)newTokenUrl __unused
{
    [[JREngage singletonInstance] updateTokenUrl:newTokenUrl];
}

- (void)setCustomInterfaceDefaults:(NSMutableDictionary *)customInterfaceDefaults
{
    [interfaceMaestro setCustomInterfaceDefaults:customInterfaceDefaults];
}

- (void)dealloc
{
    [interfaceMaestro release];
    [sessionData release];
    [delegates release];
    [super dealloc];
}

+ (void)setCustomInterfaceDefaults:(NSDictionary *)customInterfaceDefaults
{
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:customInterfaceDefaults];
    [[JREngage singletonInstance] setCustomInterfaceDefaults:mutable];
}

+ (void)setCustomProviders:(NSDictionary *)customProviders __unused
{
    [[JREngage singletonInstance].sessionData setCustomProvidersWithDictionary:customProviders];
}
@end
