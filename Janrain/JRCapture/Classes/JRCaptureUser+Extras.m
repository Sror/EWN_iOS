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
#import "JRCaptureApidInterface.h"
#import "JRCaptureObject.h"
#import "JRCaptureUser+Extras.h"
#import "JRCaptureError.h"
#import "JRCaptureObject+Internal.h"
#import "JRCaptureFlow.h"

@interface JRCaptureUserApidHandler : NSObject <JRCaptureInternalDelegate>
@end

@implementation JRCaptureUserApidHandler
+ (id)captureUserApidHandler
{
    return [[[JRCaptureUserApidHandler alloc] init] autorelease];
}

- (void)getCaptureUserDidFailWithResult:(NSDictionary *)result context:(NSObject *)context
{
    DLog(@"");
    NSDictionary *myContext = (NSDictionary *) context;
    NSObject *callerContext = [myContext objectForKey:@"callerContext"];
    id <JRCaptureUserDelegate> delegate = [myContext objectForKey:@"delegate"];

    if ([delegate respondsToSelector:@selector(fetchUserDidFailWithError:context:)])
        [delegate fetchUserDidFailWithError:[JRCaptureError errorFromResult:result onProvider:nil engageToken:nil]
                                    context:callerContext];
}

- (void)getCaptureUserDidSucceedWithResult:(NSDictionary *)result context:(NSObject *)context
{
    DLog(@"");
    NSDictionary *myContext = (NSDictionary *) context;
    NSObject *callerContext = [myContext objectForKey:@"callerContext"];
    id <JRCaptureUserDelegate> delegate = [myContext objectForKey:@"delegate"];

    if (!result)
        return [self getCaptureUserDidFailWithResult:[JRCaptureError invalidDataErrorDictForResult:result]
                                             context:context];

    if (![((NSString *)[result objectForKey:@"stat"]) isEqualToString:@"ok"])
        return [self getCaptureUserDidFailWithResult:[JRCaptureError invalidStatErrorDictForResult:result]
                                             context:context];

    NSDictionary *result_ = [result objectForKey:@"result"];
    if (!result_ || ![result_ isKindOfClass:[NSDictionary class]])
        return [self getCaptureUserDidFailWithResult:[JRCaptureError invalidDataErrorDictForResult:result]
                                             context:context];

    JRCaptureUser *captureUser = [JRCaptureUser captureUserObjectFromDictionary:result_];
    [JRCaptureData setLinkedProfiles:[[result valueForKey:@"result"] valueForKey:@"profiles"]];

    if ([delegate respondsToSelector:@selector(fetchUserDidSucceed:context:)])
        [delegate fetchUserDidSucceed:captureUser context:callerContext];
}
@end

@implementation JRCaptureUser (JRCaptureUser_Extras)

+ (void)fetchCaptureUserFromServerForDelegate:(id<JRCaptureUserDelegate>)delegate
                                      context:(NSObject *)context __unused
{
    DLog(@"");
    NSDictionary *newContext = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     @"/", @"capturePath",
                                                     delegate, @"delegate",
                                                     context, @"callerContext", nil];

    [JRCaptureApidInterface getCaptureUserWithToken:[[JRCaptureData sharedCaptureData] accessToken]
                                        forDelegate:[JRCaptureUserApidHandler captureUserApidHandler]
                                        withContext:newContext];
}

+ (id)captureUserObjectFromDictionary:(NSDictionary *)dictionary
{
    JRCaptureUser *user = [JRCaptureUser captureUserObjectFromDictionary:dictionary withPath:@""];
    // MOB-143, clear DPS on all sub-objects
    [user deepClearDirtyProperties];
    return user;
}

+ (void)testCaptureUserApidHandlerGetCaptureUserDidFailWithResult:(NSDictionary *)result
                                                          context:(NSObject *)context __unused
{
    [[JRCaptureUserApidHandler captureUserApidHandler] getCaptureUserDidFailWithResult:result context:context];
}

+ (void)testCaptureUserApidHandlerGetCaptureUserDidSucceedWithResult:(NSDictionary *)result
                                                             context:(NSObject *)context __unused
{
    [[JRCaptureUserApidHandler captureUserApidHandler] getCaptureUserDidSucceedWithResult:result context:context];
}

@end

@interface NSArray (JRArrayExtensions)
- (NSArray *)tail;
@end

@implementation JRCaptureUser (JRCaptureUser_Internal_Extras)
- (NSMutableDictionary *)toFormFieldsForForm:(NSString *)formName withFlow:(JRCaptureFlow *)flow
{
    if (!formName || !flow) return nil;

    NSMutableDictionary *retval = [NSMutableDictionary dictionary];
    NSDictionary *form = [[flow objectForKey:@"fields"] objectForKey:formName];
    NSArray *fieldNames = [form objectForKey:@"fields"];
    NSArray *fields = [[flow objectForKey:@"fields"] objectsForKeys:fieldNames notFoundMarker:[NSNull null]];

    for (NSObject *field in fields) {
        if (![field isKindOfClass:[NSDictionary class]]) {
            ALog(@"unrecognized field defn: %@", [field description]);
            continue;
        }

        id schemaId = [(NSDictionary *) field objectForKey:@"schemaId"];
        NSString *key = [fieldNames objectAtIndex:[fields indexOfObject:field]];

        if ([schemaId isKindOfClass:[NSString class]]) {
            if ([[(NSDictionary *) field objectForKey:@"type"] isEqualToString:@"dateselect"]) {
                [self setForDateValueFromDotPath:schemaId forKey:key dictionary:retval];
            } else {
                [self setForValueFromDotPath:schemaId forKey:key dictionary:retval];
            }
        } else if ([schemaId isKindOfClass:[NSDictionary class]]) {
            for (NSString *subscript in schemaId) {
                NSString *dotPath = [schemaId objectForKey:subscript];
                NSString *paramName = [NSString stringWithFormat:@"%@[%@]", key, subscript];
                [self setForValueFromDotPath:dotPath forKey:paramName dictionary:retval];
            }
        }
    }

    return retval;
}

