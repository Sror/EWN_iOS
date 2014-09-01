//
//  ContentViewOfListView.h
//  EWN
//
//  Created by Sumit Kumar on 4/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
/**------------------------------------------------------------------------
 File Name      : ContentsListView.h
 Created By     : Arpit Jain
 Created Date   : 18-Apr-2013
 Purpose        : Prepare the view for desplay the news..
 -------------------------------------------------------------------------*/
#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

@interface ContentsListView : UIView <UIScrollViewDelegate , MNMBottomPullToRefreshManagerClient>
{
    UIToolbar *tlbListTop;
    UILabel *lblCurrentContent; 
    UILabel *lblNextContent;
    UILabel *lblLoadMore;
//    UIScrollView *scrlvwContentList_;
    UIScrollView *scrollView_;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    
    /**
     * Reloads (for testing purposes)
     */
    NSUInteger reloads_;

    int numNextX;
    int numNextY;
}
@property (nonatomic,retain) UIToolbar *tlbListTop;
@property (nonatomic,retain) UILabel *lblCurrentContent;
@property (nonatomic,retain) UILabel *lblNextContent;
@property (nonatomic,retain) UIScrollView *scrlvwContentList;

- (id)initWithFrame:(CGRect)frame CurrentContentType:(NSString *)strCurrentContentType NextContentType:(NSString *)strNextContentType  ;

@end
