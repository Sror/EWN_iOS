//
//  SearchNewsListViewController.m
//  EWN
//
//  Created by Pratik Prajapati on 4/26/13.
//
//

#import "SearchNewsListViewController.h"
#import "ContentDetailViewController.h"
#import "MainViewController.h"

@interface SearchNewsListViewController ()

@end

@implementation SearchNewsListViewController

@synthesize searchText;
@synthesize tblSearchResults;

@synthesize categoryPicker;
@synthesize contentPicker;

@synthesize categoryView;
@synthesize categoryText;

@synthesize contentView;
@synthesize contentText;

@synthesize selectedCategory;
@synthesize selectedContent;

@synthesize categoryArray;
@synthesize contentArray;

# pragma mark
# pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    self.categoryPicker = [[CustomPickerViewController alloc] init];
    self.contentPicker = [[CustomPickerViewController alloc] init];
    
    return self;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblSearchResults.frame.size.width, 60.0f)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tblSearchResults.tableFooterView = footerView;
    
    [self.tblSearchResults setSeparatorColor:[UIColor clearColor]];
    [lblSearchText setFont:[UIFont fontWithName:kFontOpenSansRegular size:24.0f]];
    //lblSearchText.text = self.searchText;
    [[WebserviceComunication sharedCommManager] setNumPageNoForSearchList:0];
    
    [self performSelector:@selector(addProgressView) withObject:nil afterDelay:0.2];
    
    [self.categoryText setTag:0];
    [self.contentText setTag:1];
    
    [self.categoryView.layer setCornerRadius:5];
    [self.contentView.layer setCornerRadius:5];
    
    // Category Dictionary //
    NSArray *catArray = [[CacheDataManager sharedCacheManager] getCatogery];
    NSMutableArray *pickerArray = [[NSMutableArray alloc] init];
    self.categoryArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [catArray count]; i++)
    {
        Category_Items *dicData = [catArray objectAtIndex:i];
        [self.categoryArray addObject:[dicData categoryId]];
        [pickerArray addObject:[dicData categoryName]];
    }
    
    // Content Dictionary //
    self.contentArray = [NSMutableArray arrayWithObjects:@"Articles", @"Video", @"Image", @"Audio", nil];
    
    [self.categoryPicker setDataArray:pickerArray];
    [self.contentPicker setDataArray:self.contentArray];
    
    // Textfields
    [self.categoryText setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [self.categoryText setDelegate:self];
    
    [self.contentText setFont:[UIFont fontWithName:kFontOpenSansRegular size:12.0]];
    [self.contentText setDelegate:self];
}

/**-----------------------------------------------------------------
 Function Name  : addProgressView
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Add progress view in pullto refress view.
 ------------------------------------------------------------------*/
- (void)addProgressView
{
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:55.0f ScrollView:self.tblSearchResults withClient:self andIndicatorType:UIActivityIndicatorViewStyleGray];
    [pullToRefreshManager_ relocatePullToRefreshView];
}

/**-----------------------------------------------------------------
 Function Name  : callSearchNewsAPI
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Webservice calling of news search.
 ------------------------------------------------------------------*/

-(void)callSearchNewsAPI
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSearchNews) name:@"REFRESH_SEARCH" object:nil];
    
    NSString *category = self.categoryArray.count > self.selectedCategory ? [NSString stringWithString:[self.categoryArray objectAtIndex:self.selectedCategory]] : nil;
    NSString *content = self.contentArray.count > self.selectedContent ? [NSString stringWithString:[self.contentArray objectAtIndex:self.selectedContent]] : nil;
    
    [[WebserviceComunication sharedCommManager] setNumPageNoForSearchList:[[WebserviceComunication sharedCommManager] numPageNoForSearchList]+1];
    if(self.selectedCategory == 0)
    {
        [[WebserviceComunication sharedCommManager] searchNewsByText:self.searchText ContentType:content];
    }
    else
    {
        [[WebserviceComunication sharedCommManager] searchNewsByText:self.searchText Category:category ContentType:content];
    }
}
/**-----------------------------------------------------------------
 Function Name  : loadSearchNews
 Created By     : Wayne Langman
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : The first time the Search is triggered it sets the current Category and ContentType (always "news" on first load), to populate list with Search Results.
 ------------------------------------------------------------------*/
