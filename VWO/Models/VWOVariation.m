//
//  VWOVariation.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VWOVariation.h"
#import "NSDictionary+VWO.h"
#import "VWOLogger.h"

static NSString * kId      = @"id";
static NSString * kName    = @"name";
static NSString * kChanges = @"changes";
static NSString * kWeight  = @"weight";

@implementation VWOVariation

- (instancetype)initWith:(int)iD name:(NSString *)name changes:(NSDictionary * _Nullable)changes weight:(int)weight {
    NSParameterAssert(name);
    if (self = [self init]) {
        self.iD      = iD;
        self.name    = name;
        self.changes = changes;
        self.weight  = weight;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *) variationDict {
    NSArray *missingKeys = [variationDict keysMissingFrom:@[kId, kName, kWeight]];
    if (missingKeys.count > 0) {
        VWOLogException(@"Keys missing [%@] for Variation JSON %@",
                        [missingKeys componentsJoinedByString:@", "],
                        variationDict);
        return nil;
    }

    int iD                = [variationDict[kId] intValue];
    NSString *name        = variationDict[kName];
    NSDictionary *changes = variationDict[kChanges];
    int weight            = [variationDict[kWeight] intValue];

    /* ** IMP **
     In case of variation type control, Union of keys of all other variation are sent with nil values
     changes dictionary stores the value as [NSNull null], beacuse setting it to 'nil' would remove the key value pair
     */
    return [self initWith:iD name:name changes:changes weight:weight];
}

- (BOOL)isControl {
    return (self.iD == 1);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(id: %d)", self.name, self.iD];
}

@end
