//
//  VAOSDKInfo.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VAOSDKInfo.h"

static NSString *appKey;
static NSString *accountId;

@implementation VAOSDKInfo

+ (NSString *)sdkVersion {
    //TODO: Put it in persistent storage or plist
    return @"2.0.0-beta5";
}

+ (void)setAppKeyID:(NSString *) key {
    NSArray<NSString *> *separatedArray = [key componentsSeparatedByString:@"-"];
    [self validateAPIKey:key];

    appKey = separatedArray[0];
    accountId = separatedArray[1];
}

///Key must be in format `[32Chars]-[NUMS]`
+ (void)validateAPIKey:(NSString * )apiKey {
    NSAssert([apiKey componentsSeparatedByString:@"-"].count == 2, @"Invalid key");
    NSAssert([apiKey componentsSeparatedByString:@"-"].firstObject.length == 32, @"Invalid key");
}

+ (NSString *)appKey {
    return appKey;
}

+ (NSString *)accountID {
    return accountId;
}

@end
