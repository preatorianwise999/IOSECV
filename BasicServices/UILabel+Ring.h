//
//  UILabel+Border.h
//  Nimbus2
//
//  Created by 720368 on 7/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
@interface UILabel (Ring)

// draws two rings at the center of the label: an inner ring and an incomplete inner ring that represents a progress percentage
- (void)drawRingWithProgressPercentage:(float)p radius:(int)r ringColor:(UIColor*)color1 progressColor:(UIColor*)color2;

// draws a ring at the center of the label
- (void)drawRingWithRadius:(int)r color:(UIColor*)color;

- (void)drawRingWithRadius:(int)r thickness:(float)t color:(UIColor*)color;

@end
