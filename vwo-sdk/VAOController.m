//
//  VAOController.m
//  VAO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOController.h"
#import "VAOModel.h"
#import "VAOAPIClient.h"
#import "VAOSocketClient.h"
#import "VAOGoogleAnalytics.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include "VAOSDKInfo.h"
#import "VAOLogger.h"
#import "VAOPersistantStore.h"
#import "VWOSegmentEvaluator.h"

static const NSTimeInterval kMinUpdateTimeGap = 60*60; // seconds in 1 hour

@implementation VAOController {
    BOOL _remoteDataDownloading;
    NSTimeInterval _lastUpdateTime;
    NSMutableDictionary *previewInfo; // holds the set of changes to be used during preview mode
    NSMutableDictionary *customVariables;
}

+ (void)initializeAsynchronously:(BOOL)async
                    withCallback:(void (^)(void))completionBlock
                         failure:(void (^)(void))failureBlock {
    [VAOPersistantStore incrementSessionCount];
    [[VAOAPIClient sharedInstance] initializeAndStartTimer];
    [[self sharedInstance] downloadCampaignAsynchronously:async withCallback:completionBlock failure:failureBlock];
    [[self sharedInstance] addBackgroundListeners];
}

-(void)addBackgroundListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground)
                               name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForeground)
                               name:UIApplicationWillEnterForegroundNotification object:nil];
}

+ (instancetype)sharedInstance{
    static VAOController *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _remoteDataDownloading = NO;
        _lastUpdateTime = 0;
        self.previewMode = NO;
        customVariables = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setCustomVariable:(NSString *)variable withValue:(NSString *)value {
    VAOLogInfo(@"Setting %@ = %@", variable, value);
    VAOModel.sharedInstance.customVariables[variable] = value;
}

- (void)applicationDidEnterBackground {
    if(!self.previewMode) {
        _lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
        [[VAOAPIClient sharedInstance] stopTimer];
    }
}

- (void)applicationWillEnterForeground {
    [[VAOAPIClient sharedInstance] startTimer];
    if(_remoteDataDownloading == NO) {
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        if(currentTime - _lastUpdateTime < kMinUpdateTimeGap){
            return;
        }
        [self downloadCampaignAsynchronously:YES withCallback:nil failure:nil];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSString *) campaignInfoPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOCampaignInfo.plist"];
}

- (void)downloadCampaignAsynchronously:(BOOL)async
                          withCallback:(void (^)(void))completionBlock
                               failure:(void (^)(void))failureBlock {
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    _remoteDataDownloading = YES;

    [[VAOAPIClient sharedInstance] pullABDataAsynchronously:async success:^(id responseObject) {
        _lastUpdateTime = currentTime;
        _remoteDataDownloading = NO;
        VAOLogInfo(@"%lu campaigns received", (unsigned long)[(NSArray *) responseObject count]);
        [(NSArray *) responseObject writeToFile:[VAOController campaignInfoPath] atomically:YES];
        [[VAOModel sharedInstance] updateCampaignListFromDictionary:responseObject];
        if (completionBlock) completionBlock();
    } failure:^(NSError *error) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[VAOController campaignInfoPath]]) {
            VAOLogWarning(@"Network failed {%@}", error.localizedDescription);
            VAOLogInfo(@"LOADING CACHED RESPONSE");
            NSArray *cachedCampaings = [NSArray arrayWithContentsOfFile:[VAOController campaignInfoPath]];
            [VAOModel.sharedInstance updateCampaignListFromDictionary:cachedCampaings];
        } else {
            VAOLogWarning(@"Campaigns fetch failed. Cache not available {%@}", error.localizedDescription);
            if (failureBlock) failureBlock();
        }
    }];
}

/**
 * This replaces the _meta with the passed in changes
 * In preview mode, we only provide the preview changes and do not provide meta of currently running experiments
 */
- (void)preview:(NSDictionary *)changes {
    previewInfo = changes[@"json"];
}

- (void)markConversionForGoal:(NSString*)goalIdentifier withValue:(NSNumber*)value {
    
    if (self.previewMode) {
        [[VAOSocketClient sharedInstance] goalTriggeredWithName:goalIdentifier];
        return;
    }
    
    //Check if the goal is already marked
    NSArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];
    for (VAOCampaign *campaign in campaignList) {
        VAOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {
            if ([VAOPersistantStore isGoalMarked:matchedGoal]) {
                VAOLogInfo(@"%@ already marked", matchedGoal);
                return;
            }
        }
    }
    
    for (VAOCampaign *campaign in campaignList) {
        if ([VAOPersistantStore isTrackingUserForCampaign:campaign]) {
            VAOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
            if (matchedGoal) {
                [[VAOModel sharedInstance] markGoalConversion:matchedGoal inCampaign:campaign withValue:value];
            }
        }
    }
}

- (id)variationForKey:(NSString*)key {
    if (self.previewMode) {
        if(key && previewInfo) {
            return previewInfo[key];
        }
        return nil;
    }
    
    NSMutableArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];

    for (VAOCampaign *campaign in campaignList) {
        id variation = [campaign variationForKey:key];
        if (variation) { //If variation Key is present in Campaign
            if ([VAOPersistantStore isTrackingUserForCampaign:campaign]) {
                // already tracking
                return [variation copy];
            } else {
                // check for segmentation
                if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:campaign.segmentObject]) {
                    [[VAOModel sharedInstance] trackUserForCampaign:campaign];
                    return [variation copy];
                }
            }
        }
    }
    return nil;
}

@end
