//
//  Synchronizer.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/24/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "Synchronizer.h"

#import "FlightsViewController.h"
#import "ModelHelper.h"
#import "AppDelegate.h"
#import "Flight.h"
#import "SaveHelper.h"

@interface Synchronizer ()

@property(nonatomic, strong) NSManagedObjectContext *moc;
@property(nonatomic, strong) WebHelper *webHelper;
@property(nonatomic, strong) NSMutableArray *flightsToUpdate;
@property(nonatomic) BOOL couldDownloadFlights;
@property(nonatomic) BOOL throwWarning;

@end

@implementation Synchronizer

- (instancetype)init {
    
    if(self = [super init]) {
        
        self.moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
    
    return self;
}

- (void)synchronizeModel {
    
    self.webHelper = [[WebHelper alloc] init];
    self.webHelper.delegate = self;
    [self.webHelper testServerConnection];
}

- (void)updateFlights {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *currentAirport = [[SaveHelper sharedInstance] loadStringForKey:kSelectedAirport];
        [self.webHelper requestFlightsForAirportName:currentAirport];
    });
}

- (void)updatePassengers {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        ModelHelper *model = [[ModelHelper alloc] initWithMOC:self.moc];
        self.flightsToUpdate = [[NSMutableArray alloc] initWithArray:[model findAllAuthorizedFlights]];
        [self processNextFlight];
    });
}

- (void)uploadVouchersData {
    
    AppDelegate *appDelegate = ((AppDelegate*)[UIApplication sharedApplication].delegate);
    [appDelegate tryToUploadLocalData];
}

- (void)processNextFlight {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.flightsToUpdate.count > 0) {
            NSString *currentAirport = [[SaveHelper sharedInstance] loadStringForKey:kSelectedAirport];
            Flight *f = [self.flightsToUpdate firstObject];
//            NSLog(@"processing flight: %@", f.flightName);
            [self.flightsToUpdate removeObjectAtIndex:0];
            //NSLog(@"requesting flight %@... flights left: %ld", f.flightName, self.flightsToUpdate.count);
            [self.webHelper requestPassengerListForFlight:f inAirport:currentAirport];
        }
        
        else {
            if(self.throwWarning) {
                if([self.delegate respondsToSelector:@selector(synchronizationFinishedWithWarnings)]) {
                    [self.delegate synchronizationFinishedWithWarnings];
                }
            }
            else {
                if([self.delegate respondsToSelector:@selector(synchronizationFinishedSuccessfully)]) {
                    [self.delegate synchronizationFinishedSuccessfully];
                }
            }
        }
    });
}

#pragma mark WebHelperDelegate

- (void)serverConnectionTestEndedWithResult:(BOOL)serverReachable {
    
    if(serverReachable) {
        
        // begin synchronization. If it was forced, update local data; if not, just send vouchers
        
        [self uploadVouchersData];
        
        if(self.forcedSync) {
            [self updateFlights];
        }
    }
    
    else {
        if([self.delegate respondsToSelector:@selector(synchronizationDidFail)]) {
            [self.delegate synchronizationDidFail];
        }
    }
}

- (void)serverRespondedWithData:(NSData *)data forRequestType:(RequestType)type {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(type == kRequestFlights) {
            BOOL success = YES;     //TODO get this from JSON
            if(success) {
                self.couldDownloadFlights = YES;
                [[[ModelHelper alloc] initWithMOC:self.moc] processFlightsData:data];
                [self updatePassengers];
            }
            else {
                if([self.delegate respondsToSelector:@selector(synchronizationDidFail)]) {
                    [self.delegate synchronizationDidFail];
                }
                //NSLog(@"Web service error! (flights request)");
            }
        }
        else if(type == kRequestPassengers) {
            BOOL success = YES;     //TODO get this from JSON
            if(success) {
                
                [[[ModelHelper alloc] initWithMOC:self.moc] processPassengersData:data];
                [self processNextFlight];
            }
            else {
                if([self.delegate respondsToSelector:@selector(synchronizationDidFail)]) {
                    [self.delegate synchronizationDidFail];
                }
                //NSLog(@"Web service error! (flights request)");
            }
        }
    });
}

- (void)connectionFailedWithError:(NSError *)error {
    if(!self.couldDownloadFlights) {
        if([self.delegate respondsToSelector:@selector(synchronizationDidFail)]) {
            [self.delegate synchronizationDidFail];
        }
    }
    else if(self.flightsToUpdate.count == 0) {
        if([self.delegate respondsToSelector:@selector(synchronizationFinishedWithWarnings)]) {
            [self.delegate synchronizationFinishedWithWarnings];
        }
    }
    else {
        self.throwWarning = YES;
        [self processNextFlight];
    }
}

@end
