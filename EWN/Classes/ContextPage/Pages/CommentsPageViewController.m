//
//  CommentsPageViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/17.
//
//

#import "CommentsPageViewController.h"

#import "MainViewController.h"
#import "CommonUtilities.h"
#import "MNMBottomPullToRefreshManager.h"
#import "ODRefreshControl.h"



#define kMAX_Minimized_Height       ([UIScreen mainScreen].bounds.size.height / 3 ) * 2 //  400.0f // 320.0f



@interface CommentsPageViewController () <UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient, CommentViewControllerDelegate>
{
    __block BOOL isRefreshingList;
    CGPoint lastKnownContnetOffset;
    
    int pageCount;
    BOOL canLoadMoreComments;
}

@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) MNMBottomPullToRefreshManager *pullToRefreshManager;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end




@implementation CommentsPageViewController

// Public
@synthesize articleId;
@synthesize commentsPageSate = _commentsPageSate;
@synthesize dockMenu;
@synthesize dataArray;
@synthesize scrollView;
@synthesize activityIndicator;
@synthesize noCommentsLabel;

@synthesize isOpen;
@synthesize isClean;
@synthesize minHeight;
@synthesize contentHeight;
@synthesize engageProtocol;

// Private
@synthesize refreshControl;
@synthesize pullToRefreshManager;
@synthesize activityIndicatorView;



#pragma mark - SETTERS

- (void)setArticleId:(NSString *)value
{
    if (articleId != value)
    {
        articleId = value;
        pageCount = 1;
    }
}


#pragma mark - GETTERS

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!activityIndicatorView)
    {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.hidesWhenStopped = YES;
        activityIndicatorView.transform = CGAffineTransformMakeScale(0.70, 0.70); // We scale down the indicator as we cant adjust its internal frames.
    }
    return activityIndicatorView;
}



