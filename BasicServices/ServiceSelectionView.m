//
//  ServiceSelectionView.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/17/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "ServiceSelectionView.h"

#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"

@interface ServiceSelectionView ()

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalCenterConstraint;

@end

@implementation ServiceSelectionView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    CGRect popupRect = self.popupView.bounds;
    UIImage *bg = [UIImage drawRoundRectWithWidth:popupRect.size.width height:popupRect.size.height radius:popupRect.size.height/8.0 thickness:0 fillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.95] borderColor:[UIColor clearColor]];
    self.popupView.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    CGRect submitRect = self.okButton.bounds;
    self.okButton.backgroundColor = [UIColor clearColor];
    self.okButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage drawRoundRectWithWidth:submitRect.size.width height:submitRect.size.height radius:submitRect.size.height/2 thickness:0 fillColor:[UIColor appDarkColorWithOpacity:1.0] borderColor:[UIColor clearColor]]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapInView)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.popupView.frame, [touch locationInView:self])) {
        return NO;
    }
    return YES;
}

- (void)tapInView {
    [self hideAnimated];
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

- (IBAction)okButtonClicked:(id)sender {
    
    [self.delegate serviceSelected:([self.picker selectedRowInComponent:0])];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
