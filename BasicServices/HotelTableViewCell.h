//
//  HotelTableViewCell.h
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/9/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotelTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *hotelNameLb;
@property (weak, nonatomic) IBOutlet UILabel *singleRoomLb;
@property (weak, nonatomic) IBOutlet UILabel *doubleRoomLb;


@end
