//
//  PassengersViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "PassengersViewController.h"

#import "FlightsViewController.h"
#import "AssignationViewController.h"
#import "CompanionsTableViewController.h"

#import "TitleBar.h"
#import "UIImage+Shapes.h"
#import "UIFont+CommonValues.h"
#import "UIColor+CommonValues.h"
#import "DetailedButton.h"
#import "ActivityIndicatorView.h"
#import "WarningIndicatorManager.h"

#import "Flight.h"
#import "Passenger.h"
#import "AppDelegate.h"

#import "SaveHelper.h"
#import "ModelHelper.h"

#define SECTION_HEADER_HEIGHT   40.0
#define TABLE_ROW_HEIGHT        55.0

@interface PassengersViewController ()

@property(nonatomic, strong) NSMutableArray *sectionStatus;
@property(nonatomic, strong) NSArray *classes;
@property(nonatomic, strong) NSDictionary *passengersByClass;
@property(nonatomic, strong) NSArray *allPassengers;
@property(nonatomic, strong) NSMutableArray *filteredPassengers;
@property(nonatomic, strong) NSIndexPath *selectedPassengerIndexPath;
@property(nonatomic, strong) NSString *filterKey;

@property(nonatomic, strong) WebHelper *webHelper;

@property (weak, nonatomic) IBOutlet TitleBar *titleBar;
@property (weak, nonatomic) IBOutlet UITextField *passengerSearchField;
@property (weak, nonatomic) IBOutlet UIImageView *searchIcon;
@property (weak, nonatomic) IBOutlet UITableView *passengersTableView;
@property (strong, nonatomic) UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UITableView *companionsTableView;
@property (strong, nonatomic) CompanionsTableViewController *ctvc;
@property (weak, nonatomic) IBOutlet UILabel *flightCodeLb;
@property (weak, nonatomic) IBOutlet UIView *passengerDetailsView;
@property (weak, nonatomic) IBOutlet DetailedButton *companionsButton;
@property (weak, nonatomic) IBOutlet DetailedButton *basicServicesButton;
@property (weak, nonatomic) IBOutlet UILabel *passengerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passengerCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noPassengersLb;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pDetailsViewConstraintX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companionsConstraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passengersConstraintH;

@property (nonatomic, strong) Synchronizer *sync;

@end

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";

@implementation PassengersViewController

- (void)loadData {
    
    // fetch passengers
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Passenger"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"flight", self.flight];
    request.predicate = predicate;
    NSSortDescriptor *firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName"
                                                      ascending:YES
                                                       selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName"
                                                     ascending:YES
                                                      selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObjects:lastNameDescriptor, firstNameDescriptor, nil];
    
    NSError *fetchError = nil;
    NSArray *fetchedPassengers = [moc executeFetchRequest:request error:&fetchError];
    
    if (!fetchError) {
        
        self.sectionStatus = [[NSMutableArray alloc] init];
        NSMutableArray *classes = [[NSMutableArray alloc] init];
        NSMutableDictionary *passengersByClass =  [[NSMutableDictionary alloc] init];
        NSMutableArray *allPassengers = [[NSMutableArray alloc] init];
        self.filteredPassengers = [[NSMutableArray alloc] init];
        
        for(Passenger *p in fetchedPassengers) {
            NSString *class = @"No Class";
            if(p.type) {
                class = p.type;
            }
            if(![classes containsObject:class]) {
                [self.sectionStatus addObject:@(YES)];
                [classes addObject:class];
                [passengersByClass setObject:[[NSMutableArray alloc] init] forKey:class];
            }
            
            [allPassengers addObject:p];
            [self.filteredPassengers addObject:p];
            [((NSMutableArray*)passengersByClass[class]) addObject:p];
        }
        
        self.classes = [classes sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];
        self.passengersByClass = passengersByClass;
        self.allPassengers = allPassengers;
    } else {
        //NSLog(@"Error fetching passengers.");
        //NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
    }
}

