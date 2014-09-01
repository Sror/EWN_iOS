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

#import "JRCaptureFlow.h"

@interface JRCaptureFlow()
@property (nonatomic, copy) NSDictionary *flowDict;
@end

@implementation JRCaptureFlow {

}
+ (JRCaptureFlow *)flowWithDictionary:(NSDictionary *)dict {
    JRCaptureFlow *flow = [[JRCaptureFlow alloc] initWithDictionary:dict];

#if __has_feature(objc_arc)
    return flow;
#else
    return [flow autorelease];
#endif
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _flowDict = [dict copy];
    }

    return self;
}

- (NSDictionary *)dictionary {
    return self.flowDict;
}

- (id)objectForKey:(id)key {
    return [self.flowDict objectForKey:key];
}

- (id)schemaIdForFieldName:(NSString *)fieldName {
    NSDictionary *schemaInfo = [self.flowDict objectForKey:@"schema_info"];
    NSDictionary *paths = [schemaInfo objectForKey:@"paths"];
    return [paths objectForKey:fieldName];
}

- (NSMutableDictionary *)fieldsForForm:(NSString *)formName fromDictionary:(NSDictionary *)dict {
    NSDictionary *form = [self.fields objectForKey:formName];
    NSArray *fieldNames = [form objectForKey:@"fields"];
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];

    for (NSString *key in fieldNames) {
        if ([dict objectForKey:key]) [fields setObject:[dict objectForKey:key] forKey:key];
    }

    return fields;
}

- (NSString *)userIdentifyingFieldForForm:(NSString *)formName{

    NSDictionary *fields = [self fields];
    NSDictionary *form = [fields objectForKey:formName];
    NSArray *formFields = [form objectForKey:@"fields"];

    for (NSString *fieldName in formFields) {
        NSDictionary *field = [fields objectForKey:fieldName];
        NSString * type = [field objectForKey:@"type"];

        if ([type isEqualToString:@"email"] || [type isEqualToString:@"text"]) {
            return fieldName;
        }
    }

    return nil;
}

- (NSDictionary *)fields {
    return [self objectForKey:@"fields"];
}

- (void)dealloc
{
#if !__has_feature(objc_arc)
    [_flowDict release];

    [super dealloc];
#endif
}


@end