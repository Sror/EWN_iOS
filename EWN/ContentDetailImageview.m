//
//  ContentDetailImageview.m
//  EWN
//
//  Created by Dolfie Jay on 2014/01/23.
//
//

#import "ContentDetailImageview.h"

@implementation ContentDetailImageview

@synthesize imageUrl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        imageUrl = @"";
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