- (void)setFlight:(Flight *)flight {
    _flight = flight;
    [self loadData];
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
    
    // search bar
    
    self.filterKey = @"";
    CGRect f = self.passengerSearchField.bounds;
    UIImage *searchBackground = [UIImage drawRoundRectWithWidth:f.size.width height:f.size.height radius:f.size.height/2 thickness:0 fillColor:[UIColor searchBackgroundColor] borderColor:[UIColor clearColor]];
    self.passengerSearchField.borderStyle = UITextBorderStyleNone;
    self.passengerSearchField.background = searchBackground;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.passengerSearchField.leftView = paddingView;
    self.passengerSearchField.leftViewMode = UITextFieldViewModeAlways;
    self.passengerSearchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"passenger_placeholder_search", @"Search") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    self.passengerSearchField.textColor = [UIColor whiteColor];
    
    // search table view
    
    UITableView *searchTableView = [[UITableView alloc] initWithFrame:self.passengersTableView.frame style:self.passengersTableView.style];
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    searchTableView.backgroundColor = [UIColor clearColor];
    searchTableView.separatorColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.3];
    [self.view addSubview:searchTableView];
    self.searchTableView = searchTableView;
    [self.searchTableView reloadData];
    self.searchTableView.hidden = YES;
    
    // passengers table view
    
    self.passengersTableView.sectionHeaderHeight = SECTION_HEADER_HEIGHT;
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [self.passengersTableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
    self.passengersTableView.separatorColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.3];
    self.passengersTableView.sectionFooterHeight = 0.0;

    // flight number
    
    self.flightCodeLb.text = self.flight.flightName;
    
    // passenger details
    
    UIImage *companionsImg = [UIImage drawRectWithWidth:self.companionsButton.bounds.size.width height:self.companionsButton.bounds.size.height thickness:0 fillColor:[UIColor appLightColorWithOpacity:.8] borderColor:[UIColor clearColor]];
    UIImage *servicesImgNormal = [UIImage drawRectWithRightRoundCornersWithWidth:self.basicServicesButton.bounds.size.width height:self.basicServicesButton.bounds.size.height radius:self.basicServicesButton.bounds.size.height/8.0 thickness:0 fillColor:[UIColor appLightColorWithOpacity:.8] borderColor:[UIColor clearColor]];
    UIImage *servicesImgSelected = [UIImage drawRectWithRightRoundCornersWithWidth:self.basicServicesButton.bounds.size.width height:self.basicServicesButton.bounds.size.height radius:self.basicServicesButton.bounds.size.height/8.0 thickness:0 fillColor:[UIColor appLightColorWithOpacity:1.0] borderColor:[UIColor clearColor]];
    UIImage *fullImg = [UIImage drawRoundRectWithWidth:self.passengerDetailsView.bounds.size.width height:self.passengerDetailsView.bounds.size.height radius:self.passengerDetailsView.bounds.size.height/8.0 thickness:0 fillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.3] borderColor:[UIColor clearColor]];
    
    [self.companionsButton setBackgroundImage:companionsImg forState:UIControlStateHighlighted];
    [self.companionsButton setBackgroundImage:companionsImg forState:UIControlStateSelected];
    
    [self.basicServicesButton setBackgroundImage:servicesImgSelected forState:UIControlStateHighlighted];
    [self.basicServicesButton setBackgroundImage:servicesImgNormal forState:UIControlStateNormal];
    self.passengerDetailsView.backgroundColor = [UIColor colorWithPatternImage:fullImg];
    
    [self.basicServicesButton setUpAsBasicServicesBtn];
    [self.companionsButton setUpAsCompanionsBtnWithNumberOfCompanions:1];
    
    // companions table view
    
    self.ctvc = [[CompanionsTableViewController alloc] initWithTableView:self.companionsTableView];
    self.ctvc.tableConstraintH = self.companionsConstraintH;
    self.companionsTableView.delegate = self.ctvc;
    self.companionsTableView.dataSource = self.ctvc;
    self.companionsTableView.separatorColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.1];
    self.companionsTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
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
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self
                   action:@selector(backButtonPressed)
         forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    [backBtn setImage:[UIImage imageNamed:@"ic_back.png"] forState:UIControlStateNormal];
    [self.titleBar addView:backBtn onSide:kSideLeft];
    
    self.noPassengersLb.hidden = YES;
    
    self.pDetailsViewConstraintX.constant = -self.passengerDetailsView.bounds.size.width;
    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if(self.allPassengers.count == 0) {
        self.passengersTableView.hidden = YES;
        self.passengerSearchField.hidden = YES;
        self.searchIcon.hidden = YES;
        self.noPassengersLb.hidden = NO;
    } else {
        [self.passengersTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == self.companionsButton)) {
        return NO;
    }
    return YES;
}

