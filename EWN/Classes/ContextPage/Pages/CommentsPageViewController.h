//
//  CommentsPageViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/17.
//
//

#import <UIKit/UIKit.h>

#import "CommentViewController.h"
#import "Comments.h"

#import "DockMenuViewController.h"
#import "EngageProtocol.h"




typedef enum {
    CommentsPageStateClosed,
    CommentsPageStateMinimized,
    CommentsPageStateMaximized
}CommentsPageState;


@interface CommentsPageViewController : UIViewController
{
    
}

@property (nonatomic, strong) DockMenuViewController *dockMenu;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *noCommentsLabel;

@property (nonatomic, readwrite) BOOL isClean;
@property (nonatomic, readwrite) BOOL isOpen;
@property (nonatomic, readwrite) float minHeight;
@property (nonatomic, readwrite) float contentHeight;
// article id for commenting
@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, assign) CommentsPageState commentsPageSate;
@property (nonatomic, strong) EngageProtocol *engageProtocol;

-(void)update;
-(void)updateIfOpen;
-(void)cleanComments;

-(void)updatePosition:(float)offset;
-(void)close;

@end
