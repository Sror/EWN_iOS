//
//  PromoTestViewController.h
//  PromoTest
//
//  Created by Ray Wenderlich on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAPIRequest.h"
#import "ImageCell.h"
#import <AudioToolbox/AudioServices.h>
#import "DBRequest.h"
#import "CricketerInfo.h"

@interface PromoTestViewController : UIViewController <WebAPIRequestDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource> 
{
    IBOutlet UIButton *btnXML;
    IBOutlet UIButton *btnJSON;
    IBOutlet UIButton *btnAuth;
    IBOutlet UIButton *btnSAOP;
    
    IBOutlet UITableView *tblImages;
    
    NSMutableArray *arrUser;
    NSMutableArray *arrVideos;
    NSMutableArray *arrImages;
    NSMutableArray *arrMerchants;
    
    WebAPIRequest *webApiRequest; 
}

-(void)addTest;
-(void)getMethod;
-(void)postMethod;
-(void)authentificateUser;
-(void)soapRequest;

-(IBAction)btnXML_Pressed:(id)sender;
-(IBAction)btnJSON_Pressed:(id)sender;
-(IBAction)btnAuth_Pressed:(id)sender;
-(IBAction)btnSAOP_Pressed:(id)sender;

-(void)showAlertView:(NSString *)title withMessage:(NSString *)message withTag:(int)tag;

@end