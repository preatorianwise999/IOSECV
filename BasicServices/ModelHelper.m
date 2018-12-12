//
//  SaveHelper.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/7/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "ModelHelper.h"

#import "AppDelegate.h"
#import "Airport.h"
#import "Flight.h"
#import "Flight.h"
#import "Passenger.h"
#import "Cabin.h"
#import "Voucher.h"
#import "FoodService.h"
#import "TravelService.h"
#import "HotelService.h"
#import "CompensationService.h"
#import "Provider.h"
#import "NSDictionary+SafeValues.h"
#import "DocumentTypeDetails.h"

#define kProvidersPatch @"GENERICO ALIMENTACION"

// airports JSON
NSString *const keyAirportsIataCode                 = @"iataCode";
NSString *const keyAirportsName                     = @"name";

// flights JSON
NSString *const keyFlightsAuthorizedFlights         = @"authorizedFlight";
NSString *const keyFlightsProtectorFlights          = @"protectFlight";
NSString *const keyFlightsProviders                 = @"providers";
NSString *const keyFlightsProvidersName             = @"name";
NSString *const keyFlightsProtectorID               = @"protectorFlightID";
NSString *const keyFlightsContingencyCode           = @"contingencyCode";
NSString *const keyFlightsContingencyDetails        = @"contingencyDetails";
NSString *const keyFlightsCompensationCause         = @"causeCompensation";
NSString *const keyFlightsCompensationMotive        = @"motiveCompensation";
NSString *const keyFlightsAirlineCode               = @"airlineCode";
NSString *const keyFlightsFlightNumber1             = @"fligthNumber";
NSString *const keyFlightsFlightNumber2             = @"flightNumber";
NSString *const keyFlightsDepartureDate             = @"departureDate";
NSString *const keyFlightsDepartureAirport          = @"departureAirport";
NSString *const keyFlightsArrivalAirport            = @"arrivalAirport";
NSString *const keyFlightsAllCabins                 = @"cabins";
NSString *const keyFlightsCabinCode                 = @"code";
NSString *const keyFlightsCabinSize                 = @"numberOfPassengers";
NSString *const keyFlightsAllServices               = @"servicesBasic";

// passengers JSON
NSString *const keyPassengersAirlineCode            = @"airLineCode";
NSString *const keyPassengersFlightNumber           = @"fligthNumber";
NSString *const keyPassengersDepartureDate          = @"departureDate";
NSString *const keyPassengersAllPassengers          = @"flight";
NSString *const keyPassengersFirstName              = @"name";
NSString *const keyPassengersLastName               = @"lastName";
NSString *const keyPassengersOtherInfo              = @"info";
NSString *const keyPassengersEmail                  = @"email";
NSString *const keyPassengersVoluntary              = @"voluntary";
NSString *const keyPassengersPNR                    = @"pnr";
NSString *const keyPassengersType                   = @"categotyPassenger";
NSString *const keyPassengersID                     = @"idPassenger";
NSString *const keyPassengersEditCodes              = @"editCodes";
NSString *const keyPassengersDocType                = @"documentType";
NSString *const keyPassengersDocNumber              = @"documentNumber";
NSString *const keyPassengersDocIssuingCountry      = @"issuingCountry";
NSString *const keyPassengersCabin                  = @"cabin";
NSString *const keyPassengersAllVouchers            = @"vouchers";
NSString *const keyPassengersVoucherService         = @"service";
NSString *const keyPassengersVoucherTypeCode        = @"typeCode";
NSString *const keyPassengersVoucherTypeDescription = @"typeDescription";
NSString *const keyPassengersVoucherAmount          = @"numberOfVouchers";
NSString *const keyPassengersAuthorizedFlight       = @"flightAutorized";
NSString *const keyPassengersProtectorFlights       = @"protectFlight";

