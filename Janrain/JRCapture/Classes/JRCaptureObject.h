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

@class JRCaptureObject;

/**
 * @brief
 * Protocol adopted by an object that wishes to to receive notifications when updating a local JRCaptureObject or
 * replacing an array on the Capture server
 **/
@protocol JRCaptureObjectDelegate <NSObject>
@optional

/**
 * Sent if a call to JRCaptureObject#updateOnCaptureForDelegate:context:() succeeded for the JRCaptureObject on which
 * the selector was performed.
 *
 * @param object
 *   The object on which the selector JRCaptureObject#updateOnCaptureForDelegate:context:() was performed
 *
 * @param context
 *   The same NSObject that was sent to the method JRCaptureObject#updateOnCaptureForDelegate:context:().
 *   The \e context argument is used if you would like to send some data through the asynchronous network call back
 *   to your delegate, or \c nil. This object will be passed back to your JRCaptureObjectDelegate as is. Contexts are
 *   used across most of the asynchronous Capture methods to facilitate correlation of the response messages with the
 *   calling code. Use of the context is entirely optional and at your discretion.
 **/
- (void)updateDidSucceedForObject:(JRCaptureObject *)object context:(NSObject *)context;

/**
 * Sent if a call to JRCaptureObject#updateOnCaptureForDelegate:context:() failed for the JRCaptureObject on which
 * the selector was performed.
 *
 * @param object
 *   The object on which the selector JRCaptureObject#updateOnCaptureForDelegate:context:() was performed
 *
 * @param error
 *   The cause of the failure. Please see the list of \ref captureErrors "Capture Errors" for more information
 *
 * @param context
 *   The same NSObject that was sent to the method JRCaptureObject#updateOnCaptureForDelegate:context:().
 *   The \e context argument is used if you would like to send some data through the asynchronous network call back
 *   to your delegate, or \c nil. This object will be passed back to your JRCaptureObjectDelegate as is. Contexts are
 *   used across most of the asynchronous Capture methods to facilitate correlation of the response messages with the
 *   calling code. Use of the context is entirely optional and at your discretion.
 **/
- (void)updateDidFailForObject:(JRCaptureObject *)object withError:(NSError *)error context:(NSObject *)context;

/**
 * Sent if a call to <code>replace&lt;<em>ArrayName</em>&gt;ArrayOnCaptureForDelegate:context:</code> succeeded for
 * the JRCaptureObject on which the selector was performed.
 *
 * @param object
 *   The object on which the selector <code>replace&lt;<em>ArrayName</em>&gt;ArrayOnCaptureForDelegate:context:</code>
 *   was performed
 *
 * @param replacedArray
 *   A pointer to the new array.
 *
 * @param arrayName
 *   The name of the array property. For example, if the method JRCaptureUser#replaceStatusesArrayOnCaptureForDelegate:context:
 *   was called, this argument would have the value \c "statuses"
 *
 * @param context
 *   The same NSObject that was sent to the method JRCaptureObject#updateOnCaptureForDelegate:context:().
 *   The \e context argument is used if you would like to send some data through the asynchronous network call back
 *   to your delegate, or \c nil. This object will be passed back to your JRCaptureObjectDelegate as is. Contexts are
 *   used across most of the asynchronous Capture methods to facilitate correlation of the response messages with the
 *   calling code. Use of the context is entirely optional and at your discretion.
 *
 * @warning
 * When successful, the new array will be added to the object's property, replacing the existing NSArray. The new array
 * will contain new, but equivalent elements as the array did before the replace. That is to say, the elements will be
 * the same, but they will have new pointers. You should not hold onto any references to the array or its elements
 * when you are replacing an array on Capture. The old pointers will become invalid, and the new array will be stored
 * in the object as well as getting returned to you, as the \e replacedArray argument of this method.
 *
 **/
- (void)replaceArrayDidSucceedForObject:(JRCaptureObject *)object newArray:(NSArray *)replacedArray
                                  named:(NSString *)arrayName context:(NSObject *)context;

