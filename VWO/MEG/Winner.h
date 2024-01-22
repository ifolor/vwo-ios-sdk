//
//  Winner.h
//  Pods
//
//  Created by Harsh Raghav on 05/05/23.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"
#import "Pair.h"

@interface MEGWinner : NSObject

@property (nonatomic, copy) NSString *user;

- (MEGWinner *)fromJSONObject:(NSDictionary *)jsonObject;
- (void)addMapping:(MEGMapping *)mapping;
- (NSDictionary *)getJSONObject;
- (MEGPair *)getRemarkForUserArgs:(MEGMapping *)mapping args:(NSDictionary<NSString *, NSString *> *)args;

@end
