//
//  UIAlertView+Extended.h
//
//  Created by Andre Gomes on 2013/10/09.
//  Copyright (c) 2013 PrezenceDigital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Extended)

+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
