//
//  VWOController.h
//  VWO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWOCampaignFetcher.h"
#import "VWO.h"

@class VWOSegmentEvaluator, VWOUserDefaults;

NS_ASSUME_NONNULL_BEGIN
//latest version
static NSString *kVWOSDKversion = @"2.18.1";

@class VWOConfig;

@interface VWOController : NSObject

@property NSString *accountID;
@property NSString *appKey;

/// All the operations in controller are expected to happen on taskQueue queue
@property (class, readonly) dispatch_queue_t taskQueue;
@property NSMutableDictionary<NSString *, NSString *> *customVariables;
@property NSDictionary *previewInfo;
@property (getter=isInitialised) BOOL initialised;

+ (instancetype)shared;

- (void)launchWithAPIKey:(NSString *)apiKey
              config:(nullable VWOConfig *)config
             withTimeout:(nullable NSNumber *)timeout
            withCallback:(nullable void(^)(void))completionBlock
                 failure:(nullable void(^)(NSString *))failureBlock;

- (void)trackConversion:(NSString *)goal withValue:(nullable NSNumber *)value;
- (nullable id)variationForKey:(NSString *)key;
- (nullable id)variationForKey:(NSString *)key testKey:(NSString *)testKey;
- (VWOCampaignArray *)getCampaignData;
-(NSString *) getUserId;
- (nullable NSString *)variationNameForCampaignTestKey:(NSString *)campaignTestKey;
- (void)pushCustomDimension:(NSString *) customDimensionKey withCustomDimensionValue:(NSString *) customDimensionValue;
- (void)pushCustomDimension:(NSMutableDictionary<NSString *, id> *)customDimensionDictionary;

#pragma mark - Ifolor Additions

@property (atomic, weak) NSObject<VWODelegate> *delegate;
- (nullable VWOCampaign *)campaignForKey:(NSString *)key;
- (BOOL)isUserTrackedInCampaign:(NSString *)campaignKey;
- (void)flushRequestQueue;
- (BOOL)isGoal:(NSString *)goal markedInCampaign:(NSString *)campaignKey;

@end

NS_ASSUME_NONNULL_END
