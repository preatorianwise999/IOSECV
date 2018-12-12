//
//  HotelSelectionViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/7/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HotelSelectionDelegate

- (void)hotelSelected:(NSString*)hotelName;

@end

@interface HotelSelectionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id<HotelSelectionDelegate> delegate;

- (void)loadDataWithServices:(NSSet*)hotelServices;
- (void)showAnimated;
- (void)hideAnimated;

@end
