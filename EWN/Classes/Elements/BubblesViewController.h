//
//  BubbleViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/09/18.
//
//

#import <UIKit/UIKit.h>

#define SCALE_MAX      0x100000000

@interface BubblesViewController : UIViewController
{
    BOOL isActive;
    
    NSTimer *timer;
    
    int originX;
    int originY;
    
    int offsetX;
    int offsetY;
}

-(void) createBubbles;
-(void) updateBubbles:(NSTimer *)mTimer;
-(void) addBubble;
-(void) killBubbles;

@end
