//
//  CustomAlertView.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 10/23/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertView : UIView

@property (weak, nonatomic) IBOutlet UILabel *messageLb;

- (void)showAnimated;
- (void)hideAnimated;
- (void)addItemView:(UIView*)view;

@end
