
/*------------------------------------------------------------------------
 File Name: WebAPIRequest.h
 Created By: Pratik Prajapati
 Created Date: 23-Nov-2012
 Last Modified on: 19-Dec-2012
 Purpose: Common class for Web-service calls and Parsing of its 
          response, no matter type of response. (XML/JSON)
 -------------------------------------------------------------------------*/

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <Foundation/NSJSONSerialization.h> 
#import <QuartzCore/QuartzCore.h>
#import "JSONKit.h"
#import "Contents.h"

# define XML 1
# define JSON 2

# define _IOS_VERSION_MIN_REQUIRED_NSJON 5.0

/*---------------------------------------------------------------------------
 *                            AsyncImageView                                *
 *--------------------------------------------------------------------------*/

@interface UIImageView (AsyncImageView)

-(void)setImageAsynchronouslyFromUrl:(NSString *)imageUrl animated:(BOOL)isAnimated;
-(void)setImageAsynchronouslyFromUrl:(NSString *)imageUrl animated:(BOOL)isAnimated article:(Contents *)article;

@end


/*---------------------------------------------------------------------------
 *                          WebAPIRequestDelegate                           *
 *--------------------------------------------------------------------------*/

@class WebAPIRequest; // Forward Declaration

@protocol WebAPIRequestDelegate <NSObject>

@optional // @required
// Post data back to the caller class with tag of request and error message if any.
-(void)setItems:(NSObject *)items errorMessage:(NSString *)message error:(NSError *)error withTag:(int)tag;
-(void)setProgess:(CGFloat)progress withTag:(int)tag;
-(void)requestCancel:(NSObject *)items errorMessage:(NSString *)message withTag:(int)tag;
-(void)errorHandler:(NSString *)errorType title:(NSString *)errorTitle error:(NSError *)error message:(NSString *)errorMessage;

-(void)gotURLCheckingResponse: (ASIHTTPRequest *)response;

@optional

@end

/*---------------------------------------------------------------------------
 *                          XMLReaderNavigation                             *
 *--------------------------------------------------------------------------*/

@interface NSDictionary (XMLReaderNavigation)

// Accepts path of object seperated by '.' we want to filter from NSDictionary and enumerates it. 
- (id)retrieveForPath:(NSString *)navPath;

@end

/*---------------------------------------------------------------------------
 *                         WebRequestActivityView                           *
 *--------------------------------------------------------------------------*/

@interface WebRequestActivityView : UIView

// The View in which the Activity view will be added.
@property (nonatomic, strong) UIView *originalView;

// The view to contain the activity indicator and label. This will be bezel style which has a semi-transparent rounded rectangle.
@property (nonatomic, strong) UIView *borderView;

// Whether to show the network activity indicator in the status bar. Set to YES if the activity is network-related. This can be toggled on and off as desired while the activity view is visible (e.g. have it on while fetching data, then disable it while parsing it).
@property (nonatomic) BOOL showNetworkActivityIndicator;

// The activity indicator view.
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

// The activity label.
@property (nonatomic, strong) UILabel *activityLabel;

// A fixed width for the label text, or zero to automatically calculate the text size.
@property (nonatomic) NSUInteger labelWidth;


// Returns the currently displayed Activity view, or nil if there isn't any.
+ (WebRequestActivityView *)currentActivityView;

// Creates an instance of 'WebRequestActivityView' interface and calls constructor which initializes a View in which we want to add Loading view, Text and Width of label.
+ (WebRequestActivityView *)activityViewForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;

// Constructor which configures the Activity view having Background view, Bordered view, Label using the specified label text and width and Loading indicator. Adds this Activity view as a subview of the specified view with covering keyboard.
- (WebRequestActivityView *)initForView:(UIView *)addToView withLabel:(NSString *)labelText width:(NSUInteger)aLabelWidth;

// Immediately removes and releases the Activity view without any animation.
+ (void)removeView;

- (UIView *)viewForView:(UIView *)view;
- (CGRect)enclosingFrame;
- (void)setupBackground;
- (UIView *)makeBorderView;
- (UIActivityIndicatorView *)makeActivityIndicator;
- (UILabel *)makeActivityLabelWithText:(NSString *)labelText;
- (void)animateShow;
- (void)animateRemove;

@end

/*---------------------------------------------------------------------------
 *                             WebAPIRequest                                *
 *--------------------------------------------------------------------------*/

@interface WebAPIRequest : NSObject <NSXMLParserDelegate>
{
    int              requestTag;
    NSString         *strMessage;
    
    int              responseType;
    id               dataObject;
    
	NSObject         *callerClass;
    NSError          *errorPointer;
    
    NSMutableArray   *dictionaryStack;
    NSMutableString  *textInProgress;
    
    BOOL             userAuthRequired;
    BOOL             setKeychainPersistence; 
    BOOL             setSessionPersistence;
    BOOL             responseParsingDone;
    
    ASIHTTPRequest   *WebRequestAuth;
    NSMutableArray   *requestArray;
}

@property (readwrite) int requestTag;
@property (nonatomic, retain) NSString *strMessage;
@property (readwrite) BOOL userAuthRequired;
@property (nonatomic, retain) NSMutableArray *requestArray;

@property (nonatomic, assign) id <WebAPIRequestDelegate> delegate;

@property NSUInteger timerCount;

-(void)showIndicatorWithText:(NSString *)text;
-(void)hideIndicator;
-(void)parseResponse:(NSData *)dataResponse;
+(NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error;

// Constructor which sets Delegate object of current class. So that we can callback to that class when perticular event is done.
-(id)initWithDelegate:(id)aDelegate;

// Creates URL request using ASIFormDataRequest.'Get' in this case so we do not have to pass any parameter.
-(void)webRequestWithUrl:(NSURL *)url;

// Creates URL request using ASIFormDataRequest.'Post' in this case so we have to pass a Dictionary having all post parameters as 'key' and parameters values as 'value'.
-(void)webRequestWithUrl:(NSURL *)url withPostValues:(NSDictionary *)postDic;

// Accepts the Authentification Challange.
-(void)webRequestWithUrl:(NSURL *)url withUserName:(NSString *)userName withPassWord:(NSString *)passWord;

// Creates SOAP based request using ASIFormDataRequest. Accepts SOAP message and name of the Action to perform.
-(void)webRequestWithUrl:(NSURL *)url withSoapMessage:(NSString *)soapMessage withSoapAction:(NSString *)soapAction;

// Creates Asynchronous SOAP based request using ASIFormDataRequest. Accepts SOAP message and name of the Action to perform based on the Section.
// NOTE - This gets re-used in WebserviceCommunication
-(void)webAsyncRequestWithUrl:(NSURL *)url withSoapMessage:(NSString *)soapMessage withSoapAction:(NSString *)soapAction withTimeout:(BOOL)withTimeout;

-(void)webAsyncRequestWithUrl:(NSURL *)url
              withSoapMessage:(NSString *)soapMessage
               withSoapAction:(NSString *)soapAction
                  withTimeout:(BOOL)withTimeout
                   completion:(void (^)(BOOL successful, NSError *error, NSData *data))completion;

-(void)requestCancel;

-(void)requestTimerCreate;
-(void)requestTimerUpdate:(NSTimer *)timer;

@end
