//
//  ContentsListViewController.m
//  EWN
//
//  Created by Macmini on 23/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ContentsListViewController.h"
#import "CommanConstants.h"
#include "CustomAlertView.h"
#import "WebserviceComunication.h"
#import "MainViewController.h"
#import "ContentDetailViewController.h"

#import <dispatch/dispatch.h>

@interface ContentsListViewController()

/**
 * Loads the table
 *
 * @private
 */
-(void)reload_scrollview;

@end

@implementation ContentsListViewController

@synthesize mainView;
@synthesize tlbListTop;
@synthesize lblCurrentContent;
@synthesize lblNextContent;
@synthesize scrlvwContentList = scrollView_;
@synthesize strSelfCurrentContentType;
@synthesize retryButton;
@synthesize showAds;
@synthesize displayAds;

AppDelegate *appDelegate;

/**-----------------------------------------------------------------
 Function Name  : initWithNibName
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  :
 Purpose        : this method sets some variables.
 ------------------------------------------------------------------*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil CurrentContentType:(NSString *)strCurrentContentType NextContentType:(NSString *)strNextContentType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    showAds = kShowAdsBOOL;
    displayAds = true;
    if (self)
    {
        self.strSelfCurrentContentType = [[NSString alloc]initWithFormat:@"%@",strCurrentContentType];
        
        //create video view programatically
        self.tlbListTop = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
        
        self.lblCurrentContent = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 80,25)];
        [self.lblCurrentContent setText:strCurrentContentType];
        [self.lblCurrentContent setBackgroundColor:[UIColor clearColor]];
        [self.lblCurrentContent setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:20.0]];
        [self.lblCurrentContent setTextColor:[UIColor darkGrayColor]];
        
        self.lblNextContent = [[UILabel alloc]initWithFrame:CGRectMake(298, 5, 80,25)];
        [self.lblNextContent setText:strNextContentType];
        [self.lblNextContent setBackgroundColor:[UIColor clearColor]];
        [self.lblNextContent setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:20.0]];
        [self.lblNextContent setTextColor:[UIColor grayColor]];
    }
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
    return self;
}

-(void) setupForTwitter {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // we gotta instantiate a webview
    int y = 40;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, y, 320, self.view.frame.size.height - y)];
    [webView setDelegate:self];
    [webView setBackgroundColor:[UIColor whiteColor]];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://prezencenewmedia.com/rudolf/twitterTest.php?bottomPadding=60px"]]];
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ewn.mobi/app_twitter/twitterTest.php?bottomPadding=60px"]]];
    [self.view addSubview:webView];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

/**-----------------------------------------------------------------
 Function Name  : allocateAndCreateViews
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Allocate and creates New Views.
 ------------------------------------------------------------------*/

