//Main Background.png
//  FlightViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "FlightsViewController.h"

#import "PassengersViewController.h"
#import "FlightCardViewController.h"
#import "AppDelegate.h"
#import "WebHelper.h"
#import "ModelHelper.h"
#import "ActivityIndicatorView.h"
#import "WarningIndicatorManager.h"
#import "SaveHelper.h"

#import "TitleBar.h"

#import "Flight.h"

#import "UIFont+CommonValues.h"
#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"

#import "Reachability.h"

@interface FlightsViewController () {
    UIViewController *oldChild;
    UIViewController *newChild;
}

@property(nonatomic, strong) NSArray *flights;
@property(nonatomic, weak) IBOutlet TitleBar *titleBar;
@property(nonatomic, strong) IBOutlet iCarousel *carousel;
@property(nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property(weak, nonatomic) IBOutlet UILabel *messageLabel;

@property(nonatomic, strong) WebHelper *webHelper;
@property(nonatomic, strong) Synchronizer *sync;
@property(nonatomic, strong) Flight *selectedFlight;
@property(strong, nonatomic) UITextField *searchTf;
@property(nonatomic, strong) NSString *filterKey;
@property(nonatomic, strong) NSMutableArray *filteredFlights;

@end

@implementation FlightsViewController

- (void)loadData {
    
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    ModelHelper *model = [[ModelHelper alloc] initWithMOC:moc];
    self.flights = [model findAllAuthorizedFlights];
    
    // page control
    self.pageControl.numberOfPages = self.flights.count;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // tap to hide keyboard
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(userTappedScreen)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    self.view.clipsToBounds = YES;
    
    // title bar
    [self.titleBar addTitleImageNamed:@"brand_lan.png"];
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn addTarget:self
                action:@selector(logoutButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    logoutBtn.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    [logoutBtn setImage:[UIImage imageNamed:@"ic_shutdown.png"] forState:UIControlStateNormal];
    [self.titleBar addView:logoutBtn onSide:kSideRight];
    
    UIButton *syncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [syncBtn addTarget:self
                action:@selector(syncButtonPressed)
      forControlEvents:UIControlEventTouchUpInside];
    syncBtn.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    [syncBtn setImage:[UIImage imageNamed:@"ic_reload.png"] forState:UIControlStateNormal];
    [self.titleBar addView:syncBtn onSide:kSideRight];
    
//    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [scanBtn addTarget:self
//                action:@selector(scanButtonPressed)
//      forControlEvents:UIControlEventTouchUpInside];
//    scanBtn.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
//    [scanBtn setImage:[UIImage imageNamed:@"ic_barcode.png"] forState:UIControlStateNormal];
//    [self.titleBar addView:scanBtn onSide:kSideRight];
    
    // search
    
    self.filterKey = @"";
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220.0, 50.0)];
    [self.titleBar addView:searchView onSide:kSideLeft];
    
    self.searchTf = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, 180.0, 40.0)];
    
    CGRect f = self.searchTf.bounds;
    UIImage *searchBackground = [UIImage drawRoundRectWithWidth:f.size.width height:f.size.height radius:f.size.height/2 thickness:0 fillColor:[UIColor searchBackgroundColor] borderColor:[UIColor clearColor]];
    self.searchTf.borderStyle = UITextBorderStyleNone;
    self.searchTf.background = searchBackground;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.searchTf.leftView = paddingView;
    self.searchTf.leftViewMode = UITextFieldViewModeAlways;
    self.searchTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"flight_placeholder_search", @"Search") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    self.searchTf.textColor = [UIColor whiteColor];
    self.searchTf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchTf.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchTf.spellCheckingType = UITextSpellCheckingTypeNo;
    self.searchTf.clearButtonMode = UITextFieldViewModeAlways;
    self.searchTf.delegate = self;
    self.searchTf.returnKeyType = UIReturnKeyGo;
    [self.searchTf addTarget:self action:@selector(filterFlights:) forControlEvents:UIControlEventEditingChanged];
    [searchView addSubview:self.searchTf];
    UIImageView *searchImg = [[UIImageView alloc] initWithFrame:CGRectMake(180.0, 5.0, 40.0, 40.0)];
    searchImg.image = [UIImage imageNamed:@"ic_search.png"];
    [searchView addSubview:searchImg];
    
    // carousel
    self.carousel.pagingEnabled = YES;
    self.carousel.type = iCarouselTypeCoverFlow;
    self.messageLabel.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self loadData];
    
    if(self.flights.count == 0) {
        self.carousel.hidden = YES;
        self.pageControl.hidden = YES;
        self.messageLabel.hidden = NO;
        self.searchTf.superview.hidden = YES;
    }
    
    self.filterKey = @"";
    self.searchTf.text = @"";
    [self.searchTf resignFirstResponder];
    self.filteredFlights = nil;
    
    NSInteger index = -1;
    if([self.flights containsObject:self.selectedFlight]) {
        index = [self.flights indexOfObject:self.selectedFlight];
    }
    
    [self.carousel reloadData];
    
    if(index >= 0) {
        [self.carousel scrollToItemAtIndex:index animated:NO];
    } else {
        [self moveToNextFlight];
    }
    
    // keyboard notifs
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scanButtonPressed {
    //NSLog(@"SCAN");
}

