//
//  ProtectorFlightSelectionViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/7/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Flight;

@protocol ProtectorFlightSelectionDelegate

- (void)protectorFlightSelected:(Flight*)flight;

@end

@interface ProtectorFlightSelectionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property(nonatomic, strong) Flight *currentFlight;
@property(nonatomic, strong) NSArray *flights;
@property(nonatomic, weak) id<ProtectorFlightSelectionDelegate> delegate;

- (void)showAnimated;
- (void)hideAnimated;

@end
