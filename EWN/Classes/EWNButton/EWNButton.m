//
//  EWNButton.m
//  EWN
//
//  Created by Andre Gomes on 2014/01/08.
//
//



#import "EWNButton.h"

@interface EWNButton ()
{
    NSString *titleText;
}

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end




@implementation EWNButton

// Public
@synthesize isAnimating;

// Private
@synthesize activityIndicatorView = _activityIndicatorView;



#pragma mark - GETTERS

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
        _activityIndicatorView.transform = CGAffineTransformMakeScale(0.65, 0.65); // We scale down the indicator as we cant adjust its internal frames.
    }
    return _activityIndicatorView;
}

- (BOOL)isAnimating
{
    if (_activityIndicatorView)
        return _activityIndicatorView.isAnimating;
    
    return NO;
}


#pragma mark - Lifecycle Methods

- (id)init
{
    self = [super init];
    if (self) {
        [self initalize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize
{
    self.backgroundColor = [UIColor clearColor];
}



#pragma mark - Public Methods

- (void)shouldAnimate:(BOOL)animate
{
    titleText = self.titleLabel.text;
    
    if (!_activityIndicatorView)
        if (_activityIndicatorView.superview == nil)
            [self addSubview:self.activityIndicatorView];

    if (animate)
    {
//        self.titleLabel.text = @"";
        [self setTitle:@"" forState:UIControlStateNormal];
        [_activityIndicatorView startAnimating];
    }
    else
    {
//        self.titleLabel.text = titleText;
        [self setTitle:titleText forState:UIControlStateNormal];
        [_activityIndicatorView stopAnimating];
    }
}



#pragma mark - Override Methods

//- (void)setFrame:(CGRect)frame
//{
//    if (CGRectIsEmpty(frame) == NO || CGRectIsNull(frame) == NO)
//    {
//        if (frame.size.width > 0 || frame.size.height > 0)
//        {
//            float yValue = 44.0f - frame.size.height;
//            self.yOffset = yValue;
//            yValue = yValue > 0 ? frame.origin.y - yValue : frame.origin.y ;
//            
//            frame = CGRectMake(frame.origin.x, yValue, frame.size.width, 44.0f);
//        }
//    }
//    
//    [super setFrame:frame];
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_activityIndicatorView)
    {
        _activityIndicatorView.frame = CGRectMake((self.frame.size.width - _activityIndicatorView.frame.size.width) / 2,
                                                  (self.frame.size.height - _activityIndicatorView.frame.size.height) / 2,
                                                  _activityIndicatorView.frame.size.width,
                                                  _activityIndicatorView.frame.size.height);
    }
}

@end