- (void)syncButtonPressed {
    
    [[ActivityIndicatorView getSharedInstance] startActivityInView:self.view withMessage:NSLocalizedString(@"activity_sync", @"Sync")];
    
    self.sync = [[Synchronizer alloc] init];
    self.sync.delegate = self;
    self.sync.forcedSync = YES;
    [self.sync synchronizeModel];
}

- (void)logoutButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)pushPassengersView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
    });
    PassengersViewController *pvc = [[PassengersViewController alloc] initWithNibName:@"PassengersViewController" bundle:nil];
    self.selectedFlight = [self getCurrentFlight];
    pvc.flight = self.selectedFlight;
    [self.navigationController pushViewController:pvc animated:YES];
}

- (Flight*)getCurrentFlight {
    
    if(self.carousel.currentItemIndex < 0) {
        return nil;
    }
    
    Flight *currentflight = self.flights[self.carousel.currentItemIndex];
    if(![self.filterKey isEqualToString:@""]) {
        currentflight = self.filteredFlights[self.carousel.currentItemIndex];
    }
    
    return currentflight;
}

- (void)didSelectFlight {
    
    [[ActivityIndicatorView getSharedInstance] startActivityInView:self.view withMessage:NSLocalizedString(@"activity_retrieving_passengers", @"Retrieving")];
    self.webHelper = [[WebHelper alloc] init];
    self.webHelper.delegate = self;
    [self.webHelper testServerConnection];
}

- (void)userTappedScreen {
    [self.view endEditing:YES];
}

