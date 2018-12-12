//
//  ViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "LoginViewController.h"

#import "FlightsViewController.h"
#import "AppDelegate.h"

#import "Airport.h"

#import "ModelHelper.h"

#import "ActivityIndicatorView.h"
#import "WarningIndicatorManager.h"

#import "CredentialsHelper.h"
#import "SaveHelper.h"
#import "Reachability.h"

#import "UIFont+CommonValues.h"

#import "SecretViewController.h"

#import "Configuration.h"

#define FormXPos 100

typedef enum {
    
    kUserActivityEnteringCredentials,
    kUserActivitySelectingAirport
    
} UserActivity;

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormConstraintX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormConstraintY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *airportsFormConstraintX;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *airportPicker;

@property (nonatomic) UserActivity userActivity;
@property (nonatomic) BOOL isEditingName;
@property (nonatomic, strong) WebHelper *webHelper;
@property (nonatomic, strong) NSArray *iataCodes;

// view that contains secret
@property (nonatomic, strong) UIView *hiddenView;
@property (nonatomic, strong) SecretViewController *secretVC;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 5)];
    self.nameTextField.leftView = view;
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.nameTextField.placeholder = NSLocalizedString(@"login_username_placeholder", @"Username");
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 5)];
    self.passwordTextField.leftView = view;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.placeholder = NSLocalizedString(@"login_password_placeholder", @"Password");
    
    self.nameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    self.airportPicker.delegate = self;
    self.airportPicker.dataSource = self;
    
    NSString *appVersionString = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] stringByAppendingString:kStrEnvironmentLabel];
    NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    UIButton *versionButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 120, self.view.bounds.size.height - 45, 120, 50)];
    versionButton.titleLabel.font = [UIFont robotoWithSize:16.0];
    versionButton.titleLabel.textColor = [UIColor whiteColor];
    versionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [versionButton setTitle:[NSString stringWithFormat:@"v %@", appVersionString] forState:UIControlStateNormal];
    [versionButton setTitle:[NSString stringWithFormat:@"v %@ (%@)", appVersionString, appBuildString] forState:UIControlStateSelected];
    [versionButton addTarget:self action:@selector(toggleVersionButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:versionButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetView];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self pushLoginForm];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetView {
    self.nameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.userActivity = kUserActivityEnteringCredentials;
    self.loginFormConstraintX.constant = 1024;
    self.airportsFormConstraintX.constant = 1024;
    self.loginFormConstraintY.constant = 0;
    [self.view layoutIfNeeded];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[WarningIndicatorManager sharedInstance] hide];
    });
}

- (void)toggleVersionButton:(id)sender {
    UIButton *versionButton = (UIButton*)sender;
    versionButton.selected = !versionButton.selected;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == self.loginBtn)) {
        return NO;
    }
    return YES;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)changeViewPositionY:(int)newY {
    self.loginFormConstraintY.constant = newY;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)loginBtnPressed:(id)sender {
    
    if([self.nameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                        message:NSLocalizedString(@"alert_msg_empty_credentials", @"Invalid")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    
    } else {
        [[ActivityIndicatorView getSharedInstance] startActivityInView:self.view withMessage:NSLocalizedString(@"activity_validating", @"Validating")];
        self.webHelper = [[WebHelper alloc] init];
        self.webHelper.usernameStr = self.nameTextField.text;
        self.webHelper.passwordStr = self.passwordTextField.text;
        self.webHelper.delegate = self;
        [self dismissKeyboard];
        [self.webHelper testServerConnection];
    }
}

- (IBAction)selectAirportBtnPressed:(id)sender {
    // test internet, then request flights
    [[ActivityIndicatorView getSharedInstance] startActivityInView:self.view withMessage:NSLocalizedString(@"activity_retrieving_flights", @"Retrieving")];
    self.webHelper = [[WebHelper alloc] init];
    self.webHelper.delegate = self;
    [self.webHelper testServerConnection];
}

- (BOOL)loadAirportsDataFromMOC:(NSManagedObjectContext*)moc {
    
    if(!moc) {
        moc = [[NSManagedObjectContext alloc] init];
        moc.persistentStoreCoordinator = ((AppDelegate*)[UIApplication sharedApplication].delegate).persistentStoreCoordinator;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Airport"];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"iataCode" ascending:YES];
    request.sortDescriptors = @[sortDesc];
    NSError *fetchError = nil;
    NSArray *result = [moc executeFetchRequest:request error:&fetchError];
    if (!fetchError) {
        NSMutableArray *iataCodes = [[NSMutableArray alloc] init];
        for(Airport *airport in result) {
            [iataCodes addObject:airport.iataCode];
        }
        self.iataCodes = iataCodes;
    } else {
        //NSLog(@"Error fetching airports.");
        //NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
    }
    
    return (self.iataCodes && self.iataCodes.count > 0);
}

- (void)pushLoginForm {
    
    self.loginFormConstraintX.constant = FormXPos;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil
     ];
}

- (void)pushAirportsForm {
    
    self.userActivity = kUserActivitySelectingAirport;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.hiddenView removeFromSuperview];
        self.hiddenView = nil;
        
        NSString *iata = [[SaveHelper sharedInstance] loadStringForKey:kSelectedAirport];
        NSInteger index = [self.iataCodes indexOfObject:iata];
    
        self.loginFormConstraintX.constant = -1024;
        self.airportsFormConstraintX.constant = FormXPos;
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.view layoutIfNeeded];
                             [self.airportPicker reloadAllComponents];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if(index != NSNotFound && index > 0) {
                                     [self.airportPicker selectRow:index inComponent:0 animated:NO];
                                 }
                             });
                         }
                         completion:nil
         ];
    });
}

