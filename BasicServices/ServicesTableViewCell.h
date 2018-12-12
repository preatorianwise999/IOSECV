//
//  ServicesTableViewCell.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/4/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServiceCellDelegate

- (void)serviceCell:(id)cell didClickButton:(int)btnIndex;
- (void)roomValueChanged:(id)cell;

@end

@interface ServicesTableViewCell : UITableViewCell

@property (nonatomic) int cellIndex;

@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *selectionLabel1;
@property (weak, nonatomic) IBOutlet UILabel *selectionLabel2;
@property (weak, nonatomic) IBOutlet UILabel *selectionLabel3;
@property (weak, nonatomic) IBOutlet UISwitch *selectionSwitch;

@property (weak, nonatomic) id<ServiceCellDelegate> delegate;

- (void)setOptionsHidden:(BOOL)hidden;

@end
