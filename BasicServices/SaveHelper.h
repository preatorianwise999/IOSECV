//
//  SaveHelper.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 9/25/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kSelectedAirport;
extern NSString *const kUsername;
extern NSString *const kVoucherIndex;
extern NSString *const kSavedVouchers;

@interface SaveHelper : NSObject

+ (instancetype)sharedInstance;
- (void)saveObject:(NSObject*)obj withKey:(NSString*)key;
- (NSObject*)loadObjectForKey:(NSString*)key;
- (NSString*)loadStringForKey:(NSString*)key;
- (int)loadIntForKey:(NSString *)key;
- (NSArray*)loadArrayForKey:(NSString*)key;
- (void)removeObjectForKey:(NSString*)key;
- (void)lock;
- (void)unlock;

@end
