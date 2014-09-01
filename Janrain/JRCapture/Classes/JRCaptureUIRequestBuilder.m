/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2013, Janrain, Inc.

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

#import "JRCaptureUIRequestBuilder.h"
#import "JRCaptureUser.h"
#import "JRCaptureEnvironment.h"
#import "NSMutableURLRequest+JRRequestUtils.h"
#import "JRCaptureFlow.h"

@interface JRCaptureUIRequestBuilder()
   @property (nonatomic, retain) id<JRCaptureEnvironment> environment;
@end

@implementation JRCaptureUIRequestBuilder {
}

- (id)initWithEnvironment:(id <JRCaptureEnvironment>)environment {
    if (self = [super init]) {
#if !__has_feature(objc_arc)
        [environment retain];
#endif
        _environment = environment;
    }

    return self;
}

- (NSURLRequest *)requestWithUser:(JRCaptureUser *)user form:(NSString *)formName {
    // For future use
    return nil;
}

- (NSURLRequest *)requestWithParams:(NSDictionary *)namedParams form:(NSString *)formName {
    NSURL *url = [self captureUrlForForm:formName];

    NSMutableDictionary *params = [self.environment.captureFlow fieldsForForm:formName fromDictionary:namedParams];
    [params addEntriesFromDictionary:[self standardParameters]];
    [params setObject:self.environment.redirectUri forKey:@"redirect_uri"];
    [params setObject:formName forKey:@"form"];

    return [NSMutableURLRequest JR_requestWithURL:url params:params];
}

- (NSURL *)captureUrlForForm:(NSString *)formName {
    NSString *endpoint = nil;

    // In a dream world, we'd look this up in the flow.
    if ([formName isEqualToString:self.environment.resendEmailVerificationFormName]) {
        endpoint = @"/oauth/verify_email_native";
    } else if ([formName isEqualToString:self.environment.captureForgottenPasswordFormName]) {
        endpoint = @"/oauth/forgot_password_native";
    }

    if (endpoint) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.environment.captureBaseUrl, endpoint]];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"%@ is not a valid form name", formName];
    }
    return nil;
}

- (NSDictionary *)standardParameters {
    return @{
            @"client_id" : self.environment.clientId,
            @"flow" : self.environment.captureFlowName,
            @"flow_version" : self.environment.downloadedFlowVersion,
            @"locale" : self.environment.captureLocale,
            @"response_type" : @"token"
    };
}

- (void)dealloc
{
#if !__has_feature(objc_arc)
    [_environment release];

    [super dealloc];
#endif
}

@end