-(void)allocateAndCreateViews
{
    numTagCounter = 0;
    
    float numX = 6;
    float numY = 6;
    float numDiffX = 156; // 160
    float numDiffY = 0;
    float numWidth = 150; // 148
    float numHeight = 124;
    
    // If this was a Reload, from Pull-to-Refresh
    // WRefresh
    if(!isCompleteReload)
    {
        isCompleteReload = TRUE;
        
        // Ensures the ScrollView doesn't creep 44 pixels down each category switch after first initiating a Refresh
        self.scrlvwContentList.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [refreshControl endRefreshing];
        [self RemoveSubviews];
    }
    else
    {
        // TEMP - Fade
        [self.scrlvwContentList setAlpha:0.0f];
    }
    
    [self.scrlvwContentList setContentSize:CGSizeMake(320,self.scrlvwContentList.contentSize.height+numDiffY+numY)];
    
    if(![self.strSelfCurrentContentType isEqualToString:kstrLatest])
    {
        if( [self.strSelfCurrentContentType isEqualToString:kstrVideo])
        {
            NSMutableArray *arrContentItem;
            
            if([[WebserviceComunication sharedCommManager] isOnline])
            {
                arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrVideoNew]];
            }
            else
            {
                arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrVideo]];
            }
            
            for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++)
            {
                // dolfies first objective C function
                // so creating the pod all happens in this function
                // Audio tag
                UIView *vwContentType = [ContentsListViewController createPod:numX
                                                                       yValue:numY
                                                                       wValue:numWidth
                                                                       hValue:numHeight
                                                                   tagCounter:numTagCounter
                                                                  contentItem:arrContentItem
                                                                        index:numIndex
                                                                  contentType:self.strSelfCurrentContentType];
                                
                //jainesh
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
                [vwContentType addGestureRecognizer:tapRecognizer];
                [vwContentType setTag:numTagCounter];
                [self.scrlvwContentList addSubview:vwContentType];
                
                // CLEANUP
                [tapRecognizer release];
                tapRecognizer = nil;
                
                // this is the positioning magic
                numX = numX + numDiffX;                
                if(numX > 166)
                {
                    numDiffY = 140;
                    numX = 6;
                    numY = numY + numDiffY;
                    
                    // ADTech
                    // Every First Row
                    // And every last row
                    if(numIndex == 1)
                    {
                        if (showAds && displayAds) {
                            ATBannerView *bannerView = [(MainViewController *)self.mainView createAd];
                            [bannerView setFrame:CGRectMake(0, numY, bannerView.frame.size.width, bannerView.frame.size.height)];
                            [self.scrlvwContentList addSubview:bannerView];
                            numY += bannerView.frame.size.height + 6;
                        }
                    }
                }
                
                numTagCounter = numTagCounter + 1;
            }
            [arrContentItem removeAllObjects];
            arrContentItem = nil;
        }
        else if([self.strSelfCurrentContentType isEqualToString:kstrImages])
        {
            NSMutableArray *arrContentItem;
            
            if([[WebserviceComunication sharedCommManager] isOnline])
            {
                arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrImagesNew]];
            }
            else
            {
                arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrImages]];
            }
            
            for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++)
            {
                // Images Tab
                // so creating the pod all happens in this function
                UIView *vwContentType = [ContentsListViewController createPod:numX
                                                                       yValue:numY
                                                                       wValue:numWidth
                                                                       hValue:numHeight
                                                                   tagCounter:numTagCounter
                                                                  contentItem:arrContentItem
                                                                        index:numIndex
                                                                  contentType:self.strSelfCurrentContentType];
                //jainesh
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
                [vwContentType addGestureRecognizer:tapRecognizer];                
                [vwContentType setTag:numTagCounter];
                [self.scrlvwContentList addSubview:vwContentType];                
                
                // CLEANUP
                [tapRecognizer release];
                tapRecognizer = nil;
                
                numX = numX + numDiffX;
                
                if(numX > 166)
                {
                    numDiffY = 140;
                    numX = 6;
                    numY = numY + numDiffY;
                    
                    // ADTech
                    if(numIndex == 1)
                    {
                        if (showAds && displayAds) {
                            ATBannerView *bannerView = [(MainViewController *)self.mainView createAd];
                            [bannerView setFrame:CGRectMake(0, numY, bannerView.frame.size.width, bannerView.frame.size.height)];
                            [self.scrlvwContentList addSubview:bannerView];
                            numY += bannerView.frame.size.height + 6;
                        }
                    }
                    
                }
                numTagCounter = numTagCounter + 1;
            }
            [arrContentItem removeAllObjects];
            arrContentItem = nil;
        }
        else if([self.strSelfCurrentContentType isEqualToString:kstrAudio])
        {
            NSMutableArray *arrContentItem;
            
            if([[WebserviceComunication sharedCommManager] isOnline])
            {
                arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrAudioNew]];
            }
            else
            {
                arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrAudio]];
            }
            
            for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++)
            {
                // Audio tab :D
                // so creating the pod all happens in this function
                UIView *vwContentType = [ContentsListViewController createPod:numX
                                                                       yValue:numY
                                                                       wValue:numWidth
                                                                       hValue:numHeight
                                                                   tagCounter:numTagCounter
                                                                  contentItem:arrContentItem
                                                                        index:numIndex
                                                                  contentType:self.strSelfCurrentContentType];
                
                //jainesh
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
                [vwContentType addGestureRecognizer:tapRecognizer];                
                [vwContentType setTag:numTagCounter];                
                [self.scrlvwContentList addSubview:vwContentType];
                
                // CLEANUP
                [tapRecognizer release];
                tapRecognizer = nil;
                
                numX = numX + numDiffX;
                
                if(numX > 166)
                {
                    numDiffY = 140;
                    numX = 6;
                    numY = numY + numDiffY;
                    
                    // ADTech
                    if(numIndex == 1)
                    {
                        if (showAds && displayAds) {
                            ATBannerView *bannerView = [(MainViewController *)self.mainView createAd];
                            [bannerView setFrame:CGRectMake(0, numY, bannerView.frame.size.width, bannerView.frame.size.height)];
                            [self.scrlvwContentList addSubview:bannerView];
                            numY += bannerView.frame.size.height + 6;
                        }
                    }
                }
                numTagCounter = numTagCounter + 1;
            }
            [arrContentItem removeAllObjects];
            arrContentItem = nil;
        }
        else if([self.strSelfCurrentContentType isEqualToString:kCONTENT_TITLE_SEARCH])
        {
            // TODO - Shouldn't this get removed ... Search has change ...
            
            NSMutableArray *arrContentItem;
            if([[WebserviceComunication sharedCommManager] isOnline]) {
                if([[[WebserviceComunication sharedCommManager] arrSearchNews] count]>0) {
                    arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrSearchNews]];
                } else {
                    arrContentItem = [NSMutableArray arrayWithArray:NULL];
                }
            } else {
                arrContentItem = [NSMutableArray arrayWithArray:NULL];
            }
            
            NSArray *arrSubViewsOfLatest  = [self.scrlvwContentList subviews];
            for ( UIView *vw in arrSubViewsOfLatest) {
                [vw removeFromSuperview];
            }
            
            for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++) {
                // This one is search results which we probably have to change!!!
                // TODO
                // so creating the pod all happens in this function
                UIView *vwContentType = [ContentsListViewController createPod:numX
                                                                       yValue:numY
                                                                       wValue:numWidth
                                                                       hValue:numHeight
                                                                   tagCounter:numTagCounter
                                                                  contentItem:arrContentItem
                                                                        index:numIndex
                                                                  contentType:self.strSelfCurrentContentType];
                
                //jainesh
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
                [vwContentType addGestureRecognizer:tapRecognizer];
                [vwContentType setTag:numTagCounter];
                [self.scrlvwContentList addSubview:vwContentType];

                // CLEANUP
                [tapRecognizer release];
                tapRecognizer = nil;
                
                numX = numX + numDiffX;
                
                if(numX > 166 && (numIndex == ([arrContentItem count] - 1))) {
                    numDiffY = 140;
                    numX = 6;
                    numY = numY + numDiffY;
                }
                
                DLog(@":: count : %d", numIndex);
                
                numTagCounter = numTagCounter + 1;
            }
        }
        
    } else {
        // kstrLatestNews
        NSMutableArray *arrContentItem;
        LeadingNews *dictLeadingNewsForCalc;
        
        dictLeadingNewsForCalc = [[CacheDataManager sharedCacheManager] getLeadingNewsEntity];
        
        arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrLatestNews]];
        
        // Check we are in the AllNews Section and InFocus is disabled
        BOOL isAllNews = ([[[[WebserviceComunication sharedCommManager] dictCurrentCategory] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews] && ![[WebserviceComunication sharedCommManager] isInFocus]);
        
        if(dictLeadingNewsForCalc != nil || ![[[[WebserviceComunication sharedCommManager] dictCurrentCategory ] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews] || [[WebserviceComunication sharedCommManager] isInFocus]) {
            int numarticleCount;
            
//            if((isAllNews || version2) && ![[WebserviceComunication sharedCommManager] isInFocus]) {
            if((isAllNews) && ![[WebserviceComunication sharedCommManager] isInFocus]) {
                // +1 for Leading news?
                numarticleCount = [arrContentItem count] + 1;
            } else {
                numarticleCount = [arrContentItem count];
            }
            
            for (int numIndex = 0; numIndex < numarticleCount; numIndex++) {
                
                UIView *vwContentType;
                
                if(numIndex == 0) {
                    numWidth = appDelegate.window.frame.size.width;
                    numHeight = (numWidth * 0.6); // Ration taken from Default Image : 308x188
                    
                    vwContentType = [[UIView alloc]initWithFrame:CGRectMake(0, 0, numWidth, numHeight)];
                    
                    //jainesh
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
                    [vwContentType addGestureRecognizer:tapRecognizer];
                    
                    [vwContentType setTag:numTagCounter];
                    
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, numWidth, numHeight)];
                    [imageView setTag:101];
                    [imageView setContentMode:UIViewContentModeScaleAspectFit];
                    imageView.image = [UIImage imageNamed:kImgNameDefault];
                    imageView.backgroundColor = [UIColor clearColor];
                    imageView.opaque = NO;
                    [vwContentType addSubview:imageView];
                    
                    UIView *txtBackground = [[UIView alloc] initWithFrame:CGRectMake(0, (numHeight - 50), numWidth, 50)];
                    [txtBackground setBackgroundColor:[UIColor blackColor]];
                    [txtBackground setAlpha:0.60];
                    [vwContentType addSubview:txtBackground];
                    
                    UILabel *title =[[UILabel alloc]initWithFrame:CGRectMake(8, (txtBackground.frame.origin.y + 8), (numWidth - 16), 20)];
                    title.tag = 99;
                    [title setFont:[UIFont fontWithName:kFontOpenSansRegular size:16]];
                    [title setTextColor:[UIColor whiteColor]];
                    [title setBackgroundColor:[UIColor clearColor]];
                    [vwContentType addSubview:title];
                    
                    UILabel *lblTimeStamp = [[UILabel alloc]initWithFrame:CGRectMake(8, (title.frame.origin.y + title.frame.size.height), (numWidth - 16), 15)];
                    [lblTimeStamp setTag:60];
                    [lblTimeStamp setFont:[UIFont fontWithName:kFontOpenSansRegular size:11]];
                    [lblTimeStamp setTextColor:[UIColor colorWithHexString:@"ff323a"]];
                    [lblTimeStamp setBackgroundColor:[UIColor clearColor]];
                    [vwContentType addSubview:lblTimeStamp];
                    
                    if([[WebserviceComunication sharedCommManager]isOnline]) {
                        
//                        if ((version2 || isAllNews) && ![[WebserviceComunication sharedCommManager] isInFocus]) {
                        if (isAllNews && ![[WebserviceComunication sharedCommManager] isInFocus]) {
                            LeadingNews *dictLeadingNews = [[CacheDataManager sharedCacheManager] getLeadingNewsEntity];
                            [arrContentItem insertObject:dictLeadingNews atIndex:0];
                        }
                        
                        [title setText:[[arrContentItem objectAtIndex:0] contentTitle]];
                        
                        if([[arrContentItem objectAtIndex:0] thumbnilImageFile] != nil) {
                            NSData *imageData = [[ NSData alloc] initWithContentsOfFile:[[arrContentItem objectAtIndex:0] thumbnilImageFile]];
                            [imageView setContentMode:UIViewContentModeScaleToFill];
                            if ([imageData length] > 0)
                            {
                                [imageView setImage:[UIImage imageWithData:imageData]];
                            }
                            else
                            {
                                [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
                            }
                            [imageData release];
                            imageData = nil;
                        } else {
                            if([[WebserviceComunication sharedCommManager] isOnline]) {
                                NSString *strUrl;
                                strUrl = [[NSString alloc]initWithFormat:@"%@",[[arrContentItem objectAtIndex:0] thumbnilImageUrl]];
                                dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
                                dispatch_async(myQueue, ^{
                                    [imageView setImageAsynchronouslyFromUrl:strUrl animated:YES];
                                });
                                [strUrl release];
                                strUrl = nil;
                            } else {
                                [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
                            }
                        }
                        
                        [lblTimeStamp setText:[[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[[arrContentItem objectAtIndex:0] publishDate]]];
                        
                    } else {
                        
                        if([[[[WebserviceComunication sharedCommManager] dictCurrentCategory ] objectForKey:kstrId] isEqualToString:kstrKeyForAllNews]) {
                            LeadingNews *dictLeadingNews = [[CacheDataManager sharedCacheManager] getLeadingNewsEntity];
                            [arrContentItem insertObject:dictLeadingNews atIndex:0];
                            
                            [title setText:[dictLeadingNews contentTitle]];
                            
                            NSData *imageData = [[NSData alloc] initWithContentsOfFile:[dictLeadingNews thumbnilImageFile]];
                            
                            [imageView setContentMode:UIViewContentModeScaleToFill];
                            if ([imageData length] > 0) {
                                [imageView setImage:[UIImage imageWithData:imageData]];
                            } else {
                                [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
                            }
                            [lblTimeStamp setText:[[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[dictLeadingNews publishDate]]];
                        } else {
                            [title setText:[[arrContentItem objectAtIndex:0] contentTitle]];
                            
                            NSData *imageData = [[NSData alloc] initWithContentsOfFile:[[arrContentItem objectAtIndex:0] thumbnilImageFile]];
                            
                            [imageView setContentMode:UIViewContentModeScaleToFill];
                            if ([imageData length] > 0) {
                                [imageView setImage:[UIImage imageWithData:imageData]];
                            } else {
                                [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
                            }
                            [lblTimeStamp setText:[[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[[arrContentItem objectAtIndex:0] publishDate]]];
                        }
                    }
                    
                    [self.scrlvwContentList addSubview:vwContentType];
                    
                    numWidth = 150; // 148
                    numHeight = 124;
                    
                    //numDiffY = 280;
                    numDiffY = imageView.frame.size.height;
                    numX = 6;
                    numY = numY + numDiffY;
                    
                    // CLEANUP
                    [tapRecognizer release];
                    tapRecognizer = nil;
                    [imageView release];
                    imageView = nil;
                    [txtBackground release];
                    txtBackground = nil;
                    [title release];
                    title = nil;
                    [lblTimeStamp release];
                    lblTimeStamp = nil;
                    [vwContentType release];
                    vwContentType = nil;
                } else {
                    // this is the latest news below the leading article
                    // so creating the pod all happens in this function
                    vwContentType = [ContentsListViewController createPod:numX
                                                                   yValue:numY
                                                                   wValue:numWidth
                                                                   hValue:numHeight
                                                                tagCounter:numTagCounter
                                                              contentItem:arrContentItem
                                                                    index:numIndex
                                                              contentType:self.strSelfCurrentContentType];
                    
                    //jainesh
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
                    [vwContentType addGestureRecognizer:tapRecognizer];                    
                    [vwContentType setTag:numTagCounter];
                    [self.scrlvwContentList addSubview:vwContentType];
                    
                    // CLEANUP
                    [tapRecognizer release];
                    tapRecognizer = nil;
                    
                    numX = numX + numDiffX;
                    
                    if (numX > 166 || (numIndex == (numarticleCount - 1))) {
                        numDiffY = 140;
                        numX = 6;
                        numY = numY + numDiffY;
                    }
                    
                    // ADTech
                    if(numIndex == 2)
                    {
                        if (showAds && displayAds) {
                            ATBannerView *bannerView = [(MainViewController *)self.mainView createAd];
                            [bannerView setFrame:CGRectMake(0, numY, bannerView.frame.size.width, bannerView.frame.size.height)];
                            [self.scrlvwContentList addSubview:bannerView];
                            numY += bannerView.frame.size.height + 6;
                        }
                    }

                }
                numTagCounter = numTagCounter + 1;
            }
            
            // cleanup over here
            [arrContentItem removeAllObjects];
            arrContentItem = nil;
            
        } else {
            for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++) {
                UIView *vwContentType;
                
                vwContentType = [[UIView alloc]initWithFrame:CGRectMake(numX, numY, numWidth,numHeight)];
                
                //jainesh
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
                [vwContentType addGestureRecognizer:tapRecognizer];
                
                [vwContentType setTag:numTagCounter];
                [self.scrlvwContentList addSubview:vwContentType];
                
                UIImage *imgBackground = [UIImage imageNamed:@"item-white-bg.png"];
                UIImageView *imgVwBackground = [[UIImageView alloc]initWithImage:imgBackground];
                [imgVwBackground setFrame:CGRectMake(0,0,numWidth, numHeight)];
                [vwContentType addSubview:imgVwBackground];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6,6,numWidth-12, numHeight-44)];
                [imageView setTag:101];
                [imageView setContentMode:UIViewContentModeScaleToFill];
                imageView.image = [UIImage imageNamed:kImgNameDefault];
                
                imageView.backgroundColor = [UIColor clearColor];
                imageView.opaque = NO;
                
                [vwContentType addSubview:imageView];
                UILabel *Description = [[UILabel alloc]init];
                Description.tag = 99;
                [Description setNumberOfLines:2];
                [Description setBackgroundColor:[UIColor clearColor]];
                [Description setFont:[UIFont fontWithName:kFontOpenSansRegular size:11]];
                [Description setNumberOfLines:0];
                
                [vwContentType addSubview:Description];
                
                // This can be simplified now
                if([[WebserviceComunication sharedCommManager] isOnline])
                {
                    NSString *strUrl;
                    strUrl = [[NSString alloc]initWithFormat:@"%@",[[arrContentItem objectAtIndex:numIndex] thumbnilImageUrl]];
                    dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
                    dispatch_async(myQueue, ^{
                        [imageView setImageAsynchronouslyFromUrl:strUrl animated:YES];
                    });
                    
                    [Description setText:[[arrContentItem objectAtIndex:numIndex] contentTitle]];
                }
                else
                {
                    NSData *imageData = [[NSData alloc] initWithContentsOfFile:[[arrContentItem objectAtIndex:numIndex] thumbnilImageFile]];
                    
                    [imageView setContentMode:UIViewContentModeScaleAspectFit];
                    if ([imageData length] > 0)
                    {
                        [imageView setImage:[UIImage imageWithData:imageData]];
                    }
                    else
                    {
                        [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
                    }
                    [Description setText:[[arrContentItem objectAtIndex:numIndex] contentTitle]];
                    [imageData release];
                }
                CGSize textSize = [[Description text] sizeWithFont:[Description font] constrainedToSize:CGSizeMake(numWidth-12,30) lineBreakMode:NSLineBreakByWordWrapping];
                
                [Description setFrame:CGRectMake(7,imageView.frame.size.height+imageView.frame.origin.y+3,textSize.width,textSize.height)];
                [Description setNumberOfLines:2];
                numX += numDiffX;
                
                if(numX > 166 && (numIndex == ([arrContentItem count] - 1)))
                {
                    numDiffY = 140;
                    numX = 6;
                    numY = numY + numDiffY;
                }
            }
            numTagCounter = numTagCounter + 1;
        }
        
    }
        
    if (numX > 6) {
        numDiffY = 140;
        numX = 6;
        numY = numY + numDiffY;
    }
    
    // Adtech banner at the end
    if (numTagCounter >= kDefaultBatchCount) {
        if (showAds && displayAds) {
            ATBannerView *bannerView = [(MainViewController *)self.mainView createAd];
            [bannerView setFrame:CGRectMake(0, numY, bannerView.frame.size.width, bannerView.frame.size.height)];
            [self.scrlvwContentList addSubview:bannerView];
            numY += bannerView.frame.size.height + 6;
        }
    }
    
    // add the context nav height
    numY += 60;
    
    if(numY < self.scrlvwContentList.frame.size.height && !(numX == 166))
    {
        [self.scrlvwContentList setContentSize:CGSizeMake(320, self.scrlvwContentList.frame.size.height + 10)];
    }
    else
    {
        if(numX == 166)
        {
            [self.scrlvwContentList setContentSize:CGSizeMake(320,numY+numDiffY)];
        }
        else
        {
            [self.scrlvwContentList setContentSize:CGSizeMake(320,numY)];
        }
    }
    
    reloads_ = -1;
    if (![self.strSelfCurrentContentType isEqualToString:kCONTENT_TITLE_SEARCH])
    {
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:55.0 ScrollView:self.scrlvwContentList withClient:self];
        [pullToRefreshManager_ relocatePullToRefreshView];
        
        refreshControl = [[ODRefreshControl alloc] initInScrollView:self.scrlvwContentList activityIndicatorView:nil];
        [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    }
    
    numNextX = numX;
    numNextY = numY;
    
    [self removeWebServiceDictonary];
    
    [self.scrlvwContentList setAlpha:1.0f];
}

/**-----------------------------------------------------------------
 Function Name  : removeWebServiceDictonary
 Created By     : Arpit Jain
 Created Date   : 25-Apr-2013
 Modified By    :
 Modified Date  :
 Purpose        : Remove all unwanted Dictionaries.
 ------------------------------------------------------------------*/
-(void)removeWebServiceDictonary
{
    if( [self.strSelfCurrentContentType isEqualToString:kstrVideo])
    {
        [[[WebserviceComunication sharedCommManager] dictVideo] removeAllObjects];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrLatest])
    {
        [[[WebserviceComunication sharedCommManager]dictLatestNews] removeAllObjects];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrImages])
    {
        [[[WebserviceComunication sharedCommManager]dictImages] removeAllObjects];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrAudio])
    {
        [[[WebserviceComunication sharedCommManager]dictAudio] removeAllObjects];
    }
}