#pragma mark - Lifecycle Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _commentsPageSate = CommentsPageStateClosed;
    
    isRefreshingList = NO;
    self.isClean = YES;
    self.isOpen = NO;
    
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView setUserInteractionEnabled:YES];
    [self.scrollView setAlwaysBounceVertical:YES];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, -1.0f, 0.0f, 1.0f);
    [self.view addSubview:self.scrollView];
    
    self.pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:10.0 ScrollView:self.scrollView withClient:self andIndicatorType:UIActivityIndicatorViewStyleGray];
    [self.pullToRefreshManager relocatePullToRefreshViewForComments];
   
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.backgroundColor = [UIColor clearColor];
    [self.activityIndicator setFrame:CGRectMake((self.view.frame.size.width / 2) - 15, 10, 30, 30)];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    
    self.noCommentsLabel = [[UILabel alloc] init];
    [self.noCommentsLabel setFrame:CGRectMake(0, 5, self.view.frame.size.width, 30)];
    [self.noCommentsLabel setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12.0]];
    [self.noCommentsLabel setText:@"No Comments"];
    [self.noCommentsLabel setTextColor:[UIColor darkGrayColor]];
    [self.noCommentsLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.dockMenu = [[DockMenuViewController alloc] initWithNibName:@"DockMenuViewController" bundle:nil];
    [self.dockMenu.view setUserInteractionEnabled:YES];
    [self.dockMenu.loginBtn addTarget:self action:@selector(loginHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.dockMenu.minBtn addTarget:self action:@selector(viewAllHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.dockMenu.viewBtn addTarget:self action:@selector(viewAllHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.dockMenu.postBtn addTarget:self action:@selector(postHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dockMenu.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.dockMenu.commentCount = [[WebserviceComunication sharedCommManager] articleCommentCount];
    [self.dockMenu update];
    
//    [self.activityIndicator setFrame:CGRectMake((self.view.frame.size.width / 2) - 15, 10, 30, 30)];
}



#pragma mark - Public Methods

-(void)update
{
    self.scrollView .scrollEnabled = YES;
    
    // If comments are still loading, do nothing ...
    if([[WebserviceComunication sharedCommManager] isLoadingComments]) {
        DLog(@"STILL LOADING COMMENTS");
        return;
    }
    
    [self.refreshControl endRefreshing];
    
    if (isRefreshingList)
    {
        lastKnownContnetOffset = self.scrollView.contentOffset;
    }
    else
    {
        if (pageCount <= 1 && isRefreshingList == NO) {
            self.scrollView.contentOffset = CGPointZero;
        }
    }
    
    [self cleanComments];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 0.0f);
    
    self.isOpen = YES;
    canLoadMoreComments = NO;
    
    // If clean, grab copy from WebService for self.dataArray, then clean WebService
    if(self.isClean)
    {
        self.isClean = NO;
        
        self.dataArray = [[[WebserviceComunication sharedCommManager] arrComments] mutableCopy];
    }
    else
    {
        // If Comments have already been added, no need to redraw ...
        [self updatePosition:100];
        
        // update the login state if needs be
        [self.dockMenu update];
        return;
    }
    
    self.dockMenu.commentCount = [self.dataArray count];
    
    // Check Comments exist
    if([self.dataArray count] <= 0)
    {
        [self.view addSubview:self.noCommentsLabel];
        [self updatePosition:100];
        
        // update the login state if needs be
        [self.dockMenu update];
        // Can't stop here as we still have to be able to post comments
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        return;
    }
    
    __unused float newHeight;
    float posY;
    int commentCount;
    
    if (pageCount <= 1)
    {
        newHeight = 0; // The height of the first 3 (kCommentLimit) comments for preview ...
        posY = 10;
        commentCount = [self.dataArray count]; // Limits to 3 for preview ...
        
    }
    else
    {
        posY =  10; // self.scrollView.contentSize.height - 10.0f;
    }
    
    
    if (self.dataArray.count > 0)
    {
        for(int i = 0; i < [self.dataArray count]; i++)
        {
            Comments *commentObj = [self.dataArray objectAtIndex:i];
            
            CommentViewController *comment = [[CommentViewController alloc] init];
            comment.delegate = self;
            comment.commentObject = commentObj;
            [comment.nameLabel setText:[commentObj userName]];
            [comment.likesLabel setText:[[CommonUtilities sharedManager] formatCommentLikeString:[commentObj commentLikes]]];
            [comment.dateLabel setText:[[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[commentObj postedDate]]];
            [comment.commentLabel setText:[commentObj text]];
            
            CGRect commentFrame = CGRectMake(10.0, posY, self.view.frame.size.width - 20.0f, comment.frame.size.height);
            [comment setFrame:commentFrame];
            
            [comment setBackgroundColor:[UIColor whiteColor]];
            
            [self.scrollView addSubview:comment];
            
            [comment update];
            
            posY = comment.frame.origin.y + comment.frame.size.height + 10;
            
            commentCount++;
            
            if(self.dockMenu.isViewAll == NO && i == 2) {
                break;
            }
        }
        
        // we have to add the dockmenu and title height
        posY += 60;
        
        [self.pullToRefreshManager tableViewReloadFinished];
        [self.pullToRefreshManager relocatePullToRefreshViewForComments];
    }
    
    // if the posY is bigger than newHeight we have to freak out
    self.contentHeight = posY - 25;
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.contentHeight)];
    
    if (isRefreshingList)
    {
        self.scrollView.contentOffset = lastKnownContnetOffset;
    }
    else
    {
        if(self.dockMenu.isViewAll)
        {
        }
        else
        {
            if (self.contentHeight > kMAX_Minimized_Height)
                self.minHeight = kMAX_Minimized_Height;
            else
                self.minHeight = posY; // newHeight
            
            [self updatePosition:self.minHeight];
        }
        self.scrollView.contentOffset = CGPointZero;
    }
    
    [self.dockMenu update];
    
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

-(void)updateIfOpen
{
    if(self.isOpen)
    {
        pageCount = 1;
        [self update];
    }
}

-(void)cleanComments {
    self.minHeight = 50 + kContextPageTitleHeight; // Reset the minHeight
    
    [self.dataArray removeAllObjects];
    
    NSArray *subviewArray = [self.scrollView subviews];
    for (UIView *vw in subviewArray)
    {
        if ([vw isKindOfClass:[CommentViewController class]])
        {
            [vw removeFromSuperview];
        }
    }
    
    [self.noCommentsLabel removeFromSuperview];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 0.0f);
    
    if (self.activityIndicator.superview == nil) {
        [self.view addSubview:self.activityIndicator];
    }
    
    [self.activityIndicator startAnimating];
    
    self.isClean = YES;
}

-(void)updatePosition:(float)offset
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    self.isOpen = (offset > 0) ? YES : NO;
    [[objMainView contextPage] displayContextPage:self.isOpen WithOffset:offset];
    
    // Update DockMenu's position
    // 30 accommodates the header in ContextPage
    [self.dockMenu.view setFrame:CGRectMake(0, (offset - (self.dockMenu.view.frame.size.height + 30)), self.dockMenu.view.frame.size.width, self.dockMenu.view.frame.size.height)];
    
    float scrollViewHeight = offset - self.dockMenu.view.frame.size.height - 25.0;
    self.scrollView.frame = CGRectMake(0.0f, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, scrollViewHeight);
}

- (void)close
{
    self.isOpen = NO;
    [self.dockMenu setIsViewAll:NO];
    
    self.commentsPageSate = CommentsPageStateClosed;
}

- (void)loginHandler:(id)sender
{
    if (engageProtocol == nil) {
        engageProtocol = [[EngageProtocol alloc]init];
        engageProtocol.delegate = self;
    }
    
    NSString *appId = @"egbgbafpecbanbdmjhae";
    [JREngage setEngageAppId:appId tokenUrl:nil andDelegate:engageProtocol.delegate];
    
    [JREngage showAuthenticationDialog];
}



#pragma mark - Private Methods

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self.refreshControl beginRefreshing];
    self.scrollView .scrollEnabled = NO;
    
    __weak CommentsPageViewController *blockSafeSelf = self;
    
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:0
                     animations:^{
                         [blockSafeSelf.scrollView setAlpha:0.5f];
                     }
                     completion:^(BOOL finished){
                         [blockSafeSelf refreshCommentList];
                     }];
}

