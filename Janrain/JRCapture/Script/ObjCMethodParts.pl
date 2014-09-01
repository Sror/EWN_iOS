#!/usr/bin/env perl

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Copyright (c) 2012, Janrain, Inc.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation and/or
#   other materials provided with the distribution.
# * Neither the name of the Janrain, Inc. nor the names of its
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# File:   ObjCMethodParts.pl
# Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
# Date:   Wednesday, February 8, 2012
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

###################################################################
# OBJC METHODS TO BE POPULATED WITH PROPERTIES
###################################################################

###################################################################
# MINIMUM INSTANCE CONSTRUCTOR (W/O REQUIRED PROPERTIES)
#
#                                              (Section only here when there are required properties)     
#                                                                          |
# /**                                                                      |
#  * Default instance constructor. Returns an empty <objectClass> object.  |
#  *                                                                       |
#  * @return                                                               |
#  *   A <objectClass> object                                              |
#  *                                                                       |
#  * @note Method creates a <objectClass> object without the required      |
#  * properties: <requiredProperties>.  These properties are required <----+
#  * when updating the object on Capture.
#  **/
# - (id)init
# {                                                              
#     if ((self = [super init]))                                 
#     {     
#         self.captureObjectPath = @"<entity_path>";
#         self.canBeUpdatedOnCapture = <YES_or_NO>;\n
#
#         <subobjectProperty> = [JR<subobjectClass> alloc] init];
#
#         [self.dirtyPropertySet setSet:[NSMutableSet setWithObjects:@"<objectProperty1>", @"<objectProperty2>, ... , nil]];
#     }
#
#     return self;
# }
###################################################################

my @minConstructorDocParts = (
"/**
 * Default instance constructor. Returns an empty ",""," object
 *
 * \@return
 *   A ",""," object\n",
"","", 
" **/\n");

my @minConstructorParts = (
"- (id)init",
"\n{\n",
"    if ((self = [super init]))
    {\n",
    "","

        [self.dirtyPropertySet setSet:[self updatablePropertySet]];
    }
    return self;
}\n\n");



###################################################################
# INSTANCE CONSTRUCTOR (W REQUIRED PROPERTIES)
# (Method only here when there are required properties)
# 
# /**
#  * Returns a <objectClass> object initialized with the given required properties: <requiredProperties>
#  *
#  * @param <requiredProperty>
#  *   <requiredPropertyDescription>
#  *
#  * @return
#  *   A <objectClass> object initialized with the given <requiredProperties>
#  *   If the required arguments are \e nil or \e [NSNull null], returns \e nil
#  **/
# - (id)init<requiredProperties>
# {
#     if(!<requriredProperties>)
#     {                         
#       [self release];         
#       return nil;             
#     }                         
#                               
#     if ((self = [super init]))
#     {                         
#         self.captureObjectPath = @"<entity_path>";         
#                                                            
#         <requiredProperty> = [new<requiredProperty> copy];
#           ...
#
#         <subobjectProperty> = [JR<subobjectClass> alloc] init];
#
#         [self.dirtyPropertySet setSet:[NSMutableSet setWithObjects:@"<objectProperty1>", @"<objectProperty2>, ... , nil]];
#     }
#
#     return self;
# }
###################################################################

my @constructorDocParts = (
"/**
 * Returns a ",""," object initialized with the given required properties: ","","
 *",
"", 
" 
 * \@return
 *   A ",""," object initialized with the given required properties: ","",".\n",
" *   If the required arguments are \\e nil or \\e [NSNull null], returns \\e nil
 **/\n");

my @constructorParts = (
"- (id)init","",
"\n{\n",
"    if (","",")\n",
"    {
        [self release];
        return nil;
     }\n\n",
"    if ((self = [super init]))
    {\n",
    "","
    
        [self.dirtyPropertySet setSet:[self updatablePropertySet]];
    }
    return self;
}\n\n");


###################################################################
# MINIMUN CLASS CONSTRUCTOR (W/O REQUIRED PROPERTIES)
#
#                      (Section only here when there are required properties)     
#                                               |
# /**                                           |
#  * Default class constructor. Returns an      |
#  * empty <objectClass> object                 |
#  *                                            |
#  * @return                                    |
#  *   A <objectClass> object                   |
#  *                                            V
#  * @note Method creates a <objectClass> object without the required
#  * properties: <requiredProperties>.  These properties are required
#  * when updating the object on Capture.
#  **/
# + (id)<objectName>    
# {                                             
#     return [[[<className> alloc] init] autorelease]; 
# }
###################################################################

my @minClassConstructorDocParts = (
"/**
 * Default class constructor. Returns an empty ",""," object
 *
 * \@return
 *   A ",""," object\n",
"","", 
" **/\n");

my @minClassConstructorParts = (
"+ (id)","",
"\n{\n",
"    return [[[",""," alloc] init] autorelease];",
"\n}\n\n"); 

###################################################################
# CLASS CONSTRUCTOR (W REQUIRED PROPERTIES)
# (Method only here when there are required properties)
# 
# /**
#  * Returns a <objectClass> object initialized with the given required properties: <requiredProperties>
#  *
#  * @param <requiredProperty>
#  *   <requiredPropertyDescription>
#  *
#  * @return
#  *   A <objectClass> object initialized with the given required properties: <requiredProperties>
#  *   If the required arguments are \e nil or \e [NSNull null], returns \e nil
#  **/
# + (id)<objectName><requiredProperties>        
# {                                             
#     return [[[<className> alloc] init<requiredProperties>] autorelease]; 
# }
###################################################################

