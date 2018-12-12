//
//  Synchronizer.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/24/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WebHelper.h"

@protocol SyncDelegate <NSObject>

- (void)synchronizationFinishedSuccessfully;
- (void)synchronizationFinishedWithWarnings;
- (void)synchronizationDidFail;

@end

@interface Synchronizer : NSObject<WebHelperDelegate>

@property(nonatomic) BOOL forcedSync;
@property(nonatomic, weak) id<SyncDelegate> delegate;

- (void)synchronizeModel;

@end