- (void)loadSearchNews
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSearchNews) name:@"REFRESH_SEARCH" object:nil];
    
    NSDictionary *categoryDic = [[WebserviceComunication sharedCommManager] dictCurrentCategory];
    
    if(self.searchText)
    {
        if (self.searchText.length > 20) {
            self.searchText = [[self.searchText substringToIndex:20] stringByAppendingString:@"..."];
        }
        lblSearchText.text = [NSString stringWithFormat:@"'%@'", self.searchText];
        [lblSearchText sizeToFit];
    }
    
    self.selectedCategory = 0;
    self.selectedContent = 0;
    
    // Find the index of the matching categoryId matching the CURRENT categoryId from self.categoryArray
    for(int i = 0; i < [self.categoryArray count]; i++)
    {
        NSString *curCat = [NSString stringWithString:[categoryDic objectForKey:@"Id"]];
        NSString *cat = [NSString stringWithString:[self.categoryArray objectAtIndex:i]];
        if([cat isEqualToString:curCat])
        {
            self.selectedCategory = i;
            break;
        }
    }
    
    [self.categoryText setText:[categoryDic objectForKey:@"Name"]];
    [self.contentText setText:[self.contentArray objectAtIndex:0]];
    
    [self.categoryPicker setItemSelected:(NSInteger *)self.selectedCategory];
    [self.contentPicker setItemSelected:(NSInteger *)self.selectedContent];
    
    [self load];
}
/**-----------------------------------------------------------------
 Function Name  : load
 Created By     : Wayne Langman
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Manages the calls to WebServiceCommunication based on the selection
                  NOTE - If selectedCategory == 0, "All News" (categoryId = 001-AllNews),
                  GetLatestNewsByKeywordAndContentType, else GetLatestNewsByKeywordAndCategoryAndContentType
 ------------------------------------------------------------------*/
- (void)load
{
    [self addProgressViewWithMessage:@"loading"];    
    
    NSString *category = self.categoryArray.count > self.selectedCategory ? [NSString stringWithString:[self.categoryArray objectAtIndex:self.selectedCategory]] : nil;
    NSString *content = self.contentArray.count > self.selectedContent ? [NSString stringWithString:[self.contentArray objectAtIndex:self.selectedContent]] : nil;
    
    // CLEAN //
    [[[WebserviceComunication sharedCommManager] arrSearchNews] removeAllObjects];
    [[WebserviceComunication sharedCommManager] setNumPageNoForSearchList:0];
    
    [self.tblSearchResults reloadData];
    //////////
    
    if(self.selectedCategory == 0)
    {
        [[WebserviceComunication sharedCommManager] searchNewsByText:self.searchText ContentType:content];
    }
    else
    {
        [[WebserviceComunication sharedCommManager] searchNewsByText:self.searchText Category:category ContentType:content];
    }
}

/**-----------------------------------------------------------------
 Function Name  : refreshSearchNews
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : refresh and reload Search News.
 ------------------------------------------------------------------*/