- (void)filterFlights:(id)sender {
    
    NSString *key = self.searchTf.text;
    
    BOOL filterReset = NO;
    if(![self.filterKey isEqualToString:@""] && [key rangeOfString:self.filterKey].location != 0) {
        filterReset = YES;
    }
    
    Flight *currentFlight = [self getCurrentFlight];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        
        NSMutableArray *filteredFlights = [self.filteredFlights mutableCopy];
        
        if(filterReset || self.filterKey.length == 0) {
            filteredFlights = [self.flights mutableCopy];
        }
        
        if([key rangeOfString:self.filterKey].location == 0 || self.filterKey.length == 0 || filterReset) {
            
            // text was appended to the end
            // ---> remove rows from filteredPassengers
            NSMutableArray *indicesToRemove = [[NSMutableArray alloc] init];
            NSMutableArray *flightsToRemove = [[NSMutableArray alloc] init];
            
            if(![key isEqualToString:@""]) {
                for(int i = 0; i < filteredFlights.count; i++) {
                    NSString *flightName = ((Flight*)filteredFlights[i]).flightName;
                    
                    NSStringCompareOptions options = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
                    
                    if([flightName rangeOfString:key options:options].location != 0) {
                        [indicesToRemove addObject:@(i - indicesToRemove.count)];
                        [flightsToRemove addObject:filteredFlights[i]];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.filteredFlights = filteredFlights;
                
                for(NSString *s in flightsToRemove) {
                    [self.filteredFlights removeObject:s];
                }
                
                [self.carousel reloadData];
                
                NSUInteger newIndex = [self.filteredFlights indexOfObjectIdenticalTo:currentFlight];
                if(newIndex != NSNotFound) {
                    [self.carousel scrollToItemAtIndex:newIndex animated:NO];
                } else {
                    [self.carousel scrollToItemAtIndex:0 animated:NO];
                }
                
                if(self.filteredFlights.count == 0) {
                    self.messageLabel.hidden = NO;
                    self.carousel.hidden = YES;
                    self.pageControl.hidden = YES;
                } else {
                    self.messageLabel.hidden = YES;
                    self.carousel.hidden = NO;
                    self.pageControl.hidden = NO;
                }
                
                self.pageControl.numberOfPages = self.filteredFlights.count;
            });
        }
        
        self.filterKey = key;
    });
}

- (void)moveToNextFlight {
    
    [self.carousel scrollToItemAtIndex:self.flights.count - 1 animated:NO];
    
    for(int i = 0; i < self.flights.count; i++) {
        
        Flight *f = self.flights[i];
        
        if([[NSDate date] compare:f.departureDate] != NSOrderedDescending) {
            [self.carousel scrollToItemAtIndex:i animated:NO];
            break;
        }
    }
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(![self.filterKey isEqualToString:@""]) {
        
        Flight *result = nil;
        BOOL shouldPushNextView = NO;
        
        for(Flight *flight in self.filteredFlights) {
            
            if([flight.flightName compare:self.filterKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                
                if(result) {
                    shouldPushNextView = NO;
                } else {
                    result = flight;
                    shouldPushNextView = YES;
                }
            }
        }
        
        if(shouldPushNextView) {
            [self.carousel scrollToItemAtIndex:[self.filteredFlights indexOfObject:result] animated:NO];
            self.selectedFlight = result;
            [self didSelectFlight];
        } else if(result) {
            [self.carousel scrollToItemAtIndex:[self.filteredFlights indexOfObject:result] animated:YES];
        }
    }
    
    [self.view endEditing:YES];
    return YES;
}

#pragma mark SyncDelegate methods

- (void)synchronizationFinishedSuccessfully {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
        
        if([WarningIndicatorManager sharedInstance].currentWarningStyle == kWarningAdviceStyle) {
            
            [[WarningIndicatorManager sharedInstance] hide];
        }
        
        [self loadData];
        [self.carousel reloadData];
    });
}

- (void)synchronizationFinishedWithWarnings {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                        message:NSLocalizedString(@"alert_msg_sync_warning", @"Sync")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self loadData];
        [self.carousel reloadData];
    });
}

- (void)synchronizationDidFail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                        message:NSLocalizedString(@"alert_msg_sync_error", @"Sync")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self loadData];
        [self.carousel reloadData];
    });
}

#pragma mark WebHelperDelegate

- (void)serverConnectionTestEndedWithResult:(BOOL)serverReachable {
    
    Flight *flight = [self getCurrentFlight];
    
    if(serverReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *currentAirport = [[SaveHelper sharedInstance] loadStringForKey:kSelectedAirport];
            self.webHelper.delegate = self;
            [self.webHelper requestPassengerListForFlight:flight inAirport:currentAirport];
            
        });
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(flight.updateDate) {
                [self pushPassengersView];
                [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
            } else {
                [[ActivityIndicatorView getSharedInstance] stopAnimation];
                
                NSString *title, *msg;
                
                if([[Reachability reachabilityForInternetConnection] isReachable]) {
                    title = NSLocalizedString(@"alert_title_error", @"Error");
                    msg = NSLocalizedString(@"alert_msg_cant_reach_server", @"No server connection");
                } else {
                    title = NSLocalizedString(@"alert_title_no_connection", @"No Internet");
                    msg = NSLocalizedString(@"alert_msg_need_connection_for_passengers", @"No Internet");
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:msg
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        });
    }
}

