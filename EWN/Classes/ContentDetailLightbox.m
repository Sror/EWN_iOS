//
//  ContentDetailLightbox.m
//  EWN
//
//  Created by Dolfie Jay on 2014/04/22.
//
//

#import "ContentDetailLightbox.h"

@implementation ContentDetailLightbox

@synthesize imageView;
@synthesize imageViewDefaultFrame;
@synthesize scrolly;
@synthesize sizeFrame;
@synthesize titleBackground;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)display:(NSString *) filePath title:(NSString *) titleString {
    [self setBackgroundColor:[UIColor clearColor]];
	[self setUserInteractionEnabled:TRUE];
    
    sizeFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    // Transparent Background
    UIView *background = [[UIView alloc] initWithFrame:sizeFrame];
    // Make a little bit of the superView show through
    [background setBackgroundColor:[UIColor whiteColor]];
    background.alpha = 0.9;
    [self addSubview:background];
    
    // Image View
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:imageData];
    
    imageView = [[UIImageView alloc] init];
    [imageView setUserInteractionEnabled:YES];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    imageViewDefaultFrame = CGRectMake(3, 3, self.frame.size.width - 6, self.frame.size.height - 6);
    [imageView setFrame:imageViewDefaultFrame];
    [imageView setImage:image];
    
    UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(resetImageZoom)] autorelease];
    doubleTap.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:doubleTap];
    
    CGSize newSize = [self imageSizeAfterAspectFit:imageView];
    float labelY = (imageView.frame.origin.y + imageView.frame.size.height) - ((imageView.frame.size.height - newSize.height) / 2);
    float closeButtonY = imageView.frame.origin.y + ((imageView.frame.size.height - newSize.height) / 2);
    
    // Scroll View
    scrolly = [[UIScrollView alloc] init];
    [scrolly setDelegate:self];
    
    [scrolly setFrame:sizeFrame];
    [scrolly setContentSize:self.frame.size];
    
    scrolly.minimumZoomScale=1;
    scrolly.maximumZoomScale=6.0;
    [self addSubview:scrolly];

    [scrolly addSubview:imageView];
    
    // Title Label
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel setNumberOfLines:0];
    [titleLabel setText:titleString];
    [titleLabel setFont:[UIFont fontWithName:kFontOpenSansRegular size:13.0]];
    [titleLabel setFrame:CGRectMake(3, 5, self.frame.size.width - 6, titleLabel.frame.size.height)];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(3, 5, self.frame.size.width - 6, titleLabel.frame.size.height)];
    
    // Title background
    titleBackground = [[UIView alloc] init];
    int backgroundHeight = titleLabel.frame.size.height + 10;
    [titleBackground setUserInteractionEnabled:NO];
    [titleBackground setBackgroundColor:[UIColor blackColor]];
    [titleBackground setAlpha:0.7];
    [titleBackground setFrame:CGRectMake(3, labelY - backgroundHeight, self.frame.size.width - 6, backgroundHeight)];
    
    [self addSubview:titleBackground];
    [self.titleBackground addSubview:titleLabel];
    
    // Close Button
    float closeContainerHeight = 40;
    float closeContainerWidth = 44;
    closeButtonY -= closeContainerHeight;
    closeButtonY -= 30; // spacing above the image
    if (closeButtonY < 20) {
        closeButtonY = 20;
    }
    
    UIView *closeContainer = [[UIView alloc] init];
    [closeContainer setBackgroundColor:[UIColor clearColor]];
    [closeContainer setFrame:CGRectMake(self.frame.size.width - closeContainerWidth, closeButtonY, closeContainerWidth, closeContainerHeight)];
    [self addSubview:closeContainer];
    
    UIView *closeContainerAlpha = [[UIView alloc] init];
    [closeContainer setBackgroundColor:[UIColor blackColor]];
    [closeContainer setAlpha:0.7];
    [closeContainer setFrame:CGRectMake(self.frame.size.width - closeContainerWidth, closeButtonY, closeContainerWidth, closeContainerHeight)];
    [self addSubview:closeContainerAlpha];
    
    [closeContainer setUserInteractionEnabled:YES];
    UITapGestureRecognizer *closeHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [closeContainer addGestureRecognizer:closeHandler];
    
    UIImageView *closeImage = [[UIImageView alloc] init];
    float crossSize = 16;
    [closeImage setContentMode:UIViewContentModeScaleAspectFit];
    [closeImage setImage:[UIImage imageNamed:@"fullscreen_img_close_btn.png"]];
    float closeImageX = self.frame.size.width - closeContainerWidth + ((closeContainerWidth - crossSize) / 2);
    float closeImageY = closeButtonY + ((closeContainerHeight - crossSize) / 2);
    [closeImage setFrame:CGRectMake(closeImageX, closeImageY, crossSize, crossSize)];
    [self addSubview:closeImage];
    [closeImage setUserInteractionEnabled:NO];
}

- (void)resetImageZoom {
    [UIView animateWithDuration:0.5 animations:^{
        [imageView setFrame:imageViewDefaultFrame];
        [titleBackground setAlpha:0.7];
        [scrolly setFrame:sizeFrame];
        [scrolly setContentSize:sizeFrame.size];
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *tmpScroll = (UIScrollView *) self.superview;
            [tmpScroll setScrollEnabled:YES];
        }
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [UIView animateWithDuration:0.5 animations:^{
        [titleBackground setAlpha:0.0];
    }];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    if (scale == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            [titleBackground setAlpha:0.7];
        }];
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *tmpScroll = (UIScrollView *) self.superview;
            [tmpScroll setScrollEnabled:YES];
        }
    } else {
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *tmpScroll = (UIScrollView *) self.superview;
            [tmpScroll setScrollEnabled:NO];
        }
    }
    
    float y = 0;
    if (scrolly.frame.size.height >= scrolly.contentSize.height) {
        y = (scrolly.frame.size.height / 2) - (scrolly.contentSize.height / 2);
    }
    
    [imageView setFrame:CGRectMake(imageView.frame.origin.x, y - 1, imageView.frame.size.width, imageView.frame.size.height)];
    
    if (scrolly.frame.size.height < scrolly.contentSize.height) {
        CGFloat newContentOffsetX = (scrolly.contentSize.width/2) - (scrolly.bounds.size.width/2);
        CGFloat newContentOffsetY = (scrolly.contentSize.height/2) - (scrolly.bounds.size.height/2);
        CGPoint pointy = CGPointMake(newContentOffsetX, newContentOffsetY);
        [scrolly setContentOffset:pointy animated:YES];
    }
}

-(IBAction)tapHandler:(id)sender {
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[self.superview layer] addAnimation:animation forKey:@"layerAnimation"];
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview removeFromSuperview];
    } else {
        [self removeFromSuperview];
    }
}

-(CGSize)imageSizeAfterAspectFit:(UIImageView*)imgview{    
    float newwidth;
    float newheight;
    
    UIImage *image = imgview.image;
    
    newwidth = imgview.frame.size.width;
    newheight = (image.size.height / image.size.width) * newwidth;
    
    if(newheight > imgview.frame.size.height){
        float diff = imgview.frame.size.height - newheight;
        newwidth = newwidth+diff / newwidth * newwidth;
        newheight = imgview.frame.size.height;
    }
    
    return CGSizeMake(newwidth, newheight);
}

-(void)dealloc {
    [self.imageView release];
    [self.scrolly release];
    [self.titleBackground release];
    [super dealloc];
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
