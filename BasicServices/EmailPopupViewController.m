//
//  EmailPopupViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 3/7/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import "EmailPopupViewController.h"

#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"

@interface EmailPopupViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UILabel *desiredEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmationLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalCenterConstraint;

@end

@implementation EmailPopupViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect popupRect = self.popupView.bounds;
    UIImage *bg = [UIImage drawRoundRectWithWidth:popupRect.size.width height:popupRect.size.height radius:popupRect.size.height/15.0 thickness:0 fillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.95] borderColor:[UIColor clearColor]];
    self.popupView.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    CGRect submitRect = self.submitButton.bounds;
    self.submitButton.backgroundColor = [UIColor clearColor];
    self.submitButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage drawRoundRectWithWidth:submitRect.size.width height:submitRect.size.height radius:submitRect.size.height/2 thickness:0 fillColor:[UIColor appDarkColorWithOpacity:1.0] borderColor:[UIColor clearColor]]];
    
    self.popupView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapInView)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(textField == self.desiredEmailTextField) {
        [self.confirmationTextField becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.popupView.frame, [touch locationInView:self.view])) {
        return NO;
    }
    return YES;
}

- (IBAction)updateButtonTapped:(id)sender {
    
    self.desiredEmailLabel.textColor = [UIColor blackColor];
    self.confirmationLabel.textColor = [UIColor blackColor];
    
    if([self validateEmail:self.desiredEmailTextField.text] == NO) {
        self.desiredEmailLabel.textColor = [UIColor redColor];
        [self.desiredEmailTextField becomeFirstResponder];
    } else if([self.desiredEmailTextField.text isEqualToString:self.confirmationTextField.text] == NO) {
        self.confirmationLabel.textColor = [UIColor redColor];
        [self.confirmationTextField becomeFirstResponder];
    } else {
        [self.delegate emailPopupClosedWithNewEmail:self.desiredEmailTextField.text];
        [self hideAnimated];
    }
}

- (BOOL)validateEmail:(NSString*)emailString {
    
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

- (void)tapInView {
    [self hideAnimated];
}

- (void)showAnimated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    self.desiredEmailTextField.text = @"";
    self.confirmationTextField.text = @"";
    self.desiredEmailLabel.textColor = [UIColor blackColor];
    self.confirmationLabel.textColor = [UIColor blackColor];
    
    self.view.hidden = NO;
    
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.popupView.alpha = 0;
    
    [UIView animateWithDuration:.2 animations:^{
        self.view.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:.4].CGColor;
        self.popupView.alpha = 1;
    }];
    
    [self.desiredEmailTextField becomeFirstResponder];
}

- (void)hideAnimated {
    
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:.2 animations:^{
        self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.popupView.alpha = 0;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow {
    
    self.verticalCenterConstraint.constant = -160;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide {
    self.verticalCenterConstraint.constant = 0;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
