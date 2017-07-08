//
//  VAOCampaign.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>
#import "VAOGoal.h"
#import "VAOVariation.h"

typedef NS_ENUM(NSInteger, CampaignStatus) {
    CampaignStatusRunning,
    CampaignStatusExcluded
};

@interface VAOCampaign : NSObject

@property (nonatomic, assign) int id;
@property (atomic) NSString *name;
@property (nonatomic, assign) BOOL trackUserOnLaunch;
@property (nonatomic, assign) CampaignStatus status;
@property VAOVariation *variation;
@property NSArray<VAOGoal *> *goals;
@property NSDictionary *segmentObjects;

- (instancetype)initWithDictionary:(NSDictionary *) campaignDict;

@end
