//
//  SessionData.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/7/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "SessionData.h"

@implementation SessionData

+ (SessionData*)sharedSession {
    
    static SessionData *sharedSession = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSession = [[SessionData alloc] init];
    });
    
    return sharedSession;
}

@end
