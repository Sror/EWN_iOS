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

#import <Foundation/Foundation.h>
#import "JRCaptureUser.h"

@class JRCaptureFlow;

/**
 * @internal
 */
@interface JRCaptureUser (Private)
+ (id)captureUserObjectFromDictionary:(NSDictionary *)dictionary withPath:(NSString *)capturePath;

- (void)decodeFromDictionary:(NSDictionary *)dictionary;
@end

/**
 * @internal
 */
@interface JRCaptureUser (JRCaptureUser_Internal_Extras)
- (NSMutableDictionary *)toFormFieldsForForm:(NSString *)formName withFlow:(JRCaptureFlow *)flow;

+ (JRCaptureUser *)captureUserObjectWithPrefilledFields:(NSDictionary *)prefilledFields flow:(JRCaptureFlow *)flow;

+ (BOOL)hasPasswordField:(NSDictionary *)userDict;
@end

@protocol JRCaptureObjectDelegate;

/**
 * @brief
 * Protocol adopted by an object that wishes wishes to to receive notifications when creating a JRCaptureUser on the
 * Capture server or fetching the remote JRCaptureUser from the Capture server
 **/
@protocol JRCaptureUserDelegate <JRCaptureObjectDelegate>
@optional
/**
 * Sent if a call to JRCaptureUser#fetchCaptureUserFromServerForDelegate:context:() succeeded
 *
 * @param fetchedUser
 *   The JRCaptureUser that was fetched from the Capture server
 *
 * @param context
 *   The same NSObject that was sent to the method JRCaptureUser#fetchCaptureUserFromServerForDelegate:context:().
 *   The \e context argument is used if you would like to send some data through the asynchronous network call back
 *   to your delegate, or \c nil. This object will be passed back to your JRCaptureUserDelegate as is. Contexts are
 *   used across most of the asynchronous Capture methods to facilitate correlation of the response messages with the
 *   calling code. Use of the context is entirely optional and at your discretion.
 **/
- (void)fetchUserDidSucceed:(JRCaptureUser *)fetchedUser context:(NSObject *)context;

/**
 * Sent if a call to JRCaptureUser#fetchCaptureUserFromServerForDelegate:context:() failed
 *
 * @param error
 *   The cause of the failure. Please see the list of \ref captureErrors "Capture Errors" for more information
 *
 * @param context
 *   The same NSObject that was sent to the method JRCaptureUser#fetchCaptureUserFromServerForDelegate:context:().
 *   The \e context argument is used if you would like to send some data through the asynchronous network call back
 *   to your delegate, or \c nil. This object will be passed back to your JRCaptureUserDelegate as is. Contexts are
 *   used across most of the asynchronous Capture methods to facilitate correlation of the response messages with the
 *   calling code. Use of the context is entirely optional and at your discretion.
 **/
- (void)fetchUserDidFailWithError:(NSError *)error context:(NSObject *)context;

@end

/**
 * @brief
 * The top-level class that holds the Capture user record
 **/
@interface JRCaptureUser (JRCaptureUser_Extras)

/**
 * Sent if ...
 *
 * @param delegate
 *   delegate
 *
 * @param context
 *   Any NSObject that you would like to send through the asynchronous network call back to your delegate, or \c nil.
 *   This object will be passed back to your JRCaptureUserDelegate as is.Contexts are used across most of the
 *   asynchronous Capture methods to facilitate correlation of the response messages with the calling code. Use of the
 *   context is entirely optional and at your discretion.
 **/
+ (void)fetchCaptureUserFromServerForDelegate:(id <JRCaptureUserDelegate>)delegate context:(NSObject *)context __unused;

/**
 * @internal
 **/
+ (id)captureUserObjectFromDictionary:(NSDictionary *)dictionary;
@end
