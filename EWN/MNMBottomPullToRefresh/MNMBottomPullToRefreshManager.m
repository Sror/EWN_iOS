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

#import "MNMBottomPullToRefreshManager.h"
#import "MNMBottomPullToRefreshView.h"

CGFloat const kAnimationDuration = 0.2f;

@interface MNMBottomPullToRefreshManager()

/*
 * Pull-to-refresh view
 */
@property (nonatomic, readwrite, strong) MNMBottomPullToRefreshView *pullToRefreshView;

/*
 * Table view which p-t-r view will be added
 */
@property (nonatomic, readwrite, strong) UIScrollView *scrollView;

/*
 * Client object that observes changes
 */
@property (nonatomic, readwrite, strong) id<MNMBottomPullToRefreshManagerClient> client;

/*
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 *
 * @return The offset
 * @private
 */
- (CGFloat)ScrollOffset;
//- (CGFloat)tableScrollOffset;

@end

@implementation MNMBottomPullToRefreshManager

@synthesize pullToRefreshView = pullToRefreshView_;
@synthesize client = client_;
@synthesize scrollView = scrollView_;

#pragma mark -
#pragma mark Instance initialization

/*
 * Initializes the manager object with the information to link view and table
 */
- (id)initWithPullToRefreshViewHeight:(CGFloat)height ScrollView:(UIScrollView *)scrollView withClient:(id<MNMBottomPullToRefreshManagerClient>)client {
    
    if (self = [super init]) {
        
        client_ = client;
        scrollView_ = scrollView;   
        pullToRefreshView_ = [[MNMBottomPullToRefreshView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([scrollView_ frame]), height)];
    }
    
    return self;
}

- (id)initWithPullToRefreshViewHeight:(CGFloat)height ScrollView:(UIScrollView *)scrollView withClient:(id<MNMBottomPullToRefreshManagerClient>)client andIndicatorType:(UIActivityIndicatorViewStyle)indicator
{
    
    if (self = [super init]) {
        
        client_ = client;
        scrollView_ = scrollView;
        pullToRefreshView_ = [[MNMBottomPullToRefreshView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([scrollView_ frame]), height) andIndicatorStyle:indicator];
    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 */


- (CGFloat)ScrollOffset {
    
    CGFloat offset = 0.0f;        
    
    if ([scrollView_ contentSize].height < CGRectGetHeight([scrollView_ frame])) {
        
        offset = -[scrollView_ contentOffset].y;
        
    } else {
        
        offset = ([scrollView_ contentSize].height - [scrollView_ contentOffset].y) - CGRectGetHeight([scrollView_ frame]);
    }
    
    return offset;
}

/*
 * Relocate pull-to-refresh view
 */

- (void)relocatePullToRefreshView
{
    
    CGFloat yOrigin = 0.0f;
    
    if ([scrollView_ contentSize].height >= CGRectGetHeight([scrollView_ frame])) {
        
        yOrigin = [scrollView_ contentSize].height;
        
    } else {
        
        yOrigin = CGRectGetHeight([scrollView_ frame]);
    }
    
    CGRect frame = [pullToRefreshView_ frame];
    frame.origin.y = yOrigin;
    [pullToRefreshView_ setFrame:frame];
    
    [scrollView_ addSubview:pullToRefreshView_];
}

- (void)relocatePullToRefreshViewForComments
{
    
    CGFloat yOrigin = 0.0f;
    
    if ([scrollView_ contentSize].height >= CGRectGetHeight([scrollView_ frame])) {
        
        yOrigin = [scrollView_ contentSize].height;
        
    } else {
        
        yOrigin = CGRectGetHeight([scrollView_ frame]);
    }
    
    // Hoping this sorts the loaders issues out
    yOrigin += 35;
    
    CGRect frame = [pullToRefreshView_ frame];
    frame.origin.y = yOrigin;
    [pullToRefreshView_ setFrame:frame];
    
    [scrollView_ addSubview:pullToRefreshView_];
}


/*
 * Sets the pull-to-refresh view visible or not. Visible by default
 */
- (void)setPullToRefreshViewVisible:(BOOL)visible {
    
    [pullToRefreshView_ setHidden:!visible];
}

#pragma mark -
#pragma mark Table view scroll management

/*
 * Checks state of control depending on tableView scroll offset
 */
- (void)tableViewScrolled {
    
    if (![pullToRefreshView_ isHidden] && ![pullToRefreshView_ isLoading]) {
        
        CGFloat offset = [self ScrollOffset];

        if (offset >= 0.0f) {
            
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateIdle offset:offset];
        }
        else if (offset <= 0.0f && offset >= -30.0)//-([pullToRefreshView_ fixedHeight]))
        {
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStatePull offset:offset];
        } else
        {
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateRelease offset:offset];
            [self tableViewReleased];
        }
    }
}

/*
 * Checks releasing of the tableView
 */

- (void)tableViewReleased {
    if (![pullToRefreshView_ isHidden] && ![pullToRefreshView_ isLoading]) {
        
        CGFloat offset = [self ScrollOffset];
        CGFloat height = -[pullToRefreshView_ fixedHeight];
        
        if (offset <= 0.0f && offset < height)
        {
            [client_ bottomPullToRefreshTriggered:self];
            
            [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateLoading offset:offset];
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                
                if ([scrollView_ contentSize].height >= CGRectGetHeight([scrollView_ frame])) {
                    
                    [scrollView_ setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, -height, 0.0f)];
                    
                } else {
                    
                    [scrollView_ setContentInset:UIEdgeInsetsMake(height, 0.0f, 0.0f, 0.0f)];
                }
            }];
        }
    }
}

/*
 * The reload of the table is completed
 */

- (void)tableViewReloadFinished {
    
    [scrollView_ setContentInset:UIEdgeInsetsZero];
    
    [self relocatePullToRefreshView];
    
    [pullToRefreshView_ changeStateOfControl:MNMBottomPullToRefreshViewStateIdle offset:CGFLOAT_MAX];
}

@end