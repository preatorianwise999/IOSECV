//
//  CredentialsHelper.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/24/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "CredentialsHelper.h"

#import "KeychainWrapper.h"
#import "SaveHelper.h"

#define strUsername @"strUsername"

@implementation CredentialsHelper

- (void)saveUsername:(NSString*)username {
    [[SaveHelper sharedInstance] saveObject:username withKey:kUsername];
}

- (void)savePassword:(NSString*)password {
    KeychainWrapper *kw = [[KeychainWrapper alloc] init];
    [kw mySetObject:password forKey:(__bridge id)(kSecValueData)];
    [kw writeToKeychain];
}

- (NSString*)getUsername {
    return [[SaveHelper sharedInstance] loadStringForKey:kUsername];
}

- (NSString*)getPassword {
    KeychainWrapper *kw = [[KeychainWrapper alloc] init];
    return [kw myObjectForKey:@"v_Data"];
}

- (BOOL)checkCredentialsWithUsername:(NSString*)username password:(NSString*)password {
    
    KeychainWrapper *kw = [[KeychainWrapper alloc] init];
    
    if([password isEqualToString:[kw myObjectForKey:@"v_Data"]] &&
        [username isEqualToString:[[SaveHelper sharedInstance] loadStringForKey:kUsername]]) {
            return YES;
    }
    
    return NO;
}

- (BOOL)canFindCredentials {
    NSString *username = [[SaveHelper sharedInstance] loadStringForKey:kUsername];
    return (username != nil);
}


@end
