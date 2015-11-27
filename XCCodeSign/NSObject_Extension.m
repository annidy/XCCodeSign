//
//  NSObject_Extension.m
//  XCCodeSign
//
//  Created by annidyfeng on 15/11/27.
//  Copyright © 2015年 annidyfeng. All rights reserved.
//


#import "NSObject_Extension.h"
#import "XCCodeSign.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[XCCodeSign alloc] initWithBundle:plugin];
        });
    }
}
@end
