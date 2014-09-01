
#import <UIKit/UIKit.h>

typedef enum 
{
    BLENDIN,              
	GROW,
	BOTH
} AnimationType;


@protocol DropDownViewDelegate

@required

-(void)dropDownCellSelected:(NSInteger)returnIndex;

@end


@interface DropDownView : UIViewController<UITableViewDelegate,UITableViewDataSource> {

	UITableView *tblViewDropDown;
	
	NSArray *arrayData;
	
	CGFloat heightOfCell;
	
	CGFloat paddingLeft;
	
	CGFloat paddingRight;
	
	CGFloat paddingTop;
	
	CGFloat heightTableView;
	
	UIView *btnView;
	
	id<DropDownViewDelegate> __weak delegate;
	
	NSInteger animationType;
	
	CGFloat open;
	
	CGFloat close;
	
}

@property (nonatomic,weak) id<DropDownViewDelegate> delegate;

@property (nonatomic,strong)UITableView *tblViewDropDown;

@property (nonatomic,strong) NSArray *arrayData;

@property (nonatomic) CGFloat heightOfCell;

@property (nonatomic) CGFloat paddingLeft;

@property (nonatomic) CGFloat paddingRight;

@property (nonatomic) CGFloat paddingTop;

@property (nonatomic) CGFloat heightTableView;

@property (nonatomic,strong)UIView *btnView;

@property (nonatomic) CGFloat open;

@property (nonatomic) CGFloat close;

- (id)initWithArrayData:(NSArray*)data cellHeight:(CGFloat)cHeight heightTableView:(CGFloat)tHeightTableView paddingTop:(CGFloat)tPaddingTop paddingLeft:(CGFloat)tPaddingLeft paddingRight:(CGFloat)tPaddingRight refView:(UIView*)rView animation:(AnimationType)tAnimation  openAnimationDuration:(CGFloat)openDuration closeAnimationDuration:(CGFloat)closeDuration;

-(void)closeAnimation;

-(void)openAnimation;

@end