/**
 * Sent if a call to <code>replace&lt;<em>ArrayName</em>&gt;ArrayOnCaptureForDelegate:context:</code> failed for
 * the JRCaptureObject on which the selector was performed.
 *
 * @param object
 *   The object on which the selector <code>replace&lt;<em>ArrayName</em>&gt;ArrayOnCaptureForDelegate:context:</code>
 *   was performed
 *
 * @param arrayName
 *   The name of the array property. For example, if the method JRCaptureUser#replaceStatusesArrayOnCaptureForDelegate:context:
 *   was called, this argument would have the value \c "statuses"
 *
 * @param error
 *   The cause of the failure. Please see the list of \ref captureErrors "Capture Errors" for more information
 *
 * @param context
 *   The same NSObject that was sent to the method JRCaptureObject#updateOnCaptureForDelegate:context:().
 *   The \e context argument is used if you would like to send some data through the asynchronous network call back
 *   to your delegate, or \c nil. This object will be passed back to your JRCaptureObjectDelegate as is. Contexts are
 *   used across most of the asynchronous Capture methods to facilitate correlation of the response messages with the
 *   calling code. Use of the context is entirely optional and at your discretion.
 **/
- (void)replaceArrayDidFailForObject:(JRCaptureObject *)object arrayNamed:(NSString *)arrayName
                           withError:(NSError *)error context:(NSObject *)context;
@end

/**
 * @brief
 * Base class for all Capture objects and plural elements
 **/
@interface JRCaptureObject : NSObject
/**
 * \c YES if this object can be updated on Capture with the method JRCaptureObject#updateOnCaptureForDelegate:context:().
 * \c NO if it can't. Always \c YES if the object or any of its ancestors are \e not elements of a plural.
 *
 * Use this property to determine if the object or element can be updated on Capture or if this object's parent array
 * needs to be replaced first. If this object, or one of its ancestors, is an element of a plural, this object may or
 * may not be updated on Capture. If an element of a plural was added locally (newly allocated on the client), then the
 * array must be replaced before the element can use the method JRCaptureObject#updateOnCaptureForDelegate:context:().
 * Even if JRCaptureObject#needsUpdate returns \c YES, this object cannot be updated on Capture unless
 * JRCaptureObject#canBeUpdatedOnCapture also returns \c YES.
 *
 * That is, if any elements of a plural have changed, (added, removed, or reordered) the array
 * must be replaced on Capture with the appropriate <code>replace&lt;<em>ArrayName</em>&gt;ArrayOnCaptureForDelegate:context:</code>
 * method, before updating the elements. As such, this should be done immediately.
 *
 * @note
 * Replacing the array will also update any local changes to the properties of a the array's elements, including
 * sub-arrays and sub-objects.
 **/
@property (readonly) BOOL canBeUpdatedOnCapture;

/**
 * Use this method to determine if the object or element needs to be updated remotely.
 * That is, if there are local changes to any of the object/elements's properties or
 * sub-objects, then this object will need to be updated on Capture. You can update
 * an object on Capture by using the method updateOnCaptureForDelegate:context:().
 *
 * @return
 * \c YES if this object or any of it's sub-objects have any properties that have changed
 * locally. This does not include properties that are arrays, if any, or the elements contained
 * within the arrays. \c NO if no non-array properties or sub-objects have changed locally.
 *
 * @note
 * This method recursively checks all of the sub-objects of the JRCaptureObject.
 * If any of these objects are new, or if they need to be updated, this method returns \c YES.
 *
 * @warning
 * If this object, or one of its ancestors, is an element of a plural, and if any elements of the plural have changed,
 * (added or removed) the array must be replaced on Capture before the elements or their sub-objects can be
 * updated. Please use the appropriate <code>replace&lt;<em>ArrayName</em>&gt;ArrayOnCaptureForDelegate:context:</code>
 * method first. Even if needsUpdate returns \c YES, this object cannot be updated on Capture unless
 * canBeUpdatedOnCapture also returns \c YES.
 *
 * @par
 * This method recursively checks all of the sub-objects of the JRCaptureObject but does not check any of the arrays
 * or the arrays' elements. If you have added or removed any elements from the arrays, you must call the appropriate
 * <code>replace&lt;<em>ArrayName</em>&gt;ArrayOnCaptureForDelegate:context:</code> methods to update the array on
 * Capture. Otherwise, if the arrays' elements' canBeUpdatedOnCapture and needsUpdate returns \c YES, you can update
 * the elements by calling updateOnCaptureForDelegate:context:().
 **/
- (BOOL)needsUpdate;

/**
 * Sent if ...
 *
 * @param delegate
 *   delegate
 *
 * @param context
 *   Any NSObject that you would like to send through the asynchronous network call back to your delegate, or \c nil.
 *   This object will be passed back to your JRCaptureObjectDelegate as is.Contexts are used across most of the
 *   asynchronous Capture methods to facilitate correlation of the response messages with the calling code. Use of the
 *   context is entirely optional and at your discretion.
 **/
- (void)updateOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate
                           context:(NSObject *)context;
@end

