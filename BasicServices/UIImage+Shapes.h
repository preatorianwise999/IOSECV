//
//  UIImage+Shapes.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/30/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Shapes)

// returns a UIImage that represents a rectangle with round corners
+ (UIImage*)drawRoundRectWithWidth:(int)w height:(int)h radius:(int)r thickness:(int)thikness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor;

// return a UIImage that represents a rectangle whose right side corners are rounded
+ (UIImage*)drawRectWithRightRoundCornersWithWidth:(int)w height:(int)h radius:(int)r thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor;

// returns a UIImage that represents a rectangle
+ (UIImage*)drawRectWithWidth:(int)w height:(int)h thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor;

// returns a UIImage that represents a circle
+ (UIImage*)drawCircleWithWidth:(int)w height:(int)h thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor;

@end
