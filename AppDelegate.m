//
//  AppDelegate.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "AppDelegate.h"

#import <SystemConfiguration/SystemConfiguration.h>

#import "Reachability.h"

#import "SaveHelper.h"

#import "LoginViewController.h"

#import "Configuration.h"

#import "WarningIndicatorManager.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

typedef enum {
    
    kConnected,
    kNotConnected
    
} ConnectionState;

@interface AppDelegate ()

@property(nonatomic, strong) Reachability *reachability;
@property(nonatomic, strong) NSMutableArray *vums;
@property(nonatomic, strong) NSLock *lock;
@property(nonatomic, strong) NSTimer *autoLogoutTimer;
@property(nonatomic, strong) NSDate *backgroundLogoutDate;
@property(nonatomic) ConnectionState connectionState;

@end

@implementation AppDelegate

- (LTMWindow*)window {
    
    static LTMWindow *customWindow = nil;
    if (!customWindow) {
        customWindow = [[LTMWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return customWindow;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // integrate with crashlytics
    [Fabric with:@[[Crashlytics class]]];
    
    // listen to events (for auto-logout purposes)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetAutologoutTimer:)
                                                 name:kWindowEventNotification object:nil];
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    // Set up Reachability
    self.reachability = [Reachability reachabilityForInternetConnection];
    
    self.connectionState = kNotConnected;
    if([self.reachability isReachable]) {
        self.connectionState = kConnected;
    }
    
    [self.reachability startNotifier];
    if(![self.reachability isReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_no_connection", @"Offline mode")
                                                        message:NSLocalizedString(@"alert_msg_no_connection", @"Offline mode")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSTimeInterval timeRemaining = [self.autoLogoutTimer.fireDate timeIntervalSinceDate:[NSDate date]];
    [self.autoLogoutTimer invalidate];
    self.autoLogoutTimer = nil;
    
    if(timeRemaining > 0) {
        self.backgroundLogoutDate = [[NSDate date] dateByAddingTimeInterval:timeRemaining];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if([[NSDate date] timeIntervalSinceDate:self.backgroundLogoutDate] > 0) {
        [self autoLogout];
    }
    else {
        [self resetAutologoutTimer:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self saveContext];
}

/*
    every time a voucher is printed, this method is called and a VUM is created.
 */
- (void)tryToUploadLocalData {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.vums = [[NSMutableArray alloc] init];
        self.lock = [[NSLock alloc] init];
    });
    
    // get locally saved vouchers
    [[SaveHelper sharedInstance] lock];
    NSArray *vouchers = [[SaveHelper sharedInstance] loadArrayForKey:kSavedVouchers];
    [[SaveHelper sharedInstance] removeObjectForKey:kSavedVouchers];
    [[SaveHelper sharedInstance] unlock];
    
    if(vouchers.count == 0) {
        return;
    }
    
    // create a vum to handle the upload process
    VoucherUploadManager *vum = [[VoucherUploadManager alloc] init];
    vum.delegate = self;
    [self.lock lock];
    [self.vums addObject:vum];
    [self.lock unlock];
    [vum tryToUploadVouchers:vouchers];
}

#pragma mark - VUMDelegate

- (void)uploadFinishedSuccessfully:(id)sender {
    
    // remove the vum from the list of currently active vums
    [self.lock lock];
    [self.vums removeObject:sender];
    [self.lock unlock];
}

- (void)uploadFailedForVouchers:(NSArray *)vouchers sender:(id)sender {
    
    [[SaveHelper sharedInstance] lock];
    // create a mutable array of all local vouchers
    NSMutableArray *allVouchers = [NSMutableArray arrayWithArray:[[SaveHelper sharedInstance] loadArrayForKey:kSavedVouchers]];
    // add vouchers that failed to upload
    [allVouchers addObjectsFromArray:vouchers];
    [[SaveHelper sharedInstance] saveObject:allVouchers withKey:kSavedVouchers];
    [[SaveHelper sharedInstance] unlock];
    
    [self.lock lock];
    [self.vums removeObject:sender];
    [self.lock unlock];
}

#pragma mark - Auto-logout

- (void)resetAutologoutTimer:(NSNotification *)notif {
    
    if(self.autoLogoutTimer) {
        [self.autoLogoutTimer invalidate];
    }
    
    self.autoLogoutTimer = [NSTimer timerWithTimeInterval:kAutologoutTime target:self selector:@selector(autoLogout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.autoLogoutTimer forMode:NSRunLoopCommonModes];
}

- (void)autoLogout {
    
    UINavigationController *navController = (UINavigationController*)self.window.rootViewController;
    if(![navController.topViewController isKindOfClass:[LoginViewController class]]) {
        [navController popToRootViewControllerAnimated:YES];
    }
    else {
        LoginViewController *lvc = (LoginViewController*)navController.topViewController;
        [lvc logout];
    }
    
    if(self.autoLogoutTimer) {
        [self.autoLogoutTimer invalidate];
        self.autoLogoutTimer = nil;
    }
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification *)notif {

    NetworkStatus internetStatus = [self.reachability currentReachabilityStatus];
    
    if(internetStatus == NotReachable && self.connectionState == kConnected) {
        self.connectionState = kNotConnected;
        if([WarningIndicatorManager sharedInstance].currentWarningStyle == kWarningAdviceStyle) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[WarningIndicatorManager sharedInstance] hide];
            });
        }
    }
    else if(internetStatus == ReachableViaWiFi && self.connectionState == kNotConnected) {
        
        self.connectionState = kConnected;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[WarningIndicatorManager sharedInstance] showHintWithStyle:kWarningAdviceStyle message:NSLocalizedString(@"warning_sync", @"wifi now reachable")];
        });
        
        [self tryToUploadLocalData];
    }
    else if(internetStatus == ReachableViaWWAN && self.connectionState == kNotConnected) {
        self.connectionState = kNotConnected;
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.diegocath.hola" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BasicServices" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BasicServices.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    NSThread *currentThread = [NSThread currentThread];
    [[currentThread threadDictionary] setObject:_managedObjectContext forKey:@"managedObjectContext"];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
