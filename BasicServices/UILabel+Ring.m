//
//  UILabel+Border.m
//  Nimbus2
//
//  Created by 720368 on 7/10/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "UILabel+Ring.h"

@implementation UILabel (Ring)

- (void)drawRingWithProgressPercentage:(float)p radius:(int)r ringColor:(UIColor*)color1 progressColor:(UIColor*)color2 {
    CGPoint mid = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    double angle = (double)(360 * p) + 270;
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    int e = 6;
    circle.lineWidth = 2;
    circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(mid.x - r + e/2.0, mid.y - r +  e/2.0, 2*r - e, 2*r - e)].CGPath;
    circle.strokeColor = color1.CGColor;
    circle.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:circle];
    
    CAShapeLayer *ring = [CAShapeLayer layer];
    ring.lineWidth = e;
    ring.path = [UIBezierPath bezierPathWithArcCenter:mid
                                               radius:r
                                           startAngle:DEGREES_TO_RADIANS(270)
                                             endAngle:DEGREES_TO_RADIANS(angle)
                                            clockwise:YES].CGPath;
    ring.strokeColor = color2.CGColor;
    ring.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:ring];
}

- (void)drawRingWithRadius:(int)r color:(UIColor*)color {
    CGPoint mid = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CAShapeLayer *circle = [CAShapeLayer layer];
    int e = 6;
    circle.lineWidth = 1;
    circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(mid.x - r + e/2.0, mid.y - r + e/2.0, 2*r - e, 2*r - e)].CGPath;
    circle.strokeColor = color.CGColor;
    circle.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:circle];
}

- (void)drawRingWithRadius:(int)r thickness:(float)t color:(UIColor*)color {
    CGPoint mid = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CAShapeLayer *circle = [CAShapeLayer layer];
    int e = 6;
    circle.lineWidth = t;
    circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(mid.x - r + e/2.0, mid.y - r + e/2.0, 2*r - e, 2*r - e)].CGPath;
    circle.strokeColor = color.CGColor;
    circle.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:circle];
}


@end
