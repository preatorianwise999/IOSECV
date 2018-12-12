//
//  VoucherHelper.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 10/29/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Passenger;
@class PrinterManager;
@class VoucherData;

@interface VoucherHelper : NSObject

- (VoucherData*)getVoucherDataForService:(NSObject*)service
                               passenger:(Passenger*)p
                               voucherID:(NSString*)voucherID
                          signatureImage:(UIImage*)signatureImage
                             isDuplicate:(BOOL)isDuplicate
                          commandsString:(NSString**)commands;

@end
