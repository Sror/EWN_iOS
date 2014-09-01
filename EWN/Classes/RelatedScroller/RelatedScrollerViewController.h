//
//  RelatedScrollerViewController.h
//  EWN
//
//  Created by Wayne Langman on 2013/10/23.
//
//

#import <UIKit/UIKit.h>

@interface RelatedScrollerViewController : UIViewController <WebAPIRequestDelegate>
{
    WebAPIRequest *objWebAPIRequest;
    CGPoint prvContOff;
    MPMoviePlayerViewController *theMovie;
    NSURL *urlFile;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *articles;
@property (nonatomic, strong) CustomAlertView *alrtvwReachable;

-(void)update:(NSString *)articleId;

+ (UIView *)createPod:(float)x
               yValue:(float)y
               wValue:(float)w
               hValue:(float)h
           tagCounter:(int)numTagCounter
          contentItem:(NSMutableArray*)arrContentItem
                index:(int) numIndex
          contentType:(NSString*)strContentType;

+ (UIImageView *)createPodImage:(float)w hValue:(float)h imageName:(UIImage *)iName;

+ (UIImageView *)createPodImageOverlay:(NSString*)overlayImage imageParent:(UIImageView*)iName;

@end
