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

#define JRConventionalSigninNone JRTraditionalSignInNone
#define JRConventionalSigninEmailPassword JRTraditionalSignInEmailPassword
#define JRConventionalSigninUsernamePassword JRTraditionalSignInUsernamePassword
#define JRConventionalSigninType JRTraditionalSignInType

#define JRConventionalSignInEmailPassword JRTraditionalSignInEmailPassword
#define JRConventionalSignInUsernamePassword JRTraditionalSignInUsernamePassword
#define JRConventionalSignInNone JRTraditionalSignInNone
#define JRConventionalSignInType JRTraditionalSignInType


/**
 * Indicates the type of the user record as an argument to your
 * JRCaptureDelegate#captureAuthenticationDidSucceedForUser:status: delegate method.
 *
 * There are three possible values for \c captureRecordStatus, indicating the creation state of the record.
 *
 * During Capture authentication, if authenticating through the Engage for iOS portion of the library, the library
 * automatically posts the authentication token to the Capture server. Capture will attempt to sign the user in,
 * using the rich data available from the social identity provider.  One of three results will occur:
 *     - Returning User — The user’s record already exists on the Capture server. The record is retrieved from the
 *       Capture server and passed back to your application.
 *     - New User, Record Automatically Created — The user’s record does not already exist on the Capture server, but
 *       it is automatically created and passed back to your application.  Your application may wish to collect
 *       additional information about the user and push that information back to the Capture server.
 *     - New User, Record Not Automatically Created* — The user’s record was not automatically created, either because
 *       required information was not available in the data returned by the social identity provider, or because auto-
 *       creation was disabled.
 **/
typedef enum
{
/**
 * Indicates that this is a new user and that a new Capture record has already been
 * automatically created. Your application may wish to collect additional new-user information and push that
 * information back to the Capture server
 **/
 JRCaptureRecordNewlyCreated,          /* now it exists, and it is new */

/**
 * Indicates that the user had an existing Capture record and that record has been retrieved.
 * Your application should update its state to reflect the user being signed-in
 **/
 JRCaptureRecordExists,                /* already created, not new */
} JRCaptureRecordStatus;

/**
 * Indicates the kind of traditional sign-in to be used.
 **/
typedef enum
{
/**
 * No traditional login dialog added
 **/
 JRTraditionalSignInNone = 0,

/**
 * Traditional login dialog added prompting the user for their username and
 * password combination. Use this if your Capture instance is set up to accept a \c username argument when signing in
 * directly to your server
 **/
            JRTraditionalSignInUsernamePassword,

/**
 * Traditional login dialog added prompting the user for their email and password
 * combination. Use this if your Capture instance is set up to accept a \c email argument when signing in
 * directly to your server
 **/
            JRTraditionalSignInEmailPassword
} JRTraditionalSignInType;

/**
 * @file
 * Types used by the library's generated Capture user model
 **/

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a \e boolean on Capture can have the
 * values \c true, \c false, and \c null, while an \e NSBoolean in Objective-C can only be \c true or \c false. On the
 * other hand, an \e NSNumber can represent \c true, \c false, and \c null, but it can also hold many other things
 * that won't be accepted by the Capture API (such as \c -100) when the property has the type \e boolean.
 *
 * To ensure that your objects can correctly update themselves on Capture (i.e., contain \c null), we use an \e NSNumber
 * to hold \e boolean properties. To make it perfectly clear that \e boolean properties cannot be just any number, we
 * typedeffed them \e JRBoolean. Your IDE's auto-complete should suggest \e JRBoolean when setting a \e boolean
 * property, but since underneath it is just an \e NSNumber, you can set it to \c null as well.
 *
 * When setting a property of type \e JRBoolean, you can set it as you would an \e NSNumber. Additionally, for your
 * convenience, Capture objects that have \e boolean properties will provide getters and setters that accept and return
 * primitive booleans. For example, the JRPhoneNumbersElement#primary property has the following getters/setters:
 * JRPhoneNumbersElement#primary(), JRPhoneNumbersElement#setPrimary(), JRPhoneNumbersElement#setPrimaryWithBool:(),
 * and JRPhoneNumbersElement#getPrimaryBoolValue().
 *
 * @note
 *   In Capture there is a difference between a \e boolean with the value \c false and a \e boolean with the value
 *   \c null.
 *
 * @warning
 *   The compiler won't stop you from setting a \e JRBoolean to a non-boolean value, the JUMP for iOS library will
 *   automatically convert your \e JRBoolean properties to the equivalent boolean value when updating the object on
 *   Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSNumber JRBoolean;
