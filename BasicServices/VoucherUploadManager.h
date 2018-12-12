//
//  VoucherUploadManager.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 9/23/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebHelper.h"

@protocol VUMDelegate

- (void)uploadFinishedSuccessfully:(id)sender;
- (void)uploadFailedForVouchers:(NSArray*)vouchers sender:(id)sender;

@end

@interface VoucherUploadManager : NSObject<WebHelperDelegate>

@property(nonatomic, weak) id<VUMDelegate> delegate;

- (void)tryToUploadVouchers:(NSArray*)vouchers;

@end
