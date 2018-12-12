//
//  DetailedButton.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/30/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "DetailedButton.h"

#import "UIFont+CommonValues.h"

#import "UILabel+Ring.h"

@interface DetailedButton()

@property(nonatomic, strong) NSMutableArray *detailViews;
@property(nonatomic, strong) UIView *detail;

@end

@implementation DetailedButton

- (void)setUpAsCompanionsBtnWithNumberOfCompanions:(NSUInteger)companions {

    if(!self.detail) {
        
        UILabel *numLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        numLb.textColor = [UIColor whiteColor];
        numLb.font = [UIFont robotoWithSize:15.0];
        numLb.textAlignment = NSTextAlignmentCenter;
        numLb.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.origin.y + self.bounds.size.height/2 + 16);
        [self addSubview:numLb];
        [numLb drawRingWithRadius:15 color:[UIColor whiteColor]];
        self.detail = numLb;
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, numLb.bounds.size.height + 5.0, 0.0);
    }
    
    ((UILabel*)self.detail).text = [@(companions) stringValue];
}

- (void)setUpAsBasicServicesBtn {
    
    if(!self.detail) {
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        img.image = [UIImage imageNamed:@"star.png"];
        img.center = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2, self.bounds.origin.y + self.bounds.size.height/2 + 16);
        [self addSubview:img];
        self.detail = img;
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, img.bounds.size.height + 5.0, 0.0);
    }
}

@end
