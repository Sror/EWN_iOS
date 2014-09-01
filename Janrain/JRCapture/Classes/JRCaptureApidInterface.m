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

 File:   JRCaptureInterface.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Thursday, January 26, 2012
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "JRConnectionManager.h"
#import "JRCaptureApidInterface.h"
#import "JRCaptureData.h"
#import "NSMutableDictionary+JRDictionaryUtils.h"
#import "NSMutableURLRequest+JRRequestUtils.h"
#import "JRCaptureError.h"
#import "JRJsonUtils.h"
#import "JRCaptureFlow.h"

static NSString *const cSignInUser = @"signinUser";
static NSString *const cGetUser = @"getUser";
static NSString *const cGetObject = @"getObject";
static NSString *const cUpdateObject = @"updateObject";
static NSString *const cReplaceObject = @"replaceObject";
static NSString *const cReplaceArray = @"replaceArray";
static NSString *const cTagAction = @"action";

NSString *const kJRTradAuthUrlPath = @"/oauth/auth_native_traditional";

@interface JRCaptureApidInterface ()  <JRConnectionManagerDelegate>
@end

@implementation JRCaptureApidInterface
- (JRCaptureApidInterface *)init
{
    if ((self = [super init])) { }

    return self;
}

+ (JRCaptureApidInterface *)captureInterfaceInstance __attribute__((deprecated))
{
    return [self sharedCaptureApidInterface];
}

+ (JRCaptureApidInterface *)sharedCaptureApidInterface
{
    static JRCaptureApidInterface *singleton = nil;
    if (singleton == nil) {
        singleton = [((JRCaptureApidInterface *)[super allocWithZone:NULL]) init];
    }

    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedCaptureApidInterface] retain];
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

typedef enum CaptureInterfaceStatEnum
{
    StatOk,
    StatFail,
} CaptureInterfaceStat;

+ (void)finishSignInFailureWithError:(JRCaptureError *)error forDelegate:(id)delegate
                         withContext:(NSObject *)context
{
    if ([delegate conformsToProtocol:@protocol(JRCaptureInternalDelegate)] &&
            [delegate respondsToSelector:@selector(signInCaptureUserDidFailWithResult:context:)])
        [delegate signInCaptureUserDidFailWithResult:error context:context];
}

+ (void)signInCaptureUserWithCredentials:(NSDictionary *)credentials forDelegate:(id)delegate
                             withContext:(NSObject *)context
{
    DLog(@"");
    NSString *refreshSecret = [JRCaptureData generateAndStoreRefreshSecret];

    if (!refreshSecret)
    {
        NSString *errMsg = @"unable to generate secure random refresh secret";
        [self finishSignInFailureWithError:[JRCaptureError invalidInternalStateErrorWithDescription:errMsg]
                               forDelegate:delegate withContext:context];
        return;
    }

    NSMutableDictionary *signInParams = [[JRCaptureApidInterface class] tradAuthParamsWithParams:credentials
                                                                                   refreshSecret:refreshSecret
                                                                                        delegate:delegate];
    NSMutableURLRequest *request = [JRCaptureData requestWithPath:kJRTradAuthUrlPath];
    [request JR_setBodyWithParams:signInParams];
    [self startTradAuthForDelegate:delegate context:context request:request];
}

+ (void)startTradAuthForDelegate:(id)delegate context:(NSObject *)context request:(NSURLRequest *)request
{
    NSMutableDictionary *tag = [[@{cTagAction : cSignInUser, @"delegate" : delegate } mutableCopy] autorelease];
    if (context) [tag setObject:context forKey:@"context"];
    JRCaptureApidInterface *singleton = [JRCaptureApidInterface sharedCaptureApidInterface];
    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:singleton withTag:tag])
    {
        JRCaptureError *err = [JRCaptureError connectionCreationErr:request forDelegate:singleton withTag:tag];
        [self finishSignInFailureWithError:err forDelegate:delegate withContext:context];
    }
}

- (void)finishGetCaptureUserWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                         forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");

    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(getCaptureUserDidSucceedWithResult:context:)])
            [delegate getCaptureUserDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(getCaptureUserDidFailWithResult:context:)])
            [delegate getCaptureUserDidFailWithResult:result context:context];
    }
}

