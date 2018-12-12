//
//  UIColor+CommonValues.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/6/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "UIColor+CommonValues.h"

#import "AppDelegate.h"

@implementation UIColor (CommonValues)

+ (UIColor*)titleBarColor {
    
    return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.1];
}

+ (UIColor*)appDarkColorWithOpacity:(float)alpha {
    
    return [UIColor colorWithRed:.075 green:.2 blue:.372 alpha:alpha];
}

+ (UIColor*)appLightColorWithOpacity:(float)alpha {
    
    return [UIColor colorWithRed:48.0/255.0 green:78.0/255.0 blue:111.0/255.0 alpha:alpha];
}

+ (UIColor*)searchBackgroundColor {
    
    return [UIColor colorWithRed:.0 green:.3 blue:.5 alpha:.3];
}



@end
