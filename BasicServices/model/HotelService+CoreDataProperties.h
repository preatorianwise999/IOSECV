//
//  HotelService+CoreDataProperties.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HotelService.h"

NS_ASSUME_NONNULL_BEGIN

@interface HotelService (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSNumber *roomAvailibility;
@property (nullable, nonatomic, retain) NSString *roomTypeDesc;
@property (nullable, nonatomic, retain) NSString *subCode;
@property (nullable, nonatomic, retain) NSNumber *signatureRequired;
@property (nullable, nonatomic, retain) Flight *flight;
@property (nullable, nonatomic, retain) Provider *provider;

@end

NS_ASSUME_NONNULL_END
