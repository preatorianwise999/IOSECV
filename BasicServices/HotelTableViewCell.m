//
//  HotelTableViewCell.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/9/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "HotelTableViewCell.h"

#import "UILabel+Ring.h"

@implementation HotelTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.singleRoomLb drawRingWithRadius:20 thickness:1.5 color:[UIColor darkGrayColor]];
    [self.doubleRoomLb drawRingWithRadius:20 thickness:1.5 color:[UIColor darkGrayColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
