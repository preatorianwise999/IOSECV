//
//  PassengersViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SectionHeaderView.h"
#import "WebHelper.h"
#import "Synchronizer.h"
#import "LTMBaseViewController.h"

@interface PassengersViewController : LTMBaseViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SectionHeaderViewDelegate, UIGestureRecognizerDelegate, SyncDelegate, UITextFieldDelegate, WebHelperDelegate>

@property(nonatomic, strong) Flight *flight;

@end
