//
//  SaveHelper.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/7/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Flight;

@interface ModelHelper : NSObject

@property(nonatomic, strong) NSManagedObjectContext *moc;

- (instancetype)initWithMOC:(NSManagedObjectContext*)moc;
- (void)processAirportsData:(NSData*)data;
- (void)processFlightsData:(NSData*)data;
- (void)processPassengersData:(NSData*)data;
- (void)processHotelAvailabilityData:(NSData*)data;
- (NSString*)processCompensationData:(NSData*)data;
- (NSArray*)processDocumentTypesData:(NSData*)data;
- (void)printCoreDataObjectCount;
- (NSArray*)findAllAuthorizedFlights;

@end
