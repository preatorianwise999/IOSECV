//
//  VoucherData.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/3/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "VoucherData.h"

@implementation VoucherData

// printed voucher keys
NSString *const keyServiceType      = @"serviceType";
NSString *const keyUser             = @"user";
NSString *const keyDateVoucher      = @"dateVoucher";
NSString *const keyServiceProvider  = @"serviceProvider";
NSString *const keyProviderID       = @"idProvider";
NSString *const keyServiceName      = @"serviceName";
NSString *const keyServiceCode      = @"serviceCode";
NSString *const keyIdPassenger      = @"idPassenger";
NSString *const keyAirlineCode      = @"airlineCode";
NSString *const keyDepartureAirport = @"departureAirport";
NSString *const keyFlightNumber     = @"flightNumber";
NSString *const keyDepartureDate    = @"departureDate";
NSString *const keyVoucherID        = @"idVoucher";
NSString *const keyPassengerEmail   = @"email";

- (NSDictionary*)asDictionary {
    
    NSString *serviceType;
    
    switch (self.serviceType) {
        case serviceFood: {
            serviceType = @"Food";
        } break;
        case serviceTransport: {
            serviceType = @"Transport";
        } break;
        case serviceHotel: {
            serviceType = @"Hotel";
        } break;
        case serviceCompensation: {
            serviceType = @"Compensation";
        } break;
            
        default:
            break;
    }
    
    NSDictionary *retDict = @{
                              keyServiceType:       serviceType,
                              keyUser:              self.username,
                              keyDateVoucher:       self.dateStr,
                              keyServiceProvider:   self.providerName,
                              keyProviderID:        @(self.providerID.intValue),
                              keyServiceName:       self.serviceName,
                              keyServiceCode:       self.serviceCode,
                              keyIdPassenger:       @[@(self.idPassenger)],
                              keyAirlineCode:       self.airlineCode,
                              keyDepartureAirport:  self.departureAirport,
                              keyFlightNumber:      self.flightNumber,
                              keyDepartureDate:     self.departureDateStr,
                              keyVoucherID:         self.voucherID,
                              keyPassengerEmail:    (self.passengerEmail != nil) ? self.passengerEmail : @""
                              };
    
    return retDict;
}

@end
