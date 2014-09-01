/*
 * Copyright (c) 2012 Mario Negro Martín
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "MNMBottomPullToRefreshView.h"



#define MNM_CONTENT_Y_OFFSET                                            25.0f // 60.0f
#define MNM_CONTENT_Y_OFFSET_iOS5                                       25.0f

/*
 * Defines the localized strings table
 */
#define MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE                          @"MNMBottomPullToRefresh"

/*
 * Texts to show in different states
 */
#define MNM_BOTTOM_PTR_PULL_TEXT_KEY                                    NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_PULL_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)
#define MNM_BOTTOM_PTR_RELEASE_TEXT_KEY                                 NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_RELEASE_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)
#define MNM_BOTTOM_PTR_LOADING_TEXT_KEY                                 NSLocalizedStringFromTable(@"MNM_BOTTOM_PTR_LOADING_TEXT", MNM_BOTTOM_PTR_LOCALIZED_STRINGS_TABLE, nil)

/*
 * Defines icon image
 */
//#define MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE                                @"MNMBottomPullToRefreshArrow.png"
#define MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE                                @"ico-refresh.png"

@interface MNMBottomPullToRefreshView()

/*
 * View that contains all controls
 */
@property (nonatomic, readwrite, strong) UIView *containerView;

/*
 * Image with the icon that changes with states
 */
@property (nonatomic, readwrite, strong) UIImageView *iconImageView;

/*
 * Activiry indicator to show while loading
 */
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *loadingActivityIndicator;

/*
 * Label to set state message
 */
@property (nonatomic, readwrite, strong) UILabel *messageLabel;

/*
 * Current state of the control
 */
@property (nonatomic, readwrite, assign) MNMBottomPullToRefreshViewState state;

/*
 * YES to apply rotation to the icon while view is in MNMBottomPullToRefreshViewStatePull state
 */
@property (nonatomic, readwrite, assign) BOOL rotateIconWhileBecomingVisible;

@end

@implementation MNMBottomPullToRefreshView

@synthesize containerView = containerView_;
@synthesize iconImageView = iconImageView_;
@synthesize loadingActivityIndicator = loadingActivityIndicator_;
@synthesize messageLabel = messageLabel_;
@synthesize state = state_;
@synthesize rotateIconWhileBecomingVisible = rotateIconWhileBecomingVisible_;
@dynamic isLoading;
@synthesize fixedHeight = fixedHeight_;

#pragma mark -
#pragma mark Initialization

/*
 * Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 * @param aRect: The frame rectangle for the view, measured in points.
 * @return An initialized view object or nil if the object couldn't be created.
 */
