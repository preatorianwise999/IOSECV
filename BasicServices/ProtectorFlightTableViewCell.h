//
//  ProtectorFlightTableViewCell.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/7/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProtectorFlightTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconFood;
@property (weak, nonatomic) IBOutlet UIImageView *iconTransport;
@property (weak, nonatomic) IBOutlet UIImageView *iconHotel;
@property (weak, nonatomic) IBOutlet UIImageView *iconCompensation;

@property (weak, nonatomic) IBOutlet UILabel *servicesLabel;
@property (weak, nonatomic) IBOutlet UILabel *cashLabel;
@property (weak, nonatomic) IBOutlet UILabel *upgLabel;

@property (weak, nonatomic) IBOutlet UILabel *flightNameLb;
@property (weak, nonatomic) IBOutlet UILabel *flightDateLb;

@end