- (void)pushFlightsView {
    FlightsViewController *flightVC = [[FlightsViewController alloc] initWithNibName:@"FlightsViewController" bundle:nil];
    [self.navigationController pushViewController:flightVC animated:YES];
//    [flightVC syncApplication];
}

#pragma mark Public methods

- (void)logout {
    
    if(self.userActivity == kUserActivitySelectingAirport) {
        [self resetView];
        [self pushLoginForm];
    }
}

#pragma mark WebHelperDelegate

- (void)serverConnectionTestEndedWithResult:(BOOL)serverReachable {
    
    switch (self.userActivity) {
        case kUserActivityEnteringCredentials: {
            if(serverReachable) {
                
                // we have internet!
                // call web service requesting airports data
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webHelper requestAirports];
                });
            } else {
                
                // offline mode
                // check locally stored credentials
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[ActivityIndicatorView getSharedInstance] stopAnimation];
                });
                CredentialsHelper *ch = [[CredentialsHelper alloc] init];
                
                // has loged in before
                if([ch canFindCredentials]) {
                    
                    if([ch checkCredentialsWithUsername:self.nameTextField.text password:self.passwordTextField.text]) {
                        [self loadAirportsDataFromMOC:nil];
                        [self pushAirportsForm];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                    message:NSLocalizedString(@"alert_msg_wrong_credentials", @"Invalid")
                                    delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
                            [alert show];
                        });
                    }
                } else {  // has never loged in before
                    
                    NSString *title, *msg;
                    
                    // internet reachable
                    if([[Reachability reachabilityForInternetConnection] isReachable]) {
                        title = NSLocalizedString(@"alert_title_error", @"Error");
                        msg = NSLocalizedString(@"alert_msg_cant_reach_server", @"No server connection");
                    } else { // internet not reachable
                        title = NSLocalizedString(@"alert_title_no_connection", @"No Internet");
                        msg = NSLocalizedString(@"alert_msg_first_time", @"First Time Loging In");
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                        message:msg
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    });
                }
            }
        } break;
            
        case kUserActivitySelectingAirport: {
            
            long index = [self.airportPicker selectedRowInComponent:0];
            NSString *iata = self.iataCodes[index];
            NSString *savedIata = [[SaveHelper sharedInstance] loadStringForKey:kSelectedAirport];
            
            if(serverReachable) {
                // save selected iata. next time user logs in, picker view will remember it
                if(![savedIata isEqualToString:iata]) {
                    [[SaveHelper sharedInstance] saveObject:iata withKey:kSelectedAirport];
                }
                // request flights
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webHelper requestFlightsForAirportName:iata];
                });
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[ActivityIndicatorView getSharedInstance] stopAnimation];
                });
                
                // check whether we have previously loaded that airport
                // we do this because only the last airport loaded has its data stored locally
                
                if([savedIata isEqualToString:iata]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pushFlightsView];
                        [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
                    });
                } else {
                    
                    NSString *title, *msg;
                    
                    // internet reachable
                    if([[Reachability reachabilityForInternetConnection] isReachable]) {
                        title = NSLocalizedString(@"alert_title_error", @"Error");
                        msg = NSLocalizedString(@"alert_msg_cant_reach_server", @"No server connection");
                    } else {  // internet not reachable
                        title = NSLocalizedString(@"alert_title_no_connection", @"No Internet");
                        msg = NSLocalizedString(@"alert_msg_need_connection_for_flights", @"No Internet");
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                        message:msg
                                                                        delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                        [alert show];
                    });
                }
            }
        } break;
            
        default:
            break;
    }
}

