//
//  ContextOptionViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/03.
//
//

#import "ContextMenuViewController.h"
#import "ContextOptionViewController.h"


@interface ContextOptionViewController ()

@end




@implementation ContextOptionViewController

@synthesize activityIndicatorView;
@synthesize background;
@synthesize separator;
@synthesize optionIcon;
@synthesize optionTitle;
@synthesize commentCount;
@synthesize noImageStates;


#pragma mark - GETTERS

- (UIActivityIndicatorView *) activityIndicatorView
{
    if (!activityIndicatorView) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.hidesWhenStopped = YES;
        activityIndicatorView.transform = CGAffineTransformMakeScale(0.55, 0.55); // We scale down the indicator as we cant adjust its internal frames.
    }
    return activityIndicatorView;
}

-(UILabel *)commentCount
{
    if(!commentCount)
    {
        commentCount = [[UILabel alloc] init];
        
        [commentCount addSubview:self.activityIndicatorView];
    }
    return commentCount;
}

- (id)initWithTitle:(NSString *)title
{
    if (self = [super init])
    {
        [self setOptionType:title];
        
        NSString *tempPath = [[NSString alloc] init];
        
        /* IMAGE PATH */
        tempPath = @"icon_";
        tempPath = [tempPath stringByAppendingString:self.optionType];
        imagePath = [[NSBundle mainBundle] pathForResource:tempPath ofType:@"png"];
        
        /* IMAGE ROLL PATH */
        tempPath = @"icon_";
        tempPath = [tempPath stringByAppendingString:self.optionType];
        tempPath = [tempPath stringByAppendingString:@"_down"];
        imageRollPath = [[NSBundle mainBundle] pathForResource:tempPath ofType:@"png"];
        
        noImageStates = NO;
    }
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    initFrame = CGRectMake(0, 0, 45, 45);
    [self.view setFrame:initFrame];
    
    self.background = [[UIView alloc] init];
    [self.background setFrame:initFrame];
    [self.background setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.background];
    
    self.separator = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]] autorelease]; // This gets reused, so why not ...
    [self.separator setFrame:CGRectMake(0, 0, 2, self.background.frame.size.height)];
    [self.view addSubview:self.separator];
    
    self.upImage = [[[UIImage alloc] initWithContentsOfFile:imagePath] autorelease];
    self.downImage = [[[UIImage alloc] initWithContentsOfFile:imageRollPath] autorelease];
    
    
    self.optionIcon = [[UIImageView alloc] init];
    [self.optionIcon setImage:self.upImage];
    [self.optionIcon setFrame:CGRectMake(10, 5, 25, 25)]; // Temp Size
    [self.view addSubview:self.optionIcon];
    
    
    self.optionTitle = [[UILabel alloc] init];
    [self.optionTitle setFrame:CGRectMake(0, (initFrame.size.height - 13), initFrame.size.width, 10)];
    [self.optionTitle setText:[[self optionType] uppercaseString]];
    [self.optionTitle setTextColor:[UIColor whiteColor]];
    [self.optionTitle setTextAlignment:NSTextAlignmentCenter];
    [self.optionTitle setBackgroundColor:[UIColor clearColor]];
    [self.optionTitle setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:6.0]];
    [self.view addSubview:self.optionTitle];
    
    // Comment
    if([self.optionType isEqualToString:@"comments"])
    {
        self.commentCount.backgroundColor = [UIColor clearColor];
        [self.commentCount setFrame:CGRectMake(0, (initFrame.size.height / 2) - 17, initFrame.size.width, 20)];
        [self.commentCount setTextColor:[UIColor darkGrayColor]];
        [self.commentCount setFont:[UIFont fontWithName:kFontOpenSansSemiBold size:9.0]];
        [self.commentCount setTextAlignment:NSTextAlignmentCenter];
        [self.commentCount setText:@"0"];
        [self.view addSubview:self.commentCount];
        
        self.activityIndicatorView.frame = CGRectMake((self.commentCount.frame.size.width - activityIndicatorView.frame.size.width) / 2,
                                                      (self.commentCount.frame.size.height - activityIndicatorView.frame.size.height) / 2,
                                                      activityIndicatorView.frame.size.width,
                                                      activityIndicatorView.frame.size.height);
    }
}

-(void)setImageIcon:(NSString*)imageUrl {
    [self.optionIcon setImageAsynchronouslyFromUrl:imageUrl animated:YES];
    noImageStates = YES;
}

-(void)setPosition:(int)index
{
    CGRect posFrame = CGRectMake(0, 0, 45, 45);
    posFrame.origin.x = posFrame.size.width * index;
    [self.view setFrame:posFrame];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!noImageStates) {
        [self.optionIcon setImage:self.downImage];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (!noImageStates) {
        [self.optionIcon setImage:self.upImage];
    }
    // Either Notifications, or consider just passing a reference to ContextMenuViewController when initialising in said ViewController ... ?
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CONTEXT_OPTION_SELECTED" object:[self optionType]];
}

-(void)dealloc
{
    [self.background release];
    [self.separator release];
    [self.optionIcon release];
    [self.optionTitle release];
    [self.upImage release];
    [self.downImage release];
    [self.optionType release];
    [self.commentCount release];
    [super dealloc];
}

@end