/**-----------------------------------------------------------------
 Function Name  : reload_scrollview
 Created By     : Arpit Jain
 Created Date   : 22-Apr-2013
 Modified By    : Arpit Jain
 Modified Date  : 25-Apr-2013
 Purpose        : Reload the scrollview and creat new view acording tio content type.
 ------------------------------------------------------------------*/
-(void)reload_scrollview
{
    reloads_++;
    
    if( [self.strSelfCurrentContentType isEqualToString:kstrVideo])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddSubviews) name:kNOTIFICATION_VIDEOS object:nil];
        
        [Flurry logEvent:KFlurryEventNewsListPaging withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[[WebserviceComunication sharedCommManager] dictCurrentCategory ] objectForKey:kstrName],kstrCategoryName,kstrVideo,kstrContentType, nil]];
        
        [[WebserviceComunication sharedCommManager] getVedio];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrImages])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddSubviews) name:kNOTIFICATION_IMAGES object:nil];
        
        [Flurry logEvent:KFlurryEventNewsListPaging withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[[WebserviceComunication sharedCommManager] dictCurrentCategory ] objectForKey:kstrName],kstrCategoryName,kContentImages,kstrContentType, nil]];
        
        // Perform long running process
        //[[WebserviceComunication sharedCommManager] setNumPageNoForImages:[[WebserviceComunication sharedCommManager]numPageNoForImages]+1];
        [[WebserviceComunication sharedCommManager] getImages];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrAudio])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddSubviews) name:kNOTIFICATION_AUDIO object:nil];
        
        [Flurry logEvent:KFlurryEventNewsListPaging withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[[WebserviceComunication sharedCommManager] dictCurrentCategory ] objectForKey:kstrName],kstrCategoryName,kstrAudio,kstrContentType, nil]];
        
        //[[WebserviceComunication sharedCommManager] setNumPageNoForAudio:[[WebserviceComunication sharedCommManager]numPageNoForAudio]+1];
        [[WebserviceComunication sharedCommManager] getAudio];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrLatest])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddSubviews) name:kNOTIFICATION_ARTICLES object:nil];
        
        [Flurry logEvent:KFlurryEventNewsListPaging withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[[WebserviceComunication sharedCommManager] dictCurrentCategory ] objectForKey:kstrName],kstrCategoryName,kcontentLatest,kstrContentType, nil]];
        
        //[[WebserviceComunication sharedCommManager] setNumPageNoForLatest:[[WebserviceComunication sharedCommManager]numPageNoForLatest]+1];
        
        if([[WebserviceComunication sharedCommManager] isInFocus])
        {
            [[WebserviceComunication sharedCommManager] getInFocusNews];
        }
        else
        {
            [[WebserviceComunication sharedCommManager] getLatestNews];
        }
    }
    
}
/**-----------------------------------------------------------------
 Function Name  : AddSubviews
 Created By     : Sumit Kumar
 Created Date   : 21-May-2013
 Modified By    : Sumit Kumar
 Modified Date  : 21-May-2013
 Purpose        : add subviews of scrollview according to content type.
 ------------------------------------------------------------------*/