- (void)getCaptureUserWithToken:(NSString *)token forDelegate:(id <JRCaptureInternalDelegate>)delegate
                    withContext:(NSObject *)context
{
    NSMutableURLRequest *request = [self entityRequestForPath:nil token:token];

    NSMutableDictionary *tag = [[@{cTagAction : cGetUser, @"delegate" : delegate } mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];
    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                       [[request URL] absoluteString]];
        NSNumber *errCode = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : errCode,
        };
        [self finishGetCaptureUserWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }
}

- (void)finishGetObjectWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                    forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");

    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(getCaptureObjectDidSucceedWithResult:context:)])
            [delegate getCaptureObjectDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(getCaptureObjectDidFailWithResult:context:)])
            [delegate getCaptureObjectDidFailWithResult:result context:context];
    }
}

- (void)getCaptureObjectAtPath:(NSString *)entityPath withToken:(NSString *)token
                   forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    NSMutableURLRequest *request = [self entityRequestForPath:entityPath token:token];

    NSMutableDictionary *tag = [[@{cTagAction : cGetObject, @"delegate" : delegate } mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];
    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                       [[request URL] absoluteString]];
        NSNumber *errCode = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : errCode 
        };
        [self finishGetObjectWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }
}

- (NSMutableURLRequest *)entityRequestForPath:(NSString *)entityPath token:(NSString *)token
{
    NSMutableDictionary *params = [[@{@"access_token" : token} mutableCopy] autorelease];

    if (entityPath && ![entityPath isEqualToString:@""])
        [params setObject:entityPath forKey:@"attribute_name"];

    NSMutableURLRequest *request = [JRCaptureData requestWithPath:@"/entity"];
    [request JR_setBodyWithParams:params];
    return request;
}

- (void)finishUpdateObjectWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                       forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");

    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(updateCaptureObjectDidSucceedWithResult:context:)])
            [delegate updateCaptureObjectDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(updateCaptureObjectDidFailWithResult:context:)])
            [delegate updateCaptureObjectDidFailWithResult:result context:context];
    }
}

- (void)updateObject:(NSDictionary *)captureObject atPath:(NSString *)entityPath
           withToken:(NSString *)token forDelegate:(id <JRCaptureInternalDelegate>)delegate
         withContext:(NSObject *)context
{
    DLog(@"");

    NSString *attributes = [[captureObject JR_jsonString] stringByAddingUrlPercentEscapes];
    NSMutableData *body = [NSMutableData data];

    NSString *attrArgString = [NSString stringWithFormat:@"&attributes=%@", attributes];
    [body appendData:[attrArgString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&access_token=%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"&include_record=true" dataUsingEncoding:NSUTF8StringEncoding]];

    if (!entityPath || [entityPath isEqualToString:@""])
    {
        ;
    }
    else
    {
        NSString *attrNameArgString = [NSString stringWithFormat:@"&attribute_name=%@", entityPath];
        [body appendData:[attrNameArgString dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *updateUrl = [NSString stringWithFormat:@"%@/entity.update",
                                                     [JRCaptureData sharedCaptureData].captureBaseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:updateUrl]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSMutableDictionary *tag = [[@{cTagAction : cUpdateObject, @"delegate" : delegate} mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];

    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                       [[request URL] absoluteString]];
        NSNumber *errCode = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : errCode,
        };
        [self finishUpdateObjectWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }

}

- (void)finishReplaceObjectWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                        forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");
    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(replaceCaptureObjectDidSucceedWithResult:context:)])
            [delegate replaceCaptureObjectDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(replaceCaptureObjectDidFailWithResult:context:)])
            [delegate replaceCaptureObjectDidFailWithResult:result context:context];
    }
}

