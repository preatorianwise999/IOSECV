//
//  CompensationService+CoreDataProperties.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CompensationService.h"

NS_ASSUME_NONNULL_BEGIN

@interface CompensationService (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cashAmount;
@property (nullable, nonatomic, retain) NSString *cause;
@property (nullable, nonatomic, retain) NSString *motive;
@property (nullable, nonatomic, retain) NSString *servicesAmount;
@property (nullable, nonatomic, retain) NSNumber *signatureRequired;
@property (nullable, nonatomic, retain) NSNumber *upgrade;
@property (nullable, nonatomic, retain) Flight *flight;

@end

NS_ASSUME_NONNULL_END
