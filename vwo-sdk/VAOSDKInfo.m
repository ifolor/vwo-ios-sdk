//
//  VAOSDKInfo.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VAOSDKInfo.h"
#import "VAOPersistantStore.h"

static NSString *appKey;
static NSString *accountId;

@implementation VAOSDKInfo

+ (NSString *)sdkVersion {
    //TODO: Put it in persistent storage or plist
    return @"1.5.0";
}

+ (void)setAppKeyID:(NSString *) key {
    NSArray<NSString *> *separatedArray = [key componentsSeparatedByString:@"-"];
    if ([separatedArray count] != 2) {
        //TODO: Log Error - invalid key
        return;
    }
    appKey = separatedArray[0];
    accountId = separatedArray[1];
    [VAOPersistantStore incrementSessionCount];
}

+ (NSString *)appKey {
    return appKey;
}

+ (NSString *)accountID {
    return accountId;
}

@end
