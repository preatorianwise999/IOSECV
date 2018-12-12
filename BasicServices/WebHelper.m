//
//  WebHelper.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/7/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "WebHelper.h"

#import "Flight.h"
#import "Passenger.h"

#import "Reachability.h"
#import "CredentialsHelper.h"
#import "Configuration.h"

NSString *const WebHelperErrorDomain = @"WebHelperErrorDomain";

@interface WebHelper ()

@property(nonatomic) RequestType typeOfLastRequest;
@property(nonatomic, strong) NSMutableData *responseData;

@end

@implementation WebHelper

- (instancetype)init {
   
    if(self = [super init]) {
        CredentialsHelper *ch = [[CredentialsHelper alloc] init];
        
        self.usernameStr = [ch getUsername];
        self.passwordStr = [ch getPassword];
    }
    
    return self;
}

- (void)requestAirports {
    self.typeOfLastRequest = kRequestAirports;
    
    [self sendRequestWithURLString:[NSString stringWithFormat:@"%@/%@/Airport", kStrServerAndPort, kStrPath]];
}

- (void)requestFlightsForAirportName:(NSString*)name {
    self.typeOfLastRequest = kRequestFlights;
    
    [self sendRequestWithURLString:[NSString stringWithFormat:@"%@/%@/Fligth/%@", kStrServerAndPort, kStrPath, name]];
}

- (void)requestPassengerListForFlight:(Flight*)flight inAirport:(NSString *)iataCode {
    self.typeOfLastRequest = kRequestPassengers;
    
    NSDate *date = flight.departureDate;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"dd-MM-yyyy";
    NSString *dateStr = [df stringFromDate:date];
    
    [self sendRequestWithURLString:[NSString stringWithFormat:@"%@/%@/Passenger/%@/%@/%@/%@", kStrServerAndPort, kStrPath, flight.airlineCode, flight.flightNumber, dateStr, iataCode]];
}

- (void)requestHotelAvailabilityForAirportName:(NSString*)name {
    self.typeOfLastRequest = kRequestHotelAvailability;
    
    [self sendRequestWithURLString:[NSString stringWithFormat:@"%@/%@/Hotel/%@", kStrServerAndPort, kStrPath, name]];
}

- (void)requestTypesOfDocumentsForCountryCode:(NSString*)countryCode {
    self.typeOfLastRequest = kRequestDocumentTypes;
    
    [self sendRequestWithURLString:[NSString stringWithFormat:@"%@/%@/DocTypesByCountry/%@", kStrServerAndPort, kStrPath, countryCode]];
}

- (void)requestCompensationFoidForPassenger:(Passenger*)pax protectorFlight:(Flight*)flight sendByEmail:(BOOL)sendByEmail {
    self.typeOfLastRequest = kRequestIssueCompensation;
    
    NSDictionary *jsonDict = @{
                                @"passengerID":pax.passengerID,
                                @"countryCode":pax.docIssuingCountry,
                                @"docType":pax.documentType,
                                @"docNumber":pax.documentNumber,
                                @"email": sendByEmail ? pax.email : @"",
                                @"protectorID": flight.protectorID ? flight.protectorID : @"",
                                @"bpAgent": self.usernameStr,
                                @"languageCode": [[NSLocale preferredLanguages] firstObject]
                            };
    
    NSLog(@"%@", jsonDict);
    NSData *jsonData = nil;
    NSString *jsonString;
    
    if([NSJSONSerialization isValidJSONObject:jsonDict]) {
        
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/Compensation", kStrServerAndPort, kStrPath];
    
    [self uploadData:jsonData toPath:urlString];
}

- (void)uploadVouchersArray:(NSArray *)array {
    self.typeOfLastRequest = kRequestUploadVoucher;
    NSLog(@"Requested upload vouchers. Number of vouchers: %d", (int)array.count);
    
    NSDictionary *jsonDict = @{@"vouchers" : array};
    NSLog(@"%@", jsonDict);
    NSData *jsonData = nil;
    NSString *jsonString;
    
    if([NSJSONSerialization isValidJSONObject:jsonDict]) {
        
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/Voucher", kStrServerAndPort, kStrPath];
    
    [self uploadData:jsonData toPath:urlString];
}

- (void)uploadData:(NSData*)data toPath:(NSString*)urlString {
    
    NSLog(@"Sending local data");
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kRequestTimeout];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: data];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    
    // Create url connection and fire request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];

    if(!connection) {
        //NSLog(@"Connection error...");
    }
}

