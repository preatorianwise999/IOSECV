//
//  WarningIndicatorController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/11/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "WarningIndicatorManager.h"

#import "WarningView.h"

#import "AppDelegate.h"

#define kHintW  60
#define kAlertW 300

@interface WarningIndicatorManager ()

@property(nonatomic, strong) WarningView *warningView;

@end

@implementation WarningIndicatorManager

static WarningIndicatorManager *sharedInstance;

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[WarningIndicatorManager alloc] init];
        
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"WarningView" owner:self options:nil];
        sharedInstance.warningView = [subviewArray objectAtIndex:0];
        CGRect frame = sharedInstance.warningView.frame;
        frame.origin.x = 1024;
        frame.origin.y = 700;
        sharedInstance.warningView.frame = frame;
        
        UIWindow *window = ((AppDelegate*)[UIApplication sharedApplication].delegate).window;
        if (!window) {
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        }
        [[[window subviews] objectAtIndex:0] addSubview:sharedInstance.warningView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:sharedInstance
                                       action:@selector(tapInView)];
        tap.cancelsTouchesInView = NO;
        tap.delegate = sharedInstance;
        [sharedInstance.warningView addGestureRecognizer:tap];
    });
    
    return sharedInstance;
}

- (void)showHintWithStyle:(WarningStyle)style message:(NSString*)message {
    
    void (^setupWarningAndShow)(void) = ^{
        
        self.warningView.messageLabel.text = message;
        
        self.currentWarningStyle = style;
        
        NSString *bgName;
        if(style == kWarningErrorStyle) {
            bgName = @"alert_bg_1";
        }
        else if(style == kWarningAdviceStyle) {
            bgName = @"alert_bg_2";
        }
        
        self.warningView.backgroundImageView.image = [UIImage imageNamed:bgName];
        [self showAsHint];
    };
    
    if(self.warningView.frame.origin.x < 1024) {
        [self hideWithCallback:setupWarningAndShow];
    }
    else {
        setupWarningAndShow();
    }
}

- (void)tapInView {
    if(self.warningView.frame.origin.x >= 1024 - kHintW) {
        [self showFullWarning];
    }
    else {
        [self showAsHint];
    }
}

- (void)showAsHint {
    
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = self.warningView.frame;
        frame.origin.x = 1024 - kHintW;
        self.warningView.frame = frame;
        [self.warningView layoutIfNeeded];
    }];
}

- (void)showFullWarning {
    
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = self.warningView.frame;
        frame.origin.x = 1024 - kAlertW;
        self.warningView.frame = frame;
        [self.warningView layoutIfNeeded];
    }];
}

- (void)hide {
    
    [self hideWithCallback:nil];
}

- (void)hideWithCallback:(void (^)(void))callback {
    
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = self.warningView.frame;
        frame.origin.x = 1024;
        self.warningView.frame = frame;
        [self.warningView layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(finished) {
            if(callback) {
                callback();
            }
        }
    }];
}

@end
