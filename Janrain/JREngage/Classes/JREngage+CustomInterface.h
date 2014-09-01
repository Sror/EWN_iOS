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

 File:   JREngage+CustomInterface.h
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Friday, January 21, 2011
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "JREngage.h"

/**
 * @defgroup customInterface Custom User Interface
 * @brief Customize the user interface with your application's colors, images, native login, etc.
 *
 * @detail
 * The Engage for iPhone SDK provides the ability to customize the look and feel of the user
 * interface, as well as the ability to add your own native login experience, through the
 * \ref customInterface "Custom Interface API". You can set many of the custom interface defaults
 * through the JREngage#setCustomInterfaceDefaults:() method and override these defaults
 * programmatically through any of the \ref showMethods "...CustomInterfaceOverrides" functions.
 *
 * The SDK accepts a mutable dictionary of values, indexed by a
 * \ref customInterfaceKeys "pre-defined set of keys", and uses these to set the properties of the
 * library's user interface. To configure the SDK programmatically (e.g., dynamically integrating
 * your native login experience above or below the library's social logins), create an
 * \e NSMutableDictionary object, indexed by a \ref customInterfaceKeys "pre-defined set of keys"
 * and pass this to the library through the JREngage#setCustomInterfaceDefaults: method.
 *
 * You can also override these default customizations by launching the authentication and social
 * sharing with a new dictionary of the \ref customInterfaceKeys "pre-defined set of keys" and
 * values with the JREngage#showAuthenticationDialogWithCustomInterfaceOverrides:
 * or JREngage#showSharingDialogWithActivity:withCustomInterfaceOverrides: methods. Any overlapping
 * values passed into the \e show...Dialog methods will override the corresponding values passed
 * into the JREngage#setCustomInterfaceDefaults: method.
 *
 * @{
 **/

/**
 * @name Navigation Controller
 * @brief Keys to customize the behavior and presentation of the library's navigation bar
 **/
/*@{*/

/**
 * Key for your application's main \e UINavigationController object on which to push the sign-in
 * and sharing dialogs
 **/
#define kJRApplicationNavigationController @"Application.NavigationController"

/**
 * Key for a \e UINavigationController object that your application owns.
 *
 * If you want to push your own views onto the library’s navigation controller, but your application
 * does not have a navigation controller or your application is running on the iPad or if you want
 * the library’s dialogs to present themselves using the \e UIModalTransitionStyleCoverVertical
 * transition style, you can use the \e kJRCustomModalNavigationController key. This is also necessary
 * if you want to tint the navigation bar’s color.
 **/
#define kJRCustomModalNavigationController @"ModalDialog.NavigationController"

/**
 * Key for a boolean value represented by an \e NSObject to indicate if the dialog's "Cancel"
 * button should be hidden.
 *
 * If you want to hide the "Cancel" button on the Providers Table or Social Sharing screen, pass in
 * an \e NSObject containing a positive integer or the strings \c \@"YES" or \c \@"TRUE". This will
 * remove the "Cancel" button from the library's dialogs.
 *
 * @par Warning:
 * Do not cancel social sharing or authentication by popping the navigation controller back to one
 * of your views, as this could potentially leave the library in an unexpected state. If you wish
 * to cancel sign in or social sharing, please use the JREngage#cancelAuthentication or
 * JREngage#cancelSharing methods.
 **/
#define kJRNavigationControllerHidesCancelButton @"NavigationController.HidesCancelButton"
/*@}*/

/**
* @name Presenting View Controller
* A key to explicitly specify which UIViewController from which the library will present its
* modal view controllers when running on iPad
*/
/*@{*/
/**
 * Key for a \e UIViewController object that your application owns, which will be used to present the library's
 * modal dialogs.
*/
#define kJRModalDialogPresentationViewController @"PresentingViewController"
/*@}*/


/**
 * @name Background Colors
 * Keys to specify the background color of the library's dialogs
 **/
/*@{*/

/**
 * Key for a \e UIColor object to set as the background color of the Providers Table and the
 * User Landing screen.
 **/
#define kJRAuthenticationBackgroundColor  @"Authentication.Background.Color"

