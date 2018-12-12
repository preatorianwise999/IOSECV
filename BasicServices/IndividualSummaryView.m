//
//  IndividualSummaryView.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/12/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "IndividualSummaryView.h"

#import "UIFont+CommonValues.h"

@interface IndividualSummaryView()

@end

@implementation IndividualSummaryView

- (void)setNumberOfVouchersForFood:(int)nFood transport:(int)nTransport hotel:(int)nHotel compensation:(int)nCompensation {
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int x = 0;
    
    if(nFood > 0) {
        [self addVoucherWithImageName:@"ic_restaurant" number:nFood x:x y:0];
        x += 42;
    }
    
    if(nTransport > 0) {
        [self addVoucherWithImageName:@"ic_transport" number:nTransport x:x y:0];
        x += 42;
    }
    
    if(nHotel > 0) {
        [self addVoucherWithImageName:@"ic_hotel" number:nHotel x:x y:0];
        x += 42;
    }
    
    if(nCompensation > 0) {
        [self addVoucherWithImageName:@"ic_compensation" number:nCompensation x:x y:0];
        x += 42;
    }
}

- (void)addVoucherWithImageName:(NSString*)name number:(int)number x:(int)x y:(int)y {
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    image.frame = CGRectMake(x, y, 20, 20);
    [self addSubview:image];
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(x + 21, y, 18, 20)];
    lb.text = [NSString stringWithFormat:@"x%d", number];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.font = [UIFont robotoWithSize:12];
    lb.textColor = [UIColor whiteColor];
    [self addSubview:lb];
}

@end
