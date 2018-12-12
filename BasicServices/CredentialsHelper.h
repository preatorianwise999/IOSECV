//
//  CredentialsHelper.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/24/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialsHelper : NSObject

- (void)saveUsername:(NSString*)username;
- (void)savePassword:(NSString*)password;
- (NSString*)getUsername;
- (NSString*)getPassword;
- (BOOL)checkCredentialsWithUsername:(NSString*)username password:(NSString*)password;
- (BOOL)canFindCredentials;

@end
