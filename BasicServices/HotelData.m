//
//  HotelData.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/9/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "HotelData.h"

@implementation HotelData

- (int)numberOfBeds {
    return self.nSingle + self.nDouble;
}

@end