#define JRBoolean NSNumber

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a \e decimal on Capture is more or
 * less equivalent to an \e NSNumber in Objective-C. On the other hand an \e NSNumber can hold values that won't be
 * accepted by the Capture API (such as \c true).
 *
 * To ensure that your objects can correctly update themselves on Capture, we use an \e NSNumber to hold \e decimal
 * properties. To make it perfectly clear that these properties correspond to the type \e decimal, and they cannot be
 * just any number, we typedeffed them \e JRDecimal. Your IDE's auto-complete should suggest \e JRDecimal when setting
 * a \e decimal property. Also, since, underneath, it is just an \e NSNumber, you can set it to \c null as well.
 *
 * @warning
 *   The compiler won't stop you from setting a \e JRDecimal to a value that may not be accepted by Capture, but you
 *   will get an error when you try and update your object on Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSNumber JRDecimal;
#define JRDecimal NSNumber

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a \e integer on Capture can hold
 * both integers and \c null, while an \e NSInteger in Objective-C can only hold integers and can't be \c null. On the
 * other hand an \e NSNumber can represent \c true, \c false, and \c null, but it can also hold many other things that
 * won't be accepted by the Capture API (such as \c -100) when the property has the type \e integer.
 *
 * To ensure that your objects can correctly update themselves on Capture, we had to use an \e NSNumber to hold
 * \e integer properties. To make it perfectly clear that \e integer properties cannot be just any number, we
 * typedeffed them \e JRInteger. Your IDE's auto-complete should suggest \e JRInteger when setting a \e integer
 * property, but since underneath it is just an \e NSNumber, you can set it to \c null as well.
 *
 * When setting a property of type \e JRInteger, you can set it as you would an NSNumber. Additionally, for your
 * convenience, Capture objects that have \e integer properties will provide getters and setters that accept and return
 * primitive integers. The same goes for \e JRBooleans. For example, the JRPhoneNumbersElement#primary property
 * (a \c boolean) has the following getters/setters: JRPhoneNumbersElement#primary(),
 * JRPhoneNumbersElement#setPrimary(), JRPhoneNumbersElement#setPrimaryWithBool:(), and
 * JRPhoneNumbersElement#getPrimaryBoolValue().
 *
 * @note
 *   In Capture there is a difference between an \e integer with the value \c 0 and an \e integer with the value
 *   \c null.
 *
 * @warning
 *   The compiler won't stop you from setting a \e JRInteger to a non-integer value, the JUMP for iOS library will
 *   automatically convert your \e JRInteger properties to the equivalent integer value when updating the object on
 *   Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSNumber JRInteger;
#define JRInteger NSNumber

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a property of type \e date on Capture
 * can hold only hold values that correspond to the <a href="http://dotat.at/tmp/ISO_8601-2004_E.pdf">
 *   ISO 8601 date format</a> (e.g., \c yyyy-MM-dd), while an \e NSDate on Objective-C can hold many more values and
 * formats.
 *
 * To ensure that your objects can correctly update themselves on Capture, we had to use an \e NSDate to hold
 * \e date properties. To make it perfectly clear that \e date properties cannot be just any date, we typedeffed
 * them \e JRDate. Your IDE's auto-complete should suggest \e JRDate when setting a \e date property, but since
 * underneath it is just an \e NSDate, you can set it to \c null as well.
 *
 * @note
 *   In Capture there is a difference between the type \e date and the type \e dateTime. Properties of either type will
 *   use an \e NSDate to store its value.
 *
 * @warning
 *   The compiler won't stop you from setting a \e JRDate to any valid date value, but the JUMP for iOS library will
 *   automatically convert your \e JRDate properties to acceptable <a href="http://dotat.at/tmp/ISO_8601-2004_E.pdf">
 *   ISO 8601 dates</a> (e.g., \c yyyy-MM-dd) when updating the object on Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSDate   JRDate;
