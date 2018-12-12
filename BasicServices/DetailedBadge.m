//
//  DetailedBadge.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/4/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "DetailedBadge.h"

#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"
#import "UIFont+CommonValues.h"

@interface DetailedBadge ()

@end

@implementation DetailedBadge

- (id)initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if(self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    
    int w = self.bounds.size.width;
    int h = self.bounds.size.height;
    
    // circle background
    UIImageView* badgeBackground =
    [[UIImageView alloc] initWithImage:
     [UIImage drawCircleWithWidth:w
                            height:h
                            thickness:1
                            fillColor:[UIColor appLightColorWithOpacity:.8]
                            borderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.5]]];
    [self addSubview:badgeBackground];
    
    // first informative label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectOffset(self.bounds, 0, -8)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont robotoWithSize:20.0];
    label.text = @"2";
    [self addSubview:label];
    self.ammountLabel = label;
    
    // second informative label
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height/2.0 - 2, self.bounds.size.width, self.bounds.size.height/2.0)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont robotoWithSize:12.0];
    label.text = @"Taxi";
    [self addSubview:label];
    self.descriptionLabel = label;
    
    self.backgroundColor = [UIColor clearColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
