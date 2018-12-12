//
//  Passenger.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/8/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Cabin, Flight, Voucher;

NS_ASSUME_NONNULL_BEGIN

@interface Passenger : NSManagedObject

@property (nonatomic, strong) UIImage *signatureImage;

@end

NS_ASSUME_NONNULL_END

#import "Passenger+CoreDataProperties.h"
