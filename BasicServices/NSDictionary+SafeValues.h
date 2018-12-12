//
//  NSDictionary+SafeValues.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/3/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SafeValues)

- (NSObject*)objectForKey:(NSString*)key defaultValue:(NSObject*)obj;

- (NSString*)stringForKey:(NSString*)key defaultValue:(NSString*)obj;

- (NSArray*)arrayForKey:(NSString*)key defaultValue:(NSArray*)obj;

- (NSDictionary*)dictForKey:(NSString*)key defaultValue:(NSDictionary*)obj;

- (NSNumber*)numberForKey:(NSString*)key defaultValue:(NSNumber*)obj;

@end
