//
//  main.m
//  EWN
//
//  Created by Macmini on 17/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

//// DELETE THESE
//
//typedef int (*PYStdWriter)(void *, const char *, int);
//static PYStdWriter _oldStdWrite;
//
//// DELETE
//int __pyStderrWrite(void *inFD, const char *buffer, int size) {
//    if ( strncmp(buffer, "AssertMacros:", 13) == 0 )
//        return 0;
//    
//    return _oldStdWrite(inFD, buffer, size);
//}
//
//// DELETE
//void __iOS7B5CleanConsoleOutput(void) {
//    _oldStdWrite = stderr->_write;
//    stderr->_write = __pyStderrWrite;
//}



int main(int argc, char *argv[])
{
//    __iOS7B5CleanConsoleOutput(); // DELETE
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}