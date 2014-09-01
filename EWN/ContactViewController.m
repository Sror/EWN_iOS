//
//  ContactViewController.m
//  EWN
//
//  Created by Dolfie on 2013/12/03.
//
//

#import "ContactViewController.h"

#import "MainViewController.h"

@interface ContactViewController () <UIScrollViewDelegate, ContactFeedbackViewControllerDelegate>

@end




@implementation ContactViewController

@synthesize tableArray;

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
    
    self.tableArray = [[NSMutableArray alloc] init];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self addEntry:kTypeEmail Label:@"Newsdesk" Value:@"news@ewn.co.za"];
    [self addEntry:kTypeEmail Label:@"News Editor" Value:@"editor@ewn.co.za"];
    [self addEntry:kTypeEmail Label:@"Traffic Desk" Value:@"traffic@ewn.co.za"];
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.scrollView setFrame:CGRectMake(7, 12, 305, 490)];
    [self.scrollView setContentSize:CGSizeMake(300, 490)];
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    [self.scrollView setAlwaysBounceVertical:YES];
    self.scrollView.delegate = self;
    
    [self.scrollView addSubview:self.tableView];
    [self.view addSubview:self.scrollView];
    
    ////////////////////////////////////////////////////////////////////////////////////
    // ACCORDION - Configure
    ////////////////////////////////////////////////////////////////////////////////////
    
    posZeroY = 120;
    headingHeight = 40;
    
    int posY = posZeroY;
    
    // Section 1
    self.sectionOne = [[ContactSectionViewController alloc] init];
    [self.sectionOne.view setFrame:CGRectMake(0, posY, self.sectionOne.view.frame.size.width, self.sectionOne.view.frame.size.height)];
    [self.sectionOne setSectionId:1];
    [self.sectionOne setZeroY:posZeroY];
    [self.sectionOne.titleLabel setText:@"Contact details"];
    [self.sectionOne.button addTarget:self action:@selector(sectionHandler:) forControlEvents:UIControlEventTouchUpInside];

    // Section 1 - View
    self.contactDetails = [[ContactDetailsViewController alloc] init];
    [self.contactDetails.view setFrame:CGRectMake(0, posY + headingHeight, self.contactDetails.view.frame.size.width, self.contactDetails.view.frame.size.height)];
    [self.contactDetails.view setClipsToBounds:YES];
    [self.scrollView insertSubview:self.contactDetails.view belowSubview:self.sectionOne.view];
    [self.contactDetails build];
    
    [self.sectionOne setSectionView:self.contactDetails.view];
    
    posY += headingHeight;
    
    // Section 2
    self.sectionTwo = [[ContactSectionViewController alloc] init];
    [self.sectionTwo.view setFrame:CGRectMake(0, posY, self.sectionTwo.view.frame.size.width, self.sectionTwo.view.frame.size.height)];
    [self.sectionTwo setSectionId:2];
    [self.sectionTwo setZeroY:posZeroY];
    [self.sectionTwo.titleLabel setText:@"Social media"];
    [self.sectionTwo.button addTarget:self action:@selector(sectionHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    // Section 2 - View
    self.socialMedia = [[ContactSocialMediaViewController alloc] init];
    [self.socialMedia.view setFrame:CGRectMake(0, posY + headingHeight, self.socialMedia.view.frame.size.width, self.socialMedia.view.frame.size.height)];
    [self.socialMedia.view setClipsToBounds:YES];
    [self.scrollView insertSubview:self.socialMedia.view belowSubview:self.sectionTwo.view];
    [self.socialMedia build];
    
    [self.sectionTwo setSectionView:self.socialMedia.view];
    
    posY += headingHeight;
    
    // Section 3
    self.sectionThree = [[ContactSectionViewController alloc] init];
    [self.sectionThree.view setFrame:CGRectMake(0, posY, self.sectionThree.view.frame.size.width, self.sectionThree.view.frame.size.height)];
    [self.sectionThree setSectionId:3];
    [self.sectionThree setZeroY:posZeroY];
    [self.sectionThree.titleLabel setText:@"Feedback"];
    [self.sectionThree.button addTarget:self action:@selector(sectionHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    // Section 3 - View
    self.feedback = [[ContactFeedbackViewController alloc] initWithNibName:@"ContactFeedbackViewController" bundle:nil];
    self.feedback.delegate = self;
    [self.feedback.view setFrame:CGRectMake(0, posY + headingHeight, self.feedback.view.frame.size.width, self.feedback.view.frame.size.height)];
    [self.feedback.view setClipsToBounds:YES];
    [self.scrollView insertSubview:self.feedback.view belowSubview:self.sectionThree.view];
    
    [self.sectionThree setSectionView:self.feedback.view];
    
    [self.scrollView addSubview:self.sectionOne.view];
    [self.scrollView addSubview:self.sectionTwo.view];
    [self.scrollView addSubview:self.sectionThree.view];
    
    [self.sectionOne config];
    [self.sectionTwo config];
    [self.sectionThree config];
    
    self.sectionArray = [[NSArray alloc] initWithObjects:self.sectionOne, self.sectionTwo, self.sectionThree, nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSectionToTop) name:@"SCROLL_CONTACT_TO_CURRENT" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addEntry:(NSString *)type Label:(NSString *)label Value:(NSString *)value
{
    NSArray *entries = [NSArray arrayWithObjects:type, label, value, nil];
    NSArray *keys    = [NSArray arrayWithObjects:@"type", @"label", @"value", nil];
    
    NSDictionary *newDick = [NSDictionary dictionaryWithObjects:entries forKeys:keys];
    [self.tableArray addObject:newDick];
}

- (void)sectionHandler:(id)sender
{
    if ([self.feedback.feedbackText isFirstResponder]) {
        [self.feedback.feedbackText resignFirstResponder];
        return;
    }
    
    if([[[sender nextResponder] nextResponder] isKindOfClass:[ContactSectionViewController class]])
    {
        // Update ScrollView's height
        int newHeight = 120; // this will be the tableview's height
        ContactSectionViewController *section = (ContactSectionViewController *)[[sender nextResponder] nextResponder];
        
        int sectionId = (int)[section sectionId];
        
        if(currentSection == sectionId)
        {
            currentSection = ([self.sectionArray count] + 1); // Forces all to close
        }
        else
        {
           currentSection = sectionId;
        }
        
        for(int i = 0; i < [self.sectionArray count]; i++)
        {
            ContactSectionViewController *_section = [self.sectionArray objectAtIndex:i];
            
            // Reset the position of all Sections less than or equal to current Section, and offset remainder.
            if([_section sectionId] <= currentSection)
            {
                [_section resetPosition:NO];
            }
            else
            {
                [_section resetPosition:NO];
                [_section setPosition:section.sectionFrame.size.height];
            }
        
            // Set current Section's visibility and update scrollView's height
            if(([_section sectionId] == currentSection))
            {
                [_section toggle:YES];
                newHeight += _section.sectionView.frame.size.height;
            }
            else
            {
                [_section toggle:NO];
            }
            
            newHeight += _section.view.frame.size.height;
        }
        
        newHeight += 216; // Some padding for keyboard, which has height = 216px
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, newHeight)];
    }
}

-(void) currentSectionToTop {
    int yPoint = 0;
    
    if (1 == currentSection) {
        yPoint = self.sectionOne.view.frame.origin.y;
    } else if (2 == currentSection) {
        yPoint = self.sectionTwo.view.frame.origin.y;
    }
    
    CGPoint newPos = CGPointMake(0,yPoint);
    [UIView animateWithDuration: 0.3f
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.scrollView.contentOffset = newPos;
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

// ==============================================================================================================================
// TABLE METHODS
// ==============================================================================================================================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *tempDick = [self.tableArray objectAtIndex:(int)indexPath.row];
    
    if (cell == nil)
    {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setImage:[tempDick objectForKey:@"type"]];
    [cell.label setText:[tempDick objectForKey:@"label"]];
    [cell setOptionValue:[tempDick objectForKey:@"value"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dick = [self.tableArray objectAtIndex:(int)indexPath.row];
    NSString *type = [dick objectForKey:@"type"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MainViewController *objMainView = (MainViewController *)window.rootViewController;
    
    if([kTypeEmail isEqualToString:type])
    {
        [objMainView openEmailComposer:[dick objectForKey:@"value"]];
        
    }
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.feedback.feedbackText isFirstResponder]) {
        [self.feedback.feedbackText resignFirstResponder];
    }
}


#pragma mark - ContactFeedbackViewControllerDelegate Methods

- (void)textView:(ContactFeedbackViewController *)target firstResponder:(BOOL)isFirstResponder
{
    if (isFirstResponder)
    {
        [self.scrollView setContentOffset:CGPointMake(0.0f, self.scrollView.contentSize.height - self.scrollView.frame.size.height) animated:YES];
    }
}


#pragma mark - Memory Management Methods

- (void)dealloc
{
    [self.tableArray dealloc];
    [self.sectionArray dealloc];
    
    [self.sectionOne dealloc];
    [self.sectionTwo dealloc];
    [self.sectionThree dealloc];
    
    [self.contactDetails dealloc];
    [self.socialMedia dealloc];
    [self.feedback dealloc];
    [super dealloc];
}

@end