- (void)sendRequestWithURLString:(NSString*)urlString {
    
    // create the request
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kRequestTimeout];
    request.HTTPMethod = @"GET";
    
    // fire off the request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    
    if(!connection) {
        //NSLog(@"Connection error...");
    }
}

#pragma mark Reachability

// Checks if we have an internet connection or not
- (void)testServerConnection {
    
    Reachability *reach = [Reachability reachabilityWithHostname:kStrServer];
//    Reachability *reach = [Reachability reachabilityWithHostname:@"google.com"];
    
    __weak WebHelper *weakSelf = self;
    
    // Internet is reachable
    reach.reachableBlock = ^(Reachability*reach) {
        if([weakSelf.delegate respondsToSelector:@selector(serverConnectionTestEndedWithResult:)]) {
            [reach stopNotifier];
            [weakSelf.delegate serverConnectionTestEndedWithResult:YES];
        }
    };
    
    // Internet is not reachable
    reach.unreachableBlock = ^(Reachability*reach) {
        if([weakSelf.delegate respondsToSelector:@selector(serverConnectionTestEndedWithResult:)]) {
            [reach stopNotifier];
            [weakSelf.delegate serverConnectionTestEndedWithResult:NO];
        }
    };
    
    [reach startNotifier];
}

- (BOOL)isConnected {
    Reachability *reach = [Reachability reachabilityWithHostname:kStrServer];
    return reach.isReachable;
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    NSString *errorMsg = nil;
    NSLog(@"did receive response (%ld)", (long)code);
    
    if (code == 504) {
        errorMsg = @"Timeout";
        [connection cancel];
    }
    else if (code == 403 || code == 401 || code == 405 || code == 511) {
        errorMsg = @"Access forbidden";
        [connection cancel];
    }
    
    else if (code == 409) {
        errorMsg = @"File conflict error";
        [connection cancel];
    }
    
    else if (code == 502) {
        errorMsg = @"Bad gateway";
        [connection cancel];
    }
    
    else if (code == 500) {
        errorMsg = @"Internal server error";
        [connection cancel];
    }
    
    else if (code == 404) {
        errorMsg = @"Not found";
        [connection cancel];
    }
    
    if(errorMsg) {
        
        if([self.delegate respondsToSelector:@selector(connectionFailedWithError:)]) {
            [self.delegate connectionFailedWithError:[NSError errorWithDomain:WebHelperErrorDomain code:kErrorServerError userInfo:@{NSLocalizedDescriptionKey : errorMsg}]];
        }
    }
    
    if (!self.responseData) {
        self.responseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did receive data");
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"did fail with error");
    NSError *retError = error;
    if(error.code == NSURLErrorTimedOut) {
        retError = [NSError errorWithDomain:WebHelperErrorDomain code:kErrorTimeout userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(error.localizedDescription, @"Timeout")}];
    }
    
    [connection cancel];
    connection = nil;
    self.responseData = nil;
    if([self.delegate respondsToSelector:@selector(connectionFailedWithError:)]) {
        [self.delegate connectionFailedWithError:retError];
    }
    
    self.responseData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"did finish loading");
    [connection cancel];
    connection = nil;
    if ([self.delegate respondsToSelector:@selector(serverRespondedWithData:forRequestType:)]) {
        [self.delegate serverRespondedWithData:self.responseData forRequestType:self.typeOfLastRequest];
    }
    
    self.responseData = nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    NSLog(@"will cache response");
    return nil;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"did cancel auth challenge");
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"did receive auth challenge");
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.usernameStr
                                                             password:self.passwordStr
                                                          persistence:NSURLCredentialPersistenceNone];
    
    if (([challenge previousFailureCount] == 0) && ([challenge proposedCredential] == nil)) {
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else {
        if([self.delegate respondsToSelector:@selector(connectionFailedWithError:)]) {
            [self.delegate connectionFailedWithError:[NSError errorWithDomain:WebHelperErrorDomain code:kErrorWrongCredentials userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"alert_msg_wrong_credentials", @"Invalid Credentials")}]];
        }
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSLog(@"will request auth challenge");
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.usernameStr
                                                             password:self.passwordStr
                                                          persistence:NSURLCredentialPersistenceNone];
    
    if (([challenge previousFailureCount] == 0)) {
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else {
        if([self.delegate respondsToSelector:@selector(connectionFailedWithError:)]) {
            [self.delegate connectionFailedWithError:[NSError errorWithDomain:WebHelperErrorDomain code:kErrorWrongCredentials userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"alert_msg_wrong_credentials", @"Invalid Credentials")}]];
        }
        [connection cancel];
    }
}

@end
