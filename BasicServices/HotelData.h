//
//  HotelData.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/9/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStrSingleRoom      @"SG"
#define kStrDoubleRoom      @"DB"

@interface HotelData : NSObject

@property(nonatomic, strong) NSString *hotelName;
@property(nonatomic) int nSingle;
@property(nonatomic) int nDouble;
@property(nonatomic, readonly) int numberOfBeds;

@end
