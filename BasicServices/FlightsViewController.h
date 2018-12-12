//
//  FlightViewController.h
//  Nimbus2
//
//  Created by 720368 on 7/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "WebHelper.h"
#import "Synchronizer.h"
#import "LTMBaseViewController.h"

@interface FlightsViewController : LTMBaseViewController<iCarouselDataSource, iCarouselDelegate, WebHelperDelegate, SyncDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@end
