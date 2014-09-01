//
//  EngageProtocol.h
//  EWN
//
//  Created by Dolfie on 2013/10/28.
//
//

#import <Foundation/Foundation.h>
#import "JREngage.h"

@protocol EngageSigninDelegate <JREngageSigninDelegate>
@required
- (void) engageDialogDidFailToShowWithError: (NSError *) error;
- (void) authenticationDidNotComplete;
- (void) authenticationDidSucceedForUser:(NSDictionary *) authInfo forProvider:(NSString *)	provider;
- (void) authenticationDidFailWithError:(NSError *) error forProvider:(NSString *) provider;
- (void) authenticationDidReachTokenUrl:(NSString *) tokenUrl withResponse:(NSURLResponse *) response andPayload:(NSData *) tokenUrlPayload forProvider:(NSString *) provider;
- (void) authenticationCallToTokenUrl:(NSString *) tokenUrl didFailWithError:(NSError *) error forProvider:(NSString *) provider;
@end

@protocol EngageSharingDelegate <JREngageSharingDelegate>
@required
- (void) sharingDidNotComplete;
- (void) sharingDidComplete;
- (void) sharingDidSucceedForActivity:(JRActivityObject *) activity forProvider:(NSString *) provider;
- (void) sharingDidFailForActivity:	(JRActivityObject *) activity withError:(NSError *) error forProvider:(NSString *) provider;
@end

@interface EngageProtocol : NSObject
{
    id <EngageSigninDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;
@end
