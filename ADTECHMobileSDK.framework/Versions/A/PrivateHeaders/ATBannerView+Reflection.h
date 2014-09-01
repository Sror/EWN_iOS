//
//  ATBannerView+Reflection.h
//  ADTECHMobileSDK
//
//  Created by ADTECH GmbH on 4/26/13.
//  Copyright (c) 2013 ADTECH GmbH. All rights reserved.
//

#import <ADTECHMobileSDK/ATBannerView.h>

typedef enum
{
	kATAdTypeUnknown,
	kATAdTypeImage,
	kATAdTypeRich,
	kATAdTypeMRAID,
	kATAdTypeORMMA,
	kATAdTypeAdMob,
	kATAdTypeMillennial,
	kATAdTypeiAd,
	kATAdTypeGreystripe,
	kATAdTypeVdopia,
	kATAdTypeRubicon,
}
ATAdType;

@interface ATBannerView (Reflection)

- (ATAdType)currentAdType;

@end