- (void)replaceObject:(NSDictionary *)captureObject atPath:(NSString *)entityPath
            withToken:(NSString *)token forDelegate:(id <JRCaptureInternalDelegate>)delegate
          withContext:(NSObject *)context
{
    DLog(@"");

    NSString *attributes = [[captureObject JR_jsonString] stringByAddingUrlPercentEscapes];
    NSMutableData *body = [NSMutableData data];

    [body appendData:[[NSString stringWithFormat:@"&attributes=%@", attributes] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&access_token=%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"&include_record=true" dataUsingEncoding:NSUTF8StringEncoding]];

    if (!entityPath || [entityPath isEqualToString:@""])
    {
        ;
    }
    else
    {
        NSString *argString = [NSString stringWithFormat:@"&attribute_name=%@", entityPath];
        [body appendData:[argString dataUsingEncoding:NSUTF8StringEncoding]];        
    }

    NSString *replaceUrl = [NSString stringWithFormat:@"%@/entity.replace",
                                                      [JRCaptureData sharedCaptureData].captureBaseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:replaceUrl]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSMutableDictionary *tag = [[@{cTagAction : cReplaceObject, @"delegate" : delegate} mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];

    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                      [[request URL] absoluteString]];
        NSNumber *errCode = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : errCode,
        };
        [self finishReplaceObjectWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }

}

- (void)finishReplaceArrayWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                       forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");
    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(replaceCaptureArrayDidSucceedWithResult:context:)])
            [delegate replaceCaptureArrayDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(replaceCaptureArrayDidFailWithResult:context:)])
            [delegate replaceCaptureArrayDidFailWithResult:result context:context];
    }
}

- (void)replaceArray:(NSArray *)captureArray atPath:(NSString *)entityPath
           withToken:(NSString *)token forDelegate:(id <JRCaptureInternalDelegate>)delegate
         withContext:(NSObject *)context
{
    DLog(@"");

    NSString *attributes = [[captureArray JR_jsonString] stringByAddingUrlPercentEscapes];
    NSMutableData *body = [NSMutableData data];

    [body appendData:[[NSString stringWithFormat:@"&attributes=%@", attributes] 
            dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&access_token=%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"&include_record=true" dataUsingEncoding:NSUTF8StringEncoding]];

    if (entityPath && ![entityPath isEqualToString:@""])
    {
        NSString *argString = [NSString stringWithFormat:@"&attribute_name=%@", entityPath];
        [body appendData:[argString dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *captureBaseUrl = [JRCaptureData sharedCaptureData].captureBaseUrl;
    NSString *replaceUrl = [NSString stringWithFormat:@"%@/entity.replace", captureBaseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:replaceUrl]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSMutableDictionary *tag = [[@{cTagAction : cReplaceArray, @"delegate" : delegate} mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];

    DLog(@"%@ attributes=%@ access_token=%@ attribute_name=%@", [[request URL] absoluteString], attributes, token,
        entityPath);

    /* tag vs context for workaround */
    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag]) 
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                       [[request URL] absoluteString]];
        NSNumber *code = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : code,
        };
        [self finishReplaceArrayWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }

}

+ (void)signInCaptureUserWithCredentials:(NSDictionary *)credentials ofType:(NSString *)signInType
                             forDelegate:(id)delegate withContext:(NSObject *)context
{
    [JRCaptureApidInterface signInCaptureUserWithCredentials:credentials forDelegate:delegate withContext:context];
}

+ (void)getCaptureUserWithToken:(NSString *)token forDelegate:(id <JRCaptureInternalDelegate>)delegate
                    withContext:(NSObject *)context
{
    [[JRCaptureApidInterface sharedCaptureApidInterface]
            getCaptureUserWithToken:token forDelegate:delegate withContext:context];
}

+ (void)getCaptureObjectAtPath:(NSString *)entityPath withToken:(NSString *)token
                   forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface sharedCaptureApidInterface]
            getCaptureObjectAtPath:entityPath withToken:token forDelegate:delegate withContext:context];
}

+ (void)updateCaptureObject:(NSDictionary *)captureObject atPath:(NSString *)entityPath withToken:(NSString *)token
                forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface sharedCaptureApidInterface]
            updateObject:captureObject atPath:entityPath withToken:token forDelegate:delegate withContext:context];
}

+ (void)replaceCaptureObject:(NSDictionary *)captureObject atPath:(NSString *)entityPath withToken:(NSString *)token
                 forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface sharedCaptureApidInterface]
            replaceObject:captureObject atPath:entityPath withToken:token forDelegate:delegate
              withContext:context];
}

