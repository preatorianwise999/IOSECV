//
//  Voucher+CoreDataProperties.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Voucher.h"

NS_ASSUME_NONNULL_BEGIN

@interface Voucher (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *numberOfVouchers;
@property (nullable, nonatomic, retain) NSString *serviceName;
@property (nullable, nonatomic, retain) NSString *serviceType;
@property (nullable, nonatomic, retain) NSString *typeCode;
@property (nullable, nonatomic, retain) Passenger *passenger;

@end

NS_ASSUME_NONNULL_END