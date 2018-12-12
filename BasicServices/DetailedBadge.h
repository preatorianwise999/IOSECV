//
//  DetailedBadge.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/4/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Informative view composed of a circle background and 2 description labels ordered vertically. Used by CheckoutViewController
 */

@interface DetailedBadge : UIView

@property (weak, nonatomic) UILabel *ammountLabel;
@property (weak, nonatomic) UILabel *descriptionLabel;


@end
