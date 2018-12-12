//
//  Flight+CoreDataProperties.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/29/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Flight.h"

NS_ASSUME_NONNULL_BEGIN

@interface Flight (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *airlineCode;
@property (nullable, nonatomic, retain) NSString *arrivalAirport;
@property (nullable, nonatomic, retain) NSString *contingencyCode;
@property (nullable, nonatomic, retain) NSString *contingencyDetails;
@property (nullable, nonatomic, retain) NSString *departureAirport;
@property (nullable, nonatomic, retain) NSString *protectorID;
@property (nullable, nonatomic, retain) NSDate *departureDate;
@property (nullable, nonatomic, retain) NSString *flightName;
@property (nullable, nonatomic, retain) NSString *flightNumber;
@property (nullable, nonatomic, retain) NSDate *updateDate;
@property (nullable, nonatomic, retain) NSSet<Cabin *> *cabins;
@property (nullable, nonatomic, retain) NSSet<CompensationService *> *compensationServices;
@property (nullable, nonatomic, retain) NSSet<Provider *> *foodProviders;
@property (nullable, nonatomic, retain) NSSet<FoodService *> *foodServices;
@property (nullable, nonatomic, retain) NSSet<HotelService *> *hotelServices;
@property (nullable, nonatomic, retain) NSSet<Passenger *> *passengers;
@property (nullable, nonatomic, retain) NSSet<TravelService *> *travelServices;
@property (nullable, nonatomic, retain) NSSet<Flight *> *protectorFlights;

@end

@interface Flight (CoreDataGeneratedAccessors)

- (void)addCabinsObject:(Cabin *)value;
- (void)removeCabinsObject:(Cabin *)value;
- (void)addCabins:(NSSet<Cabin *> *)values;
- (void)removeCabins:(NSSet<Cabin *> *)values;

- (void)addCompensationServicesObject:(CompensationService *)value;
- (void)removeCompensationServicesObject:(CompensationService *)value;
- (void)addCompensationServices:(NSSet<CompensationService *> *)values;
- (void)removeCompensationServices:(NSSet<CompensationService *> *)values;

- (void)addFoodProvidersObject:(Provider *)value;
- (void)removeFoodProvidersObject:(Provider *)value;
- (void)addFoodProviders:(NSSet<Provider *> *)values;
- (void)removeFoodProviders:(NSSet<Provider *> *)values;

- (void)addFoodServicesObject:(FoodService *)value;
- (void)removeFoodServicesObject:(FoodService *)value;
- (void)addFoodServices:(NSSet<FoodService *> *)values;
- (void)removeFoodServices:(NSSet<FoodService *> *)values;

- (void)addHotelServicesObject:(HotelService *)value;
- (void)removeHotelServicesObject:(HotelService *)value;
- (void)addHotelServices:(NSSet<HotelService *> *)values;
- (void)removeHotelServices:(NSSet<HotelService *> *)values;

- (void)addPassengersObject:(Passenger *)value;
- (void)removePassengersObject:(Passenger *)value;
- (void)addPassengers:(NSSet<Passenger *> *)values;
- (void)removePassengers:(NSSet<Passenger *> *)values;

- (void)addTravelServicesObject:(TravelService *)value;
- (void)removeTravelServicesObject:(TravelService *)value;
- (void)addTravelServices:(NSSet<TravelService *> *)values;
- (void)removeTravelServices:(NSSet<TravelService *> *)values;

- (void)addProtectorFlightsObject:(Flight *)value;
- (void)removeProtectorFlightsObject:(Flight *)value;
- (void)addProtectorFlights:(NSSet<Flight *> *)values;
- (void)removeProtectorFlights:(NSSet<Flight *> *)values;

@end

NS_ASSUME_NONNULL_END
