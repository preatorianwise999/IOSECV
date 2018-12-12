//
//  ServiceSelectionView.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/17/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServiceSelectionDelegate <NSObject>

- (void)serviceSelected:(NSInteger)selectedItem;

@end

@interface ServiceSelectionView : UIView<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (nonatomic) int *selectedItem;
@property (weak, nonatomic) id<ServiceSelectionDelegate> delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;


- (void)showAnimated;
- (void)hideAnimated;

@end
