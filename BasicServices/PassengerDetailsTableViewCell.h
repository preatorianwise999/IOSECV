//
//  PassengerDetailsTableViewCell.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/24/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassengerDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *editCodesLabel;

@property (weak, nonatomic) IBOutlet UILabel *mailLabel;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;

@property (weak, nonatomic) IBOutlet UILabel *documentLabel;
@property (weak, nonatomic) IBOutlet UIButton *documentButton;

@property (weak, nonatomic) IBOutlet UISwitch *selectionSwitch;

@end