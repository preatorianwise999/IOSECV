//
//  VoucherUploadManager.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 9/23/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "VoucherUploadManager.h"

#import "WarningIndicatorManager.h"

@interface VoucherUploadManager ()

@property(nonatomic, strong) WebHelper *webHelper;
@property(nonatomic, strong) NSArray *vouchers;

@end

@implementation VoucherUploadManager

- (void)tryToUploadVouchers:(NSArray *)vouchers {
    
    //NSLog(@"Created Voucher Upload Request with %ld vouchers", vouchers.count);
    
    self.vouchers = vouchers;
    
    self.webHelper = [[WebHelper alloc] init];
    self.webHelper.delegate = self;
    [self.webHelper testServerConnection];
}

- (void)serverConnectionTestEndedWithResult:(BOOL)connected {
    
    if(connected) {
        [self uploadLocalData];
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
        });
        
        [self.delegate uploadFailedForVouchers:self.vouchers sender:self];
    }
}

- (void)uploadLocalData {
    
    self.webHelper = [[WebHelper alloc] init];
    self.webHelper.delegate = self;
    [self.webHelper uploadVouchersArray:self.vouchers];
}

- (void)serverRespondedWithData:(NSData *)data forRequestType:(RequestType)type {
    
    //NSLog(@"vouchers uploaded!");
    
    //    if(data) {
    //       NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    //    }
    
    // check data for success status
    BOOL success = YES;
    
    if(success) {
        [self.delegate uploadFinishedSuccessfully:self];
    } else {
        [self.delegate uploadFailedForVouchers:self.vouchers sender:self];
    }
}

- (void)connectionFailedWithError:(NSError *)error {
    
    //NSLog(@"vouchers failed to upload");
    [self.delegate uploadFailedForVouchers:self.vouchers sender:self];
}

@end
