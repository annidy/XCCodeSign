//
//  XCCodeSign.m
//  XCCodeSign
//
//  Created by annidyfeng on 15/11/27.
//  Copyright © 2015年 annidyfeng. All rights reserved.
//

#import "XCCodeSign.h"
#import "VVProject.h"

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#pragma mark - 修改MyCodeSign为当前机器上的
static NSString *const MyCodeSign = @"iPhone Developer: jie zhao (BF2E4X5CV7)";

static NSString *const LuaFilePath = @"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/XCCodeSign.xcplugin/Contents/Resources/xcode.lua";

@interface XCCodeSign()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation XCCodeSign

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"CodeSign %@", MyCodeSign]
                                                                action:@selector(doMenuAction)
                                                         keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    VVProject *vp = [VVProject projectForKeyWindow];
    NSString *pbpath = [vp.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xcodeproj/project.pbxproj",vp.projectName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:pbpath]) {
        NSArray *files = [fileManager contentsOfDirectoryAtPath:vp.directoryPath error:nil];
        for (NSString *file in files) {
            if ([[file pathExtension] isEqualToString:@"xcodeproj"]) {
                // process the document
                pbpath = [vp.directoryPath stringByAppendingPathComponent:[file stringByAppendingPathComponent:@"project.pbxproj"]];
                break;
            }
        }
    }
    
    [self luaLoadFile:LuaFilePath.stringByStandardizingPath filename:pbpath codesige:MyCodeSign];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)luaLoadFile:(NSString *)src filename:(NSString *)filename codesige:(NSString *)codesign
{
    if (!filename) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error: pbfile = nil"];
        [alert runModal];
        return;
    }
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    luaL_loadfile(L, [src UTF8String]);
    lua_pushstring(L, [filename UTF8String]);
    lua_setglobal(L, "filename");
    lua_pushstring(L, [codesign UTF8String]);
    lua_setglobal(L, "mycodesign");
    lua_pcall(L,0,0,0);
    lua_close(L);
}

@end
