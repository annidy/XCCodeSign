//
//  XCCodeSign.h
//  XCCodeSign
//
//  Created by annidyfeng on 15/11/27.
//  Copyright © 2015年 annidyfeng. All rights reserved.
//

#import <AppKit/AppKit.h>

@class XCCodeSign;

static XCCodeSign *sharedPlugin;

@interface XCCodeSign : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end