#define JRDate NSDate

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a property of type \e dateTime on
 * Capture can hold only hold values that correspond to the <a href="http://dotat.at/tmp/ISO_8601-2004_E.pdf">
 *   ISO 8601 dateTime format</a> (e.g., \c <code>yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ</code>), while an \e NSDate on
 * Objective-C can hold many more values and formats.
 *
 * To ensure that your objects can correctly update themselves on Capture, we had to use an \e NSDate to hold
 * \e dateTime properties. To make it perfectly clear that \e dateTime properties cannot be just any date, we
 * typedeffed them \e JRDateTime. Your IDE's auto-complete should suggest \e JRDateTime when setting a \e dateTime
 * property, but since underneath it is just an \e NSDate, you can set it to \c null as well.
 *
 * @note
 *   In Capture there is a difference between the type \e date and the type \e dateTime. Properties of either type will
 *   use an \e NSDate to store its value.
 *
 * @warning
 *   The compiler won't stop you from setting a \e JRDateTime to any valid date value, but the JUMP for iOS library
 *   will automatically convert your \e JRDateTime properties to acceptable
 *   <a href="http://dotat.at/tmp/ISO_8601-2004_E.pdf">ISO 8601 dateTimes</a>
 *   (e.g., <code>yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ</code>) when updating the object on Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSDate   JRDateTime;
#define JRDateTime NSDate

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a property of type \e ipAddress on
 * Capture can hold only hold valid IPAddresses (e.g., \c "192.168.0.1") or \c null, where valid IPAddresses are stored
 * as \e NSStrings in Objective-C.
 *
 * To ensure that your objects can correctly update themselves on Capture, we use an \e NSString to hold
 * \e ipAddress properties. To make it perfectly clear that \e ipAddress properties cannot be just any string, we
 * typedeffed them \e JRIpAddress. Your IDE's auto-complete should suggest \e JRIpAddress when setting a \e ipAddress
 * property, but since underneath it is just an \e NSString, you can set it to \c null as well.
 *
 * @warning
 *   The compiler won't stop you from setting a \e JRIpAddress to a value that may not be accepted by Capture, but you
 *   will get an error when you try and update your object on Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSString JRIpAddress;
#define JRIpAddress NSString

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a property of type \e password on
 * Capture can hold both strings and dictionaries. As such, we use an \e NSObject to hold password properties, though
 * what is stored in the \e NSObject will either be an \e NSString or \e NSDictionary.
 *
 * To ensure that your objects can correctly update themselves on Capture, we use an \e NSObject to hold
 * \e password properties. To make it perfectly clear that \e password properties can be strings or dictionaries, we
 * typedeffed them \e JRPassword. Your IDE's auto-complete should suggest \e JRPassword when setting a \e password
 * property, but since underneath it is just an \e NSObject, you can set it to \c null as well.
 *
 * @warning
 *   The compiler won't stop you from setting a \e JRPassword to a value that may not be accepted by Capture, but you
 *   will get an error when you try and update your object on Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSObject JRPassword;
#define JRPassword NSObject

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a property of type \e json on
 * Capture can hold any valid <a href="http://www.json.org/">JSON</a> object (objects, arrays, strings, numbers,
 * booleans, or null). When deserializing properties of type \e json, the JUMP for iOS library stores the result in an
 * \e NSObject property. That is, a \e json property can hold any object hierarchy that JSONKit can serialize.
 * This includes and is limited to \e NSArray, \e NSDictionary, \e NSString, \e NSNumber, and \e NSNull.
 *
 * For more information on JSONKit and what it can serialize check the README in the project:
 * https://github.com/johnezang/JSONKit
 *
 * To ensure that your objects can correctly update themselves on Capture, we use an \e NSObject to hold \e JSON
 * properties. To make it perfectly clear that \e JSON properties can only be types that are accepted by JSONKit, we
 * typedeffed them \e JRJsonObject. Your IDE's auto-complete should suggest \e JRJsonObject when setting a \e JSON
 * property, but since underneath it is just an \e NSObject, you can set it to \c nil as well.
 *
 * @note
 *   If the JSON returned by Capture is an object, this property will hold an \e NSDictionary. If
 *   the JSON returned by Capture is an array, this property will hold an \e NSArray. If it is a string, \e NSString,
 *   number or boolean, \e NSNumber, and if the property is \c null, it will hold \c nil.
 *
 * @warning
 *   The compiler won't stop you from setting a \e JRJsonObject to a value that may not be accepted by Capture or
 *   JSONKit, but you will get an error when you try and update your object on Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSObject JRJsonObject;
