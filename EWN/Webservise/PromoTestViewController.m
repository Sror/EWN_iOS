//
//  PromoTestViewController.m
//  PromoTest
//
//  Created by Ray Wenderlich on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PromoTestViewController.h"

@implementation PromoTestViewController

# pragma mark
# pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];  
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    //[self addTest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


# pragma mark
# pragma mark - Other implementation

-(void)addTest
{
    /*---------------------------------------------------------------------------
     *                                Static                                    *
     *--------------------------------------------------------------------------*/
    
    DBRequest *dbRequest = [[DBRequest alloc]init];
    NSManagedObjectContext *context = dbRequest.managedObjectContext;
    
    CricketerInfo *crickInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CricketerInfo" inManagedObjectContext:context];
    crickInfo.no = [NSNumber numberWithInt:1];
    crickInfo.name = @"Pratik Prajapati";
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    /*---------------------------------------------------------------------------
     *                                Custom                                    *
     *--------------------------------------------------------------------------*/
    
    NSDictionary *dicValues = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInteger:2], @"Sumit", nil] forKeys:[NSArray arrayWithObjects:@"no", @"name", nil]];
    [dbRequest databaseRequestWithInsertForEntity:@"CricketerInfo" withValues:dicValues];
    
    /*---------------------------------------------------------------------------
     *                                Print                                     *
     *--------------------------------------------------------------------------*/
    
    // Test listing from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CricketerInfo"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for (CricketerInfo *info in fetchedObjects)
    {
        NSLog(@"=========================");
        NSLog(@"No:%d",[info.no intValue]);
        NSLog(@"Name: %@",info.name);
        NSLog(@"=========================");
    }
}

-(IBAction)btnJSON_Pressed:(id)sender
{
    [self getMethod];
}

-(IBAction)btnXML_Pressed:(id)sender
{
    [self postMethod];
}

-(IBAction)btnAuth_Pressed:(id)sender
{
    [self authentificateUser];
}

-(IBAction)btnSAOP_Pressed:(id)sender
{
    [self soapRequest];
}


-(void)getMethod
{
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kLearnwiseRequest; // Optional
    webApiRequest.strMessage = @"Please wait for JSON..., This is extra text, more extra this is"; // Optional
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:NSLocalizedStringFromTable(@"getURL",@"WebServices",@"")]];
}

-(void)postMethod
{
    NSDictionary *dicPost = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"mvv", @"1", nil] forKeys:[NSArray arrayWithObjects:@"sec", @"page", nil]]; // Optional

    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kAmritbaniRequest; // Optional
    webApiRequest.strMessage = @"Please wait for XML..."; // Optional
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:NSLocalizedStringFromTable(@"postURL",@"WebServices",@"")] withPostValues:dicPost];
}

-(void)authentificateUser
{
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kAuthentification; // Optional
    webApiRequest.strMessage = @"Authentificating..."; // Optional
    webApiRequest.userAuthRequired = TRUE; // Optional
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:NSLocalizedStringFromTable(@"authentificationURL",@"WebServices",@"")] withUserName:@"pizero" withPassWord:@"elite276"];
}

-(void)soapRequest
{
    webApiRequest = [[WebAPIRequest alloc]initWithDelegate:self];
    webApiRequest.requestTag = kNearerMerchants; // Optional
    webApiRequest.strMessage = @"Please wait for SOAP..."; // Optional
    [webApiRequest webRequestWithUrl:[NSURL URLWithString:NSLocalizedStringFromTable(@"soapURL",@"WebServices",@"")] withSoapMessage:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetAllMerchantGPSDetails xmlns=\"http://tempuri.org/\" /></soap:Body></soap:Envelope>" withSoapAction:@"http://tempuri.org/GetAllMerchantGPSDetails"];
}

-(void)setItems:(NSObject *)items errorMessage:(NSString *)message withTag:(int)tag
{
    // Remove the current request.
    [webApiRequest release];
    webApiRequest = nil;
    
    // This is how you can identify request.
    if(tag==kLearnwiseRequest){
        NSLog(@"kLearnwiseRequest");
    }
    
    else if(tag==kAmritbaniRequest) {
        NSLog(@"kAmritbaniRequest");
    }
    
    else if(tag==kAuthentification){
        NSLog(@"kAuthentification");
    }
    
    else if(tag==kNearerMerchants){
        NSLog(@"kNearerMerchants");
    }
    
    if([message length]==0)
    {
        if([items isKindOfClass:[NSArray class]]){
            NSArray *jsonArray = (NSArray *)items;
            NSLog(@"%@",jsonArray);
        }
        else{
            NSDictionary *jsonDictionary = (NSDictionary *)items;
            NSLog(@"%@",jsonDictionary);
        }
    }
    
    else
    {
        [self showAlertView:message  withMessage:nil withTag:tag];
    }
    
    /*--------------------------------------------------------------------------*
     *                              Filtering Data                               *
     *--------------------------------------------------------------------------*/
    
    if(tag==kLearnwiseRequest)
    {
        arrUser = [(NSMutableArray *)items retain];
    }
    
    else if(tag==kAmritbaniRequest) 
    {
        NSDictionary *dicVideos = [(NSDictionary *)items retain];
        arrVideos = [dicVideos retrieveForPath:@"Videos.Video"];
    }
    
    else if(tag==kAuthentification) 
    {
        NSDictionary *dicImages = [(NSDictionary *)items retain];
        arrImages = [dicImages retrieveForPath:@"images.image"];
    }
    
    else if(tag==kNearerMerchants) 
    {
        NSDictionary *dicMerchants = [(NSDictionary *)items retain];
        arrMerchants = [dicMerchants retrieveForPath:@"soap:Envelope.soap:Body.GetAllMerchantGPSDetailsResponse.GetAllMerchantGPSDetailsResult.GPSMerchantValues"];
    }
    
    NSLog(@"%@",[arrUser description]);
    NSLog(@"%@",[arrVideos description]);
    NSLog(@"%@",[arrImages description]);
    NSLog(@"%@",[arrMerchants description]);
    
    [tblImages reloadData];
}


# pragma mark
# pragma mark - UITableView Delegate,Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([arrVideos count]>0)
        return [arrVideos count];
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
    
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) 
    {
        cell = [[[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        NSString *urlImage = [[arrVideos objectAtIndex:indexPath.row]objectForKey:@"AssetImage"];
        [cell.imgView setImageAsynchronouslyFromUrl:urlImage animated:TRUE];
    }
    
    // Configure the cell...
    if([arrVideos count]>0)
        cell.lblImageUrl.text = [[arrVideos objectAtIndex:indexPath.row]objectForKey:@"AssetName"];
    else
        cell.textLabel.text = @"Image to Load";

    return cell;
}


# pragma mark
# pragma mark - UIAlerview Delegate Methods

-(void)showAlertView:(NSString *)title withMessage:(NSString *)message withTag:(int)tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.tag = tag;
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


# pragma mark
# pragma mark - Memory management

- (void)dealloc
{
    [arrUser release];
    [arrVideos release];
    [arrImages release];
    [arrMerchants release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