- (void)AddSubviews
{
    float numDiffX = 156; // 160
    __block float numDiffY = 0;
    float numWidth = 150; // 148
    float numHeight = 124;
    
    int maxArticleLimit = 120;
    int itemsAdded = 0;
    
    // remove the context nav space
    numNextY -= 60;
    
    if( [self.strSelfCurrentContentType isEqualToString:kstrVideo])
    {
        maxArticleLimit = 60;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_VIDEOS object:nil];
        
        NSMutableArray *arrContentItem;
        
        if([[WebserviceComunication sharedCommManager] isOnline])
        {
            arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrVideoNew]];
        }
        else
        {
            arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrVideo]];
        }
                
        for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++)
        {
            // Video
            // so creating the pod all happens in this function
            UIView *vwContentType = [ContentsListViewController createPod:numNextX
                                                                   yValue:numNextY
                                                                   wValue:numWidth
                                                                   hValue:numHeight
                                                               tagCounter:numTagCounter
                                                              contentItem:arrContentItem
                                                                    index:numIndex
                                                              contentType:self.strSelfCurrentContentType];
            //jainesh
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
            [vwContentType addGestureRecognizer:tapRecognizer];
            [vwContentType setTag:numTagCounter];
            [self.scrlvwContentList addSubview:vwContentType];
            
            [tapRecognizer release];
            tapRecognizer = nil;
            
            numNextX = numNextX + numDiffX;
            
            if(numNextX > 166)
            {
                numDiffY = 140;
                numNextX = 6;
                numNextY = numNextY + numDiffY;
            }
            numTagCounter = numTagCounter + 1;
            itemsAdded++;
        }
        [arrContentItem removeAllObjects];
        arrContentItem = nil;
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrImages])
    {
        maxArticleLimit = 60;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_IMAGES object:nil];
        
        NSMutableArray *arrContentItem;
        
        if([[WebserviceComunication sharedCommManager] isOnline])
        {
            arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrImagesNew]];
        }
        else
        {
            arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrImages]];
        }
        
        for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++)
        {
            // Images
            // so creating the pod all happens in this function
            UIView *vwContentType = [ContentsListViewController createPod:numNextX
                                                                   yValue:numNextY
                                                                   wValue:numWidth
                                                                   hValue:numHeight
                                                               tagCounter:numTagCounter
                                                              contentItem:arrContentItem
                                                                    index:numIndex
                                                              contentType:self.strSelfCurrentContentType];
            
            //jainesh
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
            [vwContentType addGestureRecognizer:tapRecognizer];
            [vwContentType setTag:numTagCounter];
            [self.scrlvwContentList addSubview:vwContentType];
            
            [tapRecognizer release];
            tapRecognizer = nil;
            
            numNextX = numNextX + numDiffX;
            
            if(numNextX > 166)
            {
                numDiffY = 140;
                numNextX = 6;
                numNextY = numNextY + numDiffY;                
            }
            numTagCounter = numTagCounter + 1;
            itemsAdded++;
        }
        [arrContentItem removeAllObjects];
        arrContentItem = nil;
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrAudio])
    {
        maxArticleLimit = 60;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_AUDIO object:nil];
        
        NSMutableArray *arrContentItem;
                
        if([[WebserviceComunication sharedCommManager] isOnline])
        {
            arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrAudioNew]];
        }
        else
        {
            arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrAudio]];
        }
        
        for (int numIndex = 0; numIndex<[[[[[WebserviceComunication sharedCommManager]dictAudio] objectForKey:kstrContentItems] objectForKey:kstrContentItem] count]; numIndex++)
        {
            // Audio
            // so creating the pod all happens in this function
            UIView *vwContentType = [ContentsListViewController createPod:numNextX
                                                                   yValue:numNextY
                                                                   wValue:numWidth
                                                                   hValue:numHeight
                                                               tagCounter:numTagCounter
                                                              contentItem:arrContentItem
                                                                    index:numIndex
                                                              contentType:self.strSelfCurrentContentType];
            
            //jainesh
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
            [vwContentType addGestureRecognizer:tapRecognizer];
            [vwContentType setTag:numTagCounter];
            [self.scrlvwContentList addSubview:vwContentType];
            
            [tapRecognizer release];
            tapRecognizer = nil;
            
            numNextX = numNextX + numDiffX;
            
            if(numNextX > 166)
            {
                numDiffY = 140;
                numNextX = 6;
                numNextY = numNextY + numDiffY;
            }
            numTagCounter = numTagCounter + 1;
            itemsAdded++;
        }
        [arrContentItem removeAllObjects];
        arrContentItem = nil;
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrLatest])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_ARTICLES object:nil];
        
        NSMutableArray *arrContentItem;
        
        if([[WebserviceComunication sharedCommManager] isOnline])
        {
            arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrLatestNewsNew]];
        }
        else
        {
            arrContentItem = [NSMutableArray arrayWithArray:[[WebserviceComunication sharedCommManager] arrLatestNews]];
        }
        
        for (int numIndex = 0; numIndex<[arrContentItem count]; numIndex++)
        {
//            continue;
            // Latest News
            // so creating the pod all happens in this function
            UIView *vwContentType = [ContentsListViewController createPod:numNextX
                                                                   yValue:numNextY
                                                                   wValue:numWidth
                                                                   hValue:numHeight
                                                               tagCounter:numTagCounter
                                                              contentItem:arrContentItem
                                                                    index:numIndex
                                                              contentType:self.strSelfCurrentContentType];
            
            //jainesh
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnContent:)];
            [vwContentType addGestureRecognizer:tapRecognizer];
            [vwContentType setTag:numTagCounter];
            [self.scrlvwContentList addSubview:vwContentType];
            
            [tapRecognizer release];
            tapRecognizer = nil;
            
            numNextX = numNextX + numDiffX;
            
            if(numNextX > 166)
            {
                numDiffY = 140;
                numNextX = 6;
                numNextY = numNextY + numDiffY;
            }
            numTagCounter = numTagCounter + 1;
            itemsAdded++;
        }
        [arrContentItem removeAllObjects];
        arrContentItem = nil;
        
    }
    
    if (numNextX > 6) {
        numDiffY = 140;
        numNextX = 6;
        numNextY = numNextY + numDiffY;
    }
    
    // Adtech banner at the end
    // only if we loaded a full list though
    if (itemsAdded >= kDefaultBatchCount) {
        if (showAds && displayAds) {
            ATBannerView *bannerView = [(MainViewController *)self.mainView createAd];
            [bannerView setFrame:CGRectMake(0, numNextY, bannerView.frame.size.width, bannerView.frame.size.height)];
            [self.scrlvwContentList addSubview:bannerView];
            numNextY += bannerView.frame.size.height + 6;
        }
    }
    
    // add the context nav height
    numNextY += 60;
    
    if(numNextY < self.scrlvwContentList.frame.size.height && !(numNextX == 166))
    {
        [self.scrlvwContentList setContentSize:CGSizeMake(320,self.scrlvwContentList.frame.size.height+10)];
    }
    else
    {
        if(numNextX == 166)
        {
            [self.scrlvwContentList setContentSize:CGSizeMake(320,numNextY+numDiffY)];
        }
        else
        {
            [self.scrlvwContentList setContentSize:CGSizeMake(320,numNextY)];
        }
    }
    
    [self removeWebServiceDictonary];
    [pullToRefreshManager_ tableViewReloadFinished];
    
    // this is to stop us from running out of memory
    // also stop having it there when we have hit the limit
    if (numTagCounter >= maxArticleLimit || itemsAdded < kDefaultBatchCount) {
        [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([[WebserviceComunication sharedCommManager] isOnline] && isCompleteReload == TRUE)
    {
        [pullToRefreshManager_ tableViewScrolled];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([[WebserviceComunication sharedCommManager] isOnline] && isCompleteReload == TRUE)
    {
        [pullToRefreshManager_ tableViewReleased];
    }
}
/**-----------------------------------------------------------------
 Function Name  : bottomPullToRefreshTriggered
 Created By     : Sumit Kumar
 Created Date   : 21-May-2013
 Modified By    : Sumit Kumar
 Modified Date  : 21-May-2013
 Purpose        : refresh the content.
 ------------------------------------------------------------------*/

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager
{
    
    if([[WebserviceComunication sharedCommManager] isOnline] && isCompleteReload == TRUE)
    {
        [self performSelectorInBackground:@selector(reload_scrollview) withObject:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    DLog(@"Gotta start releasing shit or we are going to crash and burn!!!");
    DLog(@"Gotta start releasing shit or we are going to crash and burn!!!");
    DLog(@"Gotta start releasing shit or we are going to crash and burn!!!");
    displayAds = false;
    [super didReceiveMemoryWarning];
}
/**-----------------------------------------------------------------
 Function Name  : handleTapOnContent
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : called when any article has been selected.
 ------------------------------------------------------------------*/
- (UIImage *) captureScreen
{
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//jainesh
#pragma mark - Action Methods
/**-----------------------------------------------------------------
 Function Name  : handleTapOnContent
 Created By     : Jainesh Patel
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : called when any article has been selected.
 ------------------------------------------------------------------*/
- (void)handleTapOnContent : (id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    UIView *vwTemp = gesture.view;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    
    if (objMainView == nil) {
        DLog(@"[UIApplication sharedApplication].keyWindow.rootViewController (MainViewController) is nil!!");
        return;
    }
    
    if([self.strSelfCurrentContentType isEqualToString:kstrVideo])
    {
        [objMainView.articleDetailMaster PrepareDetailViewForContentType:kCONTENT_TITLE_VIDEO withCurrentArticle:vwTemp.tag];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrLatest])
    {
        [objMainView.articleDetailMaster PrepareDetailViewForContentType:kCONTENT_TITLE_LATEST withCurrentArticle:vwTemp.tag];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrImages])
    {
        [objMainView.articleDetailMaster PrepareDetailViewForContentType:kCONTENT_TITLE_IMAGE withCurrentArticle:vwTemp.tag];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kstrAudio])
    {
        [objMainView.articleDetailMaster PrepareDetailViewForContentType:kCONTENT_TITLE_AUDIO withCurrentArticle:vwTemp.tag];
    }
    else if( [self.strSelfCurrentContentType isEqualToString:kCONTENT_TITLE_SEARCH])
    {
        [objMainView.articleDetailMaster PrepareDetailViewForContentType:kCONTENT_TITLE_SEARCH withCurrentArticle:vwTemp.tag];
    }
    
    [objMainView enableArticleView];
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}
- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [pullToRefreshManager_ relocatePullToRefreshView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isCompleteReload =TRUE;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Reference for MainView
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.mainView = (MainViewController *)window.rootViewController;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/**-----------------------------------------------------------------
 Function Name  : SaveThumbImageToDatabaseForArticle
 Created By     : Arpit Jain
 Created Date   :
 Modified By    :
 Modified Date  :
 Purpose        : Saves the thumbnail images to cache database
 ------------------------------------------------------------------*/

- (void)SaveThumbImageToDatabaseForArticle:(NSUInteger)articleTag
{
    if ([self.strSelfCurrentContentType isEqualToString:kstrLatest])
    {
        NSMutableDictionary *dictCurrentArticle;
        
        if (articleTag == 0)
        {
            // Use Leading Dictionary
            dictCurrentArticle = [[[WebserviceComunication sharedCommManager] dictLeadingNews] mutableCopy];
        }
        else
        {
            // Use Latest array to get currentDictionary
            dictCurrentArticle = [[[[WebserviceComunication sharedCommManager] arrLatestNews] objectAtIndex:articleTag-1] mutableCopy];
        }
        
        UIImage *imgNewImage = [(UIImageView*)[[self.scrlvwContentList viewWithTag:articleTag] viewWithTag:101] image];
        [dictCurrentArticle setObject:UIImagePNGRepresentation(imgNewImage) forKey:kstrImageThumbnailURLData];
        
        [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[dictCurrentArticle mutableCopy]];
        if (articleTag == 0)
        {
            // Use Leading Dictionary
            [[WebserviceComunication sharedCommManager] setDictLeadingNews:[dictCurrentArticle mutableCopy]];
        }
        else
        {
            // Use Latest array to get currentDictionary
            [[[WebserviceComunication sharedCommManager] arrLatestNews] replaceObjectAtIndex:articleTag-1 withObject:[dictCurrentArticle mutableCopy]];
        }
    }
    else if ([self.strSelfCurrentContentType isEqualToString:kstrVideo])
    {
        NSMutableDictionary *dictCurrentArticle;
        dictCurrentArticle = [[[[WebserviceComunication sharedCommManager] arrVideo] objectAtIndex:articleTag] mutableCopy];
        UIImage *imgNewImage = [(UIImageView*)[[self.scrlvwContentList viewWithTag:articleTag] viewWithTag:101] image];
        [dictCurrentArticle setObject:UIImagePNGRepresentation(imgNewImage) forKey:kstrImageThumbnailURLData];
        
        [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[dictCurrentArticle mutableCopy]];
        
        [[[WebserviceComunication sharedCommManager] arrVideo] replaceObjectAtIndex:articleTag withObject:[dictCurrentArticle mutableCopy]];
    }
    else if([self.strSelfCurrentContentType isEqualToString:kstrImages])
    {
        NSMutableDictionary *dictCurrentArticle;
        dictCurrentArticle = [[[[WebserviceComunication sharedCommManager] arrImages] objectAtIndex:articleTag] mutableCopy];
        UIImage *imgNewImage = [(UIImageView*)[[self.scrlvwContentList viewWithTag:articleTag] viewWithTag:101] image];
        [dictCurrentArticle setObject:UIImagePNGRepresentation(imgNewImage) forKey:kstrImageThumbnailURLData];
        
        [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[dictCurrentArticle mutableCopy]];
        
        [[[WebserviceComunication sharedCommManager] arrImages] replaceObjectAtIndex:articleTag withObject:[dictCurrentArticle mutableCopy]];
    }
    else if ([self.strSelfCurrentContentType isEqualToString:kstrAudio])
    {
        NSMutableDictionary *dictCurrentArticle;
        dictCurrentArticle = [[[[WebserviceComunication sharedCommManager] arrAudio] objectAtIndex:articleTag] mutableCopy];
        UIImage *imgNewImage = [(UIImageView*)[[self.scrlvwContentList viewWithTag:articleTag] viewWithTag:101] image];
        [dictCurrentArticle setObject:UIImagePNGRepresentation(imgNewImage) forKey:kstrImageThumbnailURLData];
        
        [[CacheDataManager sharedCacheManager] UpdateContentByArticleId:[dictCurrentArticle mutableCopy]];
        
        [[[WebserviceComunication sharedCommManager] arrAudio] replaceObjectAtIndex:articleTag withObject:[dictCurrentArticle mutableCopy]];
    }
}

/**-----------------------------------------------------------------
 Function Name  : ReloadContentList
 Created By     : Sumit Kumar
 Created Date   : 8-Jun-2013
 Modified By    :
 Modified Date  :
 Purpose        : Reloaded the current content list
 ------------------------------------------------------------------*/

- (void)ReloadContentList
{
    if ([self.strSelfCurrentContentType isEqualToString:kstrLatest])
    {
        [[WebserviceComunication sharedCommManager] resetDictRequestDateFor:kcontentLatest];
        
        [[WebserviceComunication sharedCommManager] setNumPageNoForLatest:0];
        [[[WebserviceComunication sharedCommManager] arrLatestNews] removeAllObjects];
        
        // ONLINE ?
        if([[WebserviceComunication sharedCommManager] isOnline])
        {
            if([[WebserviceComunication sharedCommManager] isInFocus])
            {
                [[WebserviceComunication sharedCommManager] getInFocusNewsInit];
            }
            else
            {
                [[WebserviceComunication sharedCommManager] getLatestNewsInit];
            }
        }
        else
        {
            [[WebserviceComunication sharedCommManager] setArrLatestNews:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kcontentLatest andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrId]]];
        }
    }
    else if ([self.strSelfCurrentContentType isEqualToString:kstrVideo])
    {
        [[WebserviceComunication sharedCommManager] resetDictRequestDateFor:kstrVideo];
        
        [[WebserviceComunication sharedCommManager] setNumPageNoForVideo:0];
        [[[WebserviceComunication sharedCommManager] arrVideo] removeAllObjects];
        
        // ONLINE ?
        if([[WebserviceComunication sharedCommManager] isOnline])
        {
            [[WebserviceComunication sharedCommManager] getVedioInit];
        }
        else
        {
            [[WebserviceComunication sharedCommManager] setArrVideo:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrVideo andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrId]]];
        }
    }
    else if ([self.strSelfCurrentContentType isEqualToString:kstrImages])
    {
        [[WebserviceComunication sharedCommManager] resetDictRequestDateFor:kContentImages];
        
        [[WebserviceComunication sharedCommManager] setNumPageNoForImages:0];
        [[[WebserviceComunication sharedCommManager] arrImages] removeAllObjects];
        
        // ONLINE ?
        if([[WebserviceComunication sharedCommManager] isOnline])
        {
            [[WebserviceComunication sharedCommManager] getImagesInit];
        }
        else
        {
            [[WebserviceComunication sharedCommManager] setArrImages:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kContentImages andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrId]]];
        }
    }
    else if ([self.strSelfCurrentContentType isEqualToString:kstrAudio])
    {
        
        [[WebserviceComunication sharedCommManager] resetDictRequestDateFor:kstrAudio];
        
        [[WebserviceComunication sharedCommManager] setNumPageNoForAudio:0];
        [[[WebserviceComunication sharedCommManager] arrAudio] removeAllObjects];
        
        // ONLINE ?
        if([[WebserviceComunication sharedCommManager] isOnline])
        {
            [[WebserviceComunication sharedCommManager] getAudioInit];
        }
        else
        {
            [[WebserviceComunication sharedCommManager] setArrAudio:[[CacheDataManager sharedCacheManager] getContentsWithContentType:kstrAudio andCategoryId:[[[WebserviceComunication sharedCommManager] dictCurrentCategory] valueForKey:kstrId]]];
        }
    }
}

