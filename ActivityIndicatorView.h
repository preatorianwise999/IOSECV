//
//  ActivityIndicatorView.h
//  UtilityPOC
//
//  Created by palash roy on 11/19/12.
//  Copyright (c) 2012 tcs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ActivityIndicatorView : NSObject {
    
    UIView *_backgroundView;
    UILabel *_activityStatus;
    UIImageView *_airplaneView;
    
    BOOL _isRunning;
}

@property (nonatomic) BOOL isRunning;
@property (nonatomic,strong) NSString *message;

- (void)startActivityInView:(UIView*)currentView withMessage:(NSString*)statusMessage;

// this method returns the singleton shared instance
+ (ActivityIndicatorView *)getSharedInstance;

// this method starts the animation
- (void)startAnimation;

// this method stops the animation
- (void)stopAnimation;

@end
