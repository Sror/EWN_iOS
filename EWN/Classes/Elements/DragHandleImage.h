//
//  DragHandleImage.h
//  EWN
//
//  Created by Dolfie Jay on 2014/01/21.
//
//

#import <UIKit/UIKit.h>

@protocol DragHandleImageDelegate <NSObject>

-(void)touchDragImage;

@end

@interface DragHandleImage : UIImageView

@property (nonatomic, strong) id<DragHandleImageDelegate> delegate;

@end
