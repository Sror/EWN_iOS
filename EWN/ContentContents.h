//
//  ContentContents.h
//  EWN
//
//  Created by Dolfie Jay on 2014/04/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ContentContents : NSManagedObject

@property (nonatomic, strong) NSString * parentArticleId;
@property (nonatomic, strong) NSString * childArticleId;

@end