/**
 * Key for a \e UIColor object to set as the background color of the Social Sharing screen.
 **/
#define kJRSocialSharingBackgroundColor   @"SocialSharing.Background.Color"
/*@}*/

/**
 * @name Background Images
 * Keys to specify image views to be used as the background of the library's dialogs
 **/
/*@{*/

/**
 * Key for the \e UIImageView containing the image to be set as the background of the
 * Providers Table and the User Landing screen.
 **/
#define kJRAuthenticationBackgroundImageView  @"Authentication.Background.Image.View"

/**
 * Key for the \e UIImageView containing the image to be set as the background of the
 * Social Sharing screen.
 **/
#define kJRSocialSharingBackgroundImageView   @"SocialSharing.Background.Image.View"
/*@}*/

/**
 * @name Title Views
 * Keys to specify UIViews to be used as the title views of the library's dialogs
 **/
/*@{*/

/**
 * Key for the \e UIView object to be set as the title view of the Providers Table.
 *
 * @note
 * If this value is set, it will override any string value set for define #kJRProviderTableTitleString,
 * although the define #kJRProviderTableTitleString value will be used as the text on the "Back" button.
 **/
#define kJRProviderTableTitleView        @"ProviderTable.Title.View"

/**
 * Key for the \e UIView object to be set as the title view of the Social Sharing screen.
 *
 * @note
 * If this value is set, it will override any string value set for define #kJRSocialSharingTitleString,
 * although the define #kJRSocialSharingTitleString value will be used as the text on the "Back" button.
 **/
#define kJRSocialSharingTitleView        @"SocialSharing.Title.View"
/*@}*/

/**
 * @name Title Strings
 * Keys to specify NSString titles to be used as the titles of the library's dialogs
 **/
/*@{*/

/**
 * Key for the \e NSString title to be set as the title of the Providers Table.
 *
 * @note
 * If a \e UIView* is set for the define #kJRProviderTableTitleView key, this string will not
 * appear as the title on the navigation bar. It will only be used as the text on the "Back" button.
 **/
#define kJRProviderTableTitleString   @"ProviderTable.Title.String"

/**
 * Key for the \e NSString title to be set as the title of the Social Sharing screen.
 *
 * @note
 * If a \e UIView* is set for the define #kJRSocialSharingTitleView key, this string will not
 * appear as the title on the navigation bar. It will only be used as the text on the "Back" button.
 **/
#define kJRSocialSharingTitleString   @"SocialSharing.Title.String"
/*@}*/

/**
 * @name Provider Table Header and Footer Views
 * Keys to specify UIViews to be used as the Provider Table's header and footer views
 **/
/*@{*/

/**
 * Key for the \e UIView object to be set as the header view of the Providers Table.
 **/
#define kJRProviderTableHeaderView       @"ProviderTable.Table.Header.View"

/**
 * Key for the \e UIView object to be set as the footer view of the Providers Table.
 **/
#define kJRProviderTableFooterView       @"ProviderTable.Table.Footer.View"
/*@}*/

/**
 * @name Provider Table Section Header and Footer Views
 * Keys to specify UIViews to be used as the Provider Table's providers section header and footer views
 **/
/*@{*/

/**
 * Key for the \e UIView object to be set as the view of the providers section header in the
 * Providers Table.
 *
 * @note
 * Setting this value overrides any string set as the define #kJRProviderTableSectionHeaderTitleString.
 **/
#define kJRProviderTableSectionHeaderView       @"ProviderTable.Section.Header.View"

/**
 * Key for the \e UIView object to be set as the view of the providers section footer in the
 * Providers Table.
 *
 * @note
 * Setting this value overrides any string set as the define #kJRProviderTableSectionFooterTitleString.
 **/
#define kJRProviderTableSectionFooterView       @"ProviderTable.Section.Footer.View"
/*@}*/

/**
 * @name Provider Table Section Header and Footer Strings
 * Keys to specify NSStrings to be used as the Provider Table's providers section header and footer text
 **/
/*@{*/

