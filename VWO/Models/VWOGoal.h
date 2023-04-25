//
//  VWOGoal.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GoalType) {
    GoalTypeCustom,
    GoalTypeRevenue
};

@interface VWOGoal : NSObject

@property(nonatomic, assign) int iD;
@property NSString *identifier;
@property (nonatomic, assign) GoalType type;
@property NSString *revenueProp;

- (nullable instancetype)initWithDictionary:(NSDictionary *)goalDict;

@end

NS_ASSUME_NONNULL_END