+(BOOL)hasPasswordField:(NSDictionary *)dict {
    NSString *component = [[[JRCaptureData sharedCaptureData] captureFlow] schemaIdForFieldName:@"password"];
    NSArray *pathComponents = [component componentsSeparatedByString:@"."];
    NSString *passwordValue =  [JRCaptureUser valueForAttrByDotPathComponents:pathComponents userDict:dict];
    
    return (passwordValue && [passwordValue length]);
}
- (void)setForValueFromDotPath:(NSString *)dotPath forKey:(NSString *)key dictionary:(NSMutableDictionary *)dictionary
{
    NSString *formFieldValue = [self valueForAttrByDotPath:dotPath];

    if (formFieldValue) {
        [dictionary setObject:formFieldValue forKey:key];
    }
}

- (void)setForDateValueFromDotPath:(NSString *)dotPath forKey:(NSString *)key
                        dictionary:(NSMutableDictionary *)dictionary
{

    NSString *formFieldValue = [self valueForAttrByDotPath:dotPath];

    if (formFieldValue) {
        // The date is in the format yyyy-MM-dd
        NSArray *dateParts = [formFieldValue componentsSeparatedByString:@"-"];
        if ([dateParts count] == 3) {
            [dictionary setObject:dateParts[0] forKey:[key stringByAppendingString:@"[dateselect_year]"]];
            [dictionary setObject:dateParts[1] forKey:[key stringByAppendingString:@"[dateselect_month]"]];
            [dictionary setObject:dateParts[2] forKey:[key stringByAppendingString:@"[dateselect_day]"]];
        }
    }
}

- (NSString *)valueForAttrByDotPath:(NSString *)dotPath
{
    NSArray *pathComponents = [dotPath componentsSeparatedByString:@"."];
    return [JRCaptureUser valueForAttrByDotPathComponents:pathComponents userDict:[self toDictionaryForEncoder:NO]];
}

+ (NSString *)valueForAttrByDotPathComponents:(NSArray *)dotPathComponents userDict:(id)userDict
{
    if ([dotPathComponents count] == 0) return [self jsonStringForValue:userDict];

    if (![userDict isKindOfClass:[NSDictionary class]]) return nil;
    NSDictionary *userDict_ = userDict;
    NSString *dotPathComponent = [dotPathComponents objectAtIndex:0];
    NSArray *tail = [dotPathComponents tail];
    NSArray *pluralSplit = [dotPathComponent componentsSeparatedByString:@"#"];
    if ([pluralSplit count] > 1)
    {
        id val = [userDict_ objectForKey:[pluralSplit objectAtIndex:0]];
        if (![val isKindOfClass:[NSArray class]]) return nil;
        for (id elt in val)
        {
            if (![elt isKindOfClass:[NSDictionary class]]) return nil;
            if ([[elt objectForKey:@"id"] isEqual:[pluralSplit objectAtIndex:1]])
            {
                return [self valueForAttrByDotPathComponents:tail userDict:elt];
            }
        }
        return nil;
    }
    else
    {
        id val = [userDict_ objectForKey:dotPathComponent];
        return [self valueForAttrByDotPathComponents:tail userDict:val];
    }
}

+ (NSString *)jsonStringForValue:(id)userDict
{
    if (userDict == [NSNull null]) return nil;
    // This hack will get us the string-ified version of a JSON-able value.
    NSError *ignore = nil;
    NSArray *thisIsAHack = [NSArray arrayWithObject:userDict];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:thisIsAHack options:(NSJSONWritingOptions) 0
                                                             error:&ignore];
    NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    if ([jsonString characterAtIndex:1] == '"')
        {
            return [jsonString substringWithRange:NSMakeRange(2, [jsonString length] - 4)];
        }
        else
        {
            return [jsonString substringWithRange:NSMakeRange(1, [jsonString length] - 2)];
        }
}

+ (JRCaptureUser *)captureUserObjectWithPrefilledFields:(NSDictionary *)prefilledFields flow:(JRCaptureFlow *)flow
{
    NSMutableDictionary *preregAttributes = [NSMutableDictionary dictionary];
    for (id key in prefilledFields)
    {
        id value = [prefilledFields objectForKey:key];
        if ([value isEqual:[NSNull null]]) continue;
        NSDictionary *fieldDefn = [self fieldDictForFieldName:key flow:flow];
        if ([fieldDefn isKindOfClass:[NSDictionary class]] && [fieldDefn objectForKey:@"schemaId"])
        {
            [preregAttributes setObject:value forKey:[fieldDefn objectForKey:@"schemaId"]];
        }
    }
    return [JRCaptureUser captureUserObjectFromDictionary:preregAttributes];
}

+ (NSDictionary *)fieldDictForFieldName:(NSString *)fieldName flow:(JRCaptureFlow *)flow
{
    NSDictionary *fields = [flow objectForKey:@"fields"];
    for (id key in fields)
    {
        if ([key isEqual:fieldName]) return [fields objectForKey:key];
    }
    return nil;
}

@end

@implementation NSArray (JRArrayExtensions)
- (NSArray *)tail
{
    if ([self count] == 0) return nil;
    if ([self count] == 1) return @[];
    return [self subarrayWithRange:NSMakeRange(1, [self count] - 1)];
}
@end