/**
 * Key for the \e NSString to be set as the title of the providers section header in the Providers Table.
 *
 * @note
 * If a \e UIView* is set for the define #kJRProviderTableSectionHeaderView key, this string will not be used.
 **/
#define kJRProviderTableSectionHeaderTitleString  @"ProviderTable.Section.Header.Title.String"

/**
 * Key for the \e NSString to be set as the title of the providers section footer in the Providers Table.
 *
 * @note
 * If a \e UIView* is set for the define #kJRProviderTableSectionFooterView key, this string will not be used.
 **/
#define kJRProviderTableSectionFooterTitleString  @"ProviderTable.Section.Footer.Title.String"
/*@}*/

/**
 * @name Popover Controller
 * Keys to specify the behavior of the \e UIPopoverController used to present the dialogs on the iPad
 **/
/*@{*/

/**
 * Key specifying the \e NSValue of a \e CGRect from which the authentication and sharing dialogs
 * should originate if using a modal popover view on the iPad.
 *
 * @par Example:
 * @code
 * CGRect rect = CGRectMake(x,y,w,h);
 * NSValue *rectValue = [NSValue valueWithCGRect:rect];
 * @endcode
 **/
#define kJRPopoverPresentationFrameValue @"Popover.Presentation.Frame.Value"

/**
 * Key for the \e UIBarButtonItem object from which the authentication and sharing dialogs
 * should originate if using a modal popover view on the iPad.
 **/
#define kJRPopoverPresentationBarButtonItem @"Popover.Presentation.BarButtonItem"

/**
 * Key for an \e NSNumber object representing the \e UIPopoverArrowDirection enumeration
 * when presenting the dialog from a \e UIPopoverController.
 *
 * The default is \c UIPopoverArrowDirectionAny.
 *
 * @par Example:
 * @code
 * [NSNumber numberWithInt:UIPopoverArrowDirectionDown];
 * @endcode
 **/
#define kJRPopoverPresentationArrowDirection @"Popover.Presentation.ArrowDirection"
/*@}*/

/**
 * @name Custom Authentication
 * Keys to customize the list of providers during sign-in
 **/
/*@{*/
/**
 * Key for an \e NSArray object containing a list of /e NSString provider names that you would like to exclude from table of
 * providers when you launch the sign-in dialog
 *
 * For a list of possible strings, please see the \ref basicProviders "List of Providers"
 **/
#define kJRRemoveProvidersFromAuthentication @"ProviderTable.RemoveProviders"
/*@}*/

/**
 * @name Capture Conventional Sign-in
 * Keys to customize the Capture Native Sign-in view
 **/
/*@{*/
/**
 * Key for the \e NSString title to be set as the title of the Native Sign-in view.
 *
 * @note
 * If a \e UIView* is set for the define #kJRCaptureNativeSigninTitleView key, this string will not appear as the title
 * above the table section with the Capture Native Sign-in view, but the customized title view will be used instead.
 * If you want to customize the title that will appear over the table section displaying the social providers, you can
 * use the keys define #kJRProviderTableSectionHeaderTitleString or define #kJRProviderTableSectionHeaderView
 **/
#define kJRCaptureTraditionalSignInTitleString    @"Capture.ConventionalSignin.Title.String"

/**
 * Key for the \e UIView object to be set as the title view of the Native Sign-in view.
 *
 * @note
 * If this value is set, it will override any string value set for define #kJRCaptureNativeSigninTitleString key.
 * If you want to customize the title view that will appear over the table section displaying the social providers,
 * you can use the keys define #kJRProviderTableSectionHeaderTitleString or define #kJRProviderTableSectionHeaderView
 **/
#define kJRCaptureTraditionalSignInTitleView      @"Capture.ConventionalSignin.Title.View"
/*@}*/

#define kJRCaptureConventionalSigninTitleView @"Capture.ConventionalSignin.Title.View"
#define kJRCaptureConventionalSigninTitleString @"Capture.ConventionalSignin.Title.String"
/**
 * @internal
 **/
#define kJRCaptureTraditionalSignInViewController @"Capture.ConventionalSignin.ViewController"
/** @}*/

