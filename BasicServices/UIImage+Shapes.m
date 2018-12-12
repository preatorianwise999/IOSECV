//
//  UIImage+Shapes.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/30/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "UIImage+Shapes.h"

@implementation UIImage (Shapes)

+ (UIImage*)drawRoundRectWithWidth:(int)w height:(int)h radius:(int)r thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, thickness, thickness);
    
    CGRect ovalRect = CGRectMake(0, 0, w, h);
    ovalRect = CGRectInset(ovalRect, thickness + 1, thickness + 1);
    
    [borderColor setStroke];
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:ovalRect cornerRadius:r];
    
    [path fill];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)drawRectWithRightRoundCornersWithWidth:(int)w height:(int)h radius:(int)r thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, thickness, thickness);
    
    CGRect ovalRect = CGRectMake(0, 0, w, h);
    ovalRect = CGRectInset(ovalRect, thickness + 1, thickness + 1);
    CGRect sharpRect = CGRectMake(0, 0, w/2, h);
    sharpRect = CGRectInset(sharpRect, thickness + 1, thickness + 1);
    
    [borderColor setStroke];
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:ovalRect cornerRadius:r];
    [path appendPath:[UIBezierPath bezierPathWithRect:sharpRect]];
    
    [path fill];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)drawRectWithWidth:(int)w height:(int)h thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, thickness, thickness);
    
    CGRect rect = CGRectMake(0, 0, w, h);
    rect = CGRectInset(rect, thickness + 1, thickness + 1);
    
    [borderColor setStroke];
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    [path fill];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage*)drawCircleWithWidth:(int)w height:(int)h thickness:(int)thickness fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, thickness, thickness);
    
    CGRect rect = CGRectMake(0, 0, w, h);
    rect = CGRectInset(rect, thickness + 1, thickness + 1);
    
    [borderColor setStroke];
    [fillColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [path fill];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

@end