my @classConstructorDocParts = (
"/**
 * Returns a ",""," object initialized with the given required properties: ","","
 *",
"", 
" 
 * \@return
 *   A ",""," object initialized with the given required properties: ","",".\n",
" *   If the required arguments are \\e nil or \\e [NSNull null], returns \\e nil
 **/\n");

my @classConstructorParts = (
"+ (id)","","", 
"\n{\n",
"    return [[[",""," alloc] init","","] autorelease];",
"\n}\n\n"); 


###################################################################
# COPY CONSTRUCTOR (W REQUIRED PROPERTIES)
#
# - (id)copyWithZone:(NSZone*)zone
# {                                                      
#     <className> *<object>Copy = (<className> *)[JRCaptureObject copy];
#
#     <object>Copy.<property> = self.<property>;
#       ...
#
#     <object>Copy.canBeUpdatedOnCapture = self.canBeUpdatedOnCapture;
#
#     return <object>Copy;
# }
###################################################################

my @copyConstructorParts = (
"- (id)copyWithZone:(NSZone*)zone",
"\n{\n", 
"","[super copyWithZone:zone];\n\n",
"", 
"\n    return ","",";",
"\n}\n\n");


###################################################################
# MAKE OBJECT FROM DICTIONARY
#                                               
# /**                                           
#  * Returns a <objectClass> object created from an \\e NSDictionary
#  * representing the object
#  *
#  * @param dictionary
#  *   An \e NSDictionary containing keys/values which map the the object's 
#  *   properties and their values/types.  This value cannot be nil
#  *
#  * @param capturePath
#  *   This is the qualified name used to refer to specific elements in a record;
#  *   a pound sign (#) is used to refer to plural elements with an id. The path
#  *   of the root object is "/"
#  *
#  * @par Example:
#  * The \c /primaryAddress/city refers to the city attribute of the primaryAddress object
#  * The \c /profiles#1/username refers to the username attribute of the element in profiles with id=1
#  *                                            
#  * @return                                              (Section only here when there are required properties)
#  *   A <objectClass> object created from an \e NSDictionary.                       |
#  *   If the \e NSDictionary is \e nil, returns \e nil                              |
#  *                                                                                 |
#  * @note Method creates a <objectClass> object without the required                |
#  * properties <requiredProperties>.  These properties are required  <--------------+
#  * when updating the object on Capture.
#  **/
# + (id)<objectName>[Object/Element]FromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder
# {
#     if (!dictionary)
#         return nil;
#                                                                                                                 For elements in a plural
#     <className> *<object> = [<className> <object>];                                                                         |
#                                                                                                                             |
#     NSSet *dirtyPropertySetCopy;                                                                                            |
#     if (fromDecoder)                                                                                                        |
#     {                                                                                                                       |
#         dirtyPropertySetCopy            = [NSSet setWithArray:[dictionary objectForKey:@"dirtyPropertiesSet"]];             |
#         <object>.canBeUpdatedOnCapture  = [(NSNumber *)[dictionary objectForKey:@"canBeUpdatedOnCapture"] boolValue];  <----+
#         <object>.captureObjectPath      = [dictionary objectForKey:@"captureObjectPath"]; <---------------------------------+
#     }
#     else
#     {                                                                                         Only if an element of a plural
#         dirtyPropertySetCopy            = [[self.dirtyPropertySet copy] autorelease];                +----------|
#         <object>.canBeUpdatedOnCapture  = YES;  <----------------------------------------------------+          V
#         <object>.captureObjectPath      = [NSString stringWithFormat:@"%@/%@#%d", capturePath, @"<object>", [(NSNumber*)[dictionary objectForKey:@"id"] integerValue]];
#     }
#
#     <object>.captureObjectPath = [NSString stringWithFormat:@"%@/%@#%d", capturePath, @"<object>", [(NSNumber*)[dictionary objectForKey:@"id"] integerValue]];
#     self.canBeUpdatedOnCapture = YES; 
#
#     <object>.<property> = [dictionary objectForKey:@"<property>"] != [NSNull null] ? 
#                                   [dictionary objectForKey:@"<property>"] : nil;
#       OR
#     <object>.<property> = [dictionary objectForKey:@"<property>"] != [NSNull null] ? 
#                                   [<propertyFromDictionaryMethod>:[dictionary objectForKey:@"<property>"]] : nil;
#       ...
#
#     if (fromDecoder)
#         [<object>.dirtyPropertySet setSet:dirtyPropertySetCopy];
#     else
#         [<object>.dirtyPropertySet removeAllObjects];
#
#     return <object>;
# }
#
# + (id)<objectName>[Object/Element]FromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder
# {
#      return [<className> <objectName>[Object/Element]FromDictionary:dictionary withPath:capturePath fromDecoder:NO];
# }
###################################################################

my @fromDictionaryDocParts = (
"/**
 * Returns a ",""," object created from an \\e NSDictionary representing the object
 *
 * \@param dictionary
 *   An \\e NSDictionary containing keys/values which map the the object's 
 *   properties and their values/types.  This value cannot be nil
 *
 * \@param capturePath
 *   This is the qualified name used to refer to specific elements in a record;
 *   a pound sign (#) is used to refer to plural elements with an id. The path
 *   of the root object is \"/\"
 *
 * \@par Example:
 * The \\c /primaryAddress/city refers to the city attribute of the primaryAddress object
 * The \\c /profiles#1/username refers to the username attribute of the element in profiles with id=1
 *
 * \@return
 *   A ",""," object\n",
"", 
" **/\n");

my @fromDictionaryParts = (
"+ (id)","","FromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder
{
    if (!dictionary)
        return nil;\n\n",
""," = [","","];

    NSSet *dirtyPropertySetCopy = nil;
    if (fromDecoder)
    {
        dirtyPropertySetCopy = [NSSet setWithArray:[dictionary objectForKey:\@\"dirtyPropertiesSet\"]];
        ","",".captureObjectPath = ([dictionary objectForKey:\@\"captureObjectPath\"] == [NSNull null] ?
                                                              nil : [dictionary objectForKey:\@\"captureObjectPath\"]);",
        "","
    }
    else
    {
        ","",".captureObjectPath      = [NSString stringWithFormat:\@\"\%\@/\%\@","","\", capturePath, ","","","];",
        "","
    }\n",
"",
"
    if (fromDecoder)
        [","",".dirtyPropertySet setSet:dirtyPropertySetCopy];
    else
        [","",".dirtyPropertySet removeAllObjects];
    
    return ","",";
}

+ (id)","","FromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    return [","","FromDictionary:dictionary withPath:capturePath fromDecoder:NO];",
"\n}\n\n");


###################################################################
# DECODE CAPTURE USER OBJECT FROM DICTIONARY
#                                               
# - (void)decodeFromDictionary:(NSDictionary*)dictionary
# {
#     NSSet *dirtyPropertySetCopy = [NSSet setWithArray:[dictionary objectForKey:@"dirtyPropertiesSet"]];
#
#     self.<property> = [dictionary objectForKey:@"<property>"] != [NSNull null] ? 
#                                   [dictionary objectForKey:@"<property>"] : nil;
#       OR
#     self.<property> = [dictionary objectForKey:@"<property>"] != [NSNull null] ? 
#                                   [<propertyFromDictionaryMethod>:[dictionary objectForKey:@"<property>"]] : nil;
#       ...
#
#     [<object>.dirtyPropertySet setSet:dirtyPropertySetCopy];
# }
###################################################################

my @decodeUserFromDictParts = (
"- (void)decodeFromDictionary:(NSDictionary*)dictionary",
"\n{\n",
"    NSSet *dirtyPropertySetCopy = [NSSet setWithArray:[dictionary objectForKey:\@\"dirtyPropertiesSet\"]];

    self.captureObjectPath = \@\"\";
    self.canBeUpdatedOnCapture = YES;
","",
"\n    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
}\n\n");


###################################################################
# MAKE DICTIONARY FROM OBJECT
#
# /**
#  * Creates an \e NSDictionary represention of a <objectClass> object
#  * populated with all of the object's properties, as the dictionary's 
#  * keys, and the properties' values as the dictionary's values
#  *
#  * \@return
#  *   An \e NSDictionary represention of a <objectClass> object
#  **/
# - (NSDictionary*)toDictionaryForEncoder:(BOOL)forEncoder
# {
#     NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:10];
#
#     [dictionary setObject:(<property> ? <property> : [NSNull null]) forKey:@"<propertyKey>"];
#       OR
#     [dictionary setObject:(<property> ? <propertyToDictionaryMethod> : [NSNull null]) forKey:@"<propertyKey>"];
#       ...
#
#     if (forEncoder)
#     {
#         [dictionary setObject:[self.dirtyPropertySet allObjects] forKey:@"dirtyPropertySet"];
#         [dictionary setObject:self.captureObjectPath forKey:@"captureObjectPath"];
#         [dictionary setObject:[NSNumber numberWithBool:self.canBeUpdatedOnCapture] forKey:@"canBeUpdatedOnCapture"];
#     }
#
#     return [NSDictionary dictionaryWithDictionary:dictionary];
#  }
###################################################################

my @toDictionaryDocParts = (
"/**
 * Creates an \e NSDictionary representation of a ",""," object
 * populated with all of the object's properties, as the dictionary's 
 * keys, and the properties' values as the dictionary's values
 *
 * \@return
 *   An \\e NSDictionary representation of a ",""," object\n",
" **/\n");

my @toDictionaryParts = (
"- (NSDictionary*)toDictionaryForEncoder:(BOOL)forEncoder",
"\n{\n",
"    NSMutableDictionary *dictionary = 
        [NSMutableDictionary dictionaryWithCapacity:10];\n\n",
"","
    if (forEncoder)
    {
        [dictionary setObject:([self.dirtyPropertySet allObjects] ? [self.dirtyPropertySet allObjects] : [NSArray array])
                       forKey:\@\"dirtyPropertiesSet\"];
        [dictionary setObject:(self.captureObjectPath ? self.captureObjectPath : [NSNull null])
                       forKey:\@\"captureObjectPath\"];
        [dictionary setObject:[NSNumber numberWithBool:self.canBeUpdatedOnCapture] 
                       forKey:\@\"canBeUpdatedOnCapture\"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];",
"\n}\n\n");


###################################################################
# UPDATE CURRENT OBJECT FROM A NEW DICTIONARY
#
# /**
#  * @internal
#  * Updates the object from an \e NSDictionary populated with some of the object's
#  * properties, as the dictionary's keys, and the properties' values as the dictionary's values.
#  * This method is used by other JRCaptureObjects and should not be used by consumers of the 
#  * mobile Capture library
#  *
#  * @param dictionary
#  *   An \e NSDictionary containing keys/values which map the the object's 
#  *   properties and their values/types
#  *
#  * @param capturePath
#  *   This is the qualified name used to refer to specific elements in a record;
#  *   a pound sign (#) is used to refer to plural elements with an id. The path
#  *   of the root object is "/"
#  *
#  * @par Example:
#  * The \c /primaryAddress/city refers to the city attribute of the primaryAddress object
#  * The \c /profiles#1/username refers to the username attribute of the element in profiles with id=1
#  *
#  * @note 
#  * The main difference between this method and the replaceFromDictionary:withPath:(), is that
#  * in this method properties are only updated if they exist in the dictionary, and in 
#  * replaceFromDictionary:withPath:(), all properties are replaced.  Even if the value is \e [NSNull null]
#  * so long as the key exists in the dictionary, the property is updated.
#  **/
# - (void)updateFromDictionary:(NSDictionary *)dictionary withPath:(NSString *)capturePath
# {
#     self.canBeUpdatedOnCapture = YES;
#
#     NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];
#
#     self.canBeUpdatedOnCapture = YES;
#     self.captureObjectPath = [NSString stringWithFormat:@"%@/%@#%d", capturePath, @"<object>", [(NSNumber*)[dictionary objectForKey:@"id"] integerValue]];
#
#     if ([dictionary objectForKey:@"<property>"])
#         self.<property> = [dictionary objectForKey:@"<property>"] != [NSNull null] ? 
#                                       [dictionary objectForKey:@"<property>"] : nil;
#           OR
#         self.<property> = [dictionary objectForKey:@"<property>"] != [NSNull null] ? 
#                                       [<propertyFromDictionaryMethod>:[dictionary objectForKey:@"<property>"]] : nil;
#           ...
#
#     [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
# }
###################################################################

my @updateFrDictDocParts = (
"/**
 * \@internal
 * Updates the object from an \\e NSDictionary populated with some of the object's
 * properties, as the dictionary's keys, and the properties' values as the dictionary's values. 
 * This method is used by other JRCaptureObjects and should not be used by consumers of the 
 * mobile Capture library
 *
 * \@param dictionary
 *   An \\e NSDictionary containing keys/values which map the the object's 
 *   properties and their values/types
 *
 * \@param capturePath
 *   This is the qualified name used to refer to specific elements in a record;
 *   a pound sign (#) is used to refer to plural elements with an id. The path
 *   of the root object is \"/\"
 *
 * \@par Example:
 * The \\c /primaryAddress/city refers to the city attribute of the primaryAddress object
 * The \\c /profiles#1/username refers to the username attribute of the element in profiles with id=1
 *
 * \@note 
 * The main difference between this method and the replaceFromDictionary:withPath:(), is that
 * in this method properties are only updated if they exist in the dictionary, and in 
 * replaceFromDictionary:withPath:(), all properties are replaced.  Even if the value is \\e [NSNull null]
 * so long as the key exists in the dictionary, the property is updated.
 **/\n");

my @updateFrDictParts = (
"- (void)updateFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath",
"\n{\n    DLog(@\"\%\@ \%\@\", capturePath, [dictionary description]);\n","
    NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];

    self.canBeUpdatedOnCapture = YES;\n",
"    self.captureObjectPath = [NSString stringWithFormat:\@\"\%\@/\%\@","","\", capturePath, ","","","];\n",
"","
    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
}\n\n");


###################################################################
# REPLACE CURRENT OBJECT FROM A NEW DICTIONARY
#
# /**
#  * @internal
#  * Replaces the object from an \e NSDictionary populated with some or all of the object's
#  * properties, as the dictionary's keys, and the properties' values as the dictionary's values.
#  * This method is used by other JRCaptureObjects and should not be used by consumers of the 
#  * mobile Capture library
#  *
#  * @param dictionary
#  *   An \e NSDictionary containing keys/values which map the the object's 
#  *   properties and their values/types
#  *
#  * @param capturePath
#  *   This is the qualified name used to refer to specific elements in a record;
#  *   a pound sign (#) is used to refer to plural elements with an id. The path
#  *   of the root object is "/"
#  *
#  * @par Example:
#  * The \c /primaryAddress/city refers to the city attribute of the primaryAddress object
#  * The \c /profiles#1/username refers to the username attribute of the element in profiles with id=1
#  *
#  * @note 
#  * The main difference between this method and the updateFromDictionary:withPath:(), is that
#  * in this method \e all the properties are replaced, and in updateFromDictionary:withPath:(),
#  * they are only updated if the exist in the dictionary.  If the key does not exist in
#  * the dictionary, the property is set to \e nil
#  **/
# - (void)replaceFromDictionary:(NSDictionary *)dictionary withPath:(NSString *)capturePath
# {
#     DLog(@"%@ %@", capturePath, [dictionary description]);
#
#     self.<property> = [dictionary objectForKey:@"<property>"] != [NSNull null] ? 
#                                   [dictionary objectForKey:@"<property>"] : nil;
#       OR
#     self.<property> = [dictionary objectForKey:@"<property>"] != [NSNull null] ? 
#                                   [<propertyFromDictionaryMethod>:[dictionary objectForKey:@"<property>"]] : nil;
#       ...
#     [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
# }
###################################################################

my @replaceFrDictDocParts = (
"/**
 * \@internal
 * Replaces the object from an \\e NSDictionary populated with some or all of the object's
 * properties, as the dictionary's keys, and the properties' values as the dictionary's values.
 * This method is used by other JRCaptureObjects and should not be used by consumers of the 
 * mobile Capture library
 *
 * \@param dictionary
 *   An \\e NSDictionary containing keys/values which map the the object's 
 *   properties and their values/types
 *
 * \@param capturePath
 *   This is the qualified name used to refer to specific elements in a record;
 *   a pound sign (#) is used to refer to plural elements with an id. The path
 *   of the root object is \"/\"
 *
 * \@par Example:
 * The \\c /primaryAddress/city refers to the city attribute of the primaryAddress object
 * The \\c /profiles#1/username refers to the username attribute of the element in profiles with id=1
 *
 * \@note 
 * The main difference between this method and the updateFromDictionary:withPath:(), is that
 * in this method \\e all the properties are replaced, and in updateFromDictionary:withPath:(),
 * they are only updated if the exist in the dictionary.  If the key does not exist in 
 * the dictionary, the property is set to \\e nil
 **/\n");

my @replaceFrDictParts = (
"- (void)replaceFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath",
"\n{
    DLog(@\"\%\@ \%\@\", capturePath, [dictionary description]);\n","
    NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];

    self.canBeUpdatedOnCapture = YES;\n",
"    self.captureObjectPath = [NSString stringWithFormat:\@\"\%\@/\%\@","","\", capturePath, ","","","];\n",
"","
    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
}\n\n");


###################################################################
# DIRTY PROPERTY SNAPSHOT MANAGEMENT
#

###################################################################

my @dirtyPropertySnapshotParts = (
"- (NSSet *)updatablePropertySet
{
    return [NSSet setWithObjects:","","nil];
}\n\n",
"- (void)setAllPropertiesToDirty
{
    [self.dirtyPropertySet addObjectsFromArray:[[self updatablePropertySet] allObjects]];\n",
"",
"\n}\n\n",
"- (NSDictionary *)snapshotDictionaryFromDirtyPropertySet
{
    NSMutableDictionary *snapshotDictionary =
             [NSMutableDictionary dictionaryWithCapacity:10];

    [snapshotDictionary setObject:[[self.dirtyPropertySet copy] autorelease] forKey:\@\"","","\"];\n\n",
"",
"    return [NSDictionary dictionaryWithDictionary:snapshotDictionary];
}\n\n",
"- (void)restoreDirtyPropertiesFromSnapshotDictionary:(NSDictionary *)snapshotDictionary
{
    if ([snapshotDictionary objectForKey:\@\"","","\"])
        [self.dirtyPropertySet addObjectsFromArray:[[snapshotDictionary objectForKey:\@\"","","\"] allObjects]];\n",
"",
"\n}\n\n");


###################################################################
# UPDATE OBJECT ON CAPTURE
#
# - (NSDictionary *)toUpdateDictionary
# {
#     NSMutableDictionary *dictionary =
#          [NSMutableDictionary dictionaryWithCapacity:10];
# 
#     if ([self.dirtyPropertySet containsObject:@"<property>"])
#         [dictionary setObject:(self.<property> ? self.<property> : [NSNull null]) forKey:@"<property>"];
#           OR
#         [dictionary setObject:(self.<property> ? <propertyToUpdateDictionaryMethod> : [NSNull null]) forKey:@"<property>"];
#
#     [self.dirtyPropertySet removeAllObjects];
# 
#     return [NSDictionary dictionaryWithDictionary:dictionary];
# }
# 
# /**
#  * TODO: Doxygen doc
#  **/
# - (void)updateObjectOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate withContext:(NSObject *)context
# {
#     NSDictionary *newContext = [NSDictionary dictionaryWithObjectsAndKeys:
#                                                      context, @"callerContext",
#                                                      delegate, @"delegate",
#                                                      context, @"callerContext", nil];
# 
#     [JRCaptureInterface updateCaptureObject:[self toUpdateDictionary]
#                                      withId:self.<objectName>Id OR 0
#                                      atPath:self.captureObjectPath
#                                   withToken:[JRCaptureData accessToken]
#                                 forDelegate:self
#                                 withContext:newContext];
# }
###################################################################

my @updateRemotelyDocParts = (
"/**
 * TODO: Doxygen doc
 **/
- (void)updateOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate context:(NSObject *)context;\n");

my @toUpdateDictionaryParts = (
"- (NSDictionary *)toUpdateDictionary",
"\n{\n",
"    NSMutableDictionary *dictionary =
         [NSMutableDictionary dictionaryWithCapacity:10];\n",
"",         
"
    [self.dirtyPropertySet removeAllObjects];
    return [NSDictionary dictionaryWithDictionary:dictionary];",
"\n}\n\n");

my @updateRemotelyParts = (
"- (void)updateOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate context:(NSObject *)context",
"\n{\n",
"    [super updateOnCaptureForDelegate:delegate context:context];",
"\n}\n\n");


###################################################################
# REPLACE OBJECT ON CAPTURE
#
# - (NSDictionary *)toReplaceDictionary
# {
#     NSMutableDictionary *dictionary =
#          [NSMutableDictionary dictionaryWithCapacity:10];
# 
#     [dictionary setObject:(self.<property> ? self.<property> : [NSNull null]) forKey:@"<property>"];
#       OR
#     [dictionary setObject:(self.<property> ? <propertyToUpdateDictionaryMethod> : [NSNull null]) forKey:@"<property>"];
# 
#     [self.dirtyPropertySet removeAllObjects];
#
#     return [NSDictionary dictionaryWithDictionary:dictionary];
# }
# 
# /**
#  * TODO: Doxygen doc
#  **/
# - (void)replaceObjectOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate withContext:(NSObject *)context
# {
#     NSDictionary *newContext = [NSDictionary dictionaryWithObjectsAndKeys:
#                                                      self, @"captureObject",
#                                                      delegate, @"delegate",
#                                                      context, @"callerContext", nil];
# 
#     [JRCaptureInterface updateCaptureObject:[self toReplaceDictionary]
#                                      withId:self.<objectName>Id OR 0
#                                      atPath:self.captureObjectPath
#                                   withToken:[JRCaptureData accessToken]
#                                 forDelegate:self
#                                 withContext:newContext];
# }
###################################################################

my @replaceRemotelyDocParts = (
"/**
 * TODO: Doxygen doc
 **/\n");

my @toReplaceDictionaryParts = (
"- (NSDictionary *)toReplaceDictionary",
"\n{\n",
"    NSMutableDictionary *dictionary =
         [NSMutableDictionary dictionaryWithCapacity:10];\n\n",
"",         
"
    [self.dirtyPropertySet removeAllObjects];
    return [NSDictionary dictionaryWithDictionary:dictionary];",
"\n}\n\n");

#my @replaceRemotelyParts = (
#"- (void)replaceObjectOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate withContext:(NSObject *)context",
#"\n{\n",
#"    NSDictionary *newContext = [NSDictionary dictionaryWithObjectsAndKeys:
#                                                     self, \@\"captureObject\",
#                                                     self.captureObjectPath, \@\"capturePath\",
#                                                     delegate, \@\"delegate\",
#                                                     context, \@\"callerContext\", nil];
#
#    [JRCaptureInterface replaceCaptureObject:[self toReplaceDictionary]
#//                                      withId:
#                                      atPath:self.captureObjectPath
#                                   withToken:[JRCaptureData accessToken]
#                                 forDelegate:self
#                                 withContext:newContext];",
#"\n}\n\n");


###################################################################
# OBJECT EQUALITY
#
# /**
#  * TODO: Doxygen doc
#  **/
# - (BOOL)isEqualTo<objectName>:<className>other<objectName>
# {
#     if (!self.<objectProperty> && !other<objectName>.<objectProperty>) /* Keep going... */;
#     else if ((self.<objectProperty> == nil) ^ (other<objectName>.<objectProperty> == nil)) return NO; // xor
#     else if (![self.<objectProperty> isEqualTo<propertyObject>:other<objectName>.<objectProperty>]) return NO;
#       ...
#
#     return YES;    
# }
###################################################################

my @isEqualObjectDocParts = (
"/**
 * TODO: Doxygen doc
 **/\n");
 
my @isEqualObjectParts = (
"- (BOOL)isEqualTo","",
"\n{\n",
#"    if (![self.captureObjectPath isEqualToString:other","",".captureObjectPath])
#         return NO;\n\n",
"",
"    return YES;",
"\n}\n\n");


###################################################################
# RECURSIVE CHECK IF OBJECT NEEDS UPDATE
#
# /**
#  * TODO: Doxygen doc
#  **/
# - (BOOL)needsUpdate
# {
#     if ([dirtyPropertiesSet count])
#         return YES;
#
#     if ([self.<objectProperty> needsUpdate])
#         return YES;
#       ...
#
#     return NO;    
# }
###################################################################

my @needsUpdateDocParts = (
"/**
 * Use this method to determine if the object or element needs to be updated remotely.
 * That is, if there are local changes to any of the object/elements's properties or 
 * sub-objects, then this object will need to be updated on Capture. You can update
 * an object on Capture by using the method updateOnCaptureForDelegate:context:().
 *
 * \@return
 * \\c YES if this object or any of it's sub-objects have any properties that have changed
 * locally. This does not include properties that are arrays, if any, or the elements contained 
 * within the arrays. \\c NO if no non-array properties or sub-objects have changed locally.",
 "","",
 "","","","
 **/\n");
 
my @needsUpdateParts = (
"- (BOOL)needsUpdate",
"\n{\n",
"    if ([self.dirtyPropertySet count])
         return YES;\n\n",
"",
"    return NO;",
"\n}\n\n");


###################################################################
# MAKE DICTIONARY OF OBJECT'S PROPERTIES
#
# /**
#  * TODO: Doxygen doc
#  **/
# - (NSDictionary*)objectProperties
# {
#     NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:10];
#
#     [dictionary setObject:@"<propertyType>" forKey:@"<propertyName>"];
#
#     return [NSDictionary dictionaryWithDictionary:dictionary];
#  }
###################################################################

my @objectPropertiesDocParts = (
"/**
 * TODO: Doxygen doc
 **/\n");
 
my @objectPropertiesParts = (
"- (NSDictionary*)objectProperties",
"\n{\n",
"    NSMutableDictionary *dictionary = 
        [NSMutableDictionary dictionaryWithCapacity:10];\n\n",
"", 
"\n    return [NSDictionary dictionaryWithDictionary:dictionary];",
"\n}\n\n");


###################################################################
# DESTRUCTOR
#
# - (void)dealloc
# {
#     [<property> release];
#       ...
# 
#     [super dealloc];
# }
###################################################################

my @destructorParts = (
"- (void)dealloc",
"\n{\n",
"", 
"\n    [super dealloc];",
"\n}\n");


my $copyrightHeader = 
"/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */\n\n";


my @doxygenClassDescParts = (
"/**
 * \@brief ","", 
"\n **/\n");


sub createArrayCategoryForSubobject { 
  my $propertyName = $_[0];
  
  my $arrayCategoryIntf = "\@interface NSArray (JRArray_" . ucfirst($propertyName) . "_ToFromDictionary)\n";
  my $arrayCategoryImpl = "\@implementation NSArray (JRArray_" . ucfirst($propertyName) . "_ToFromDictionary)\n";

  my $methodName1 = "- (NSArray*)arrayOf" . ucfirst($propertyName) . "ElementsFrom" . ucfirst($propertyName) . "DictionariesWithPath:(NSString*)capturePath fromDecoder:(BOOL)fromDecoder";
  my $methodName2 = "- (NSArray*)arrayOf" . ucfirst($propertyName) . "ElementsFrom" . ucfirst($propertyName) . "DictionariesWithPath:(NSString*)capturePath";
  my $methodName3 = "- (NSArray*)arrayOf" . ucfirst($propertyName) . "DictionariesFrom" . ucfirst($propertyName) . "ElementsForEncoder:(BOOL)forEncoder";
  my $methodName4 = "- (NSArray*)arrayOf" . ucfirst($propertyName) . "DictionariesFrom" . ucfirst($propertyName) . "Elements";
  my $methodName5 = "- (NSArray*)arrayOf" . ucfirst($propertyName) . "ReplaceDictionariesFrom" . ucfirst($propertyName) . "Elements";
 
  $arrayCategoryIntf .= "$methodName1;\n$methodName2;\n$methodName3;\n$methodName4;\n$methodName5;\n\@end\n\n";
  
  $arrayCategoryImpl .= "$methodName1\n{\n";
  $arrayCategoryImpl .=        
       "    NSMutableArray *filtered" . ucfirst($propertyName) . "Array = [NSMutableArray arrayWithCapacity:[self count]];\n" . 
       "    for (NSObject *dictionary in self)\n" . 
       "        if ([dictionary isKindOfClass:[NSDictionary class]])\n" . 
       "            [filtered" . ucfirst($propertyName) . "Array addObject:[JR" . ucfirst($propertyName) . "Element " . $propertyName . "ElementFromDictionary:(NSDictionary*)dictionary withPath:capturePath fromDecoder:fromDecoder]];\n\n" . 
       "    return filtered" . ucfirst($propertyName) . "Array;\n}\n\n";

  $arrayCategoryImpl .= "$methodName2\n{\n";
  $arrayCategoryImpl .=        
       "    return [self arrayOf" . ucfirst($propertyName) . "ElementsFrom" . ucfirst($propertyName) . "DictionariesWithPath:capturePath fromDecoder:NO];\n}\n\n";

       
  $arrayCategoryImpl .= "$methodName3\n{\n";
  $arrayCategoryImpl .=        
       "    NSMutableArray *filteredDictionaryArray = [NSMutableArray arrayWithCapacity:[self count]];\n" . 
       "    for (NSObject *object in self)\n" . 
       "        if ([object isKindOfClass:[JR" . ucfirst($propertyName) . "Element class]])\n" . 
       "            [filteredDictionaryArray addObject:[(JR" . ucfirst($propertyName) . "Element*)object toDictionaryForEncoder:forEncoder]];\n\n" . 
       "    return filteredDictionaryArray;\n}\n\n";

  $arrayCategoryImpl .= "$methodName4\n{\n";
  $arrayCategoryImpl .=        
       "    return [self arrayOf" . ucfirst($propertyName) . "DictionariesFrom" . ucfirst($propertyName) . "ElementsForEncoder:NO];\n}\n\n";

  $arrayCategoryImpl .= "$methodName5\n{\n";
  $arrayCategoryImpl .=        
       "    NSMutableArray *filteredDictionaryArray = [NSMutableArray arrayWithCapacity:[self count]];\n" . 
       "    for (NSObject *object in self)\n" . 
       "        if ([object isKindOfClass:[JR" . ucfirst($propertyName) . "Element class]])\n" . 
       "            [filteredDictionaryArray addObject:[(JR" . ucfirst($propertyName) . "Element*)object toReplaceDictionary]];\n\n" . 
       "    return filteredDictionaryArray;\n}\n\@end\n\n";          

  return $arrayCategoryImpl;#"$arrayCategoryIntf$arrayCategoryImpl";
}

sub createObjectCategoryForSubobject { 
  my $propertyName   = $_[0];
  my $isArrayElement = $_[1];
  
  my $objectCategoryIntf = "\@interface JR" . ucfirst($propertyName) . " (JR" . ucfirst($propertyName) . "_InternalMethods)\n" . 
                           "+ (id)" . $propertyName . ($isArrayElement ? "" : "Object") . "FromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder;\n" . 
                           "- (BOOL)isEqualTo" . ucfirst($propertyName) . ":(JR" . ucfirst($propertyName) . " *)other" . ucfirst($propertyName) . ";\n" . 
                           "\@end\n\n";

  return $objectCategoryIntf;
}

sub getArrayComparisonDeclaration { 
  my $propertyName = $_[0];
  
  return "- (BOOL)isEqualTo" . ucfirst($propertyName) . "Array:(NSArray *)otherArray;\n";
}

sub getArrayComparisonImplementation { 
  my $propertyName = $_[0];
  
  return "\n" . 
  "- (BOOL)isEqualTo" . ucfirst($propertyName) . "Array:(NSArray *)otherArray\n{\n" .
  "    if ([self count] != [otherArray count]) return NO;\n\n" . 
  "    for (NSUInteger i = 0; i < [self count]; i++)\n" .
  "        if (![((JR" . ucfirst($propertyName) . "Element *)[self objectAtIndex:i]) isEqualTo" . ucfirst($propertyName) . "Element:[otherArray objectAtIndex:i]])\n" .
  "            return NO;\n\n" .
  "    return YES;\n}\n";             
}

sub createArrayReplaceMethodDeclaration { 
  my $propertyName = $_[0];
  my $className    = $_[1];

  my $methodDeclaration = 
       "\n"  .
       "/**\n" . 
       " * Use this method to replace the " . $className . "#" . $propertyName . " array on Capture after adding, removing,\n" . 
       " * or reordering elements. You should call this method immediately after you perform any of these actions.\n" .
       " * This method will replace the entire array on Capture, including all of its elements and their sub-arrays and\n" .
       " * sub-objects. When successful, the new array will be added to the " . $className . "#" . $propertyName . " property,\n" . 
       " * replacing the existing NSArray.\n" .
       " *\n" . 
       " * If the array is replaced successfully, the method JRCaptureObjectDelegate#replaceArrayDidSucceedForObject:newArray:named:context:\n" . 
       " * will be called on your delegate. This method will return a pointer to the new array, which is also the same pointer\n" .
       " * stored in the " . $className . "#" . $propertyName . " property, and the name of the replaced array: \\c \"" . $propertyName . "\".\n" .
       " *\n" .
       " * If unsuccessful, the method JRCaptureObjectDelegate#replaceArrayDidFailForObject:arrayNamed:withError:context:\n" .
       " * will be called on your delegate.\n" .
       " *\n" . 
       " * \@param delegate\n" . 
       " *   The JRCaptureObjectDelegate that implements the optional delegate methods JRCaptureObjectDelegate#replaceArrayDidSucceedForObject:newArray:named:context:\n" .
       " *   and JRCaptureObjectDelegate#replaceArrayDidFailForObject:arrayNamed:withError:context:.\n" .
       " *\n" . 
       " * \@param context\n" . 
       " *   Any NSObject that you would like to send through the asynchronous network call back to your delegate, or \\c nil.\n" .
       " *   This object will be passed back to your JRCaptureObjectDelegate as is. Contexts are used across most of the\n" .
       " *   asynchronous Capture methods to facilitate correlation of the response messages with the calling code. Use of the\n" .
       " *   context is entirely optional and at your discretion.\n" .
       " *\n" . 
       " * \@warning\n" . 
       " * When successful, the new array will be added to the " . $className . "#" . $propertyName . " property,\n" . 
       " * replacing the existing NSArray. The new array will contain new, but equivalent JR" . ucfirst($propertyName) . "Element\n" . 
       " * objects. That is to say, the elements will be the same, but they will have new pointers. You should not hold onto\n" . 
       " * any references to the " . $className . "#" . $propertyName . " or JR" . ucfirst($propertyName) . "Element objects\n" . 
       " * when you are replacing this array on Capture, as the pointers will become invalid.\n" .
       " * \n" . 
       " * \@note\n" . 
       " * After the array has been replaced on Capture, you can now call JR" . ucfirst($propertyName) . "Element#updateOnCaptureForDelegate:context:()\n" .  
       " * on the array's elements. You can check the JR" . ucfirst($propertyName) . "Element#canBeUpdatedOnCapture property to determine\n" .  
       " * if an element can be updated or not. If the JR" . ucfirst($propertyName) . "Element#canBeUpdatedOnCapture property is equal\n" . 
       " * to \\c NO you should replace the " . $className . "#" . $propertyName . " array on Capture. Replacing the array will also\n" . 
       " * update any local changes to the properties of a JR" . ucfirst($propertyName) . "Element, including sub-arrays and sub-objects.\n" . 
       " *\n * \@par\n" . 
       " * If you haven't added, removed, or reordered any of the elements of the " . $className . "#" . $propertyName . " array, but\n" . 
       " * you have locally updated the properties of a JR" . ucfirst($propertyName) . "Element, you can just call\n" . 
       " * JR" . ucfirst($propertyName) . "Element#updateOnCaptureForDelegate:context:() to update the local changes on the Capture server.\n" . 
       " * The JR" . ucfirst($propertyName) . "Element#canBeUpdatedOnCapture property will let you know if you can do this.\n" .
       " **/\n" . 
       "- (void)replace" . ucfirst($propertyName) . "ArrayOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate context:(NSObject *)context;\n";

  return $methodDeclaration;
}

sub createArrayReplaceMethodImplementation { 
  my $propertyName  = $_[0];
  my $isStringArray = $_[1];
  my $elementType   = $_[2];

  my $methodImplementation =
       "- (void)replace" . ucfirst($propertyName) . "ArrayOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate context:(NSObject *)context\n" . 
       "{\n" . 
       "    [self replaceArrayOnCapture:self." . $propertyName . " named:\@\"" . $propertyName . "\" isArrayOfStrings:" . ($isStringArray ? "YES" : "NO" ) . "\n" . 
       "                       withType:\@\"" . ($isStringArray ? $elementType : "" ) . "\" forDelegate:delegate withContext:context];\n" . 
       "}\n\n";
       
  return $methodImplementation;
}

sub createGetterSetterForProperty {
  my $propertyName  = $_[0];
  my $propertyType  = $_[1];
  my $isBoolOrInt   = $_[2];
  my $isArray       = $_[3];
  my $isObject      = $_[4];
  my $getter;
  my $setter;
  my $primitiveGetter = "";
  my $primitiveSetter = "";
  
  $getter = "- (" . $propertyType . ")" . $propertyName;
  
  $getter .= "\n{\n";
  $getter .= "    return _" . $propertyName . ";";
  $getter .= "\n}\n\n";
  
  $setter .= "- (void)set". ucfirst($propertyName) . ":(" . $propertyType . ")new" . ucfirst($propertyName); 
  $setter .= "\n{\n";

#  if ($isArray) {
#    $setter .= "    [self.dirtyArraySet addObject:@\"" . $propertyName . "\"];\n\n";
#  } else {
  if (!$isArray) {
    $setter .= "    [self.dirtyPropertySet addObject:@\"" . $propertyName . "\"];\n\n";
  }

  $setter .= "    [_" . $propertyName . " autorelease];\n";
  
  if ($isObject) {
    $setter .= "    _" . $propertyName . " = [new" . ucfirst($propertyName) . " retain];\n\n";  
    $setter .= "    [_" . $propertyName . " setAllPropertiesToDirty];"
  } else {
    $setter .= "    _" . $propertyName . " = [new" . ucfirst($propertyName) . " copy];";    
  }
  
  $setter .= "\n}\n\n";

  if ($isBoolOrInt eq "b") {
  
    $primitiveGetter .= "- (BOOL)get" . ucfirst($propertyName) . "BoolValue";
    $primitiveGetter .= "\n{\n";
    $primitiveGetter .= "    return [_" . $propertyName .  " boolValue];";    
    $primitiveGetter .= "\n}\n\n";
    
    $primitiveSetter .= "- (void)set" . ucfirst($propertyName) . "WithBool:(BOOL)boolVal";
    $primitiveSetter .= "\n{\n";
    $primitiveSetter .= "    [self.dirtyPropertySet addObject:@\"" . $propertyName . "\"];\n\n";
  
    $primitiveSetter .= "    [_" . $propertyName .  " autorelease];\n";    
    $primitiveSetter .= "    _" . $propertyName .  " = [[NSNumber numberWithBool:boolVal] retain];";    
    $primitiveSetter .= "\n}\n\n";

  } elsif ($isBoolOrInt eq "i") {

    $primitiveGetter .= "- (NSInteger)get" . ucfirst($propertyName) . "IntegerValue";
    $primitiveGetter .= "\n{\n";
    $primitiveGetter .= "    return [_" . $propertyName .  " integerValue];";    
    $primitiveGetter .= "\n}\n\n";
    
    $primitiveSetter .= "- (void)set" . ucfirst($propertyName) . "WithInteger:(NSInteger)integerVal";
    $primitiveSetter .= "\n{\n";
    $primitiveSetter .= "    [self.dirtyPropertySet addObject:@\"" . $propertyName . "\"];\n\n";

    $primitiveSetter .= "    [_" . $propertyName .  " autorelease];\n";  
    $primitiveSetter .= "    _" . $propertyName .  " = [[NSNumber numberWithInteger:integerVal] retain];";    
    $primitiveSetter .= "\n}\n\n";
    
  }

  return $getter . $setter . $primitiveGetter . $primitiveSetter;
}

# sub createGetterSetterForSimpleArray {
#   my $propertyName  = $_[0];
#   my $pluralType    = $_[1];
#   my $getter;
#   my $setter;
#   
#   $getter = "- (NSArray *)" . $propertyName;
#   
#   $getter .= "\n{\n";
#   $getter .= "    return _" . $propertyName . ";";
#   $getter .= "\n}\n\n";
#   
#   $setter .= "- (void)set". ucfirst($propertyName) . ":(NSArray *)new" . ucfirst($propertyName); 
#   $setter .= "\n{\n";
#   $setter .= "    [self.dirtyArraySet addObject:@\"" . $propertyName . "\"];\n";
# 
# #   $setter .= "    if (!new" . ucfirst($propertyName) . ")\n";
# #   $setter .= "        _" . $propertyName .  " = [NSNull null];\n";  
# #   $setter .= "    else\n";
#   $setter .= "    _" . $propertyName .  " = ";
#   $setter .= "[new" . ucfirst($propertyName) . " copyArrayOfStringPluralElementsWithType:\@\"" . $pluralType . "\"];";  
#   
#   $setter .= "\n}\n\n";
# 
#   return $getter . $setter;
# }

sub getMinConstructorParts {
  return @minConstructorParts;
}

sub getConstructorParts {
  return @constructorParts;
}

sub getMinClassConstructorParts {
  return @minClassConstructorParts;
}

sub getClassConstructorParts {
  return @classConstructorParts;
}

sub getCopyConstructorParts {
  return @copyConstructorParts;
}

sub getToDictionaryParts {
  return @toDictionaryParts;
}

sub getFromDictionaryParts {
  return @fromDictionaryParts;
}

sub getDecodeUserFromDictParts {
  return @decodeUserFromDictParts;
}

sub getUpdateFromDictParts {
  return @updateFrDictParts;
}

sub getReplaceFromDictParts {
  return @replaceFrDictParts;
}

sub getDirtyPropertySnapshotParts {
  return @dirtyPropertySnapshotParts;
}

sub getToUpdateDictParts {
  return @toUpdateDictionaryParts;
}

sub getUpdateRemotelyParts {
  return @updateRemotelyParts;
}

sub getToReplaceDictParts {
  return @toReplaceDictionaryParts;
}

#sub getReplaceRemotelyParts {
#  return @replaceRemotelyParts;
#}

sub getNeedsUpdateDocParts {
  return @needsUpdateDocParts;
}

sub getNeedsUpdateParts {
  return @needsUpdateParts;
}

sub getIsEqualObjectParts {
  return @isEqualObjectParts;
}

sub getIsEqualObjectDocParts {
  return @isEqualObjectDocParts;
}

sub getObjectPropertiesParts {
  return @objectPropertiesParts;
}

sub getDestructorParts {
  return @destructorParts;
}

sub getCopyrightHeader {
  return $copyrightHeader;
}

sub getDoxygenClassDescParts {
  return @doxygenClassDescParts;
}

sub getMinConstructorDocParts {
  return @minConstructorDocParts;
}

sub getConstructorDocParts {
  return @constructorDocParts;
}

sub getMinClassConstructorDocParts {
  return @minClassConstructorDocParts;
}

sub getClassConstructorDocParts {
  return @classConstructorDocParts;
}

sub getToDictionaryDocParts {
  return @toDictionaryDocParts;
}

sub getFromDictionaryDocParts {
  return @fromDictionaryDocParts;
}

sub getUpdateFromDictDocParts {
  return @updateFrDictDocParts;
}

sub getReplaceFromDictDocParts {
  return @replaceFrDictDocParts;
}

sub getUpdateRemotelyDocParts {
  return @updateRemotelyDocParts;
}

sub getReplaceRemotelyDocParts {
  return @replaceRemotelyDocParts;
}

sub getObjectPropertiesDocParts {
  return @objectPropertiesDocParts;
}

sub getObjcKeywords {
  my @keywords = ("auto", "_Bool", "_Complex", "_Imaginery", "atomic", "BOOL", "break", "bycopy", "byref", 
                  "case", "char", "Class", "const", "continue", "default", "do", "double", "else", "enum", 
                  "extern", "float", "for", "goto", "id", "if", "IMP", "in", "inline", "inout", "int", "long", 
                  "nil", "NO", "nonatomic", "NULL", "oneway", "out", "Protocol", "register", "restrict", 
                  "retain", "return", "SEL", "self", "short", "signed", "sizeof", "static", "struct", 
                  "super", "switch", "typedef", "union", "unsigned", "void", "volatile", "while", "YES"); 

  my %keywords = map { $_ => 1 } @keywords;
  
  return %keywords;
}

sub getJanrainObjectNames {
  my @objectNames = ("objectId", "integer", "boolean", "uuid", "ipAddress", "password", 
                     "jsonObject", "simpleArray", "array", "date", "dateTime");

  my %keywords = map { $_ => 1 } @keywords;
  
  return %keywords;
}




1;