#define JRJsonObject NSObject

/**
 * Plurals contain collections of elements, where an element is just an object stored in a plural. Like objects, plural
 * elements can contain primitive values, sub-objects, or sub-plurals.  Plurals only store one type of element, and
 * that element’s attributes are defined in the schema.  Some plurals just store lists of strings.  For example, the
 * JRCaptureUser#profiles plural stores JRProfilesElements, and the JRProfile#quotes plural stores a list of strings
 * (quotes).
 *
 * For both types of plurals (plurals with strings and plurals with objects) use \e NSArrays to hold their elements.
 * When the Capture User Model is generated, the script will determine if the plural property contains a list of strings
 * or a list of elements.
 *
 * If the plural only contains a list of strings, this property is typedeffed to \e JRStringArray. \e JRStringArray
 * properties should only contain \e NSStrings. Your IDE's auto-complete should suggest \e JRStringArray when setting
 * a plural of strings. For example, the JRProfile#books array and the JRProfile#heros array both holds a lists of
 * strings (books and heroes, respectively).
 *
 * If the plural contains elements that are more than just a string, a sub-object is created for that element. For
 * example, the JRCaptureUser contains an \e NSArray property called JRCaptureUser#statuses. This array contains
 * objects of type JRStatusesElements.
 *
 * When adding elements to an array, you should only add the elements that belong in that array.
 *
 * @warning
 *   The compiler won't stop you from setting a most objects to arrays. For example, you could add an \e NSDictionary
 *   to a \e JRStringArray, which is only supposed to hold \e NSStrings. As this value will not be accepted by Capture,
 *   the JUMP for iOS library will filter the array, accepting only the correct element type, before replacing it on
 *   Capture.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page"
 **/
//typedef NSArray  JRStringArray;
#define JRStringArray NSArray

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a property of type \e uuid on
 * Capture holds a string and cannot be modified by a client; that is, \e uuid properties are read-only. To make this
 * clear, the JUMP for iOS library stores the \e uuid property as an \e NSString typedeffed as a \e JRUuid.
 *
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSString JRUuid;
#define JRUuid NSString

/**
 * Some types do not perfectly map between Objective-C and Capture. For example, a property of type \e id on
 * Capture holds a integer id and cannot be modified by a client; that is, \e id properties are read-only. To make this
 * clear, the JUMP for iOS library stores the \e uuid property as an \e NSNumber typedeffed as a \e JRObjectId.
 *
 * @note
 *   Only the top-level JRCaptureUser and elements of plurals have \e id properties. As there can be several plural
 *   elements that are similar (
 * @sa
 *   For more information, please see the \ref typesTable "Type Mapping Reference Page".
 **/
//typedef NSNumber JRObjectId;
#define JRObjectId NSNumber

