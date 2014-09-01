//
//  PDSocialSharingManager.h
//  EWN
//
//  Created by Andre Gomes on 2014/01/28.
//
//

#import <Foundation/Foundation.h>


/*!
 *  @brief This class provides for an easy plug and play implementation for sharing to social media providers.
 *
 *  This class provides methods necessary for sharing supporting share option from iOS 5 to iOS 7 (and beyond).
 *  Sharing for iOS 7 makes use of the UIActivityViewController where as for iOS 5 & 6, integration with JanRain to secure the share options. \n
 *
 *  @note The class has dependencies on the JanRain Library.
 *  @author Andre Gomes.
 *  @version 1.0
 *
 */

@interface PDSocialSharingManager : NSObject


/**
 *  Predefined enums for possible sharing types.
 *
 *  @note modifying this list will require additional condition to be made in PDSocialSharingManager.m file.
 */
typedef enum {
    PDSocialSharingTypeNone,
    PDSocialSharingTypeMail,
    PDSocialSharingTypeTwitter,
    PDSocialSharingTypeFacebook
}PDSocialSharingType;


#if NS_BLOCKS_AVAILABLE
typedef void (^PDSocialSharingManagerCompletionBlock)(PDSocialSharingManager *manager, BOOL successful, NSError *error);
#endif



/*!
 *  @brief Returns the singleton instance for PDSocialSharingManager.
 *
 *  This returns an instance of the class to allow the implementation class to then make use of the public methods.
 *
 *  @note This method is required for referencing a global instance.
 *
 *  @return PDSocialSharingManager singleton instance.
 *
 */
+ (PDSocialSharingManager *) sharedInstance;



/*!
 *  @brief Returns the enum of selected provider.
 *
 *  This method can be called after invoking showSharingOptions:target:callback to indicate the provider that was selected.
 *
 *  @note This method is optional for read-only purposes.
 *
 *  @since v 1.0
 *  @see PDSocialSharingType enum for information on available providers.
 *  @return PDSocialSharingType.
 *
 */
- (PDSocialSharingType)selectedSocialSharingType;




#if NS_BLOCKS_AVAILABLE
/*!
 *  @brief Presents sharing options.
 *
 *  This method must be called to invoke the app to present sharing options specific to OS version. \n
 *  Example code:
 *
 *  @code
 *  [[PDSocialSharingManager sharedInstance] showSharingOptions:sharingItemsArray target:self callback:^(PDSocialSharingManager *manager, BOOL successful, NSError *error) 
 *  {
 *       if (successful && error == nil)
 *       {
 *           if ([manager selectedSocialSharingType] == PDSocialSharingTypeMail) {}
 *           else {}
 *       }
 *       else
 *       {
 *           if (error) {}
 *           else {}
 *       }
 *   }];
 *  @endcode
 *
 *  @note Can only be used for block based calls.
 *
 *  @param userInfo 
 *      References an array of strings that represent a title and url in that order for sharing.
 *  @param target 
 *      The UIVIewController from which the share option will be presented.
 *  @param completed 
 *      Provides a block callback for handling sharing inline within other class methods (PDSocialSharingManagerCompletionBlock).
 *
 */
- (void)showSharingOptions:(id)userInfo target:(id)target callback:(PDSocialSharingManagerCompletionBlock)completed;
#endif



@end
