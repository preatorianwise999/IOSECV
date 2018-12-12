//
//  CustomAlertView.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 10/23/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "CustomAlertView.h"

#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"

@interface CustomAlertView ()

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIView *itemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalCenterConstraint;

@end

@implementation CustomAlertView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    CGRect popupRect = self.popupView.bounds;
    UIImage *bg = [UIImage drawRoundRectWithWidth:popupRect.size.width height:popupRect.size.height radius:popupRect.size.height/8.0 thickness:0 fillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.95] borderColor:[UIColor clearColor]];
    self.popupView.backgroundColor = [UIColor colorWithPatternImage:bg];
}

- (void)addItemView:(UIView*)view {
    
    view.center = self.itemView.center;
    [self.popupView addSubview:view];
    [self.itemView removeFromSuperview];
    self.itemView = view;
}

- (void)showAnimated {
    
    self.hidden = NO;
    
    self.verticalCenterConstraint.constant = self.center.y + self.popupView.bounds.size.height;
    [self layoutIfNeeded];
    
    self.verticalCenterConstraint.constant = 0;
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.popupView.alpha = 1.0;
    
    [UIView animateWithDuration:.4 animations:^{
        self.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:.4].CGColor;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideAnimated {
    
    [UIView animateWithDuration:.2 animations:^{
        self.popupView.alpha = 0.0;
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end
