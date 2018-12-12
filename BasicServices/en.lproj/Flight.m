//
//  Flight.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import "Flight.h"
#import "Cabin.h"
#import "CompensationService.h"
#import "FoodService.h"
#import "HotelService.h"
#import "Passenger.h"
#import "Provider.h"
#import "TravelService.h"

@implementation Flight

- (NSString*)flightName {
    
    [self willAccessValueForKey:@"flightName"];
    
    NSString *flightName = [NSString stringWithFormat:@"%@%@", self.airlineCode, self.flightNumber];
    
    [self didAccessValueForKey:@"flightName"];
    
    return flightName;
}

- (void)setFlightName:(NSString *)flightName {
    
    [self willChangeValueForKey:@"flightName"];
    
    self.airlineCode = [flightName substringToIndex:2];
    self.flightNumber = [flightName substringFromIndex:2];
    
    [self didChangeValueForKey:@"flightName"];
}

- (Flight*)defaultProtectorFlight {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", @"airlineCode", self.airlineCode, @"flightNumber", self.flightNumber];
    
    NSSet *flights = [self.protectorFlights filteredSetUsingPredicate:predicate];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.departureDate];
    NSInteger day = components.day;
    NSInteger month = components.month;
    NSInteger year = components.year;
    
    for(Flight *f in flights) {
        
        components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:f.departureDate];
        
        if(day == components.day && month == components.month && year == components.year) {
            return f;
        }
    }
    
    return [self.protectorFlights anyObject];
}

@end