// services dict
NSString *const keyServiceFood                      = @"food";
NSString *const keyServiceFoodType                  = @"type";
NSString *const keyServiceFoodCode                  = @"code";
NSString *const keyServiceFoodSubCode               = @"subCode";
NSString *const keyServiceFoodDetails               = @"details";
NSString *const keyServiceFoodAmount                = @"amount";
NSString *const keyServiceFoodCurrency              = @"currency";
NSString *const keyServiceFoodSignatureRequired     = @"signatureRequired";
NSString *const keyServiceFoodPrintAmount           = @"printAmount";
NSString *const keyServiceSnack                     = @"snack";
NSString *const keyServiceSnackType                 = @"type";
NSString *const keyServiceSnackCode                 = @"code";
NSString *const keyServiceSnackSubCode              = @"subCode";
NSString *const keyServiceSnackDetails              = @"details";
NSString *const keyServiceSnackAmount               = @"amount";
NSString *const keyServiceSnackCurrency             = @"currency";
NSString *const keyServiceSnackSignatureRequired    = @"signatureRequired";
NSString *const keyServiceSnackPrintAmount          = @"printAmount";
NSString *const keyServiceTransport                 = @"transport";
NSString *const keyServiceTransportProviderName     = @"provider";
NSString *const keyServiceTransportProviderID       = @"idProvider";
NSString *const keyServiceTransportDetails          = @"description";
NSString *const keyServiceTransportCode             = @"code";
NSString *const keyServiceTransportSubCode          = @"subCode";
NSString *const keyServiceTransportSignatureRequired= @"signatureRequired";
// hotels JSON
NSString *const keyServiceHotel                     = @"hotel";
NSString *const keyServiceHotelProviderName         = @"provider";
NSString *const keyServiceHotelProviderID           = @"idProvider";
NSString *const keyServiceHotelRoomTypes            = @"roomType";
NSString *const keyServiceHotelCode                 = @"code";
NSString *const keyServiceHotelSubCode              = @"subCode";
NSString *const keyServiceHotelRoomTypeDesc         = @"roomTypeDesc";
NSString *const keyServiceHotelRoomAvailability     = @"roomAvailability";
NSString *const keyServiceHotelSignatureRequired    = @"signatureRequired";

// compensation dict
NSString *const keyCompensation                     = @"compensation";
NSString *const keyCompensationCash                 = @"cash";
NSString *const keyCompensationLatamServices        = @"latamServices";
NSString *const keyCompensationSignatureRequired    = @"signatureRequired";
NSString *const keyCompensationUpgrade              = @"upgrade";

// document types dict

NSString *const keyDocTypesArray                    = @"docTypes";
NSString *const keyDocTypesName                     = @"name";
NSString *const keyDocTypesCode                     = @"code";
NSString *const keyDocTypesMask                     = @"mask";

// compensation emission dict
NSString *const keyCompensationEmissionFoid         = @"foid";

@implementation ModelHelper

- (instancetype)init {
    if(self = [super init]) {
        self.moc = [[NSManagedObjectContext alloc] init];
        self.moc.persistentStoreCoordinator = ((AppDelegate*)[UIApplication sharedApplication].delegate).persistentStoreCoordinator;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];
    }
    return self;
}

- (instancetype)initWithMOC:(NSManagedObjectContext*)moc {
    if(self = [super init]) {
        self.moc = moc;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];
    }
    return self;
}