#pragma mark - MNMBottomPullToRefreshManagerClient Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([[WebserviceComunication sharedCommManager] articleCommentCount] > [self.dataArray count]) {
        canLoadMoreComments = YES;
    } else {
        canLoadMoreComments = NO;
    }
    
    if(canLoadMoreComments && [[WebserviceComunication sharedCommManager] isOnline] && self.commentsPageSate == CommentsPageStateMaximized)
    {
        [self.pullToRefreshManager relocatePullToRefreshViewForComments];
        [self.pullToRefreshManager tableViewReleased];
    }
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager
{
    if ([[WebserviceComunication sharedCommManager] articleCommentCount] > [self.dataArray count]) {
        canLoadMoreComments = YES;
    } else {
        canLoadMoreComments = NO;
    }
    
    if([[WebserviceComunication sharedCommManager] isOnline] && canLoadMoreComments && self.commentsPageSate == CommentsPageStateMaximized)
    {
        [self.pullToRefreshManager relocatePullToRefreshViewForComments];
        [self.pullToRefreshManager setPullToRefreshViewVisible:YES];
        
        isRefreshingList = YES;
        
        // then we are at the end
        pageCount = [[WebserviceComunication sharedCommManager] numPageNoForComments] + 1;
        
        __weak CommentsPageViewController *blockSafeSelf = self;
        
        
        PDBackgroundTaskManager *backgroundTaskManager = [PDBackgroundTaskManager backgroundTaskManager];
        
        [backgroundTaskManager executeBackgroundTaskWithExpirationHandler:nil executionHandler:^(PDBackgroundTaskManager *manager, NSString *taskName) {
            
            [[WebserviceComunication sharedCommManager] getComments:nil
                                                          pageCount:pageCount
                                                          batchSize:0
                                                         completion:^(BOOL successful, NSError *error, NSArray *dataCollection) {
                                                             if (successful)
                                                             {
                                                                 blockSafeSelf.isClean = YES;
                                                                 if (dataCollection && dataCollection.count > 0)
                                                                 {
                                                                     [blockSafeSelf update];
                                                                     isRefreshingList = NO;
                                                                 }
                                                                 else
                                                                 {
                                                                     pageCount--;
                                                                 }
                                                             }
                                                             else
                                                             {
                                                                 blockSafeSelf.isClean = NO;
                                                                 pageCount--;
                                                             }
                                                             [blockSafeSelf.refreshControl endRefreshing];
                                                         }];
        }];
    }
}



#pragma mark - CommentViewControllerDelegate Methods

- (void)refreshCommentList
{
    // Get the current count
    int currentCount = [[[WebserviceComunication sharedCommManager] arrComments] count];
    
    [[[WebserviceComunication sharedCommManager] arrComments] removeAllObjects];
    
    isRefreshingList = YES;
    
    __weak CommentsPageViewController *blockSafeSelf = self;
    
    
    PDBackgroundTaskManager *backgroundTaskManager = [PDBackgroundTaskManager backgroundTaskManager];
    
    [backgroundTaskManager executeBackgroundTaskWithExpirationHandler:nil executionHandler:^(PDBackgroundTaskManager *manager, NSString *taskName) {
    
        [[WebserviceComunication sharedCommManager] getComments:nil
                                                      pageCount:1
                                                      batchSize:currentCount // self.dataArray.count
                                                     completion:^(BOOL successful, NSError *error, NSArray *dataCollection) {
                                                         
                                                         if (successful)
                                                         {
                                                             blockSafeSelf.isClean = YES;
                                                             
                                                             if (dataCollection && dataCollection.count > 0)
                                                             {
                                                                 [blockSafeSelf update];
                                                                 isRefreshingList = NO;
                                                             }
                                                         }
                                                         else
                                                         {
                                                             blockSafeSelf.isClean = NO;
                                                         }
                                                         
                                                         
                                                         [blockSafeSelf.refreshControl endRefreshing];
                                                         
                                                     }];
    }];
    
    
}



