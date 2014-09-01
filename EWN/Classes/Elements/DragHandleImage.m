//
//  DragHandleImage.m
//  EWN
//
//  Created by Dolfie Jay on 2014/01/21.
//
//

#import "DragHandleImage.h"

@implementation DragHandleImage
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    UIImage* image = [UIImage imageNamed:@"articles_drag_btn"];
//    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//}


@end
