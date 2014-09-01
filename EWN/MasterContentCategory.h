//
//  MasterContentCategory.h
//  EWN
//
//  Created by Arpit Jain on 4/30/13.
//
//
/**------------------------------------------------------------------------
 File Name      : MasterContentCategory.h
 Created By     : Arpit Jain
 Created Date   :
 Purpose        : The DataBase Entity file named Master Content Category which stores the ID's of content and category.
 -------------------------------------------------------------------------*/
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MasterContentCategory : NSManagedObject

@property (nonatomic, strong) NSString * contentID;
@property (nonatomic, strong) NSString * categoryID;

@end
