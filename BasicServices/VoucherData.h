//
//  VoucherData.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/3/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServiceTypes.h"

@interface VoucherData : NSObject

@property(nonatomic) ServiceType serviceType;
@property(nonatomic) int idPassenger;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *dateStr;
@property(nonatomic, strong) NSString *providerName;
@property(nonatomic, strong) NSNumber *providerID;
@property(nonatomic, strong) NSString *serviceName;
@property(nonatomic, strong) NSString *serviceCode;
@property(nonatomic, strong) NSString *airlineCode;
@property(nonatomic, strong) NSString *departureAirport;
@property(nonatomic, strong) NSString *flightNumber;
@property(nonatomic, strong) NSString *departureDateStr;
@property(nonatomic, strong) NSString *voucherID;
@property(nonatomic, strong) NSString *passengerEmail;

- (NSDictionary*)asDictionary;

@end
