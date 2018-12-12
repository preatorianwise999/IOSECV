//
//  NSDictionary+SafeValues.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/3/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "NSDictionary+SafeValues.h"

@implementation NSDictionary (SafeValues)

- (NSObject*)objectForKey:(NSString*)key defaultValue:(NSObject*)obj {
    
    if([self[key] isEqual:[NSNull null]] || self[key] == nil) {
        return obj;
    }
    
    return self[key];
}

- (NSString*)stringForKey:(NSString*)key defaultValue:(NSString*)obj {
    return (NSString*)[self objectForKey:key defaultValue:obj];
}

- (NSArray*)arrayForKey:(NSString*)key defaultValue:(NSString*)obj {
    return (NSArray*)[self objectForKey:key defaultValue:obj];
}

- (NSDictionary*)dictForKey:(NSString*)key defaultValue:(NSString*)obj {
    return (NSDictionary*)[self objectForKey:key defaultValue:obj];
}

- (NSNumber*)numberForKey:(NSString*)key defaultValue:(NSString*)obj {
    return (NSNumber*)[self objectForKey:key defaultValue:obj];
}

@end
