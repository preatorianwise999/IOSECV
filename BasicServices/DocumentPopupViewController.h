//
//  DocumentPopupViewController.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/25/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentData : NSObject

@property(strong, nonatomic) NSString *countryCode;
@property(strong, nonatomic) NSString *documentType;
@property(strong, nonatomic) NSString *documentNumber;

@end

@protocol DocumentPopupDelegate <NSObject>

- (void)documentPopupClosedWithNewDocument:(DocumentData*)document;

@end

@interface DocumentPopupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *paxNameLabel;
@property (weak, nonatomic) id<DocumentPopupDelegate> delegate;

- (void)showAnimated;

@end