/**-----------------------------------------------------------------
 Function Name  : dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
 Created By     : Sumit Kumar
 Created Date   : 8-Jun-2013
 Modified By    :
 Modified Date  :
 Purpose        : Calback method for Top Pull to refresh
 ------------------------------------------------------------------*/
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)pRefreshControl
{
    if ([AReachability reachabilityWithHostName:@"htp://www.google.com"] == NO || [[WebserviceComunication sharedCommManager] isOnline] == NO)
    {
        NSString *messageString = @"Unable to refresh content. Check your connection and try again later.";
        [[WebserviceComunication sharedCommManager] showAlert:@"Connection Offline" message:messageString];
        [pRefreshControl endRefreshing];
        return;
    }
    
    
    // WRefresh
    
    // Add Progress View
    isCompleteReload = FALSE;
    
    //[[WebserviceComunication sharedCommManager] addProgressViewWithMessage:kstrPleaseWaitLoadingData];
    [self addProgressViewForRefresh];
    
    //[refreshControl hideActivity]; // To COMBAT the double loader issue Landi doesn't like ... Like a lightsabre
    [self performSelector:@selector(ReloadContentList) withObject:nil afterDelay:0.2];
}

/*
 Dolfies Functions
 */
// So this guys constructs an entire pod item
+ (UIView *)createPod:(float)x
               yValue:(float)y
               wValue:(float)w
               hValue:(float)h
           tagCounter:(int)numTagCounter
          contentItem:(NSMutableArray*)arrContentItem
                index:(int) numIndex
          contentType:(NSString*)strContentType
{
    UIView * podView = [[[UIView alloc] initWithFrame:CGRectMake(x, y, w, h + 10)] autorelease];
    UIImage *imgBackground = [UIImage imageNamed:@"item-white-bg.png"];
    UIImageView *imgVwBackground = [[UIImageView alloc] initWithImage:imgBackground];
    [imgVwBackground setFrame:CGRectMake(0, 0, w, (h + 10))];
    [podView addSubview:imgVwBackground];
    
    // add image
    UIImageView *imageView = [ContentsListViewController createPodImage:w hValue:h imageName:[UIImage imageNamed:kImgNameDefault]];
    [podView addSubview:imageView];
    
    if([strContentType isEqualToString:kstrVideo])
    {
        // add video overlay
        UIImageView *imgVwForButton = [ContentsListViewController createPodImageOverlay:@"btn-play-video.png" imageParent:imageView];
        [podView addSubview:imgVwForButton];
        [imgVwForButton release];
        imgVwBackground = nil;
    }
    
    if([strContentType isEqualToString:kstrAudio])
    {
        // add audio overlay
        UIImageView *imgVwForButton = [ContentsListViewController createPodImageOverlay:@"btn-play-audio.png" imageParent:imageView];
        [podView addSubview:imgVwForButton];
        [imgVwForButton release];
        imgVwBackground = nil;
    }
    
    /// NEW
    NSString *titleString = [[arrContentItem objectAtIndex:numIndex] contentTitle];
    UILabel *Description = [[UILabel alloc]init];
    Description.tag = 99;
    [Description setBackgroundColor:[UIColor clearColor]];
    [Description setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:12.0]];
    [Description setTextColor:[UIColor darkGrayColor]];
    [Description setText:titleString];
    [Description setFrame:CGRectMake(7, (imageView.frame.origin.y + imageView.frame.size.height) - 2, imageView.frame.size.width, 50)];
    [Description setNumberOfLines:2];

    NSString *dateString = [[CommonUtilities sharedManager] formatDateWithTimeDurationFormat:[[arrContentItem objectAtIndex:numIndex] publishDate]];
    UILabel *PublishedTime = [[UILabel alloc]init];
    PublishedTime.tag = 100;
    [PublishedTime setBackgroundColor:[UIColor clearColor]];
    [PublishedTime setFont:[UIFont fontWithName:kFontOpenSansRegular size:11]];
    [PublishedTime setTextColor:[UIColor whiteColor]];
    [PublishedTime setNumberOfLines:1];
    [PublishedTime setText:dateString];
    [PublishedTime setFrame:CGRectMake(10, (Description.frame.origin.y - 20), (Description.frame.size.width - 5), 20)];
    
    // Graident BG
    UIView *txtBackground = [[UIView alloc] initWithFrame:CGRectMake(Description.frame.origin.x, PublishedTime.frame.origin.y, PublishedTime.frame.size.width + 3, PublishedTime.frame.size.height + 2)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = txtBackground.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    [txtBackground.layer insertSublayer:gradient atIndex:0];
    [txtBackground setAlpha:0.75];
    
    [podView addSubview:txtBackground];
    [podView addSubview:Description];
    [podView addSubview:PublishedTime];
    
    if([[arrContentItem objectAtIndex:numIndex] thumbnilImageFile] != nil) {
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:[[arrContentItem objectAtIndex:numIndex] thumbnilImageFile]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        if ([imageData length] > 0) {
            [imageView setImage:[UIImage imageWithData:imageData]];
            [imageData release];
            imageData = nil;
        } else {
            [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
        }
        
        // CLEANUP

        [imgVwBackground release];
        imgVwBackground = nil;
        [imageView release];
        imageView = nil;
        
    } else {
        if([[WebserviceComunication sharedCommManager] isOnline]) {
            NSString *strUrl;
            strUrl = [[NSString alloc]initWithFormat:@"%@",[[arrContentItem objectAtIndex:numIndex] thumbnilImageUrl]];
            dispatch_queue_t myQueue = dispatch_queue_create("SET_IMAGE", NULL);
            dispatch_async(myQueue, ^{
                [imageView setImageAsynchronouslyFromUrl:strUrl animated:YES];
            });
            [strUrl release];
            strUrl = nil;
        } else {
            [imageView setImage:[UIImage imageNamed:kImgNameDefault]];
        }
        
        // CLEANUP
        [imgVwBackground release];
        imgVwBackground = nil;
    }
    
    // CLEANUP
//    [Description release];
//    Description = nil;
//    [gradient release];
//    gradient = nil;
    [txtBackground release];
    txtBackground = nil;
    
    return podView;
}

+ (UIImageView *)createPodImage:(float)w hValue:(float)h imageName:(UIImage *)iName
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(6,6,w-12, h-44)];
    [imageView setTag:101];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    imageView.image = [UIImage imageNamed:kImgNameDefault];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setOpaque:NO];
    return imageView;
}