- (void)userTappedScreen {
    self.companionsButton.selected = NO;
    [self.ctvc setTableViewHidden:YES];
    [self.view endEditing:YES];
}

- (Passenger*)getPassengerFromTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)index {
    
    if([tableView isEqual:self.passengersTableView]) {
        return [self getPassengerAtIndexPath:index];
    }
    
    return self.filteredPassengers[index.row];
}

- (Passenger*)getPassengerAtIndexPath:(NSIndexPath*)index {
    
    NSString *className = self.classes[index.section];
    NSArray *passengers = self.passengersByClass[className];
    
    return passengers[index.row];
}

- (void)setupCompanionsBtnForPassenger:(Passenger*)passenger {
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    moc.persistentStoreCoordinator = ((AppDelegate*)[UIApplication sharedApplication].delegate).persistentStoreCoordinator;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Passenger"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", @"flight", self.flight, @"pnr", passenger.pnr];
    request.predicate = predicate;
    
    NSError *fetchError = nil;
    NSArray *result = [moc executeFetchRequest:request error:&fetchError];
    NSArray *fetchedPassengers = result;
    
    if (!fetchError) {
        [self.companionsButton setUpAsCompanionsBtnWithNumberOfCompanions:fetchedPassengers.count - 1];
        if(fetchedPassengers.count == 1) {
            [self.companionsButton setEnabled:NO];
        } else {
            [self.companionsButton setEnabled:YES];
        }
    } else {
        //NSLog(@"Error fetching companions.");
        //NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Button Actions

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)filterPassengers:(id)sender {

    NSString *key = self.passengerSearchField.text;
    
    // filter reset happens when the user modifies the search key other than by appending text at the tail of the current value.
    // in case of filter reset, we perform a fresh search instead of using what we already have.
    
    BOOL filterReset = NO;
    if(![self.filterKey isEqualToString:@""] && [key rangeOfString:self.filterKey].location != 0) {
        filterReset = YES;
    }
    
    NSMutableArray *filteredPassengers = [self.filteredPassengers mutableCopy];
    
    if(filterReset || self.filterKey.length == 0) {
        // start fresh
        filteredPassengers = [self.allPassengers mutableCopy];
    }
    
    // remove rows from filteredPassengers
    
    if([key rangeOfString:self.filterKey].location == 0 || self.filterKey.length == 0 || filterReset) {
        
        NSMutableArray *indicesToRemove = [[NSMutableArray alloc] init];
        NSMutableArray *passengersToRemove = [[NSMutableArray alloc] init];
        
        if(![key isEqualToString:@""]) {
            for(int i = 0; i < filteredPassengers.count; i++) {
                Passenger *p = filteredPassengers[i];
                NSString *firstName = p.firstName;
                NSString *lastName = p.lastName;
                NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                NSString *code = p.pnr;
                
                NSStringCompareOptions options = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
                
                if([firstName rangeOfString:key options:options].location != 0 &&
                   [lastName rangeOfString:key options:options].location != 0 &&
                   [fullName rangeOfString:key options:options].location != 0 &&
                   [code rangeOfString:key options:options].location != 0) {
                    [indicesToRemove addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    [passengersToRemove addObject:p];
                }
            }
        }
    
        self.filteredPassengers = filteredPassengers;
        
        if([key isEqualToString:@""]) {
            self.passengersTableView.hidden = NO;
            self.searchTableView.hidden = YES;
        } else {
            self.passengersTableView.hidden = YES;
            self.searchTableView.hidden = NO;
        }
        
        if(filterReset) {
            [self.searchTableView reloadData];
        }
        
        for(Passenger *p in passengersToRemove) {
            [self.filteredPassengers removeObject:p];
        }
        
        [self.searchTableView deleteRowsAtIndexPaths:indicesToRemove withRowAnimation:UITableViewRowAnimationNone];
    }
    
    self.filterKey = key;
}

- (IBAction)continueBtnTapped:(id)sender {
    
    BOOL shouldUpdateHotels = NO;
    
    for(Flight *f in self.flight.protectorFlights) {
        if(f.hotelServices && f.hotelServices.count > 0) {
            shouldUpdateHotels = YES;
            break;
        }
    }
    
    if(shouldUpdateHotels) {
        [[ActivityIndicatorView getSharedInstance] startActivityInView:self.view withMessage:NSLocalizedString(@"activity_checking_hotels", @"Checking hotels")];
        self.webHelper = [[WebHelper alloc] init];
        self.webHelper.delegate = self;
        [self.webHelper testServerConnection];
    } else {
        [self pushAssignationView];
    }
}

- (IBAction)companionsButtonTouched:(id)sender {
    
    self.companionsButton.selected = !self.companionsButton.selected;
    if(self.companionsButton.selected) {
        self.ctvc.passengerObjID = [self getPassengerAtIndexPath:self.selectedPassengerIndexPath].objectID;
    }
    [self.ctvc setTableViewHidden:!self.companionsButton.selected];
}

- (void)pushAssignationView {
    
    AssignationViewController *avc = [[AssignationViewController alloc] initWithNibName:@"AssignationViewController" bundle:nil];
    avc.passenger = [self getPassengerAtIndexPath:self.selectedPassengerIndexPath];
    
    [self.navigationController pushViewController:avc animated:YES];
    
    [[ActivityIndicatorView getSharedInstance] stopAnimation];
}

#pragma mark SyncDelegate methods

- (void)synchronizationFinishedSuccessfully {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
        
        if([WarningIndicatorManager sharedInstance].currentWarningStyle == kWarningAdviceStyle) {
            [[WarningIndicatorManager sharedInstance] hide];
        }
    });
    [self popToFlightsViewController];
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
    });
    [self popToFlightsViewController];
}