- (void)processAirportsData:(NSData*)data {
    
    NSArray *airports = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Airport"];
    NSError *fetchError = nil;
    NSMutableArray *airportsToDelete = [[NSMutableArray alloc] initWithArray:[self.moc executeFetchRequest:request error:&fetchError]];
    
    for(NSDictionary *airportDict in airports) {
        
        // get locally saved airport if it exists
        request = [NSFetchRequest fetchRequestWithEntityName:@"Airport"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"iataCode", [airportDict stringForKey:keyAirportsIataCode defaultValue:@"(?)"]];
        request.predicate = predicate;
        NSError *fetchError = nil;
        Airport *newAirport = [[self.moc executeFetchRequest:request error:&fetchError] firstObject];
        
        // if it doesn't exists, create it
        if(!newAirport) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Airport" inManagedObjectContext:self.moc];
            newAirport = [[Airport alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
            newAirport.name = [airportDict stringForKey:keyAirportsName defaultValue:@"(?)"];
            newAirport.iataCode = [airportDict stringForKey:keyAirportsIataCode defaultValue:@"(?)"];
        }
        
        // else, remove airport from airportsToDelete
        else {
            [airportsToDelete removeObject:newAirport];
        }
    }
    
    for(Airport *a in airportsToDelete) {
        [self.moc deleteObject:a];
    }
    
    [self saveMOC:self.moc];
}

- (void)processFlightsData:(NSData*)data {
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSMutableArray *flightsToDelete = [NSMutableArray arrayWithArray:[self findAllAuthorizedFlights]];
    
    if([dict arrayForKey:keyFlightsAuthorizedFlights defaultValue:@[]]) {
        
        NSArray *authorizedFlights = [dict arrayForKey:keyFlightsAuthorizedFlights defaultValue:@[]];
        for(NSDictionary *flightDict in authorizedFlights) {
            Flight *newFlight = nil;
            BOOL updatedExisting = [self processFlight:flightDict providersArray:[dict arrayForKey:keyFlightsProviders defaultValue:@[]] isProtector:NO pointer:&newFlight];
            
            // remove flight from flights to delete
            if(updatedExisting) {
                for(NSUInteger i = 0; i < flightsToDelete.count; i++) {
                    Flight *f = flightsToDelete[i];
                    if([newFlight.flightName isEqualToString:f.flightName] && [newFlight.departureDate isEqual:f.departureDate]) {
                        [flightsToDelete removeObject:f];
                        i = flightsToDelete.count;  // break
                    }
                }
            }
        }
        
        for(Flight *f in flightsToDelete) {
            [self.moc deleteObject:f];
        }
            
        [self saveMOC:self.moc];
    }
}

- (void)processPassengersData:(NSData*)data {
    
    NSMutableDictionary *paxEmailTable = [NSMutableDictionary new];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    Flight *flight = nil;
    [self processFlight:dict[keyPassengersAuthorizedFlight] providersArray:nil isProtector:NO pointer:&flight];
    flight.updateDate = [NSDate date];
    NSSet *cabins = [flight.cabins copy];
    
    // remove current passengers
    NSSet *flightsPassengers = [flight.passengers copy];
    for(Passenger *p in flightsPassengers) {
        if(p.email != nil) {
            paxEmailTable[p.passengerID] = p.email;
        }
        [flight removePassengersObject:p];
        [self.moc deleteObject:p];
    }
    // remove current services
    NSSet *foodServices = [flight.foodServices copy];
    for(FoodService *f in foodServices) {
        [flight removeFoodServicesObject:f];
        [self.moc deleteObject:f];
    }
    NSSet *transportServices = [flight.travelServices copy];
    for(TravelService *t in transportServices) {
        [flight removeTravelServicesObject:t];
        [self.moc deleteObject:t];
    }
    NSSet *hotelServices = [flight.hotelServices copy];
    for(HotelService *h in hotelServices) {
        [flight removeHotelServicesObject:h];
        [self.moc deleteObject:h];
    }
    
    NSArray *passengers = ([dict arrayForKey:keyPassengersAllPassengers defaultValue:@[]]);
    for(NSDictionary *passengerDict in passengers) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Passenger" inManagedObjectContext:self.moc];
        Passenger *newPassenger = [[Passenger alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
        [flight addPassengersObject:newPassenger];
        newPassenger.firstName      = [passengerDict stringForKey:keyPassengersFirstName defaultValue:@"(?)"];
        newPassenger.lastName       = [passengerDict stringForKey:keyPassengersLastName defaultValue:@"(?)"];
        newPassenger.pnr            = [passengerDict stringForKey:keyPassengersPNR defaultValue:@"(?)"];
        newPassenger.passengerID    = [passengerDict numberForKey:keyPassengersID defaultValue:@(-1)];
        newPassenger.type           = [passengerDict stringForKey:keyPassengersType defaultValue:@"REGULAR"];
        newPassenger.editCodes      = [passengerDict stringForKey:keyPassengersEditCodes defaultValue:@"(?)"];
        
        NSString *countryCode = [passengerDict stringForKey:keyPassengersDocIssuingCountry defaultValue:nil];
        
        if(countryCode != nil && countryCode.length == 2) {
            newPassenger.documentType   = [passengerDict stringForKey:keyPassengersDocType defaultValue:nil];
            newPassenger.documentNumber = [passengerDict stringForKey:keyPassengersDocNumber defaultValue:nil];
            newPassenger.docIssuingCountry = countryCode;
        }
        
        NSDictionary *otherInfoDict = [passengerDict dictForKey:keyPassengersOtherInfo defaultValue:@{}];
        newPassenger.voluntary = [otherInfoDict stringForKey:keyPassengersVoluntary defaultValue:@"NO"];
        
        newPassenger.email = paxEmailTable[newPassenger.passengerID];
        if(newPassenger.email == nil) {
            newPassenger.email = [otherInfoDict stringForKey:keyPassengersEmail defaultValue:nil];
        }
        
        NSSet *filteredCabins = [cabins filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", [passengerDict stringForKey:keyPassengersCabin defaultValue:@"(?)"]]];
        newPassenger.cabin = [filteredCabins anyObject];
        
        NSArray *vouchers = [passengerDict arrayForKey:keyPassengersAllVouchers defaultValue:@[]];
        for(NSDictionary *vDict in vouchers) {
            
            NSString *code = [vDict stringForKey:keyPassengersVoucherTypeCode defaultValue:@"(?)"];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Voucher" inManagedObjectContext:self.moc];
            Voucher *newVoucher = [[Voucher alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
            newVoucher.serviceType = [vDict stringForKey:keyPassengersVoucherService defaultValue:@"(?)"];
            
            //NOTE(diego_cath): this is a patch. remove this when backend issues are fixed
            
            if([code isEqualToString:@"AH"] || [code isEqualToString:@"AL"]) {
                code = @"A1";
            }
            else if([code isEqualToString:@"SH"] || [code isEqualToString:@"SN"]) {
                code = @"S1";
            }
            
            newVoucher.typeCode = code;
            newVoucher.serviceName = [vDict stringForKey:keyPassengersVoucherTypeDescription defaultValue:@"(?)"];
            newVoucher.numberOfVouchers = [vDict numberForKey:keyPassengersVoucherAmount defaultValue:@0];
            [newPassenger addVouchersObject:newVoucher];
        }
    }
    
    [self saveMOC:self.moc];
}

- (void)processHotelAvailabilityData:(NSData*)data {
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSArray *hotelInfos = [dict arrayForKey:keyServiceHotel defaultValue:@[]];
    
    for(NSDictionary *hotelInfo in hotelInfos) {
        
        NSString *provider = [hotelInfo stringForKey:keyServiceHotelProviderName defaultValue:@"(?)"];
        NSArray *roomInfoArray = [hotelInfo arrayForKey:keyServiceHotelRoomTypes defaultValue:@[]];
        int singleAvailability = 0, doubleAvailability = 0;
        
        for(NSDictionary *roomInfo in roomInfoArray) {
            
            if([[roomInfo stringForKey:keyServiceHotelSubCode defaultValue:@"(?)"] isEqualToString:@"SG"]) {
                singleAvailability = [[roomInfo numberForKey:keyServiceHotelRoomAvailability defaultValue:@0] intValue];
            } else if([[roomInfo stringForKey:keyServiceHotelSubCode defaultValue:@"(?)"] isEqualToString:@"DB"]) {
                doubleAvailability = [[roomInfo numberForKey:keyServiceHotelRoomAvailability defaultValue:@0] intValue];
            }
        }
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"HotelService"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"provider", provider];
        request.predicate = predicate;
        
        NSError *fetchError = nil;
        NSArray *results = [self.moc executeFetchRequest:request error:&fetchError];
        
        for(HotelService *service in results) {
            
            if([service.subCode isEqualToString:@"SG"]) {
                service.roomAvailibility = @(singleAvailability);
            } else if([service.subCode isEqualToString:@"DB"]) {
                service.roomAvailibility = @(doubleAvailability);
            }
        }
    }
    
    [self saveMOC:self.moc];
}

- (NSString*)processCompensationData:(NSData*)data {
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if(dict[keyCompensationEmissionFoid] != nil && [dict[keyCompensationEmissionFoid] isEqual:[NSNull null]] == NO) {
        return dict[keyCompensationEmissionFoid];
    } else {
        return nil;
    }
}

- (NSArray*)processDocumentTypesData:(NSData*)data {

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSArray *docTypesArray = [dict arrayForKey:keyDocTypesArray defaultValue:@[]];
    NSMutableArray *retArray = [NSMutableArray new];
    
    for(NSDictionary *docTypeDict in docTypesArray) {
        
        DocumentTypeDetails *doc = [DocumentTypeDetails new];
        doc.name = [docTypeDict stringForKey:keyDocTypesName defaultValue:@"(?)"];
        doc.code = [docTypeDict stringForKey:keyDocTypesCode defaultValue:@"(?)"];
        doc.mask = [docTypeDict stringForKey:keyDocTypesMask defaultValue:@"(?)"];
        [retArray addObject:doc];
    }

    return retArray;
}

- (BOOL)processFlight:(NSDictionary*)flightDict providersArray:(NSArray*)providers isProtector:(BOOL)isProtector pointer:(Flight**)pointer {
    
    BOOL updatedExisting = NO;
    
    // parse date
    NSString *dateStr = [flightDict stringForKey:keyFlightsDepartureDate defaultValue:@""];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"dd-MM-yyyy";
    NSDate *date = [df dateFromString:dateStr];

    // NOTE(diego_cath): this variable is just a patch because backend has 2 names for flight numbers
    NSString *flightNumberKey = keyFlightsFlightNumber2;
    
    NSEntityDescription *entity;
    Flight *newFlight;
    
    // get locally saved flight if it exists (only for authorized flights)
    if(isProtector == NO) {
        flightNumberKey = keyFlightsFlightNumber1;
        newFlight = [self findAuthorizedFlightWithAirlineCode:[flightDict stringForKey:keyFlightsAirlineCode defaultValue:@"(?)"] flightNumber:[flightDict stringForKey:flightNumberKey defaultValue:@"(?)"] andDate:date];
        if(newFlight != nil) {
            updatedExisting = YES;
        }
    }
    
    if(newFlight == nil) {
        entity = [NSEntityDescription entityForName:@"Flight" inManagedObjectContext:self.moc];
        newFlight = [[Flight alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
    }
    
    newFlight.arrivalAirport    = [flightDict stringForKey:keyFlightsArrivalAirport defaultValue:@"(?)"];
    newFlight.departureAirport  = [flightDict stringForKey:keyFlightsDepartureAirport defaultValue:@"(?)"];
    newFlight.airlineCode       = [flightDict stringForKey:keyFlightsAirlineCode defaultValue:@"(?)"];
    newFlight.flightNumber      = [flightDict stringForKey:flightNumberKey defaultValue:@"(?)"];
    newFlight.departureDate     = date;
    
    // ----- cabins
    
    NSArray *cabins = [flightDict arrayForKey:keyFlightsAllCabins defaultValue:@[]];
    
    if(cabins != nil && cabins.count > 0) {
        
        // remove current cabins
        NSSet *currentCabins = [newFlight.cabins copy];
        for(Cabin *c in currentCabins) {
            [newFlight removeCabinsObject:c];
            [self.moc deleteObject:c];
        }
        
        for(NSDictionary *cabinDict in cabins) {
            entity = [NSEntityDescription entityForName:@"Cabin" inManagedObjectContext:self.moc];
            Cabin *newCabin = [[Cabin alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
            newCabin.name           = [cabinDict stringForKey:keyFlightsCabinCode defaultValue:@"(?)"];
            newCabin.currentValue   = [cabinDict numberForKey:keyFlightsCabinSize defaultValue:@0];
            [newFlight addCabinsObject:newCabin];
        }
    }
    
    // ----- providers
    
    if(providers) {
        
        // remove current providers
        NSMutableSet *foodProviders = [newFlight.foodProviders copy];
        for(Provider *p in foodProviders) {
            [newFlight removeFoodProvidersObject:p];
            [self.moc deleteObject:p];
        }
        
        foodProviders = [[NSMutableSet alloc] init];
        for(NSDictionary *providerDict in providers) {
            
            if([[providerDict stringForKey:keyFlightsProvidersName defaultValue:@"(?)"] isEqualToString:kProvidersPatch]) {
                continue;
            }
            
            entity = [NSEntityDescription entityForName:@"Provider" inManagedObjectContext:self.moc];
            Provider *newProvider = [[Provider alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
            newProvider.name = [providerDict stringForKey:keyFlightsProvidersName defaultValue:@"(?)"];
            [foodProviders addObject:newProvider];
        }
        
        [newFlight addFoodProviders:foodProviders];
    }
    
    if(isProtector) {
        
        // NOTE(diego_cath): protector flights come with a compensation and a list of services
        
        // protectorID
        newFlight.protectorID = [flightDict stringForKey:keyFlightsProtectorID defaultValue:@""];
        
        // compensation
        NSDictionary *compensationDict = [[flightDict arrayForKey:keyCompensation defaultValue:@[]] firstObject];
        entity = [NSEntityDescription entityForName:@"CompensationService" inManagedObjectContext:self.moc];
        CompensationService *compensationService = [[CompensationService alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
        
        compensationService.cashAmount = [compensationDict stringForKey:keyCompensationCash defaultValue:@"0"];
        compensationService.servicesAmount = [compensationDict stringForKey:keyCompensationLatamServices defaultValue:@"0"];
        compensationService.cause = [flightDict stringForKey:keyFlightsCompensationCause defaultValue:@"(?)"];
        compensationService.motive = [flightDict stringForKey:keyFlightsCompensationMotive defaultValue:@"(?)"];
        compensationService.signatureRequired = [compensationDict numberForKey:keyCompensationSignatureRequired defaultValue:@(NO)];
        compensationService.upgrade = [compensationDict numberForKey:keyCompensationUpgrade defaultValue:@(NO)];
        [newFlight addCompensationServicesObject:compensationService];
        
        // services
        [self processServices:[flightDict dictForKey:keyFlightsAllServices defaultValue:@{}] forFlight:newFlight];
    
    } else {
        
        // NOTE(diego_cath): authorized flights come with a contingency details and a list of protectors
        
        newFlight.contingencyCode = [flightDict stringForKey:keyFlightsContingencyCode defaultValue:@"(?)"];
        newFlight.contingencyDetails = [flightDict stringForKey:keyFlightsContingencyDetails defaultValue:@"(?)"];
        
        // remove current protectors
        NSArray *protectorFlights = [newFlight.protectorFlights allObjects];
        for(Flight *f in protectorFlights) {
            [newFlight removeProtectorFlightsObject:f];
            [self.moc deleteObject:f];
        }
        
        protectorFlights = [flightDict arrayForKey:keyFlightsProtectorFlights defaultValue:@[]];
        for(NSDictionary *flightDict in protectorFlights) {
            Flight *protector = nil;
            [self processFlight:flightDict providersArray:[flightDict arrayForKey:keyFlightsProviders defaultValue:@[]] isProtector:YES pointer:&protector];
            [newFlight addProtectorFlightsObject:protector];
        }
    }
    
    if(pointer) {
        *pointer = newFlight;
    }
    
    return updatedExisting;
}

- (void)processServices:(NSDictionary*)services forFlight:(Flight*)flight {
    
    NSArray *foods = [services arrayForKey:keyServiceFood defaultValue:@[]];
    for(NSDictionary *foodDict in foods) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FoodService" inManagedObjectContext:self.moc];
        FoodService *newFood = [[FoodService alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
        newFood.type = [foodDict stringForKey:keyServiceFoodType defaultValue:@"(?)"];
        newFood.code = [foodDict stringForKey:keyServiceFoodCode defaultValue:@"(?)"];
        newFood.subCode = [foodDict stringForKey:keyServiceFoodSubCode defaultValue:@"(?)"];
        newFood.details = [foodDict stringForKey:keyServiceFoodDetails defaultValue:@"(?)"];
        newFood.amount = [foodDict numberForKey:keyServiceFoodAmount defaultValue:@0];
        newFood.currency = [foodDict stringForKey:keyServiceFoodCurrency defaultValue:@"(?)"];
        newFood.signatureRequired = [foodDict numberForKey:keyServiceFoodSignatureRequired defaultValue:@(NO)];
        newFood.printAmount = [foodDict numberForKey:keyServiceFoodPrintAmount defaultValue:@(NO)];
        [flight addFoodServicesObject:newFood];
    }
    
    NSArray *snacks = [services arrayForKey:keyServiceSnack defaultValue:@[]];
    for(NSDictionary *foodDict in snacks) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FoodService" inManagedObjectContext:self.moc];
        FoodService *newFood = [[FoodService alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
        newFood.type = [foodDict stringForKey:keyServiceSnackType defaultValue:@"(?)"];
        newFood.code = [foodDict stringForKey:keyServiceSnackCode defaultValue:@"(?)"];
        newFood.subCode = [foodDict stringForKey:keyServiceSnackSubCode defaultValue:@"(?)"];
        newFood.details = [foodDict stringForKey:keyServiceSnackDetails defaultValue:@"(?)"];
        newFood.amount = [foodDict numberForKey:keyServiceSnackAmount defaultValue:@0];
        newFood.currency = [foodDict stringForKey:keyServiceSnackCurrency defaultValue:@"(?)"];
        newFood.signatureRequired = [foodDict numberForKey:keyServiceSnackSignatureRequired defaultValue:@(NO)];
        newFood.printAmount = [foodDict numberForKey:keyServiceSnackPrintAmount defaultValue:@(NO)];
        [flight addFoodServicesObject:newFood];
    }
    
    NSArray *travels = [services arrayForKey:keyServiceTransport defaultValue:@[]];
    for(NSDictionary *transportDict in travels) {
        
        // provider
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Provider" inManagedObjectContext:self.moc];
        Provider *newProvider = [[Provider alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
        newProvider.name = [transportDict stringForKey:keyServiceTransportProviderName defaultValue:@"(?)"];
        newProvider.providerID = [transportDict numberForKey:keyServiceTransportProviderID defaultValue:@(-1)];
        
        // service
        entity = [NSEntityDescription entityForName:@"TravelService" inManagedObjectContext:self.moc];
        TravelService *newTransport = [[TravelService alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
        newTransport.provider = newProvider;
        newTransport.details = [transportDict stringForKey:keyServiceTransportDetails defaultValue:@"(?)"];
        newTransport.code = [transportDict stringForKey:keyServiceTransportCode defaultValue:@"(?)"];
        newTransport.subCode = [transportDict stringForKey:keyServiceTransportSubCode defaultValue:@"(?)"];
        newTransport.signatureRequired = [transportDict numberForKey:keyServiceFoodSignatureRequired defaultValue:@(NO)];
        
        [flight addTravelServicesObject:newTransport];
    }
    
    NSArray *hotels = [services arrayForKey:keyServiceHotel defaultValue:@[]];
    for(NSDictionary *hotelDict in hotels) {
        
        for(NSDictionary *roomTypeDict in [hotelDict arrayForKey:keyServiceHotelRoomTypes defaultValue:@[]]) {
            
            // provider
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Provider" inManagedObjectContext:self.moc];
            Provider *newProvider = [[Provider alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
            newProvider.name = [hotelDict stringForKey:keyServiceHotelProviderName defaultValue:@"(?)"];
            newProvider.providerID = [hotelDict numberForKey:keyServiceHotelProviderID defaultValue:@(-1)];
            
            // service
            entity = [NSEntityDescription entityForName:@"HotelService" inManagedObjectContext:self.moc];
            HotelService *newHotel = [[HotelService alloc] initWithEntity:entity insertIntoManagedObjectContext:self.moc];
            newHotel.provider = newProvider;
            newHotel.code = [roomTypeDict stringForKey:keyServiceHotelCode defaultValue:@"(?)"];
            newHotel.subCode = [roomTypeDict stringForKey:keyServiceHotelSubCode defaultValue:@"(?)"];
            newHotel.roomTypeDesc = [roomTypeDict stringForKey:keyServiceHotelRoomTypeDesc defaultValue:@"(?)"];
            newHotel.roomAvailibility = [roomTypeDict numberForKey:keyServiceHotelRoomAvailability defaultValue:@0];
            newHotel.signatureRequired = [hotelDict numberForKey:keyServiceFoodSignatureRequired defaultValue:@(NO)];
            
            [flight addHotelServicesObject:newHotel];
        }
    }
}

- (void)saveMOC:(NSManagedObjectContext*)moc {
    if (moc) {
        NSError *error = nil;
        if ([moc hasChanges] && ![moc save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [((AppDelegate*)([UIApplication sharedApplication].delegate)).managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

- (NSArray*)findAllAuthorizedFlights {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contingencyCode != NIL"];
    return [self findAllFlightsWithPredicate:predicate];
}

- (NSArray*)findAllProtectorFlights {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contingencyCode == NIL"];
    return [self findAllFlightsWithPredicate:predicate];
}

- (NSArray*)findAllFlightsWithPredicate:(NSPredicate*)predicate {
    NSMutableArray *flights;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Flight"];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"departureDate" ascending:YES];
    request.sortDescriptors = @[sortDesc];
    request.predicate = predicate;
    NSError *fetchError = nil;
    NSArray *result = [self.moc executeFetchRequest:request error:&fetchError];
    if (!fetchError) {
        flights = [NSMutableArray new];
        for(Flight *flight in result) {
            [flights addObject:flight];
        }
    }
    
    return flights;
}

- (Flight*)findAuthorizedFlightWithAirlineCode:(NSString*)airlineCode flightNumber:(NSString*)flightNumber andDate:(NSDate*)date {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@ AND contingencyCode != NIL", @"airlineCode", airlineCode, @"flightNumber", flightNumber];
    
    NSArray *flights = [self findAllFlightsWithPredicate:predicate];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger day = components.day;
    NSInteger month = components.month;
    NSInteger year = components.year;
    
    for(Flight *f in flights) {
        
        components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:f.departureDate];
        
        if(day == components.day && month == components.month && year == components.year) {
            return f;
        }
    }
    
    return nil;
}

- (void)printCoreDataObjectCount {
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray *entityNames = [[appDelegate.managedObjectModel entities] valueForKey:@"name"];
    
    for(NSString *name in entityNames) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
        NSError *fetchError = nil;
        NSArray *results = [self.moc executeFetchRequest:request error:&fetchError];
        NSLog(@"%@: %ld", name, results.count);
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
