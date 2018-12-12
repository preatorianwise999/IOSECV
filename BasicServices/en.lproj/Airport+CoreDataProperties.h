//
//  Airport+CoreDataProperties.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Airport.h"

NS_ASSUME_NONNULL_BEGIN

@interface Airport (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *iataCode;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Flight *> *airportFlights;

@end

@interface Airport (CoreDataGeneratedAccessors)

- (void)addAirportFlightsObject:(Flight *)value;
- (void)removeAirportFlightsObject:(Flight *)value;
- (void)addAirportFlights:(NSSet<Flight *> *)values;
- (void)removeAirportFlights:(NSSet<Flight *> *)values;

@end

NS_ASSUME_NONNULL_END
