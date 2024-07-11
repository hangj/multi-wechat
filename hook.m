#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


@interface NSObject (WeChatHook)
+ (void)hookWeChat;
@end

@interface AboutWindowController : NSWindowController
@property(retain, nonatomic) NSTextField* textField;
@end

@implementation AboutWindowController
@end


static int argc = 1;
static char** argv = 0;
static int is_hooked = 0;


// Common Function Attributes
// https://gcc.gnu.org/onlinedocs/gcc-6.2.0/gcc/Common-Function-Attributes.html
__attribute__((constructor))
static void init(int _argc, char** _argv) {
    argc = _argc;
    argv = _argv;

    [NSObject hookWeChat];

}

__attribute__((destructor))
static void drop() {}

// https://github.com/MustangYM/WeChatExtension-ForMac/blob/develope/WeChatExtension/WeChatExtension/Sources/Helper/YMSwizzledHelper.m
void hookMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(swizzledClass, swizzledSelector);
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@implementation NSObject (WeChatHook)

+ (void)hookWeChat {
    if(is_hooked) {
        return;
    }
    is_hooked = 1;


    // Class cls = NSClassFromString(@"QRCodeLoginCGI");
    // Class cls = objc_getClass("QRCodeLoginCGI");

    // 多开
    hookClassMethod(objc_getClass("NSRunningApplication"), @selector(runningApplicationsWithBundleIdentifier:), [self class], @selector(hook_runningApplicationsWithBundleIdentifier:));
    hookMethod(objc_getClass("AppDelegate"), @selector(applicationDockMenu:), [self class], @selector(hook_applicationDockMenu:));
    hookMethod(objc_getClass("AppDelegate"), @selector(applicationDidFinishLaunching:), [self class], @selector(hook_applicationDidFinishLaunching:));

    // crash handler
    hookMethod(objc_getClass("MMSafeModeService"), @selector(shouldShowSafeMode), [self class], @selector(hook_shouldShowSafeMode));
    hookMethod(objc_getClass("MMSafeModeService"), @selector(addCrash), [self class], @selector(hook_addCrash));
    hookMethod(objc_getClass("MMSafeModeService"), @selector(saveData), [self class], @selector(hook_saveData));
    hookMethod(objc_getClass("KSCrash"), @selector(setOnCrash:), [self class], @selector(hook_emptySet:));
    hookMethod(objc_getClass("KSCrash"), @selector(setOnHandleSignalCallBack:), [self class], @selector(hook_emptySet:));


    // crash report
    hookMethod(objc_getClass("WCCrashReporter"), @selector(uploadCrash), [self class], @selector(hook_uploadCrash));
    hookMethod(objc_getClass("WCCrashBlockMonitorPlugin"), @selector(reportCrash), [self class], @selector(hook_reportCrash));
    hookMethod(objc_getClass("KSCrash"), @selector(sendReports:onCompletion:), [self class], @selector(hook_sendReports:onCompletion:));
    hookMethod(objc_getClass("KSCrash"), @selector(reportUserException:reason:language:lineOfCode:stackTrace:logAllThreads:enableSnapshot:terminateProgram:writeCpuUsage:dumpFilePath:dumpType:), [self class], @selector(hook_reportUserException:reason:language:lineOfCode:stackTrace:logAllThreads:enableSnapshot:terminateProgram:writeCpuUsage:dumpFilePath:dumpType:));
    hookMethod(objc_getClass("KSCrash"), @selector(sendAllReportsWithCompletion:), [self class], @selector(hook_sendAllReportsWithCompletion:));
    hookMethod(objc_getClass("MMSafeModeService"), @selector(uploadLog), [self class], @selector(hook_uploadLog));
    hookMethod(objc_getClass("MMAppLogUploader"), @selector(uploadLog:), [self class], @selector(hook_uploadLog:));
    hookMethod(objc_getClass("MMLogUploader"), @selector(uploadLog:), [self class], @selector(hook_uploadLog:));
    hookMethod(objc_getClass("MMCovLogUploader"), @selector(uploadLog:), [self class], @selector(hook_uploadLog:));

    // 检查第三方 dylib
    // Expt MMExptOldImpl.mm:-[MMExptOldImpl getStringExpt:] INFO: [10094]expt API got expt result[WeChatTweak,WeChatExtension,WeChatPlugin,WeChatSeptet,libtrld_trlib.dylib] exptId[4260079] key[clicfg_mac_third_party_image_list] cost[0]
    hookMethod(objc_getClass("MMExptOldImpl"), @selector(getStringExpt:), [self class], @selector(hook_getStringExpt:));
    hookMethod(objc_getClass("MMSafeModeService"), @selector(detect), [self class], @selector(hook_detect));
    hookMethod(objc_getClass("MMSafeModeService"), @selector(binaryImages), [self class], @selector(hook_binaryImages));
    hookMethod(objc_getClass("MMSafeModeService"), @selector(setBinaryImages), [self class], @selector(hook_setBinaryImages));
}


-(BOOL)hook_shouldShowSafeMode {
    return FALSE;
}

-(void)hook_addCrash:(id)arg1 {  }
-(void)hook_saveData{}
-(void)hook_uploadLog{}
-(void)hook_uploadLog:(id)arg1{  }
-(void)hook_uploadCrash {}
-(void)hook_reportCrash {}
-(void)hook_detect {}
-(void)hook_emptySet:(id)arg{}
-(void)hook_sendReports:(id)arg1 onCompletion:(id)arg2 {
    [self performSelector:@selector(deleteAllReports)];
}
-(void)hook_reportUserException:(id)arg1 reason:(id)arg2 language:(id)arg3 lineOfCode:(id)arg4 stackTrace:(id)arg5 logAllThreads:(id)arg6 enableSnapshot:(id)arg7 terminateProgram:(id)arg8 writeCpuUsage:(id)arg9 dumpFilePath:(id)arg10 dumpType:(id)arg11 {
    [self performSelector:@selector(deleteAllReports)];
}
-(void)hook_sendAllReportsWithCompletion:(id)arg{
    [self performSelector:@selector(deleteAllReports)];
}


