//
//  Category_Items.h
//  EWN
//
//  Created by Arpit Jain on 4/29/13.
//
//
/**------------------------------------------------------------------------
 File Name      : Category_Items.h
 Created By     : Arpit Jain
 Created Date   :
 Purpose        : The DataBase Entity file of Category which stores the data of Category.
 -------------------------------------------------------------------------*/
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Category_Items : NSManagedObject

@property (nonatomic, strong) NSString * categoryId;
@property (nonatomic, strong) NSString * categoryName;
@property (nonatomic, readwrite) int categoryIndex;

@end
