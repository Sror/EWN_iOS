//
//  CustomAlertView.m
//  EWN
//
//  Created by Macmini on 18/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame Title:(NSString *)strTitle OKButton:(BOOL)isOK CancelButton:(BOOL)isCancel
{
    self = [super initWithFrame:frame];
    if(self)
    {
    
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