- (void)refreshSearchNews
{
    
    [self removeNoResults];
    [self removeProgressView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"REFRESH_SEARCH" object:nil];
    
    [self.tblSearchResults reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
    
    if([[WebserviceComunication sharedCommManager] numPageNoForSearchList] == 0)
    {
        [self.tblSearchResults scrollRectToVisible:CGRectMake(0, 0, tblSearchResults.frame.size.width, tblSearchResults.frame.size.height) animated:NO];
    }
    
    int totalNews = [[[WebserviceComunication sharedCommManager]arrSearchNews]count];
    
    if(totalNews == 0)
    {
        [self addNoResults:@"No Results"];
    }
    
    int supposedTotalNews = ([[WebserviceComunication sharedCommManager] numPageNoForSearchList] + 1) * 20;
    
    if (totalNews < supposedTotalNews) {
        [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
    }
}

# pragma mark
# pragma mark - Other implementation

# pragma mark
# pragma mark - UITableView Delegate,Datasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[WebserviceComunication sharedCommManager] arrSearchNews]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 70;
}

/**-----------------------------------------------------------------
 Function Name  : cellForRowAtIndexPath
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : prepares the cell and its contents.
 ------------------------------------------------------------------*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    SearchNewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Contents *dicSeachedNews = [[[WebserviceComunication sharedCommManager] arrSearchNews]objectAtIndex:indexPath.row];
    
    if (cell == nil)
    {
        cell = [[SearchNewsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *imgURL = [dicSeachedNews thumbnilImageUrl];
    [[cell imgCellBg] setImageAsynchronouslyFromUrl:imgURL animated:NO];
    
    // check the type here cause we might have to add a overlay image
    if ([[dicSeachedNews contentType]  isEqual:@"video"]) {
        UIImageView *imgVwForButton = [SearchNewsListViewController createPodImageOverlay:@"btn-play-video.png" imageParent:[cell imgCellBg]];
        [[cell imgCellBg]addSubview:imgVwForButton];
    }
 
    if ([[dicSeachedNews contentType]  isEqual:@"audio"]) {
        UIImageView *imgVwForButton = [SearchNewsListViewController createPodImageOverlay:@"btn-play-audio.png" imageParent:[cell imgCellBg]];
        [[cell imgCellBg]addSubview:imgVwForButton];
    }
    
    [[cell lblTime] setText:[[CommonUtilities sharedManager] formatSearchDateWithTimeDurationFormat:[dicSeachedNews dateAdded]]];
    
    if ([[dicSeachedNews contentTitle] length] > 0)
    {
        [cell headingLabel].text = [dicSeachedNews contentTitle];
    }
    else
    {
        [cell headingLabel].text = [dicSeachedNews captionShort];
    }
    
    if ([[dicSeachedNews introParagraph] length] > 0)
    {
        [cell lblNewsDesc].text = [dicSeachedNews introParagraph];
    }
    else
    {
        [cell lblNewsDesc].text = [dicSeachedNews caption];
    }
    
    return cell;
}

+ (UIImageView *)createPodImageOverlay:(NSString*)overlayImage imageParent:(UIImageView*)iName
{
    UIImageView *imgVwForButton = [[UIImageView alloc]initWithFrame:iName.frame];
    [imgVwForButton setImage:[UIImage imageNamed:overlayImage]];
    [imgVwForButton setContentMode:UIViewContentModeCenter];
    return imgVwForButton;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
}
/**-----------------------------------------------------------------
 Function Name  : didSelectRowAtIndexPath
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Prepares the detail view of selected article.
 ------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strXib;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568)
        {
            strXib = kstrContentDetailViewController_iPhone5;
        }
        else
        {
            strXib = kstrContentDetailViewController;
        }
    }
    NSMutableDictionary *dicSelected;
    if([[WebserviceComunication sharedCommManager]isOnline])
    {
        dicSelected = [[[WebserviceComunication sharedCommManager] arrSearchNews] objectAtIndex:indexPath.row];
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    [objMainView enableArticleView];
    [objMainView.articleDetailMaster PrepareDetailViewForContentType:kCONTENT_TITLE_SEARCH withCurrentArticle:indexPath.row];
    
    [self closePickers];
}

-(void) closePickers {
    if ([self.contentPicker.textField isEditing]) {
        [self.contentPicker.textField endEditing:YES];
    }
    if ([self.categoryPicker.textField isEditing]) {
        [self.categoryPicker.textField endEditing:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullToRefreshManager_ tableViewScrolled];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullToRefreshManager_ tableViewReleased];
}
/**-----------------------------------------------------------------
 Function Name  : bottomPullToRefreshTriggered
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : calling the callSearchNewsAPI method.
 ------------------------------------------------------------------*/

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    if ([[[WebserviceComunication sharedCommManager]arrSearchNews]count] >= 100) {
        [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        return;
    }
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:@"REFRESH_SEARCH" object:nil];
    [self performSelectorInBackground:@selector(callSearchNewsAPI) withObject:nil];
}
# pragma mark
# pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/* TEXTFIELD DELEGATE METHODS */

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    switch(textField.tag)
    {
        case 0: // CATEGORY
            [textField setInputView:[self.categoryPicker view]];
            [self.categoryPicker setTextField:self.categoryText];
            break;
            
        
        case 1: // CONTENT
            [textField setInputView:[self.contentPicker view]];
            [self.contentPicker setTextField:self.contentText];
            break;
        
        default:
            //
            break;
    }
    return TRUE;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"REFRESH_SEARCH" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSearchNews) name:@"REFRESH_SEARCH" object:nil];
    
    switch(textField.tag)
    {
        case 0:
            self.selectedCategory = (int)[self.categoryPicker itemSelected];
            break;
        case 1:
            self.selectedContent = (int)[self.contentPicker itemSelected];
            break;
        default:
            break;
    }
    [self load];
}

