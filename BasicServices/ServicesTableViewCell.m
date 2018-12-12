//
//  ServicesTableViewCell.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/4/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "ServicesTableViewCell.h"

#import "UIImage+Shapes.h"
#import "UILabel+Ring.h"

@interface ServicesTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *firstSection;
@property (weak, nonatomic) IBOutlet UIButton *secondSection;

@property (weak, nonatomic) IBOutlet UIButton *plus1;
@property (weak, nonatomic) IBOutlet UIButton *minus1;
@property (weak, nonatomic) IBOutlet UIButton *plus2;
@property (weak, nonatomic) IBOutlet UIButton *minus2;

@end

@implementation ServicesTableViewCell

- (void)awakeFromNib {
    
    // setup row highlighting (applied when tapped)
    
    CGRect fRect = self.firstSection.bounds;
    if(fRect.size.width > 0) {
        [self.firstSection setBackgroundImage:[UIImage drawRectWithWidth:fRect.size.width height:fRect.size.height thickness:0 fillColor:[UIColor colorWithWhite:1.0 alpha:.5] borderColor:[UIColor clearColor]] forState:UIControlStateHighlighted];
    }
    
    CGRect sRect = self.secondSection.bounds;
    if(sRect.size.width > 0) {
        [self.secondSection setBackgroundImage:[UIImage drawRectWithWidth:sRect.size.width height:sRect.size.height thickness:0 fillColor:[UIColor colorWithWhite:1.0 alpha:.5] borderColor:[UIColor clearColor]] forState:UIControlStateHighlighted];
    }
    
    if(self.plus1) {
        
        // setup controls/labels for hotel rooms
        
        CGRect rect = self.plus1.bounds;
        UIImage *img = [UIImage drawRoundRectWithWidth:rect.size.width height:rect.size.height radius:3 thickness:1 fillColor:[UIColor clearColor] borderColor:[UIColor whiteColor]];
        [self.plus1 setBackgroundImage:img forState:UIControlStateNormal];
        [self.minus1 setBackgroundImage:img forState:UIControlStateNormal];
        [self.plus2 setBackgroundImage:img forState:UIControlStateNormal];
        [self.minus2 setBackgroundImage:img forState:UIControlStateNormal];
        [self.label2 drawRingWithRadius:16 color:[UIColor whiteColor]];
        [self.label3 drawRingWithRadius:16 color:[UIColor whiteColor]];
        [self setOptionsHidden:YES];
    }
    
    // get rid of touch delay
    // iterate over all the UITableViewCell's subviews
    for (id view in self.subviews) {
        // looking for a UITableViewCellScrollView
        if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewCellScrollView"]) {
            // this test is here for safety only, also there is no UITableViewCellScrollView in iOS8
            if([view isKindOfClass:[UIScrollView class]]) {
                // turn OFF delaysContentTouches in the hidden subview
                UIScrollView *scroll = (UIScrollView *) view;
                scroll.delaysContentTouches = NO;
            }
            break;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)firstSectionClicked:(id)sender {
    [self.delegate serviceCell:self didClickButton:0];
}

- (IBAction)secondSectionClicked:(id)sender {
    [self.delegate serviceCell:self didClickButton:1];
}

- (IBAction)plusBtnClicked:(id)sender {
    if([sender isEqual:self.plus1]) {
        NSInteger max = MAX(0, [self.label2.text integerValue]);
        NSInteger val = [self.selectionLabel2.text integerValue];
        self.selectionLabel2.text = [@((int)MIN(max, val + 1)) stringValue];
    }
    else if([sender isEqual:self.plus2]) {
        NSInteger max = MAX(0, [self.label3.text integerValue]);
        NSInteger val = [self.selectionLabel3.text integerValue];
        self.selectionLabel3.text = [@((int)MIN(max, val + 1)) stringValue];
    }
    
    [self.delegate roomValueChanged:self];
}

- (IBAction)minusBtnClicked:(id)sender {
    if([sender isEqual:self.minus1]) {
        NSInteger val = [self.selectionLabel2.text integerValue];
        self.selectionLabel2.text = [@((int)MAX(0, val - 1)) stringValue];
    }
    else if([sender isEqual:self.minus2]) {
        NSInteger val = [self.selectionLabel3.text integerValue];
        self.selectionLabel3.text = [@((int)MAX(0, val - 1)) stringValue];
    }
    
    [self.delegate roomValueChanged:self];
}

- (void)setOptionsHidden:(BOOL)hidden {
    self.label2.hidden = hidden;
    self.label3.hidden = hidden;
    self.selectionLabel2.hidden = hidden;
    self.selectionLabel3.hidden = hidden;
    self.plus1.hidden = hidden;
    self.minus1.hidden = hidden;
    self.plus2.hidden = hidden;
    self.minus2.hidden = hidden;
}

@end
