//
//  BubbleViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/09/18.
//
//

#import "BubblesViewController.h"

// VIEW //
@interface BubblesViewController()

@end

// CONTROLLER //

@implementation BubblesViewController

-(id)init
{    
    isActive = FALSE;
    
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
//    DLog(@":: Bubble - View");
}

-(void) createBubbles
{
    // Config
    originX = 0;
    originY = 0;
    
    offsetX = self.view.frame.size.width / 2;
    offsetY = self.view.frame.size.height / 2;
    
    self.view.layer.position = CGPointMake(self.view.layer.position.x * 2, self.view.layer.position.y * 2);
    
//    DLog(@"Origin : %f", self.view.layer.position.x);
//    DLog(@"Origin : %f", self.view.layer.position.y);
//    DLog(@"Origin : %f", self.view.layer.anchorPoint.x);
//    DLog(@"Origin : %f", self.view.layer.anchorPoint.y);
    
    isActive = TRUE;
    
    /* Timer generates fresh Bubbles every 10 seconds */
    [self updateBubbles:NULL];
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateBubbles:) userInfo:nil repeats:YES];
}

-(void)updateBubbles:(NSTimer *)mTimer
{
    if(isActive)
    {
        for(int i = 0; i < 10; i++)
        {
            [self addBubble];
        }
    }
    else
    {
        isActive = FALSE;
        [timer invalidate];
        timer = nil;
    }
}

-(void)addBubble
{
    UIImageView *bubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble.png"]];
    
    /* Generate Random Coordinates */
    int ranX = (arc4random() % offsetX);
    int ranY = (arc4random() % offsetY);
    
    int posX = (originX / 2) + ranX;
    int posY = (originY / 2) + ranY;
    
//    DLog(@"Pos X : %d", posX);
//    DLog(@"Pos Y : %d", posY);
    
    // Step 1 - Calculate the coordinates
    int deltaX = (posX - originX);
    int deltaY = (posY - originY);
    float angleRadians = atan2(deltaX, deltaY) * 180 / M_PI;
    
//    DLog(@" MATH : %f", angleRadians);
    
    // Step 2 - Plot a path based on angle
    int pathLength = 250;
    int endX = originX + pathLength * cos(angleRadians);
    int endY = originY + pathLength * sin(angleRadians);
    
    // Step 3 - Random Scale, Delay, Speed
    int initDelay = 5;
    int initSpeed = 5;
    
    //double ranScale = ((double)arc4random() / SCALE_MAX);
    float ranScale = ((float)rand() / RAND_MAX) * 0.25f;
    int ranDelay = (arc4random() % initDelay);
    int ranSpeed = (arc4random() % initSpeed) + 5;
    
    // Step 4 - Configure Bubble
    CGRect animFrame = bubble.frame;
    animFrame.origin.x += endX;
    animFrame.origin.y += endY;
    
    bubble.frame = CGRectMake(bubble.frame.origin.x, bubble.frame.origin.y, (bubble.frame.size.width * ranScale), (bubble.frame.size.height * ranScale));
    bubble.layer.position = CGPointMake(0, 0);
    bubble.alpha = 0.1f;
        
    // Delay and Fade
    [UIView animateWithDuration:0
                          delay:ranDelay
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         bubble.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         // Start Animation
                         [UIView animateWithDuration:ranSpeed
                                               delay:0
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              bubble.frame = animFrame;
                                              bubble.alpha = 0.1f;
                                          }
                                          completion:^(BOOL finished){
                                              [bubble removeFromSuperview];
                                          }
                          ];
                         
                     }
     ];
    
    [self.view addSubview:bubble];
}

-(void)killBubbles
{    
    isActive = FALSE;
    [self.view removeFromSuperview];
}

@end