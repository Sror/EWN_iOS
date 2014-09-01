//
//  RelatedScrollerViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/23.
//
//

#import "RelatedScrollerViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"

@interface RelatedScrollerViewController ()

@end

@implementation RelatedScrollerViewController

@synthesize articles;
@synthesize scrollView;
@synthesize alrtvwReachable;

AppDelegate *appDelegate;

-(UIScrollView *)scrollView
{
    if(!scrollView)
    {
        scrollView = [[UIScrollView alloc] init];
    }
    return scrollView;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView setUserInteractionEnabled:YES];
    [self.scrollView setAlwaysBounceHorizontal:YES];
    [self.view addSubview:self.scrollView];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)update:(NSString *)articleId {
    // find the related article id's
    articles = [[CacheDataManager sharedCacheManager] getContentsForArticleId:articleId];

    // Clean
    for(UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    int posX = 5;
    int i = 0;
    
    int podWidth = 70;
    int podHeight = 40;
    
    for(Contents *article in articles) {
        if(i > 0) {
            posX += 75;
        }
        
        UIView *pod = [RelatedScrollerViewController createPod:posX yValue:5 wValue:podWidth hValue:podHeight tagCounter:i contentItem:article index:i contentType:article.contentType];
        [pod setTag:i];
        [scrollView addSubview:pod];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        [pod addGestureRecognizer:tapRecognizer];
        i++;
    }
    
    [self.scrollView setContentSize:CGSizeMake((80 * [articles count]) + 60, 80)]; // we add 60 px to scrollView to accomodate for the Menu bar.
}

-(IBAction)tapHandler:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    UIView *vwTemp = gesture.view;
    
    Contents *article = [articles objectAtIndex:vwTemp.tag];
    
    if ([article.contentType isEqualToString:@"audio"] || [article.contentType isEqualToString:@"video"]) {
        if ([[WebserviceComunication sharedCommManager] isOnline]) {
            objWebAPIRequest = [[WebAPIRequest alloc] initWithDelegate:self];
            urlFile = [[WebserviceComunication sharedCommManager] prepareURLForFile:[article filename] withContentType:[article contentType]];
            [objWebAPIRequest webRequestWithUrl:urlFile];
        }
    } else if ([article.contentType isEqualToString:@"image"]) {
        [self tappedOnImage:vwTemp.tag];
        return;
    }
}

- (void)tappedOnImage:(int)selectedIndex {
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    int index = 0;
    int sIndex = 0;
    for (int x = 0; x < [articles count]; x++) {
        Contents *ImageArticle = [articles objectAtIndex:x];
        if ([ImageArticle.contentType isEqualToString:@"image"]) {
            if (selectedIndex == x) {
                sIndex = index;
            }
            index++;
            if ([ImageArticle featuredImageFile] == nil) {
                // show a loader
                [self showLoader:@"Loading image"];
                // download the file
                [self downloadFeaturedImage:ImageArticle selectedIndex:selectedIndex];
                return;
            }
            [filePaths addObject:[ImageArticle featuredImageFile]];
            [titles addObject:[ImageArticle contentTitle]];
        }
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView showMultipleLightBoxImages:filePaths titles:titles index:sIndex];
    return;
}

- (void)downloadFeaturedImage:(Contents *) dicArticleDetail selectedIndex:(int) index {
    NSString *imageUrl = [dicArticleDetail featuredImageUrl];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [request setTimeOutSeconds:5];
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [self hideLoader];
        if (image == nil) {
            [[WebserviceComunication sharedCommManager] showAlert:@"Image Error" message:@"The image could not be downloaded at this time. Please try again later."];
            return;
        }
        [dicArticleDetail setFeaturedImageUrlData:UIImagePNGRepresentation(image)];
        [[CacheDataManager sharedCacheManager] UpdatefeaturedImage:dicArticleDetail];
        [self tappedOnImage:index];
    }];
    [request setFailedBlock:^{
        [self hideLoader];
        [[WebserviceComunication sharedCommManager] showAlert:@"Image Error" message:@"The image could not be downloaded at this time. Please try again later."];
        
    }];
    [request startAsynchronous];
}

- (void)showLoader:(NSString *)message {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView showBreakingLoadingScreen:message];
}

- (void)hideLoader {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    [objMainView hideBreakingLoadingScreen];
}