- (void)serverRespondedWithData:(NSData *)data forRequestType:(RequestType)type {
    if(type == kRequestPassengers) {
        BOOL success = YES; //TODO: get this from JSON
        if(success) {
            [[[ModelHelper alloc] init] processPassengersData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pushPassengersView];
                if([WarningIndicatorManager sharedInstance].currentWarningStyle == kWarningErrorStyle) {
                    [[WarningIndicatorManager sharedInstance] hide];
                }
            });
        }
    }
}

- (void)connectionFailedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        Flight *flight = [self getCurrentFlight];
        if(flight.updateDate) {
            [self pushPassengersView];
            [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
        } else {
            [[ActivityIndicatorView getSharedInstance] stopAnimation];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                            message:NSLocalizedString(@"alert_msg_connection_error", @"Connection error")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    });
}

#pragma mark iCarousel

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel {
    
    if(![self.filterKey isEqualToString:@""]) {
        return self.filteredFlights.count;
    }
    
    return self.flights.count;
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    FlightCardViewController *fcView = [[FlightCardViewController alloc] initWithNibName:@"FlightCardViewController" bundle:nil];
    
    if(![self.filterKey isEqualToString:@""]) {
        
        if(carousel.numberOfItems != self.filteredFlights.count) {
            //NSLog(@"mistakes were made (1)");
            [self.carousel reloadData];
            return fcView.view;
        }
        
        fcView.flight = self.filteredFlights[index];
    } else {
        
        if(carousel.numberOfItems != self.flights.count) {
            //NSLog(@"mistakes were made (2)");
            [self.carousel reloadData];
            return fcView.view;
        }
        
        fcView.flight = self.flights[index];
    }
    
    return fcView.view;
}

- (NSInteger)numberOfPlaceholdersInCarousel:(__unused iCarousel *)carousel {
    //NOTE: placeholder views are only displayed on some carousels if wrapping is disabled
    return 0;
}

- (UIView *)carousel:(__unused iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    //create new view if no view is available for recycling
    if (view == nil) {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 754, 348)];
        
    } else {
        //get a reference to the label in the recycled view
        //label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //label.text = (index == 0)? @"[": @"]";
    
    return view;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return 700.0;
}

- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    //implement 'flip3D' style carousel
//    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
//    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carousel.itemWidth);
    
    return CATransform3DIdentity;
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 4.05f;
        }
        case iCarouselOptionFadeMinAlpha: {
            return 0.2;
        }
        case iCarouselOptionFadeMin: {
            return 0.0;
        }
        case iCarouselOptionFadeMax: {
            return 0.0;
        }
        case iCarouselOptionTilt: {
            return NO;
        }
        default: {
            return value;
        }
    }
}

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    NSInteger n = self.flights.count;
    if(![self.filterKey isEqualToString:@""]) {
        n = self.filteredFlights.count;
    }
    
    if(index < 0 || index >= n) {
        return;
    }
    
    [self didSelectFlight];
    
    [self.view endEditing:YES];
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    
    self.pageControl.currentPage = self.carousel.currentItemIndex;
}

- (void)carouselDidEndScrollingAnimation:(__unused iCarousel *)carousel {
    
}

#pragma mark - UIKeyboard notifications

- (void)keyboardWillShow:(NSNotification*)notif {
    //    self.passengersConstraintH.constant = 220;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.view layoutIfNeeded];
    //    });
}

- (void)keyboardWillHide:(NSNotification*)notif {
    //    self.passengersConstraintH.constant = 560;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.view layoutIfNeeded];
    //    });
}

@end
