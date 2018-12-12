//
//  SignaturePopupViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/12/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignaturePopupDelegate <NSObject>

- (void)signaturePopupClosedWithResult:(UIImage*)image;

@end

@interface SignaturePopupViewController : UIViewController

@property(nonatomic, weak) id<SignaturePopupDelegate> delegate;

- (void)showWithSignatureImage:(UIImage*)image;

@end
