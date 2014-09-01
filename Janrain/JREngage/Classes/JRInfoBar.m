/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2010, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
     list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation and/or
     other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
     contributors may be used to endorse or promote products derived from this
     software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 File:   JRInfoBar.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import "JRInfoBar.h"
#import "debug_log.h"
#import "JRUserInterfaceMaestro.h"

@implementation JRInfoBar

- (id)initWithFrame:(CGRect)frame andStyle:(JRInfoBarStyle)style
{
    if ((self = [super initWithFrame:frame]))
    {
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;

        iPad = style / 2;
        hidesPoweredBy = style % 2;
        y_origin_hidden = self.frame.origin.y + height;

        if (hidesPoweredBy)
            [self setFrame:CGRectMake(self.frame.origin.x, y_origin_hidden, width, height)];

        barBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        barBackground.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        barBackground.autoresizingMask = UIViewAutoresizingNone | UIViewAutoresizingFlexibleWidth;

        poweredByLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/2, 0, width/2 - 30, height)];
        poweredByLabel.backgroundColor = [UIColor clearColor];
        poweredByLabel.font = [UIFont italicSystemFontOfSize:(iPad) ? 30.0 : 13.0];
        poweredByLabel.textColor = [UIColor whiteColor];
        poweredByLabel.textAlignment = NSTextAlignmentRight;
        poweredByLabel.autoresizingMask = UIViewAutoresizingNone | UIViewAutoresizingFlexibleLeftMargin;

        poweredByLabel.text = (hidesPoweredBy) ? @"" : @"Powered by Janrain";

        infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        infoButton.frame = CGRectMake(width - 20, 7, 15, 15);
        infoButton.autoresizingMask = UIViewAutoresizingNone | UIViewAutoresizingFlexibleLeftMargin;

        [infoButton addTarget:self
                       action:@selector(showInfo:)
             forControlEvents:UIControlEventTouchUpInside];

        if (iPad)
            spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(15, 15, 42, 42)];
        else
            spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];

        spinner.activityIndicatorViewStyle = (iPad) ? UIActivityIndicatorViewStyleWhiteLarge : UIActivityIndicatorViewStyleWhite;
        spinner.autoresizingMask = UIViewAutoresizingNone | UIViewAutoresizingFlexibleRightMargin;

        if (iPad)
            loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 300, height)];
        else
            loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, 0, 130, 30)];

        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.font = [UIFont systemFontOfSize:(iPad) ? 30.0 : 13.0];
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.textAlignment = JR_TEXT_ALIGN_LEFT;
        loadingLabel.autoresizingMask = UIViewAutoresizingNone | UIViewAutoresizingFlexibleRightMargin;
        loadingLabel.text = @"Loading...";

        [self addSubview:barBackground];
        [self addSubview:poweredByLabel];
        [self addSubview:infoButton];
        [self addSubview:spinner];
        [self addSubview:loadingLabel];

        spinner.alpha = 0.0;
        loadingLabel.alpha = 0.0;

        self.alpha = 0.9;

        [self setAutoresizingMask:UIViewAutoresizingNone | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    }

    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (!iPad)
    {
        [UIView beginAnimations:@"fade" context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        self.alpha = 0.8;
        [UIView commitAnimations];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (!iPad)
    {
        [UIView beginAnimations:@"fade" context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        self.alpha = 0.0;
        [UIView commitAnimations];
    }
}

- (void)showInfo:(id <UIActionSheetDelegate>)delegate
{
    [[JRInfoBar getInfoSheet:self] showInView:self.superview];
}

+ (UIActionSheet *)getInfoSheet:(id <UIActionSheetDelegate>)delegate
{
    DLog(@"");

    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:
                                                    [[[NSBundle mainBundle] resourcePath]
                                                            stringByAppendingPathComponent:@"/JREngage-Info.plist"]];

    // todo don't use this key, since this isn't actually a CFBundleShortVersionString value, it's just a string we
    // stick a Janrain release version number in.
    NSString *version = [infoPlist objectForKey:@"CFBundleShortVersionString"];

    version = [version stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *verString = [NSString stringWithFormat:
                                            @"Janrain Engage for iPhone Library\nVersion %@\nwww.janrain.com", version];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:verString
                                                              delegate:delegate
                                                     cancelButtonTitle:@"OK"
                                                destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    return actionSheet;
}

- (void)startProgress
{
    [spinner startAnimating];

    if (hidesPoweredBy)
    {
        [UIView beginAnimations:@"show" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.0];
        [self setFrame:CGRectMake(self.frame.origin.x, (y_origin_hidden - self.frame.size.height), self.frame.size.width, self.frame.size.height)];
        [UIView commitAnimations];
    }

    [UIView beginAnimations:@"fade" context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelay:(hidesPoweredBy) ? 0.3 : 0.0];
    spinner.alpha = 1.0;
    loadingLabel.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)stopProgress
{
    [spinner stopAnimating];

    [UIView beginAnimations:@"fade" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.1];
    spinner.alpha = 0.0;
    loadingLabel.alpha = 0.0;
    [UIView commitAnimations];

    if (hidesPoweredBy)
    {
        [UIView beginAnimations:@"show" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.9];
        [self setFrame:CGRectMake(self.frame.origin.x, y_origin_hidden, self.frame.size.width, self.frame.size.height)];
        [UIView commitAnimations];
    }
}


@end
