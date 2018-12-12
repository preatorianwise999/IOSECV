//
//  ViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WebHelper.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, WebHelperDelegate, UIGestureRecognizerDelegate>

- (void)logout;

@end

