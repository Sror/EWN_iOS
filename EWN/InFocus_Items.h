//
//  InFocus_Items.h
//  EWN
//
//  Created by Dolfie on 2013/12/09.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface InFocus_Items : NSManagedObject

@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * imageLargeUrl;
@property (nonatomic, strong) NSString * imageThumbnailUrl;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) NSString * title;

@end
