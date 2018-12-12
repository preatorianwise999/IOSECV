//
//  DetailedButton.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/30/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 UIButton used in PassengersViewController to represent the Companions and Basic Services buttons
 */

@interface DetailedButton : UIButton

// sets up the button with a title label (COMPANIONS) and a description label (# of companions)
- (void)setUpAsCompanionsBtnWithNumberOfCompanions:(NSUInteger)companions;

// sets up the button with a title label (BBSS) and a glyph icon
- (void)setUpAsBasicServicesBtn;

@end