-(void)hook_reportWithProtocalID:(int)arg1 message:(id)msg {}


+ (NSArray<NSRunningApplication *> *)hook_runningApplicationsWithBundleIdentifier:(NSString *)bundleIdentifier {
    NSArray<NSRunningApplication *> *ret = [self hook_runningApplicationsWithBundleIdentifier:bundleIdentifier];
    if ([bundleIdentifier isEqualToString:NSBundle.mainBundle.bundleIdentifier] && ret.count > 0) {
        return @[ret.firstObject]; // @[NSRunningApplication.currentApplication]; // @[];
    }
    return ret;
}

- (NSMenu *)hook_applicationDockMenu:(NSApplication *)sender {
    NSMenu *menu = [self hook_applicationDockMenu:sender];
    NSMenuItem *menuItem = ({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: @"登录新的微信" action:@selector(openNewWeChatInstace:) keyEquivalent:@""];
        item.tag = 9527;
        item;
    });

    // __block makes the blocks keep a reference to the variable (call-by-reference).
    __block BOOL added = NO;
    [menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 9527) {
            *stop = added = YES;
        }
    }];
    if (!added) {
        [menu insertItem:menuItem atIndex:0];
    }
    return menu;
}

- (NSString*)hook_getStringExpt:(id)arg1 {
    NSString* ret = [self hook_getStringExpt:arg1];
    if (![arg1 containsString:@"clicfg_mac_third_party_image_list"])
        return ret;

    NSArray<NSString *> * arr = [ret componentsSeparatedByString:@","];
    NSMutableArray<NSString*>* mut = [NSMutableArray arrayWithCapacity: arr.count];

    for(id s in arr){
        if ([s containsString:@"multi-wechat"])
            continue;
        [mut addObject:s];
    }

    ret = [mut componentsJoinedByString:@","];

    return ret;
}


- (void)openNewWeChatInstace:(id)sender {
    NSString *applicationPath = NSBundle.mainBundle.bundlePath;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/open";

    task.arguments = ({
        const char* dyld_insert_libs = getenv("DYLD_INSERT_LIBRARIES");
        int nparams = dyld_insert_libs == NULL ? argc + 2 : argc + 4;

        NSMutableArray<NSString*> *arguments = [NSMutableArray arrayWithCapacity: nparams];
        [arguments addObject:@"-n"];
        if (dyld_insert_libs) {
            [arguments addObject:@"--env"];
            [arguments addObject:[[NSString alloc] initWithFormat:@"DYLD_INSERT_LIBRARIES=%s", dyld_insert_libs]];
        }
        [arguments addObject:applicationPath];

        [arguments addObject:@"--args"];
        for (int i=1; i < argc; i++) {
            [arguments addObject:[[NSString alloc] initWithFormat:@"%s", argv[i]]];
        }

        arguments;
    });

    [task launch];
    [task waitUntilExit];
}


-(void)hook_applicationDidFinishLaunching:(id)arg {
    NSMenuItem *newlogin = ({
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: @"登录新的微信" action:@selector(openNewWeChatInstace:) keyEquivalent:@""];
        item.state = NSControlStateValueOff;
        item;
    });

    NSMenuItem* about = [[NSMenuItem alloc] initWithTitle:@"about" action:@selector(aboutThisHelper:) keyEquivalent:@""];
    about.state = NSControlStateValueOff; // NSControlStateValueOn; NSControlStateValueOff; NSControlStateValueMixed;


    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"WeCode"];
    [subMenu addItem:newlogin];
    [subMenu addItem:about];

    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setSubmenu:subMenu];

    [[[NSApplication sharedApplication] mainMenu] addItem:menuItem];

    [self hook_applicationDidFinishLaunching:arg];
}

-(void)aboutThisHelper:(NSMenuItem*)item {
    static char dummy;

    id wechat = [objc_getClass("WeChat") sharedInstance];
    AboutWindowController *about = objc_getAssociatedObject(wechat, &dummy);

    if (!about) {
        NSSize screenSize = [NSScreen mainScreen].frame.size;
        NSSize windowSize = NSMakeSize(600, 300);

        // https://stackoverflow.com/a/11010614/1936057
        NSWindow* window = [
            [[NSWindow alloc]
                initWithContentRect:NSMakeRect(screenSize.width/2 - windowSize.width/2, screenSize.height/2 - windowSize.height/2, windowSize.width, windowSize.height)
                styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
                backing:NSBackingStoreBuffered
                defer:NO]
            autorelease
            ];

        // [window cascadeTopLeftFromPoint:NSMakePoint(100, 100)];
        [window setTitle:@"WeCode"];
        [window makeKeyAndOrderFront:nil];
        [window center];

        NSTextField *myTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,100)];
        myTextField.stringValue = @"Hello World";
        myTextField.alignment = NSTextAlignmentLeft;
        window.contentView = myTextField;
        // [window.contentView addSubview:myTextField];

        about = [[AboutWindowController alloc] initWithWindow:window];
        about.textField = myTextField;
        objc_setAssociatedObject(wechat, &dummy, about, OBJC_ASSOCIATION_RETAIN);
    }

    about.textField.stringValue = [NSString
        stringWithFormat:
            @"author: %s\n\n"
            @"github: %s\n\n",

            "hangj",
            "https://github.com/hangj/multi-wechat"
        ];
    [about showWindow:nil];
}

@end
