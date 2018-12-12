//
//  LTMWindow.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 12/5/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "LTMWindow.h"

NSString *const kWindowEventNotification      = @"kReceivedEvent";

@implementation LTMWindow


- (void)sendEvent:(UIEvent *)event {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWindowEventNotification object:nil];
    
    [super sendEvent:event];
}

@end
