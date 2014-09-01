//
//  EWNImageView.m
//  EWN
//
//  Created by Andre Gomes on 2013/12/05.
//
//

#import "EWNImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface EWNImageView ()

@property (nonatomic, strong) CALayer *maskImageLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CALayer *loadImageLayer;

@end

@implementation EWNImageView

// Public
@synthesize progress = _progress;
@synthesize maskImage = _maskImage;
@synthesize loadImage = _loadImage;
@synthesize animationTimeinterval = _animationTimeinterval;

// Private
@synthesize maskImageLayer;
@synthesize maskLayer;
@synthesize loadImageLayer;

#pragma mark - GETTERS

- (CALayer *)maskImageLayer
{
    if (!maskImageLayer) {
        maskImageLayer = [CALayer layer];
        maskImageLayer.backgroundColor = [UIColor clearColor].CGColor;
        maskImageLayer.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    }
    return maskImageLayer;
}

- (CAShapeLayer *)maskLayer
{
    if (!maskLayer) {
        maskLayer = [CAShapeLayer layer];
        maskLayer.fillRule = kCAFillRuleEvenOdd;
        maskLayer.fillColor = [UIColor whiteColor].CGColor;
        maskLayer.path = CGPathCreateWithRect((CGRect){{0.0f, 0.0f}, {self.frame.size.width, self.frame.size.height}}, nil);
        
        self.maskLayer.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }
    return maskLayer;
}

- (CALayer *)loadImageLayer
{
    if (!loadImageLayer) {
        loadImageLayer = [CALayer layer];
        loadImageLayer.backgroundColor = [UIColor clearColor].CGColor;
        loadImageLayer.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    }
    return loadImageLayer;
}

#pragma mark - SETTERS

- (void)setMaskImage:(UIImage *)image
{
    if (image == nil)
    {
        if (maskImageLayer && maskImageLayer.superlayer != nil) {
            [maskImageLayer removeFromSuperlayer];
            maskImageLayer = nil;
        }
    }
    
    if (image != _maskImage) {
        _maskImage = image;
        
        if (self.maskImageLayer.superlayer == nil)
            [self.layer insertSublayer:self.maskImageLayer atIndex:0];
        
        
        self.maskImageLayer.contents = (id)image.CGImage;
    }
}

- (void)setLoadImage:(UIImage *)image
{
    if (image == nil)
    {
        if (loadImageLayer && loadImageLayer.superlayer != nil) {
            [loadImageLayer removeFromSuperlayer];
            loadImageLayer = nil;
            maskLayer = nil;
        }
    }
    
    if (image != _loadImage) {
        _loadImage = image;
        
        if (self.loadImageLayer.superlayer == nil)
            [self.layer addSublayer:self.loadImageLayer];
        
        self.loadImageLayer.mask = self.maskLayer;
        
        self.loadImageLayer.contents = (id)image.CGImage;
    }
}

#pragma mark - Lifecycle Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialise];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialise];
    }
    return self;
}

- (void)initialise
{
    _progress = 0.0f;
    _animationTimeinterval = 1.50f; // 0.80f
}

#pragma mark - Override Methods

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview)
        [self initialise];
}

#pragma mark - Public Methods

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (progress <= 0.0)
        _progress = progress;
    else
        _progress += progress;

    
    if (_progress > 1.0) {
        _progress = 1.0;
    }
    
    float yOffset = self.frame.size.height - (self.frame.size.height * _progress);
    
    if (animated)
    {
        EWNImageView *blockSafeSelf = self;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:_animationTimeinterval];
        
        self.maskLayer.frame = CGRectMake(0.0f, yOffset, self.frame.size.width, self.frame.size.height);
        
        [CATransaction setCompletionBlock:^{
            if (_progress == 1.0)
                [blockSafeSelf fadeOutLogo];
        }];
        [CATransaction commit];
    }
    else
    {
        // There is actually an implicit animation on setting some values for a CALayer. You have to disable the animations before you set a new frame.
        // https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreAnimation_guide/Articles/Transactions.html
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
         self.maskLayer.frame = CGRectMake(0.0f, yOffset, self.frame.size.width, self.frame.size.height);
        
        [CATransaction commit];
        
        if (_progress == 1.0)
            [self fadeOutLogo];
    }
}


#pragma mark - Private Methods

- (void)fadeOutLogo
{
    EWNImageView *blockSafeSelf = self;

    [UIView animateWithDuration:0.35f
                          delay:0.40 // 0.60f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         blockSafeSelf.frame = CGRectMake(blockSafeSelf.superview.frame.size.width,
                                                          blockSafeSelf.frame.origin.y,
                                                          blockSafeSelf.frame.size.width,
                                                          blockSafeSelf.frame.size.height);
                         blockSafeSelf.alpha = 0.2;
                     }
                     completion:^(BOOL finished){
                         // remove the splash screen from view
                         [[self.superview.superview viewWithTag:8000] removeFromSuperview];
                     }];
}

@end
