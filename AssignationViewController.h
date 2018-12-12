//
//  VoucherSelectionViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Passenger.h"
#import "Synchronizer.h"
#import "LTMBaseViewController.h"

@interface AssignationViewController : LTMBaseViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property(nonatomic, strong) Passenger *passenger;

@end