+ (UIImageView *)createPodImageOverlay:(NSString*)overlayImage imageParent:(UIImageView*)iName
{
    UIImageView *imgVwForButton = [[UIImageView alloc]initWithFrame:iName.frame];
    [imgVwForButton setImage:[UIImage imageNamed:overlayImage]];
    [imgVwForButton setContentMode:UIViewContentModeCenter];
    return imgVwForButton;
}

- (void)RemoveSubviews {
    NSArray *arrSubViewsOfLatest  = [self.scrlvwContentList subviews];
    for (UIView *vw in arrSubViewsOfLatest) {
        [vw removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_ARTICLES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_VIDEOS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_IMAGES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_AUDIO object:nil];
    
    [pullToRefreshManager_ tableViewReloadFinished];
    
    [self.scrlvwContentList scrollRectToVisible:CGRectMake(0, 0, self.scrlvwContentList.frame.size.width, self.scrlvwContentList.frame.size.height) animated:FALSE];
    
    [self removeProgressView];
    [self removeRetryButton];
}

- (void)addProgressViewWithMessage:(NSString *)strMessage
{
    [self removeNoResults];
    
    progressView = [[UIView alloc] initWithFrame:appDelegate.window.frame];
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
    else
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
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:strMessage];
    //[progressView addSubview:titleLabel];
    
    [self.view addSubview:progressView];
}

