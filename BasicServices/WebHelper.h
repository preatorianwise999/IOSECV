//
//  WebHelper.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/7/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    kRequestAirports,
    kRequestFlights,
    kRequestPassengers,
    kRequestHotelAvailability,
    kRequestDocumentTypes,
    kRequestIssueCompensation,
    kRequestUploadVoucher
    
} RequestType;

typedef enum {
    
    kErrorWrongCredentials,
    kErrorCantReachInternet,
    kErrorServerError,
    kErrorTimeout
    
} WebHelperErrorCode;

@class Flight;
@class Passenger;

extern NSString *const WebHelperErrorDomain;

@protocol WebHelperDelegate <NSObject>

@optional

- (void)serverRespondedWithData:(NSData*)data forRequestType:(RequestType)type;
- (void)serverConnectionTestEndedWithResult:(BOOL)result;
- (void)connectionFailedWithError:(NSError*)error;

@end

@interface WebHelper : NSObject<NSURLConnectionDelegate>

@property(nonatomic, strong) NSString *usernameStr;
@property(nonatomic, strong) NSString *passwordStr;
@property(nonatomic, weak) id<WebHelperDelegate> delegate;

- (void)requestAirports;
- (void)requestFlightsForAirportName:(NSString*)name;
- (void)requestPassengerListForFlight:(Flight*)flight inAirport:(NSString*)iataCode;
- (void)requestHotelAvailabilityForAirportName:(NSString*)name;
- (void)requestTypesOfDocumentsForCountryCode:(NSString*)countryCode;
- (void)requestCompensationFoidForPassenger:(Passenger*)pax protectorFlight:(Flight*)flight sendByEmail:(BOOL)sendByEmail;
- (void)uploadVouchersArray:(NSArray*)array;
- (void)testServerConnection;
- (BOOL)isConnected;

@end