//
//  WarningIndicatorView.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/11/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    kWarningErrorStyle,
    kWarningAdviceStyle
    
} WarningStyle;

@interface WarningIndicatorManager : NSObject <UIGestureRecognizerDelegate>

@property(nonatomic) WarningStyle currentWarningStyle;

+ (instancetype)sharedInstance;
- (void)showHintWithStyle:(WarningStyle)style message:(NSString*)message;
- (void)showFullWarning;
- (void)hide;

@end
