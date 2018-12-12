//
//  SaveHelper.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 9/25/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "SaveHelper.h"

NSString *const kSelectedAirport    = @"kSelectedAirport";
NSString *const kUsername           = @"kUsername";
NSString *const kVoucherIndex       = @"kVoucherIndex";
NSString *const kSavedVouchers      = @"kSavedVouchersInfo";

@interface SaveHelper ()

@property(nonatomic, strong) NSLock *lockObj;

@end

@implementation SaveHelper

+ (instancetype)sharedInstance {
    
    static SaveHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SaveHelper alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if(self = [super init]) {
        self.lockObj = [[NSLock alloc] init];
    }
    return self;
}

- (void)saveObject:(NSObject *)obj withKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSObject*)loadObjectForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (NSString*)loadStringForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (int)loadIntForKey:(NSString *)key {
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if(number) {
       return [number intValue];
    }
    
    return 0;
}

- (NSArray*)loadArrayForKey:(NSString *)key {
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    return array;
}

- (void)removeObjectForKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)lock {
    [self.lockObj lock];
}

- (void)unlock {
    [self.lockObj unlock];
}

@end
