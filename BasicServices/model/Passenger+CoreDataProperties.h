//
//  Passenger+CoreDataProperties.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 6/20/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Passenger.h"

NS_ASSUME_NONNULL_BEGIN

@interface Passenger (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *boardingNumber;
@property (nullable, nonatomic, retain) NSString *destination;
@property (nullable, nonatomic, retain) NSString *docIssuingCountry;
@property (nullable, nonatomic, retain) NSString *documentNumber;
@property (nullable, nonatomic, retain) NSString *documentType;
@property (nullable, nonatomic, retain) NSString *editCodes;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSNumber *passengerID;
@property (nullable, nonatomic, retain) NSString *pnr;
@property (nullable, nonatomic, retain) NSString *ticketNumber;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *voluntary;
@property (nullable, nonatomic, retain) Cabin *cabin;
@property (nullable, nonatomic, retain) Flight *flight;
@property (nullable, nonatomic, retain) NSSet<Voucher *> *vouchers;

@end

@interface Passenger (CoreDataGeneratedAccessors)

- (void)addVouchersObject:(Voucher *)value;
- (void)removeVouchersObject:(Voucher *)value;
- (void)addVouchers:(NSSet<Voucher *> *)values;
- (void)removeVouchers:(NSSet<Voucher *> *)values;

@end

NS_ASSUME_NONNULL_END
