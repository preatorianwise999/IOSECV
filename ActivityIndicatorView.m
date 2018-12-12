//
//  ActivityIndicatorView.m
//  UtilityPOC
//
//  Created by palash roy on 11/19/12.
//  Copyright (c) 2012 tcs. All rights reserved.
//

#import "ActivityIndicatorView.h"
#import "UIFont+CommonValues.h"

@implementation ActivityIndicatorView

@synthesize isRunning;

/*
 This method is used in classes which ever want to access the ActivityIndicatorView Object
 */

+ (ActivityIndicatorView *)getSharedInstance {
    
	static ActivityIndicatorView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ActivityIndicatorView alloc] init];
    });
    
    return sharedInstance;
}

- (void)startActivityInView:(UIView*)currentView withMessage:(NSString*)statusMessage {
    _message = statusMessage;
    
    // container background
    _backgroundView = [[UIView alloc] init];
    _backgroundView.bounds = currentView.bounds;
    _backgroundView.center = currentView.center;
    _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
    [currentView addSubview:_backgroundView];
    
    // width
    CGSize size = [statusMessage sizeWithAttributes:
                   @{NSFontAttributeName: [UIFont robotoWithSize:16.0]}];
    int w = MAX(250, size.width + 50);
    
    // box
    UIView *boxView = [[UIView alloc] init];
    boxView.bounds = CGRectMake(0, 0, w, 140);
    boxView.center = currentView.center;
    boxView.layer.cornerRadius = 10;
    boxView.backgroundColor = [UIColor blackColor];
    boxView.alpha = .8;
    [boxView clipsToBounds];
    [_backgroundView addSubview:boxView];
    
    // airplane image
    _airplaneView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"round_trip"]];
    CGRect frame = _airplaneView.frame;
    frame.size.width = 50;
    frame.size.height = 50;
    frame.origin.x = boxView.bounds.size.width/2 - frame.size.width/2;
    frame.origin.y = boxView.bounds.size.height/2 - frame.size.height/2 - 20;
    _airplaneView.frame = frame;
    [boxView addSubview:_airplaneView];
    
    [self startAnimation];
    
    // status msg
    _activityStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 83, w, 40)];
    _activityStatus.backgroundColor = [UIColor redColor];
    _activityStatus.text = statusMessage;
    _activityStatus.backgroundColor = [UIColor clearColor];
    _activityStatus.textAlignment = NSTextAlignmentCenter;
    _activityStatus.textColor = [UIColor whiteColor];
    [_activityStatus setFont:[UIFont robotoWithSize:16.0]];
    [boxView addSubview:_activityStatus];
    
    isRunning = YES;
}

- (void)setMessage:(NSString*)changedStatusMessage {
    _message = changedStatusMessage;
    _activityStatus.text = changedStatusMessage;
}

- (void)animateFlight:(UIImageView*)flightPath {
    [flightPath.layer removeAllAnimations];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setToValue:[NSNumber numberWithFloat:M_PI*2]];
    [rotationAnimation setDuration:1.0];
    [rotationAnimation setRepeatCount:HUGE_VALF];
    // Make the animation timing linear
    [rotationAnimation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [[flightPath layer] addAnimation:rotationAnimation forKey:nil];
}

/*
 This method is used to animate the UIActivityIndicatorView Object "activityIndicator"
 */

- (void)startAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateFlight:_airplaneView];
    });
}

/*
 This method is used to stop the animation of UIActivityIndicatorView Object "activityIndicator"
 */

- (void)stopAnimation {
    [_backgroundView removeFromSuperview];
    isRunning = NO;
}

- (void)dealloc {
    
}

@end
