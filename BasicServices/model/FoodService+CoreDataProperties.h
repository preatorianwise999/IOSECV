//
//  FoodService+CoreDataProperties.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 6/29/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FoodService.h"

NS_ASSUME_NONNULL_BEGIN

@interface FoodService (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *currency;
@property (nullable, nonatomic, retain) NSString *details;
@property (nullable, nonatomic, retain) NSNumber *signatureRequired;
@property (nullable, nonatomic, retain) NSString *subCode;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSNumber *printAmount;
@property (nullable, nonatomic, retain) Flight *flight;

@end

NS_ASSUME_NONNULL_END