- (id)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame])
    {
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [self setBackgroundColor:[UIColor clearColor]];
        
        containerView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        
        [containerView_ setBackgroundColor:[UIColor clearColor]];
        [containerView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        
        [self addSubview:containerView_];
        
        UIImage *iconImage = [[UIImage imageNamed:MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE] autorelease];
        
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 15.0f, [iconImage size].width/2, [iconImage size].height/2)];
        [iconImageView_ setContentMode:UIViewContentModeScaleAspectFit];
        [iconImageView_ setImage:iconImage];
        [iconImageView_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        
        loadingActivityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 6)
            [loadingActivityIndicator_ setCenter:CGPointMake([containerView_ center].x,[containerView_ center].y - 10 - MNM_CONTENT_Y_OFFSET)];
        else
            [loadingActivityIndicator_ setCenter:CGPointMake([containerView_ center].x,[containerView_ center].y - 10 - MNM_CONTENT_Y_OFFSET_iOS5)];
        
        [loadingActivityIndicator_ setHidesWhenStopped:YES];
        [loadingActivityIndicator_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        CGFloat topMargin = 0.0f;
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 6)
            topMargin = 0.0f - MNM_CONTENT_Y_OFFSET;
        else
            topMargin = 0.0f - MNM_CONTENT_Y_OFFSET_iOS5;
        
        if (![[WebserviceComunication sharedCommManager] isOnline]) {
            topMargin -= 40;
        }
        
        messageLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, topMargin, CGRectGetWidth(frame), CGRectGetHeight(frame) - topMargin * 2.0f)];
        [messageLabel_ setBackgroundColor:[UIColor clearColor]];
        [messageLabel_ setTextAlignment:NSTextAlignmentCenter];
        [messageLabel_ setFont:[UIFont fontWithName:kFontOpenSansRegular size:15.0f]];
        [messageLabel_ setTextColor:[UIColor grayColor]];
        [messageLabel_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        if ([[WebserviceComunication sharedCommManager] isOnline])
        {
            [containerView_ addSubview:loadingActivityIndicator_];
        }
        else
        {
            [containerView_ addSubview:messageLabel_];
        }
        
        fixedHeight_ = CGRectGetHeight(frame);
        rotateIconWhileBecomingVisible_ = YES;
        
        [self changeStateOfControl:MNMBottomPullToRefreshViewStateIdle offset:CGFLOAT_MAX];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andIndicatorStyle:(UIActivityIndicatorViewStyle)indicator
{
    
    if (self = [super initWithFrame:frame])
    {
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [self setBackgroundColor:[UIColor clearColor]];
        
        containerView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        
        [containerView_ setBackgroundColor:[UIColor clearColor]];
        [containerView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        
        [self addSubview:containerView_];
        
        UIImage *iconImage = [[UIImage imageNamed:MNM_BOTTOM_PTR_ICON_BOTTOM_IMAGE] autorelease];
        
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 15.0f, [iconImage size].width/2, [iconImage size].height/2)];
        [iconImageView_ setContentMode:UIViewContentModeScaleAspectFit];
        [iconImageView_ setImage:iconImage];
        [iconImageView_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        
        loadingActivityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicator];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 6)
            [loadingActivityIndicator_ setCenter:CGPointMake([containerView_ center].x,[containerView_ center].y - 10 - MNM_CONTENT_Y_OFFSET)];
        else
            [loadingActivityIndicator_ setCenter:CGPointMake([containerView_ center].x,[containerView_ center].y - 10 - MNM_CONTENT_Y_OFFSET_iOS5)];
        
        [loadingActivityIndicator_ setHidesWhenStopped:YES];
        [loadingActivityIndicator_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        [containerView_ addSubview:loadingActivityIndicator_];
        
        CGFloat topMargin = 10.0f;
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 6)
            topMargin = 0.0f - MNM_CONTENT_Y_OFFSET;
        else
            topMargin = 0.0f - MNM_CONTENT_Y_OFFSET_iOS5;
        
        messageLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, topMargin, CGRectGetWidth(frame), CGRectGetHeight(frame) - topMargin * 2.0f)];
        [messageLabel_ setBackgroundColor:[UIColor clearColor]];
        [messageLabel_ setTextAlignment:NSTextAlignmentCenter];
        [messageLabel_ setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0f]];
        [messageLabel_ setTextColor:[UIColor grayColor]];
        [messageLabel_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        
        fixedHeight_ = CGRectGetHeight(frame);
        rotateIconWhileBecomingVisible_ = YES;
        
        [self changeStateOfControl:MNMBottomPullToRefreshViewStateIdle offset:CGFLOAT_MAX];
    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Lays out subviews.
 */
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize messageSize = [[messageLabel_ text] sizeWithFont:[messageLabel_ font]];
    
    CGRect frame = [messageLabel_ frame];
    frame.size.width = messageSize.width;
    
    frame.size.width = CGRectGetMaxX([messageLabel_ frame]);
    [containerView_ setFrame:frame];
}

/*
 * Changes the state of the control depending on state_ value
 */
- (void)changeStateOfControl:(MNMBottomPullToRefreshViewState)state offset:(CGFloat)offset {
    
    state_ = state;
    
    CGFloat height = fixedHeight_;
    
    switch (state_) {
        
        case MNMBottomPullToRefreshViewStateIdle:
        {
            [iconImageView_ setTransform:CGAffineTransformIdentity];
            [iconImageView_ setHidden:NO];
            
            [loadingActivityIndicator_ stopAnimating];
            
            [messageLabel_ setText:MNM_BOTTOM_PTR_PULL_TEXT_KEY];
            [messageLabel_ setHidden:YES];
            
            break;
            
        } case MNMBottomPullToRefreshViewStatePull: {
            if (rotateIconWhileBecomingVisible_) {
            
                CGFloat angle = (-offset * M_PI) / CGRectGetHeight([self frame]);
                
                [iconImageView_ setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
                
            } else {
            
                [iconImageView_ setTransform:CGAffineTransformIdentity];
            }
            
            [messageLabel_ setText:MNM_BOTTOM_PTR_PULL_TEXT_KEY];
            [messageLabel_ setHidden:NO];
            
            break;
            
        } case MNMBottomPullToRefreshViewStateRelease: {
            [iconImageView_ setTransform:CGAffineTransformMakeRotation(M_PI)];
            
            [messageLabel_ setText:MNM_BOTTOM_PTR_RELEASE_TEXT_KEY];
            [messageLabel_ setHidden:YES];
            
            height = fixedHeight_ + fabs(offset);
            
            break;
            
        } case MNMBottomPullToRefreshViewStateLoading: {
            [iconImageView_ setHidden:YES];
            
            [loadingActivityIndicator_ startAnimating];
            
            [messageLabel_ setText:MNM_BOTTOM_PTR_LOADING_TEXT_KEY];
            [messageLabel_ setHidden:YES];
            
            height = fixedHeight_ + fabs(offset);
            
            break;
            
        } default:
            break;
    }
    
    CGRect frame = [self frame];
    frame.size.height = height;
    [self setFrame:frame];
    
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Properties

/*
 * Returns state of activity indicator
 */
- (BOOL)isLoading {
    
    return [loadingActivityIndicator_ isAnimating];
}

@end
