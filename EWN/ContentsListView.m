//
//  ContentViewOfListView.m
//  EWN
//
//  Created by Sumit Kumar on 4/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ContentsListView.h"
#import "CommanConstants.h"

@interface ContentsListView()

/**
 * Loads the table
 *
 * @private
 */
- (void)loadTable;
-(void)reload_scrollview;

@end


@implementation ContentsListView

@synthesize tlbListTop;
@synthesize lblCurrentContent;
@synthesize lblNextContent;
@synthesize scrlvwContentList = scrollView_;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*//create video view view programatically 
         
         self.tlbListTop = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)];
         [self.tlbListTop setBackgroundImage:[UIImage imageNamed:kstrImgToolbar] forToolbarPosition:UIControlStateNormal barMetrics:UIBarMetricsDefault];
         [self addSubview:tlbListTop];
         self.scrlvwContentList = [[UIScrollView alloc] initWithFrame:CGRectMake(0,44,320,416)];
         
         [self.scrlvwContentList setContentSize:CGSizeMake(320,416)];
         [self addSubview:self.scrlvwContentList];
         
         [self setBackgroundColor:[UIColor redColor]];
         float numX = 9;
         float numY = 6;
         float numDiffX = 152;
         float numDiffY = 0;
         float numWidth = 150;
         float numHeight = 75;
         
         for (int numIndex = 0; numIndex<8; numIndex++) 
         {
         UIView *vwContentType = [[UIView alloc]initWithFrame:CGRectMake(numX, numY, numWidth,numHeight)];
         
         [vwContentType setTag:numIndex+1];
         [vwContentType setBackgroundColor:[UIColor blackColor]];
         [self.scrlvwContentList addSubview:vwContentType];
         
         numX = numX + numDiffX;
         
         if(numX > 161)
         {
         numDiffY = 78;
         numX = 9;
         numY = numY + numDiffY;
         }
         }*/
    }
    return self;
}
/**-----------------------------------------------------------------
 Function Name  : initWithFrame
 Created By     : Arpit Jain
 Created Date   : 19-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 19-Apr-2013
 Purpose        : In this Function I create the content view for news view. 
 ------------------------------------------------------------------*/

- (id)initWithFrame:(CGRect)frame CurrentContentType:(NSString *)strCurrentContentType NextContentType:(NSString *)strNextContentType
{ 
    self = [super initWithFrame:frame];
    if (self) {
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 ScrollView:scrollView_ withClient:self];

        //create video view view programatically 
        [self.scrlvwContentList setDelegate:self];
        self.tlbListTop = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)];
        [self.tlbListTop setBackgroundImage:[UIImage imageNamed:kstrImgToolbar] forToolbarPosition:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self addSubview:tlbListTop];
        
        self.lblCurrentContent = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80,25)];
        [self.lblCurrentContent setText:strCurrentContentType];
        [self.lblCurrentContent setBackgroundColor:[UIColor clearColor]];
        [self.lblCurrentContent setFont:[UIFont boldSystemFontOfSize:20]];
        [self.lblCurrentContent setTextColor:[UIColor darkGrayColor]];
        
        [self addSubview:self.lblCurrentContent];
        
        self.lblNextContent = [[UILabel alloc]initWithFrame:CGRectMake(298, 0, 80,20)];
        [self.lblNextContent setText:strNextContentType];
        [self.lblNextContent setBackgroundColor:[UIColor clearColor]];
        [self.lblNextContent setFont:[UIFont systemFontOfSize:17]];
        [self.lblNextContent setTextColor:[UIColor grayColor]];
        
        
        [self addSubview:self.lblNextContent];
        
        self.scrlvwContentList = [[UIScrollView alloc] initWithFrame:CGRectMake(0,44,320,410)];
        
        [self.scrlvwContentList setContentSize:CGSizeMake(320,800)];
        [self addSubview:self.scrlvwContentList];
        
        [self setBackgroundColor:[UIColor redColor]];
        float numX = 9;
        float numY = 6;
        float numDiffX = 152;
        float numDiffY = 0;
        float numWidth = 150;
        float numHeight = 90;
        
        if(![strCurrentContentType isEqualToString:kstrLatest])
        {
            for (int numIndex = 0; numIndex<16; numIndex++) 
            {
                UIView *vwContentType = [[UIView alloc]initWithFrame:CGRectMake(numX, numY, numWidth,numHeight)];
                
                [vwContentType setTag:numIndex+1];
                [vwContentType setBackgroundColor:[UIColor blackColor]];
                [self.scrlvwContentList addSubview:vwContentType];
                
                numX = numX + numDiffX;
                
                if(numX > 161)
                {
                    numDiffY = 93;
                    numX = 9;
                    numY = numY + numDiffY;
                }
            }
        }
        else
        {
            for (int numIndex = 0; numIndex<13; numIndex++)
            {
                UIView *vwContentType;
                if(numIndex == 0)
                {
                    numWidth = 302;
                    numHeight = 183;
                    vwContentType = [[UIView alloc]initWithFrame:CGRectMake(numX, numY, numWidth,numHeight)];
                    [vwContentType setTag:numIndex+1];
                    [vwContentType setBackgroundColor:[UIColor blackColor]];
                    [self.scrlvwContentList addSubview:vwContentType];
                    numWidth = 150;
                    numHeight = 90;
                    
                    numDiffY = 186;
                    numX = 9;
                    numY = numY + numDiffY;
                }
                else
                {
                    vwContentType = [[UIView alloc]initWithFrame:CGRectMake(numX, numY, numWidth,numHeight)];
                    
                    [vwContentType setTag:numIndex+1];
                    [vwContentType setBackgroundColor:[UIColor blackColor]];
                    [self.scrlvwContentList addSubview:vwContentType];
                    
                    numX = numX + numDiffX;
                    
                    if(numX > 161)
                    {
                        numDiffY = 93;
                        numX = 9;
                        numY = numY + numDiffY;
                    }
                }
            }
        }
        
        if(numX == 9)
        {
            numNextX = numX + numDiffX;
        }
        else
        {
            numNextX = 9;
            numNextY = numY + numDiffY;
        }
    }
    return self;
}
-(void)reload_scrollview
{
    reloads_++;
    
//    float numX = 9;
//    float numY = 6;
    float numDiffX = 152;
    float numDiffY = 0;
    float numWidth = 150;
    float numHeight = 90;
    
    
    for (int numIndex = 0; numIndex<8; numIndex++) 
    {
        UIView *vwContentType = [[UIView alloc]initWithFrame:CGRectMake(numNextX, numNextY, numWidth,numHeight)];
        
        [vwContentType setTag:numIndex+1];
        [vwContentType setBackgroundColor:[UIColor blackColor]];
        [self.scrlvwContentList addSubview:vwContentType];
        
        numNextX = numNextX + numDiffX;
        
        if(numNextX > 161)
        {
            numDiffY = 93;
            numNextX = 9;
            numNextY = numNextY + numDiffY;
        }
    }
    
    [pullToRefreshManager_ tableViewReloadFinished];
    
    [pullToRefreshManager_ relocatePullToRefreshView];

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullToRefreshManager_ tableViewScrolled];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate 
{
    [pullToRefreshManager_ tableViewReleased];
}
- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    
    [self performSelector:@selector(reload_scrollview) withObject:nil afterDelay:1.0f];
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
