//
//  ServicesTableViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/3/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServicesTableViewCell.h"
#import "ServiceSelectionView.h"
#import "HotelSelectionViewController.h"
#import "ProtectorFlightSelectionViewController.h"

#define kStrHighValue       @"HIGH VALUE"
#define kStrRegular         @"REGULAR"

@class VoucherInput;
@class Flight;
@class CheckoutInput;

@interface ServicesTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, ServiceCellDelegate, ServiceSelectionDelegate, HotelSelectionDelegate, ProtectorFlightSelectionDelegate>

@property(nonatomic, strong) ServiceSelectionView *serviceSelectionView;
@property(nonatomic, strong) HotelSelectionViewController *hotelSelectionController;
@property(nonatomic, strong) ProtectorFlightSelectionViewController *protectorSelectionController;
@property(nonatomic) CGPoint center;
@property (weak, nonatomic) NSLayoutConstraint *servicesHeightConstraint;

@property(nonatomic) BOOL includeCompensationSection;
@property(nonatomic) BOOL includeFoodSection;
@property(nonatomic) BOOL includeTransportSection;
@property(nonatomic) BOOL includeHotelSection;

@property(nonatomic, strong) CheckoutInput *input;

- (id)initWithTableView:(UITableView*)tableView andFlight:(Flight*)flight;
- (int)formHeight;

@end
