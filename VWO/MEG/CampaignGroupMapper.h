//
//  CampaignGroupMapper.h
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface MEGCampaignGroupMapper : NSObject

+ (NSDictionary *)getCampaignGroups: (NSDictionary *)jsonObject;
+ (NSDictionary *)createAndGetGroups: (NSDictionary *)jsonObject;
+ (void)preparePriority: (NSDictionary *)source destination:(MEGGroup *)destination;
+ (void)prepareEt:(NSDictionary *)source destination:(MEGGroup *)destination;
+ (void)prepareCampaigns:(NSDictionary *)source destination:(MEGGroup *)destination;
+ (void)prepareWeight:(NSDictionary *)source destination:(MEGGroup *)destination;
+ (NSDictionary *)getGroups: (NSDictionary *)jsonObject;

@end

NS_ASSUME_NONNULL_END
