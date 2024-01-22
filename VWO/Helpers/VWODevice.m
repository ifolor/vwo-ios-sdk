//
//  VWODevice.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VWODevice.h"
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@implementation VWODevice

/// Tells if the Device is connected to Xcode
/// Taken from https://github.com/plausiblelabs/plcrashreporter/blob/2dd862ce049e6f43feb355308dfc710f3af54c4d/Source/Crash%20Demo/main.m#L96
+ (BOOL)isAttachedToDebugger {

    static BOOL debuggerIsAttached = NO;

    static dispatch_once_t debuggerPredicate;
    dispatch_once(&debuggerPredicate, ^{
        struct kinfo_proc info;
        size_t info_size = sizeof(info);
        int name[4];

        name[0] = CTL_KERN;
        name[1] = KERN_PROC;
        name[2] = KERN_PROC_PID;
        name[3] = getpid();

        if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
            debuggerIsAttached = false;
        }

        if (!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
            debuggerIsAttached = true;
    });

    return debuggerIsAttached;
}

+ (VWOAppleDeviceType)appleDeviceType {
#if TARGET_OS_IPHONE
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return VWOAppleDeviceTypeIPhone;
    }
#endif
    return VWOAppleDeviceTypeIPad;
}

+ (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    return deviceModel;
}

+ (NSString *)userName {
#if TARGET_OS_IPHONE
    return UIDevice.currentDevice.name;
#endif
    return @"macOS";
}

+ (NSString *)iOSVersion {
#if TARGET_OS_IPHONE
    return UIDevice.currentDevice.systemVersion;
#endif
    return @"";
}

+ (int)screenWidth {
#if TARGET_OS_IPHONE
    return UIScreen.mainScreen.bounds.size.width;
#endif
    return 393;
}

+(int)screenHeight {
#if TARGET_OS_IPHONE
    return UIScreen.mainScreen.bounds.size.height;
#endif
    return 852;
}

@end
