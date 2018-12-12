//
//  AppDelegate.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "VoucherUploadManager.h"
#import "LTMWindow.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, VUMDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// upload locally saved vouchers
- (void)tryToUploadLocalData;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