- (void) addProgressViewForRefresh
{
    [self removeNoResults];
    
    progressView = [[UIView alloc] initWithFrame:appDelegate.window.frame];
	[progressView setBackgroundColor:[UIColor clearColor]];
	[progressView setUserInteractionEnabled:TRUE];
    
    float viewHeight, viewWidth;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         [self.scrlvwContentList setAlpha:0.5f];
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
    [self.view addSubview:progressView];
}

- (void)removeProgressView {
    [progressView removeFromSuperview];
    progressView = nil;
}

- (void) addNoResults:(NSString *)strMessage
{
    [self removeProgressView];
    
    progressView = [[UIView alloc] initWithFrame:appDelegate.window.frame];
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
    else
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
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:strMessage];
    [progressView addSubview:titleLabel];
        
    [self.view addSubview:progressView];
}

-(void) removeNoResults
{
    [progressView removeFromSuperview];
    progressView = nil;
}

-(void)addRetryButton
{    
    [self removeProgressView];
    
    float viewWidth, viewHeight;
    
    viewWidth = appDelegate.window.frame.size.width;
    viewHeight = appDelegate.window.frame.size.height;
    
    retryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [retryButton setFrame:CGRectMake((viewWidth / 2) - 50, (viewHeight / 2) - 45, 100, 30)];
    [retryButton setTitle:@"retry" forState:UIControlStateNormal];
    [UIFont fontWithName:kFontOpenSansSemiBold size:[UIFont systemFontSize]]; // The fr@ck does this do?
    retryButton.titleLabel.font = [UIFont fontWithName:kFontOpenSansSemiBold size:18.0];
    [retryButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [retryButton addTarget:self action:@selector(retryHandler:) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:retryButton];
}

-(void)removeRetryButton
{
    if(retryButton)
    {
        [retryButton removeFromSuperview];
        retryButton = nil;
    }
}

-(IBAction)retryHandler:(id)sender
{
    [self removeRetryButton];
    
    isCompleteReload = FALSE;
    [self addProgressViewWithMessage:@"retrying"];
    [self performSelector:@selector(ReloadContentList) withObject:nil afterDelay:0.2];
}

- (void)setItems:(NSObject *)items errorMessage:(NSString *)message error:(NSError *)error withTag:(int)tag {}

@end
