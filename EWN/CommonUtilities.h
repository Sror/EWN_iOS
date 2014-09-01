//
//  CommonUtilities.h
//  EWN
//
//  Created by Jainesh Patel on 5/1/13.
//
//
/**------------------------------------------------------------------------
 File Name      : CommonUtilities.h
 Created By     : Jainesh Patel.
 Created Date   :
 Purpose        : This class contains the common methods.
 -------------------------------------------------------------------------*/
#import <Foundation/Foundation.h>

@interface CommonUtilities : NSObject
{
}

+ (id)sharedManager;
- (id)init;

- (NSString *)formatDateWithTimeDurationFormat : (NSString *)strDate;
- (NSDate*)datefromString:(NSString*)strDate;

- (NSString *)formatSearchDateWithTimeDurationFormat : (NSString *)strDate;

- (NSString *)formatCommentLikeString:(NSString *)string;

@end