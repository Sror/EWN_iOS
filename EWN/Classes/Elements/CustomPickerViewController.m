//
//  CustomPickerViewController.m
//  EWN
//
//  Created by Wayne Langman on 2013/10/22.
//
//

#import "CustomPickerViewController.h"

@interface CustomPickerViewController ()

@end

@implementation CustomPickerViewController

@synthesize textField;
@synthesize dataArray;
@synthesize itemSelected;

+(id)sharedInstance {
    static CustomPickerViewController *sharedCustomPicker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCustomPicker = [[self alloc] init];
    });
    return sharedCustomPicker;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        itemSelected = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self.toolBar setFrame:CGRectMake(0, 0, self.toolBar.frame.size.width, self.toolBar.frame.size.height)];
    [self.pickerView setFrame:CGRectMake(0, self.toolBar.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height)];
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.toolBar.frame.size.height + self.pickerView.frame.size.height))];
    
    [self.doneButton setTarget:self];
    [self.doneButton setAction:@selector(doneHandler:)];
    
    if ((long)itemSelected >= [dataArray count]) {
        itemSelected = (int*)0;
    }
    [self.pickerView selectRow:(long)itemSelected inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneHandler:(id)sender
{
    if(self.textField)
    {
        [self.textField endEditing:YES];
    }
}

/* PICK DELEGATE METHODS */

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [dataArray count];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    int tmp = row;
    itemSelected = (NSInteger*)tmp;
    [self.textField setText:[dataArray objectAtIndex:row]];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [dataArray objectAtIndex:row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.0f;
}

-(void)dealloc
{
    [self.textField release];
    [self.dataArray release];
    [super dealloc];
}

@end