/**
 * @page Types Mapping Reference
 * The Capture schema, the JSON language, Objective-C, and the JUMP for iOS libraries all use different nomenclature
 * when referring to types. For example, the schema may define a property as having type \c "string", which
 * is the same as the JSON \c "String" and the Objective-C foundational class \c "NSString".
 *
 * Some types do not perfectly map between systems. For example, a \c boolean on Capture can have the
 * values \c true, \c false, and \c null, while an \e NSBoolean in Objective-C can only be \c YES or \c NO.
 * On the other hand an \e NSNumber can represent \c true, \c false, and \c null, but it can also hold many other things
 * that won't be accepted by the Capture API (such as \c -100).
 *
 * To ensure that your objects can correctly update themselves on Capture, we had to use an \e NSNumber to hold
 * boolean properties. To make it perfectly clear that boolean properties cannot be just any number, we typedeffed
 * them \c JRBoolean.  Your IDE's auto-complete should suggest JRBoolean when setting a boolean property, but since
 * underneath it is just an NSNumber, you can set it to \c null as well.
 *
 * @warn
 * The compiler won't stop you from setting a \c JRBoolean to a non-boolean value, but you will get an error when you
 * try and update your object on Capture.
 *
 * @anchor typesTable
 * @table
 * | Schema Type | Json Type        | Obj-C Type | JRCapture Type                  | Recursive  | Typedeffed | Notes|
 * ---------------------------------------------------------------------------------------------------------------------
 * | string      | String           | NSString   | NSString                        |            | No         |      |
 * | boolean     | Boolean          | NSNumber   | ::JRBoolean                     |            | \e Yes     |      |
 * | integer     | Number           | NSNumber   | ::JRInteger                     |            | \e Yes     |      |
 * | decimal     | Number           | NSNumber   | NSNumber                        |            | No         |      |
 * | date        | String           | NSDate     | ::JRDate                        |            | \e Yes     |      |
 * | dateTime    | String           | NSDate     | ::JRDateTime                    |            | \e Yes     |      |
 * | ipAddress   | String           | NSString   | ::JRIpAddress                   |            | \e Yes     |      |
 * | password    | String or Object | NSObject   | ::JRPassword                    |            | \e Yes     |      |
 * | JSON        | (any type)       | NSObject   | ::JRJsonObject                  |            | \e Yes     | The JSON type is unstructured data; it only has to be valid parseable JSON. |
 * | plural      | Array            | NSArray    | NSArray or ::JRStringArray      | \e Yes     | No/\e Yes  | Primitive child attributes of plurals may have the constraint locally-unique. |
 * | object      | Object           | NSObject   | JR&lt;<em>PropertyName</em>&gt; | \e Yes     | No         |      |
 * | uuid        | String           | NSString   | ::JRUuid                        |            | \e Yes     | Not an externally usable type. |
 * | id          | Number           | NSNumber   | ::JRObjectId                    |            | \e Yes     | Not an externally usable type. |
 * @endtable
 *
 *
 *
@anchor types
@htmlonly
<!--
<table border="1px solid black">
<tr><b><td>Schema Type  </td><td>Json Type         </td><td>Obj-C Type   </td><td>JRCapture Type                   </td><td>Recursive  </td><td>Typedeffed    </td><td>Notes  </td></b></tr>
<tr><td>string          </td><td>String            </td><td>NSString     </td><td>NSString                         </td><td>           </td><td>No            </td><td>       </td></tr>
<tr><td>boolean         </td><td>Boolean           </td><td>NSNumber     </td><td>JRBoolean                        </td><td>           </td><td><b>Yes</b>    </td><td>       </td></tr>
<tr><td>integer         </td><td>Number            </td><td>NSNumber     </td><td>JRInteger                        </td><td>           </td><td><b>Yes</b>    </td><td>       </td></tr>
<tr><td>decimal         </td><td>Number            </td><td>NSNumber     </td><td>NSNumber                         </td><td>           </td><td>No            </td><td>       </td></tr>
<tr><td>date            </td><td>String            </td><td>NSDate       </td><td>JRDate                           </td><td>           </td><td><b>Yes</b>    </td><td>       </td></tr>
<tr><td>dateTime        </td><td>String            </td><td>NSDate       </td><td>JRDateTime                       </td><td>           </td><td><b>Yes</b>    </td><td>       </td></tr>
<tr><td>ipAddress       </td><td>String            </td><td>NSString     </td><td>JRIpAddress                      </td><td>           </td><td><b>Yes</b>    </td><td>       </td></tr>
<tr><td>password        </td><td>String or Object  </td><td>NSObject     </td><td>JRPassword                       </td><td>           </td><td><b>Yes</b>    </td><td>       </td></tr>
<tr><td>JSON            </td><td>(any type)        </td><td>NSObject     </td><td>JRJsonObject                     </td><td>           </td><td><b>Yes</b>    </td><td>The JSON type is unstructured data; it only has to be valid parseable JSON.</td></tr>
<tr><td>plural          </td><td>Array             </td><td>NSArray      </td><td>NSArray or JRSimpleArray         </td><td><b>Yes</b> </td><td>No/<b>Yes</b> </td><td>Primitive child attributes of plurals may have the constraint locally-unique.</td></tr>
<tr><td>object          </td><td>Object            </td><td>NSObject     </td><td>JR&lt;<em>PropertyName</em>&gt;  </td><td><b>Yes</b> </td><td>No            </td><td>       </td></tr>
<tr><td>uuid            </td><td>String            </td><td>NSString     </td><td>JRUuid                           </td><td>           </td><td><b>Yes</b>    </td><td>Not an externally usable type.</td></tr>
<tr><td>id              </td><td>Number            </td><td>NSNumber     </td><td>JRObjectId                       </td><td>           </td><td><b>Yes</b>    </td><td>Not an externally usable type.</td></tr>
</table>
-->
@endhtmlonly
 *
 **/

