//
//  TitleBar.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 7/29/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "TitleBar.h"

#import "UIColor+CommonValues.h"

#define kSideViewMargin     30
#define kSideViewSeparation 20

@interface TitleBar()

@property(nonatomic, strong) UIView *container;
@property(nonatomic, strong) UIView *titleView;
@property(nonatomic, strong) NSMutableArray *leftSideViews;
@property(nonatomic, strong) NSMutableArray *rightSideViews;

@end

@implementation TitleBar

- (id)initWithCoder:(NSCoder*)aCoder {
    if(self = [super initWithCoder:aCoder]) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)rect {
    if(self = [super initWithFrame:rect]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    self.leftSideViews = [[NSMutableArray alloc] init];
    self.rightSideViews = [[NSMutableArray alloc] init];
    
    static const int topInset = 5;
    static const int bottomInset = 5;
    
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, topInset, self.bounds.size.width, self.bounds.size.height - (topInset + bottomInset))];
    [self addSubview:self.container];
    
    self.backgroundColor = [UIColor titleBarColor];
}

- (void)addTitle:(NSString*)title {
    
    UILabel *titleLb = [[UILabel alloc] initWithFrame:self.container.bounds];
    titleLb.font = [UIFont systemFontOfSize:40];
    titleLb.text = title;
    titleLb.textColor = [UIColor whiteColor];
    titleLb.textAlignment = NSTextAlignmentCenter;
    
    if(self.titleView) {
        [self.titleView removeFromSuperview];
    }
    
    [self.container addSubview:titleLb];
    self.titleView = titleLb;
}

- (void)addTitleImageNamed:(NSString *)imageName {
    
    UIImage *img = [UIImage imageNamed:imageName];
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:self.container.bounds];
    titleImageView.image = img;
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if(self.titleView) {
        [self.titleView removeFromSuperview];
    }
    
    [self.container addSubview:titleImageView];
    self.titleView = titleImageView;
}

- (void)addView:(UIView *)view onSide:(TBSide)side {
    
    if(side == kSideRight) {
        
        if(self.rightSideViews.count == 0) {
            
            [view setCenter:CGPointMake(self.container.bounds.size.width - kSideViewMargin - view.bounds.size.width/2, self.container.bounds.size.height/2)];
        }
        
        else {
            
            UIView* last = self.rightSideViews[self.rightSideViews.count - 1];
            
            [view setCenter:CGPointMake(last.frame.origin.x - kSideViewSeparation - view.bounds.size.width/2, self.container.bounds.size.height/2)];
        }
        
        [self.rightSideViews addObject:view];
    }
    
    else {
        
        if(self.leftSideViews.count == 0) {
            
            [view setCenter:CGPointMake(kSideViewMargin + view.bounds.size.width/2, self.container.bounds.size.height/2)];
        }
        
        else {
            
            UIView* last = self.leftSideViews[self.leftSideViews.count - 1];
            
            [view setCenter:CGPointMake(last.frame.origin.x + last.frame.size.width + kSideViewSeparation + view.bounds.size.width/2, self.container.bounds.size.height/2)];
        }
        
        [self.leftSideViews addObject:view];
    }
    
    [self.container addSubview:view];
}

@end
