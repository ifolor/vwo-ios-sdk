//
//  Winner.m
//  VWO
//
//  Created by Harsh Raghav on 05/05/23.
//

#import <Foundation/Foundation.h>
#import "VWOConstants.h"
#import "Winner.h"
#import "Pair.h"
#import "Mapping.h"
#import "VWOLogger.h"

@implementation MEGWinner
NSString *user;

NSMutableArray<MEGMapping *> *mappings;

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialize private properties
        mappings = [NSMutableArray array];
    }
    return self;
}

- (MEGWinner *)fromJSONObject:(NSDictionary *)jsonObject {
    MEGWinner *winner = [[MEGWinner alloc] init];
    
    @try {
        winner.user = [jsonObject objectForKey:KEY_USER];
        mappings = [[NSMutableArray alloc] init];
        
        NSArray *jMappings = [jsonObject objectForKey:KEY_MAPPING];
        NSInteger jMappingSize = jMappings.count;
        for (int i = 0; i < jMappingSize; i++) {
            NSDictionary *jMapping = [jMappings objectAtIndex:i];
            
            MEGMapping *_mapping = [[MEGMapping alloc] init];
            _mapping.testKey = [jMapping objectForKey:KEY_TEST_KEY];
            _mapping.group = [jMapping objectForKey:KEY_GROUP];
            _mapping.winnerCampaign = [jMapping objectForKey:KEY_WINNER_CAMPAIGN];

            [mappings addObject:_mapping];
        }
    } @catch (NSException *exception) {
        // Handle the exception
        VWOLogDebug(@"MutuallyExclusive  %@", exception);
    }
    
    return winner;
}

- (void)setUser:(NSString *)user {
    _user = user;
}

- (void)addMapping:(MEGMapping *)mapping {
    NSLog(@"%@", [mapping getAsJson]);

    BOOL found = NO;
    for (MEGMapping *m in mappings) {
        if ([m isSameAs:mapping]) {
            found = YES;
            break;
        }
    }

    if (!found) {
        [mappings addObject:mapping];
    }
}

- (NSDictionary *)getJSONObject {
    NSMutableDictionary *json = [NSMutableDictionary new];
    if (_user != nil) {
        [json setValue:_user forKey:@"user"];
    }
    
    NSMutableArray *mappingArray = [NSMutableArray new];
    for (MEGMapping *mapping in mappings) {
        NSDictionary *mappingJson = [mapping getAsJson];
        if (mappingJson != nil) {
            [mappingArray addObject:mappingJson];
        }
    }
    
    if (mappingArray.count > 0) {
        [json setValue:mappingArray forKey:@"mapping"];
    }
    
    return json;
}

- (MEGPair *)getRemarkForUserArgs:(MEGMapping *)mapping args:(NSDictionary<NSString *, NSString *> *)args {

    NSString *nonConstID_GROUP = [ID_GROUP copy];
    NSString *nonConstKEY_TEST_KEY = [KEY_TEST_KEY copy];
    BOOL isGroupIdPresent = FALSE;
    BOOL isTestKeyPresent = FALSE;
    if(args[nonConstID_GROUP] != nil){
        isGroupIdPresent = ![args[nonConstID_GROUP] isEqualToString:@""];
    }
    if(args[nonConstKEY_TEST_KEY] != nil){
        isTestKeyPresent = ![args[nonConstKEY_TEST_KEY] isEqualToString:@""];
    }

    if (!isGroupIdPresent && !isTestKeyPresent) {
        // there's no point in evaluating the stored values if both are null
        // as this is a user error
        return [[MEGPair alloc] initWithFirst:@(NotFoundForPassedArgs) second:@""];
    }

    NSString *empty = @"";

    for (MEGMapping *m in mappings) {

        // because "" = null for mappings
        NSString *group = [empty isEqualToString:[m group]] ? nil : [m group];

        BOOL isGroupSame = [group isEqualToString:[mapping group]];
        BOOL isTestKeySame = [[m testKey] isEqualToString:[m testKey]];

        if (isGroupIdPresent && isGroupSame) {
            // cond 1. if { groupId } is PRESENT then there is no need to check for the { test_key }
            if ([empty isEqualToString:[m winnerCampaign]]) {
                return [[MEGPair alloc] initWithFirst:@(ShouldReturnNull) second:@""];
            }
            return [[MEGPair alloc] initWithFirst:@(ShouldReturnWinnerCampaign) second:[m winnerCampaign]];
        } else if (!isGroupIdPresent && isTestKeySame) {
            // cond 2. if { groupId } is NOT PRESENT then then check for the { test_key }
            if ([empty isEqualToString:[m testKey]]) {
                return [[MEGPair alloc] initWithFirst:@(ShouldReturnNull) second:@""];
            }
            return [[MEGPair alloc] initWithFirst:@(ShouldReturnWinnerCampaign) second:[m winnerCampaign]];
        }
    }
    return [[MEGPair alloc] initWithFirst:@(NotFoundForPassedArgs) second:@""];
}

@end
