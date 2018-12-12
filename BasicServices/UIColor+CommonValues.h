//
//  UIColor+CommonValues.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/6/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CommonValues)

+ (UIColor*)titleBarColor;
+ (UIColor*)appDarkColorWithOpacity:(float)alpha;
+ (UIColor*)appLightColorWithOpacity:(float)alpha;
+ (UIColor*)searchBackgroundColor;

@end
