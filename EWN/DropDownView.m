#import "DropDownView.h"
#import <QuartzCore/QuartzCore.h>


@implementation DropDownView

@synthesize tblViewDropDown;
@synthesize arrayData;
@synthesize heightOfCell;
@synthesize btnView;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingTop;
@synthesize open;
@synthesize close;
@synthesize heightTableView;
@synthesize delegate;


/*-----------------------------------------------------------------------------
 Procedure/Function Name : initWithArrayData
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to create a view that is of size and Properties specified by the Parameters.
 -----------------------------------------------------------------------------*/
- (id)initWithArrayData:(NSArray*)data cellHeight:(CGFloat)cHeight heightTableView:(CGFloat)tHeightTableView paddingTop:(CGFloat)tPaddingTop paddingLeft:(CGFloat)tPaddingLeft paddingRight:(CGFloat)tPaddingRight refView:(UIView*)rView animation:(AnimationType)tAnimation openAnimationDuration:(CGFloat)openDuration closeAnimationDuration:(CGFloat)closeDuration
{
	if ((self = [super init])) {
		
		self.arrayData = data;
		
		self.heightOfCell = cHeight;
		
		self.btnView = rView;
		
		self.paddingTop = tPaddingTop;
		
		self.paddingLeft = tPaddingLeft;
		
		self.paddingRight = tPaddingRight;
		
		self.heightTableView = [arrayData count]*cHeight;
		
		self.open = openDuration;
		
		self.close = closeDuration;
		
		CGRect rectFrame = btnView.frame;
		
               
        self.view.frame = CGRectMake(rectFrame.origin.x-paddingLeft, rectFrame.origin.y+rectFrame.size.height+paddingTop, rectFrame.size.width+paddingRight, heightTableView);
        
		self.view.layer.shadowColor = [[UIColor blackColor] CGColor];
		
		self.view.layer.shadowOffset = CGSizeMake(-5.0f, 5.0f);
		
		self.view.layer.shadowOpacity =1.0f;
		
		self.view.layer.shadowRadius = 5.0f;
                
        animationType = tAnimation;
	}
	
	return self;
	
}

/*-----------------------------------------------------------------------------
 Procedure/Function Name : viewDidLoad
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to load the tableView.
 -----------------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGRect rectFrame = btnView.frame;
    
	tblViewDropDown = [[UITableView alloc] initWithFrame:CGRectMake(0,0,rectFrame.size.width+paddingRight, (animationType == BOTH || animationType == BLENDIN)?heightTableView:1) style:UITableViewStylePlain];
	
    [tblViewDropDown.layer setCornerRadius:2.0];

	tblViewDropDown.dataSource = self;
	
	tblViewDropDown.delegate = self;
    
    [tblViewDropDown setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]];
    
    [tblViewDropDown setSeparatorColor:[UIColor darkGrayColor]];
    
	[self.view addSubview:tblViewDropDown];
    
	self.view.hidden = YES;
	
	if(animationType == BOTH || animationType == BLENDIN)
		[self.view setAlpha:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.view.frame = CGRectMake(0,0, self.view.superview.frame.size.width, self.view.superview.frame.size.height);
    [tblViewDropDown setFrame:CGRectMake(btnView.frame.origin.x-self.paddingLeft, btnView.frame.origin.y+btnView.frame.size.height+self.paddingTop, btnView.frame.size.width+self.paddingRight, self.heightTableView)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(hideDropDown:) forControlEvents:UIControlEventTouchDown];
    button.frame = CGRectMake(0,0, self.view.superview.frame.size.width, self.view.superview.frame.size.height);
    [self.view addSubview:button];
    [button.superview sendSubviewToBack:button];
}

-(IBAction)hideDropDown:(id)sender
{
    [self.view removeFromSuperview];
}

/*-----------------------------------------------------------------------------
 Procedure/Function Name : dealloc
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to release the Memory allocated to the Outlets and other objects.
 -----------------------------------------------------------------------------*/

