//
//  EmailPopupViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 3/7/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmailPopupDelegate <NSObject>

- (void)emailPopupClosedWithNewEmail:(NSString*)email;

@end

@interface EmailPopupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *passengerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentEmailLabel;
@property (weak, nonatomic) IBOutlet UITextField *desiredEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmationTextField;
@property (weak, nonatomic) id<EmailPopupDelegate> delegate;

- (void)showAnimated;

@end
