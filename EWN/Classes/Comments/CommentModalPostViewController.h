//
//  CommentModalPostViewController.h
//  EWN
//
//  Created by Dolfie Jay on 2013/12/03.
//
//

#import <UIKit/UIKit.h>

@class EWNButton;

@interface CommentModalPostViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *closeBtn;
@property (nonatomic, strong) IBOutlet EWNButton *submitBtn;
@property (nonatomic, strong) IBOutlet UIView *modalView;
@property (nonatomic, strong) IBOutlet UITextView *commentTextView;
// article id for commenting
@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

-(void)close:(id)sender;
-(void)submitButtonHandler:(EWNButton *)sender;
-(NSString *)userIdReturn;
-(NSString *)trimWhitespace:(NSString *)stringToTrim;

@end
