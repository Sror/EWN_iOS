//
//  EWNDragHandleView.m
//  EWN
//
//  Created by Andre Gomes on 2014/01/22.
//
//

#import "EWNDragHandleView.h"

@implementation EWNDragHandleView

@synthesize image;

#pragma mark - Lifecycle Methods

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = TRUE;
    }
    return self;
}


#pragma mark - Override Methods

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    image = [UIImage imageNamed:@"articles_drag_btn"];
    
    if (image)
    {
        // Calculate the frame to draw image.
        float scale = 2; // [UIScreen mainScreen].scale;
        CGSize imageSize = CGSizeMake(image.size.width / scale, image.size.height / scale);
        CGRect imageRect = CGRectMake(rect.size.width - imageSize.width - 10, 10, imageSize.width, imageSize.height);
        
        // Perform drawing action.
        [image drawInRect:imageRect];
    }
}

- (void)dealloc {
    [image release];
    [super dealloc];
}

@end
