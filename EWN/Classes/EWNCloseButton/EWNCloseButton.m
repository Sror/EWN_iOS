//
//  EWNCloseButton.m
//  EWN
//
//  Created by Andre Gomes on 2014/01/23.
//
//

#import "EWNCloseButton.h"


@interface EWNCloseButton () {
    float offset;
}

@end


@implementation EWNCloseButton


#pragma mark - Lifecycle Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        offset = 5.0f;
    }
    return self;
}



#pragma mark - Override Methods

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        [self setImage:nil forState:UIControlStateNormal | UIControlStateHighlighted | UIControlStateSelected];
    }
}

- (void)setFrame:(CGRect)frame {
    if (CGRectIsEmpty(frame) == NO || CGRectIsNull(frame) == NO) {
        if (frame.size.width > 0 || frame.size.height > 0) {
            float xValue = 44.0f - frame.size.width;
            xValue = xValue > 0 ? frame.origin.x - xValue : frame.origin.x ;
            frame = CGRectMake(xValue + offset, frame.origin.y - offset, 44.0f, 35.0f);
        }
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    UIImage *image = nil;
    
    if (self.isHighlighted || self.isSelected) {
        image = [[UIImage imageNamed:@"close_button_down"] autorelease];
    } else {
        image = [[UIImage imageNamed:@"close_button"] autorelease];
    }
    
    if (image) {
        // Calculate the frame to draw image.
        float scale = 1; // [UIScreen mainScreen].scale;
        CGSize imageSize = CGSizeMake(image.size.width / scale, image.size.height / scale);
        CGRect imageRect = CGRectMake(rect.size.width - imageSize.width - offset , 0.0f + offset, imageSize.width, imageSize.height);
        // Perform drawing action.
        [image drawInRect:imageRect];
    }
}


@end