- (void)serverRespondedWithData:(NSData *)data forRequestType:(RequestType)type {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
    });
    
    if(type == kRequestAirports) {
        BOOL success = YES;     //TODO get this from JSON
        if(success) {
            
            CredentialsHelper *ch = [[CredentialsHelper alloc] init];
            [ch saveUsername:self.nameTextField.text];
            [ch savePassword:self.passwordTextField.text];
            
            ModelHelper *saver = [[ModelHelper alloc] init];
            [saver processAirportsData:data];
            [self loadAirportsDataFromMOC:saver.moc];
            [self pushAirportsForm];
            if([WarningIndicatorManager sharedInstance].currentWarningStyle == kWarningErrorStyle) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[WarningIndicatorManager sharedInstance] hide];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                                message:NSLocalizedString(@"alert_msg_wrong_credentials", @"Invalid")
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            });
        }
    } else if(type == kRequestFlights) {
        BOOL success = YES;     //TODO get this from JSON
        if(success) {
            [[[ModelHelper alloc] init] processFlightsData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pushFlightsView];
                if([WarningIndicatorManager sharedInstance].currentWarningStyle == kWarningErrorStyle) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[WarningIndicatorManager sharedInstance] hide];
                    });
                }
            });
        }
    }
}

- (void)connectionFailedWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ActivityIndicatorView getSharedInstance] stopAnimation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_error", @"Error")
                                                    message:error.localizedDescription
                                                    delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [alert show];
        
        if(self.userActivity == kUserActivityEnteringCredentials && error.code != kErrorWrongCredentials) {
            
            CredentialsHelper *ch = [[CredentialsHelper alloc] init];
            if([ch canFindCredentials] && [ch checkCredentialsWithUsername:self.nameTextField.text password:self.passwordTextField.text]) {
                [self loadAirportsDataFromMOC:nil];
                [self pushAirportsForm];
                [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
            }
        } else if(self.userActivity == kUserActivitySelectingAirport && error.code != kErrorWrongCredentials) {
            long index = [self.airportPicker selectedRowInComponent:0];
            NSString *iata = self.iataCodes[index];
            NSString *savedIata = [[SaveHelper sharedInstance] loadStringForKey:kSelectedAirport];
            if([savedIata isEqualToString:iata]) {
                [self pushFlightsView];
                [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningErrorStyle message:NSLocalizedString(@"warning_connection", @"connection failed")];
            }
        }
    });
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.iataCodes.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *iata = self.iataCodes[row];
    return iata;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.0;
}

#pragma mark - TextFields

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.nameTextField) {
        self.isEditingName = YES;
        [self changeViewPositionY:-160];
    } else if (textField == self.passwordTextField) {
        [self changeViewPositionY:-220];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([self checkSecret]) {
        [self.view endEditing:YES];
        return YES;
    }
    
    if (textField == self.nameTextField) {
        self.isEditingName = NO;
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self.view endEditing:YES];
        [self loginBtnPressed:nil];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.nameTextField) {
        if(self.isEditingName) {
            [textField resignFirstResponder];
        }
    } else if (textField == self.passwordTextField) {
        if(self.isEditingName == NO) {
            [textField resignFirstResponder];
        }
    }
    return YES;
}

#pragma mark - UIKeyboard notifications

- (void)keyboardWillShow:(NSNotification*)notif {
}

- (void)keyboardWillHide:(NSNotification*)notif {
    [self changeViewPositionY:0];
}

#pragma mark - Secret

- (BOOL)checkSecret {
    
    int options = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    if(self.hiddenView) {
        return NO;
    }
    
    NSString *name = [self.nameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([name compare:@"abretesesamo" options:options] == NSOrderedSame
       || [name compare:@"opensesame" options:options] == NSOrderedSame
       || [name compare:@"abreosimsim" options:options] == NSOrderedSame) {
        
        const int dx = 20;
        
        self.hiddenView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:self.hiddenView atIndex:1];
        
        self.secretVC = [[SecretViewController alloc] initWithNibName:nil bundle:nil];
        self.secretVC.view.frame = CGRectMake(FormXPos + dx, 0, 395, 768);
        [self.hiddenView addSubview:self.secretVC.view];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(FormXPos + dx, 0, 395, 768)];
        bgView.backgroundColor = [UIColor redColor];
        bgView.clipsToBounds = YES;
        [self.hiddenView addSubview:bgView];
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_login.jpg"]];
        CGRect frame = img.frame;
        frame.origin.x = -FormXPos - dx;
        img.frame = frame;
        [bgView addSubview:img];
        
        self.loginFormConstraintX.constant = FormXPos + 420;
        [UIView animateWithDuration:1.5 animations:^{
            CGRect frame = bgView.frame;
            frame.origin.x = FormXPos + 420 + dx;
            bgView.frame = frame;
            [self.view layoutIfNeeded];
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