- (void)addProgressViewWithMessage:(NSString *)strMessage
{
    [self removeNoResults];
    
    // NOTE - The Progress overlays the "pickers" also, to avoid selection during load ...
    progressView = [[UIView alloc] initWithFrame:self.tblSearchResults.window.frame];
	[progressView setBackgroundColor:[UIColor clearColor]];
	[progressView setUserInteractionEnabled:TRUE];
    
    float viewHeight, viewWidth;
    
    viewWidth = progressView.frame.size.width;
    viewHeight = progressView.frame.size.height;
    
    UILabel *titleLabel;
    UIActivityIndicatorView *showProcessIndicator;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        showProcessIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [showProcessIndicator setFrame:CGRectMake((viewWidth/2)-18, (viewHeight/2)-150, 30, 30)];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (viewHeight/2)-100, viewWidth-40, 50)];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        showProcessIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [showProcessIndicator setFrame:CGRectMake((viewWidth/2)-15, (viewHeight/2)-45, 30, 30)];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (progressView.frame.size.height/2)-25, 280, 30)];
        [titleLabel setMinimumFontSize:10.0f];
        [titleLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:10.0]];
        [titleLabel setAdjustsFontSizeToFitWidth:TRUE];
    }
    
    showProcessIndicator.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0f, 2.0f);
    
    [showProcessIndicator setTag:5];
    [progressView addSubview:showProcessIndicator];
    [showProcessIndicator startAnimating];
    
    [titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:18.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTag:1];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setText:strMessage];
    //[progressView addSubview:titleLabel];
    
    [self.view addSubview:progressView];
}

- (void)removeProgressView
{
    [progressView removeFromSuperview];
    progressView = nil;
    
    if(self.tblSearchResults.alpha < 1.0f)
    {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             [self.tblSearchResults setAlpha:1.0f];
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
    }
}

- (void) addNoResults:(NSString *)strMessage
{
    [self removeProgressView];
    
    // NOTE - The Label overlays the Table only, allowing User to change their Category/Content and try again
    progressView = [[UIView alloc] initWithFrame:self.tblSearchResults.frame];
	[progressView setBackgroundColor:[UIColor clearColor]];
	[progressView setUserInteractionEnabled:TRUE];
    
    float viewHeight, viewWidth;
    
    viewWidth = progressView.frame.size.width;
    viewHeight = progressView.frame.size.height;
    
    UILabel *titleLabel;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (viewHeight/2)-100, viewWidth-40, 50)];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (progressView.frame.size.height/2)-50, 280, 30)];
        [titleLabel setMinimumFontSize:10.0f];
        [titleLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:10.0]];
        [titleLabel setAdjustsFontSizeToFitWidth:TRUE];
    }
    
    [titleLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:18.0]];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [titleLabel setTag:1];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setText:strMessage];
    [progressView addSubview:titleLabel];
    
    [self.view addSubview:progressView];
}

-(void) removeNoResults
{
    [progressView removeFromSuperview];
    progressView = nil;
}

- (void)dealloc
{
    self.categoryPicker;
    self.contentPicker;
    self.categoryArray;
    self.contentArray;
}

@end
