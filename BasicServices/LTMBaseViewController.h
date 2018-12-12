//
//  LTMBaseViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 2/29/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTMBaseViewController : UIViewController

- (void)backButtonPressed;

- (void)scanButtonPressed;

- (void)syncButtonPressed;

- (void)logoutButtonPressed;

- (void)popToFlightsViewController;

@end
