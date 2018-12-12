//
//  UIButton+BorderFill.m
//  Nimbus2
//
//  Created by 720368 on 7/24/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "UIButton+BorderFill.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIButton (BorderFill)

- (void)setUnclicked {
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderColor = self.backgroundColor.CGColor;
    UIColor *mycolor =  [UIColor colorWithCGColor:self.layer.borderColor];
    self.layer.borderWidth = 1.0f;
    self.backgroundColor = [UIColor whiteColor];
    [self setTitleColor:mycolor forState:UIControlStateNormal];
}

- (void)setClicked {
    self.layer.cornerRadius = self.frame.size.width/2;
    self.backgroundColor = [UIColor colorWithCGColor:self.layer.borderColor];
    self.layer.borderColor = self.backgroundColor.CGColor;
    self.layer.borderWidth = 0.0f;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

@end
