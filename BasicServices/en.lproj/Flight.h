//
//  Flight.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cabin, CompensationService, FoodService, HotelService, Passenger, Provider, TravelService;

NS_ASSUME_NONNULL_BEGIN

@interface Flight : NSManagedObject

- (Flight*)defaultProtectorFlight;

@end

NS_ASSUME_NONNULL_END

#import "Flight+CoreDataProperties.h"
