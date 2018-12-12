//
//  TitleBar.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    kSideLeft,
    kSideRight
    
} TBSide;

/*
    Custom implementation of a UINavigationBar. You can add one title view at the center and multiple views at the left or right hand side of the bar.
 */

@interface TitleBar : UIView

// adds a UILabel at the center of the bar
- (void)addTitle:(NSString*)title;

// adds a UIImage at the center of the bar
- (void)addTitleImageNamed:(NSString*)imageName;

// adds the specified UIView at the right or left hand side of the bar. New items are added from the outside in.
- (void)addView:(UIView*)view onSide:(TBSide)side;

@end