// Roughly 304x174 (80x45)
+ (UIView *)createPod:(float)x
               yValue:(float)y
               wValue:(float)w
               hValue:(float)h
           tagCounter:(int)numTagCounter
          contentItem:(Contents *)arrContentItem
                index:(int) numIndex
          contentType:(NSString *)strContentType
{
    UIView * podView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    UIImage *imgBackground = [UIImage imageNamed:@"item-white-bg.png"];
    UIImageView *imgVwBackground = [[UIImageView alloc] initWithImage:imgBackground];
    [imgVwBackground setFrame:CGRectMake(0, 0, w, h)];
    [podView addSubview:imgVwBackground];
    
    // add image
    UIImageView *imageView = [RelatedScrollerViewController createPodImage:w hValue:h imageName:[UIImage imageNamed:kImgNameDefault]];
    [podView addSubview:imageView];
    
    if([strContentType isEqualToString:kstrVideo]) {
        // add video overlay
        UIImageView *imgVwForButton = [RelatedScrollerViewController createPodImageOverlay:@"btn-play-video.png" imageParent:imageView];
        [podView addSubview:imgVwForButton];
    }
    
    if([strContentType isEqualToString:kstrAudio]) {
        // add audio overlay
        UIImageView *imgVwForButton = [RelatedScrollerViewController createPodImageOverlay:@"btn-play-audio.png" imageParent:imageView];
        [podView addSubview:imgVwForButton];
    }
    
    if(arrContentItem.thumbnilImageFile != nil) {
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:arrContentItem.thumbnilImageFile];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        if ([imageData length] > 0) {
            [imageView setImage:[UIImage imageWithData:imageData]];
        } else {
            [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
        }
    } else {
        if([[WebserviceComunication sharedCommManager] isOnline]) {
            NSString *strUrl;
            strUrl = [[NSString alloc]initWithFormat:@"%@",arrContentItem.thumbnilImageUrl];
            dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
            dispatch_async(myQueue, ^{
                [imageView setImageAsynchronouslyFromUrl:strUrl animated:YES article:arrContentItem];
            });
        } else {
            [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
        }
    }
    
    return podView;
}

+ (UIImageView *)createPodImage:(float)w hValue:(float)h imageName:(UIImage *)iName {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    [imageView setTag:101];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    imageView.image = [UIImage imageNamed:kImgNameDefault];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setOpaque:NO];
    return imageView;
}

+ (UIImageView *)createPodImageOverlay:(NSString*)overlayImage imageParent:(UIImageView*)iName {
    UIImageView *imgVwForButton = [[UIImageView alloc]initWithFrame:iName.frame];
    [imgVwForButton setImage:[UIImage imageNamed:overlayImage]];
    [imgVwForButton setContentMode:UIViewContentModeCenter];
    return imgVwForButton;
}

-(void)dealloc {
    self.scrollView;
}

-(void)gotURLCheckingResponse: (ASIHTTPRequest *)response
{
    [objWebAPIRequest hideIndicator];
    objWebAPIRequest.delegate = nil;
    objWebAPIRequest = nil;
    
    if(response.responseStatusCode == 404)
    {
        alrtvwReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwReachable show:YES ShowDetail:YES NumberOfButtons:1];
        alrtvwReachable.lblHeading.text=[NSString stringWithFormat:kstrError];
        alrtvwReachable.lblDetail.text=[NSString stringWithFormat:kstrFileIsNotFound];
        [alrtvwReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
    }
    
    else if(response.responseStatusCode == 200)
    {
        [self playFile];
    }
    else if(response.responseStatusCode == 302)
    {
        [self playFile];
    }
    else
    {
        alrtvwReachable =[[CustomAlertView alloc] initWithNibName:kstrCustomAlertView bundle:nil];
        [alrtvwReachable show:YES ShowDetail:YES NumberOfButtons:1];
        alrtvwReachable.lblHeading.text=[NSString stringWithFormat:kstrUnknownError];
        alrtvwReachable.lblDetail.text=[NSString stringWithFormat:kstrErrorPlaying];
        [alrtvwReachable.btn1 setImage:[UIImage imageNamed:@"ok.png"] forState:UIControlStateNormal];
    }
    [response cancel];
}

-(void)playFile
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade]; // UIStatusBarAnimationFade
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:urlFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackComplete:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController presentMoviePlayerViewControllerAnimated:theMovie];
    
    theMovie.moviePlayer.shouldAutoplay = TRUE;
    [theMovie.moviePlayer play];
}

- (void)moviePlaybackComplete:(NSNotification *)obj
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; // UIStatusBarAnimationFade
    
    // For iOS 7 - This has to be performed after a delay, otherwise it doesn't work on iOS 7 ...
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [theMovie.moviePlayer setCurrentPlaybackTime:theMovie.moviePlayer.duration];
    [theMovie.moviePlayer stop];
    [theMovie.moviePlayer setContentURL:nil];
    [appDelegate.window.rootViewController dismissMoviePlayerViewControllerAnimated];
}

@end