#pragma mark -
#pragma mark UITableViewDelegate


/*-----------------------------------------------------------------------------
 Procedure/Function Name : heightForRowAtIndexPath
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to specify the hieght of the cell in TableView.
 -----------------------------------------------------------------------------*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return heightOfCell;
}

/*-----------------------------------------------------------------------------
 Procedure/Function Name : numberOfRowsInSection
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to specify the number of rows in the TableView depending on the arrayData row Count.
 -----------------------------------------------------------------------------*/
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [arrayData count];
}

/*-----------------------------------------------------------------------------
 Procedure/Function Name : cellForRowAtIndexPath
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to specify the value for each row in the TableView.
 -----------------------------------------------------------------------------*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont fontWithName:kFontOpenSansSemiBold size:13];
        
        UIImageView *imgCellBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.heightOfCell)];
        imgCellBg.backgroundColor = [UIColor clearColor];
        imgCellBg.opaque = NO;
        imgCellBg.image = [UIImage imageNamed:kImgNameDefault];
        cell.backgroundView = imgCellBg;
        
        cell.textLabel.shadowColor = [UIColor blackColor];
        cell.textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    NSDictionary *dicData = [arrayData objectAtIndex:indexPath.row];
    if([[WebserviceComunication sharedCommManager] isOnline] == TRUE)
    {
	cell.textLabel.text = [dicData objectForKey:kstrName];
    }
    else
    {
    cell.textLabel.text = [(Category_Items *)dicData  categoryName];
    }
    
     cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ico_%@",[cell.textLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
	return cell;
}

/*-----------------------------------------------------------------------------
 Procedure/Function Name : didSelectRowAtIndexPath
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to call the dropDownCellSelected with the selected
 row as parameter and closeAnimation method.
 -----------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[delegate dropDownCellSelected:indexPath.row];
	
	[self closeAnimation];
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark DropDownViewDelegate

/*-----------------------------------------------------------------------------
 Procedure/Function Name : dropDownCellSelected
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to move back to the Main View.
 -----------------------------------------------------------------------------*/
-(void)dropDownCellSelected:(NSInteger)returnIndex
{
	
}

#pragma mark -
#pragma mark Class Methods


/*-----------------------------------------------------------------------------
 Procedure/Function Name : openAnimation
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to Open the TableView.
 -----------------------------------------------------------------------------*/
-(void)openAnimation
{
	self.view.hidden = NO;
	
	if(animationType == BOTH || animationType == GROW)
		self.tblViewDropDown.frame = CGRectMake(tblViewDropDown.frame.origin.x,tblViewDropDown.frame.origin.y,tblViewDropDown.frame.size.width, heightTableView);
	
	if(animationType == BOTH || animationType == BLENDIN)
		self.view.alpha = 1;
}

/*-----------------------------------------------------------------------------
 Procedure/Function Name : closeAnimation
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to Close the TableView.
 -----------------------------------------------------------------------------*/
-(void)closeAnimation
{
	
	[self.tblViewDropDown deselectRowAtIndexPath:[tblViewDropDown indexPathForSelectedRow] animated:NO];
	if(animationType == BOTH || animationType == GROW)
		self.tblViewDropDown.frame = CGRectMake(tblViewDropDown.frame.origin.x,tblViewDropDown.frame.origin.y,tblViewDropDown.frame.size.width, 1);
	
	if(animationType == BOTH || animationType == BLENDIN)
		self.view.alpha = 0;
	
	[self performSelector:@selector(hideView) withObject:nil afterDelay:close];
	
}


/*-----------------------------------------------------------------------------
 Procedure/Function Name : hideView
 Author : Sharvin
 Creation Date : 20-April-2011
 Modification Date :
 Purpose : This purpose of this method is to hide the view.
 -----------------------------------------------------------------------------*/
-(void)hideView
{
	self.view.hidden = YES;
    [self performSelector:@selector(hideDropDown:) withObject:nil afterDelay:0.5];
}

@end