#pragma mark - Sample protocol delegate

- (void) authenticationDidFailWithError:(NSError *) error forProvider:(NSString *) provider
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Sign In"
                          message: error.localizedFailureReason
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [JREngage removeDelegate:engageProtocol.delegate];
}

- (void) authenticationDidSucceedForUser:(NSDictionary *) authInfo forProvider:(NSString *)	provider
{
    // register a receiver for the webservice
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;  
    [[NSNotificationCenter defaultCenter] addObserver:[objMainView contextPage] selector:@selector(authenticationFromEWN) name:kNOTIFICATION_AUTHENTICATE object:nil];
    
    // Creating the dictionary this way as we have more control on not inserting nil values
    // into dictionary which causes crash - Andre
    NSMutableDictionary *authDetails = [NSMutableDictionary dictionary];
    
    if ([authInfo objectForKey:@"profile"])
    {
        if ([[authInfo objectForKey:@"profile"] objectForKey:@"providerName"])
            [authDetails setValue:[[authInfo objectForKey:@"profile"] objectForKey:@"providerName"] forKey:@"providerName"];
        
        if ([[authInfo objectForKey:@"profile"] objectForKey:@"displayName"])
            [authDetails setValue:[[authInfo objectForKey:@"profile"] objectForKey:@"displayName"] forKey:@"displayName"];
        
        if ([[authInfo objectForKey:@"profile"] objectForKey:@"email"])
            [authDetails setValue:[[authInfo objectForKey:@"profile"] objectForKey:@"email"] forKey:@"email"];
        
        if ([[authInfo objectForKey:@"profile"] objectForKey:@"photo"])
            [authDetails setValue:[[authInfo objectForKey:@"profile"] objectForKey:@"photo"] forKey:@"image"];
    }
    
    if ([authInfo objectForKey:@"token"]) {
        [authDetails setValue:[authInfo objectForKey:@"token"] forKey:@"id"];
    }
    
    
    // call the ewn webservice with these details
    [[[WebserviceComunication sharedCommManager] dictAuthenticate]addEntriesFromDictionary:authDetails];
    [[WebserviceComunication sharedCommManager] getAuthentication];
    
    [JREngage removeDelegate:engageProtocol.delegate];
}

- (void) authenticationDidNotComplete
{
    [JREngage removeDelegate:engageProtocol.delegate];
}

- (void)viewAllHandler:(id)sender
{
    pageCount = 1;
    
    if(self.dockMenu.isViewAll)
    {
        self.commentsPageSate = CommentsPageStateMinimized;
        
        [self.dockMenu setIsViewAll:NO];
        [self update];
        [self updatePosition:self.minHeight];
    }
    else
    {
        self.commentsPageSate = CommentsPageStateMaximized;
        
        CGRect fullScreen = [[UIScreen mainScreen] applicationFrame];
        [self.dockMenu setIsViewAll:YES];
        [self update];
        [self updatePosition:fullScreen.size.height];
    }
    [self.dockMenu update];
}

- (void)postHandler:(id)sender
{
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        NSString *messageString = @"Your connection is offline and you won't be able to post a comment. Check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    // get the article id...
    [objMainView postCommentModal:articleId];
    // ok at some stage we have to come back here and resume what we were doing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentPostedHandler) name:@"COMMENT_MODAL_CLOSED" object:nil];
}

// after a comment is posted this gets notified
- (void)commentPostedHandler
{
    [self.dataArray removeAllObjects];
    NSArray *subviewArray = [self.scrollView subviews];
    
    for (UIView *vw in subviewArray) {
        if ([vw isKindOfClass:[CommentViewController class]])
            [vw removeFromSuperview];
    }
    
    if (self.activityIndicator.superview == nil) { [self.view addSubview:self.activityIndicator]; }
    [self.activityIndicator startAnimating];

    self.isClean = YES;
    
    PDBackgroundTaskManager *backgroundTaskManager = [PDBackgroundTaskManager backgroundTaskManager];
    
    [backgroundTaskManager executeBackgroundTaskWithExpirationHandler:nil executionHandler:^(PDBackgroundTaskManager *manager, NSString *taskName) {
        
        [[WebserviceComunication sharedCommManager] getCommentsInit:articleId];
    }];
    
    [[WebserviceComunication sharedCommManager] showAlert:@"Comments" message:@"Your comment has been submitted."];
    
}



#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.dockMenu release];
    [self.dataArray release];
    [self.scrollView release];
    [self.activityIndicator release];
    [self.noCommentsLabel release];
    [super dealloc];
}

@end
