//
//  Cabin+CoreDataProperties.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Cabin.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cabin (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *currentValue;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) Flight *flight;
@property (nullable, nonatomic, retain) NSSet<Passenger *> *passengers;

@end

@interface Cabin (CoreDataGeneratedAccessors)

- (void)addPassengersObject:(Passenger *)value;
- (void)removePassengersObject:(Passenger *)value;
- (void)addPassengers:(NSSet<Passenger *> *)values;
- (void)removePassengers:(NSSet<Passenger *> *)values;

@end

NS_ASSUME_NONNULL_END