+ (void)replaceCaptureArray:(NSArray *)captureArray atPath:(NSString *)entityPath withToken:(NSString *)token
                forDelegate:(id <JRCaptureInternalDelegate>)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface sharedCaptureApidInterface]
            replaceArray:captureArray atPath:entityPath withToken:token forDelegate:delegate withContext:context];
}

- (void)connectionDidFinishLoadingWithPayload:(NSString *)payload request:(NSURLRequest*)request andTag:(id)userData
{
    DLog(@"%@", payload);

    NSDictionary *tag       = (NSDictionary *) userData;
    NSString     *action    = [tag objectForKey:cTagAction];
    NSObject     *context   = [tag objectForKey:@"context"];

    NSDictionary *response    = [payload JR_objectFromJSONString];
    CaptureInterfaceStat stat = [[response objectForKey:@"stat"] isEqualToString:@"ok"] ? StatOk : StatFail;

    id<JRCaptureInternalDelegate> delegate = [tag objectForKey:@"delegate"];

    if ([action isEqualToString:cSignInUser])
    {
        [self finishSignInUserWithPayload:payload context:context response:response stat:stat delegate:delegate];
    }
    else if ([action isEqualToString:cGetUser])
    {
        [self finishGetCaptureUserWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cGetObject])
    {
        [self finishGetObjectWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cUpdateObject])
    {
        [self finishUpdateObjectWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cReplaceObject])
    {
        [self finishReplaceObjectWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cReplaceArray])
    {
        [self finishReplaceArrayWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
}

- (void)finishSignInUserWithPayload:(NSString *)payload context:(NSObject *)context response:(NSDictionary *)response
                               stat:(CaptureInterfaceStat)stat delegate:(id)delegate
{
    if (stat == StatOk) {
        if ([delegate conformsToProtocol:@protocol(JRCaptureInternalDelegate)] &&
                [delegate respondsToSelector:@selector(signInCaptureUserDidSucceedWithResult:context:)])
            [delegate signInCaptureUserDidSucceedWithResult:payload context:context];
    } else {
        JRCaptureError *error = [JRCaptureError errorFromResult:response onProvider:nil engageToken:nil];    
        [JRCaptureApidInterface finishSignInFailureWithError:error forDelegate:delegate withContext:context];
    }
}

- (void)connectionDidFinishLoadingWithFullResponse:(NSURLResponse*)fullResponse unencodedPayload:(NSData*)payload
                                           request:(NSURLRequest*)request andTag:(id)userData { }

- (void)connectionDidFailWithError:(NSError *)error request:(NSURLRequest*)request andTag:(id)userData
{
    DLog(@"");

    NSDictionary *tag       = (NSDictionary*) userData;
    NSString     *action    = [tag objectForKey:cTagAction];
    NSObject     *context   = [tag objectForKey:@"context"];
    id<JRCaptureInternalDelegate> delegate = [tag objectForKey:@"delegate"];

    NSString *localizedFailureReason = [error localizedFailureReason];
    localizedFailureReason = localizedFailureReason ? localizedFailureReason : @"";
    NSDictionary *errDict = @{
            @"stat" : @"error",
            @"error" : [error localizedDescription],
            @"error_description" : localizedFailureReason,
            @"code" : [NSNumber numberWithInteger:JRCaptureLocalApidErrorConnectionDidFail],
            @"wrapped_error" : error,
    };

    JRCaptureError *wrappingError = [JRCaptureError errorFromResult:errDict onProvider:nil engageToken:nil];

    if ([action isEqualToString:cSignInUser])
    {
        [JRCaptureApidInterface finishSignInFailureWithError:wrappingError forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cGetUser])
    {
        [self finishGetCaptureUserWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cGetObject])
    {
        [self finishGetObjectWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cUpdateObject])
    {
        [self finishUpdateObjectWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cReplaceObject])
    {
        [self finishReplaceObjectWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cReplaceArray])
    {
        [self finishReplaceArrayWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
}

+ (NSMutableDictionary *)tradAuthParamsWithParams:(NSDictionary *)paramsDict refreshSecret:(NSString *)refreshSecret
                                         delegate:(id <JRCaptureDelegate>)delegate {
    NSDictionary *flowCreds = [self flowCredentialsFromStaticCredentials:paramsDict];
    NSDictionary *credsParams = flowCreds ? flowCreds : paramsDict;
    JRCaptureData *captureData = [JRCaptureData sharedCaptureData];

    NSMutableDictionary *signInParams = [[@{
            @"client_id" : captureData.clientId,
            @"locale" : captureData.captureLocale,
            @"form" : captureData.captureTraditionalSignInFormName,
            @"redirect_uri" : [captureData redirectUri],
            @"response_type" : [captureData responseType:delegate],
            @"refresh_secret" : refreshSecret
    } mutableCopy] autorelease];

    [signInParams addEntriesFromDictionary:credsParams];
    [signInParams JR_maybeSetObject:[JRCaptureData sharedCaptureData].bpChannelUrl forKey:@"bp_channel"];
    [signInParams JR_maybeSetObject:[JRCaptureData sharedCaptureData].captureFlowName forKey:@"flow"];
    [signInParams JR_maybeSetObject:[JRCaptureData sharedCaptureData].downloadedFlowVersion forKey:@"flow_version"];
    [signInParams JR_maybeSetObject:[paramsDict objectForKey:@"merge_token"] forKey:@"merge_token"];
    return signInParams;
}

/*
 * Takes legacy style static credential dictionary and creates a credentials dictionary suitable for submission to the
 * traditional sign-in form.
 *
 * So, e.g. for the standard reg flow @{ @"email":@"a@a.com", @"password":@"a" } goes to:
 *
 * @{
 *     @"traditionalSignIn_email" : @"a@a.com",
 *     @"traditionalSignIn_password" : @"a"
 * }
 *
 * The "name"~ field must be named either "email", "username", or "user". No other field name is allowable.
*/
+ (NSDictionary *)flowCredentialsFromStaticCredentials:(NSDictionary *)dictionary {
    NSString *password = [dictionary objectForKey:@"password"];
    NSString *name = [dictionary objectForKey:@"email"];
    if (!name) name = [dictionary objectForKey:@"username"];
    if (!name) name = [dictionary objectForKey:@"user"];

    return [self flowTraditionalSignInCredentialsForName:name andPassword:password];
}

/*
 * Finds a password field in the trad sign-in form, maps it to the given password argument
 * Finds any other field in the form, maps it to the given name argument
 *
 * Naturally, this assumes there are only two fields in the trad reg form, and that one is of type password.
 */
+ (NSDictionary *)flowTraditionalSignInCredentialsForName:(NSString *)name andPassword:(NSString *)password {
    JRCaptureData *data = [JRCaptureData sharedCaptureData];
    JRCaptureFlow *captureFlow = [data captureFlow];
    NSDictionary *fields = [captureFlow objectForKey:@"fields"];
    NSString *tradSignInFormName = [data captureTraditionalSignInFormName];
    NSDictionary *tradSignInForm = [fields objectForKey:tradSignInFormName];
    NSArray *tradSignInFields = [tradSignInForm objectForKey:@"fields"];

    if ([tradSignInFields count] > 2) [NSException raiseJRDebugException:@"unsupportedFormException"
                                                                  format:@"the traditional sign-in form configured in"
                                                                          " your flow uses more than two fields, which"
                                                                          " is unsupported in the native clients."];

    NSString *passwordFieldName = nil;
    NSString *anyOtherFieldName = nil;
    for (NSString *fieldName in tradSignInFields) {
        NSDictionary *field = [fields objectForKey:fieldName];
        NSString *type = [field objectForKey:@"type"];
        if ([type isEqualToString:@"password"]) passwordFieldName = fieldName;
        else anyOtherFieldName = fieldName;
    }

    if (anyOtherFieldName && passwordFieldName && name && password) {
        return @{anyOtherFieldName : name, passwordFieldName : password};
    } else {
        return nil;
    }
}

- (void)connectionWasStoppedWithTag:(id)userData { }
@end