- (void)synchronizationDidFail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                        message:NSLocalizedString(@"alert_msg_sync_error", @"Error")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

#pragma mark WebHelperDelegate

- (void)serverConnectionTestEndedWithResult:(BOOL)serverReachable {
    
    if(serverReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *currentAirport = [[SaveHelper sharedInstance] loadStringForKey:kSelectedAirport];
            self.webHelper.delegate = self;
            [self.webHelper requestHotelAvailabilityForAirportName:currentAirport];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pushAssignationView];
            [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
        });
    }
}

- (void)serverRespondedWithData:(NSData *)data forRequestType:(RequestType)type {
    if(type == kRequestHotelAvailability) {
        BOOL success = YES;  //TODO: get this from JSON
        if(success) {
            [[[ModelHelper alloc] init] processHotelAvailabilityData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pushAssignationView];
                if([WarningIndicatorManager sharedInstance].currentWarningStyle == kWarningErrorStyle) {
                    [[WarningIndicatorManager sharedInstance] hide];
                }
            });
        }
    }
}

- (void)connectionFailedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self pushAssignationView];
        [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
    });
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if([tableView isEqual:self.searchTableView]) {
        return 1.0;
    }
    
    return SECTION_HEADER_HEIGHT;
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.indexPathForSelectedRow == nil) {
        self.pDetailsViewConstraintX.constant = 50;
        [UIView animateWithDuration:0.3
            animations:^{
             [self.view layoutIfNeeded];
            }
         ];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Passenger *data = [self getPassengerFromTableView:tableView atIndexPath:indexPath];
    
    NSString *name = [NSString stringWithFormat:@"%@, %@", data.lastName, data.firstName];
    self.passengerNameLabel.text = [name uppercaseString];
    self.passengerCodeLabel.text = [NSString stringWithFormat:@"%@/%@", data.editCodes, [data.pnr uppercaseString]];
    [self setupCompanionsBtnForPassenger:data];
    
    self.companionsButton.selected = NO;
    [self.ctvc setTableViewHidden:YES];
    
    if([tableView isEqual:self.passengersTableView]) {
        self.selectedPassengerIndexPath = indexPath;
    } else if([tableView isEqual:self.searchTableView]) {
        NSString *class = data.type;
        NSInteger section = [self.classes indexOfObject:class];
        NSInteger row = [self.passengersByClass[class] indexOfObject:data];
        self.selectedPassengerIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        if([self tableView:self.passengersTableView numberOfRowsInSection:section] > 0) {
            [self.passengersTableView selectRowAtIndexPath:self.selectedPassengerIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if([tableView isEqual:self.searchTableView]) {
        return 1;
    }
    
    return self.classes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([tableView isEqual:self.searchTableView]) {
        return self.filteredPassengers.count;
    }
    
    if(![self.sectionStatus[section] boolValue]) {
        return 0;
    }
    NSString *className = self.classes[section];
    return ((NSArray*)self.passengersByClass[className]).count;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if([tableView isEqual:self.searchTableView]) {
        return nil;
    }
    
    NSString *title = self.classes[section];
    
    SectionHeaderView *sectionHeaderView = [self.passengersTableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    
    sectionHeaderView.titleLabel.text = title;
    sectionHeaderView.numberLabel.text = [@(((NSArray*)self.passengersByClass[title]).count) stringValue];
    sectionHeaderView.section = section;
    sectionHeaderView.delegate = self;
    [sectionHeaderView setOpen:([self.passengersTableView numberOfRowsInSection:section] > 0)];
    
    sectionHeaderView.contentView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.3];
    
    return sectionHeaderView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Passenger *paxInfo = [self getPassengerFromTableView:tableView atIndexPath:indexPath];
    
    static NSString *passengersCellID = @"PassengerCellID";
    static NSString *searchCellID = @"SearchCellID";
    
    NSString *cellIdentifier = [tableView isEqual:self.passengersTableView] ? passengersCellID : searchCellID;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        // setup
        cell.textLabel.font = [UIFont robotoWithSize:15.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont robotoWithSize:13.0];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.2];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, TABLE_ROW_HEIGHT)];
        lineView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.5];
        [bgColorView addSubview:lineView];
        cell.selectedBackgroundView = bgColorView;
    }
    
    NSString *name = [NSString stringWithFormat:@"%@, %@", paxInfo.lastName, paxInfo.firstName];
    cell.textLabel.text = [name uppercaseString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", paxInfo.editCodes, [paxInfo.pnr uppercaseString]];
    
    cell.accessoryView = nil;
    if(paxInfo.vouchers.count > 0) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_check"]];
        cell.accessoryView.frame = CGRectMake(0, 0, 24, 24);
        cell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return cell;
}

#pragma mark - SectionHeaderDelegate

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section {
    
    self.sectionStatus[section] = @(YES);
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSString *className = self.classes[section];
    NSInteger countOfRowsToInsert = ((NSArray*)self.passengersByClass[className]).count;
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    [self.passengersTableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationMiddle];
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section {
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
    self.sectionStatus[section] = @(NO);
    NSInteger countOfRowsToDelete = [self.passengersTableView numberOfRowsInSection:section];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
        [self.passengersTableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
