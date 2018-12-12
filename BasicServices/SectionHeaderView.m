//
//  SectionHeaderView.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/7/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "SectionHeaderView.h"
#import "UILabel+Ring.h"

@implementation SectionHeaderView

- (void)awakeFromNib {
    
    // set the selected image for the disclosure button
    [self.disclosureButton setImage:[UIImage imageNamed:@"disclosure_closed.png"] forState:UIControlStateSelected];
    
    // set up the tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
    [self addGestureRecognizer:tapGesture];
    
    [self.numberLabel drawRingWithRadius:15 color:[UIColor whiteColor]];
}

- (IBAction)toggleOpen:(id)sender {
    
    [self toggleOpenWithUserAction:YES];
}

- (void)setOpen:(BOOL)open {
    self.disclosureButton.selected = !open;
}

- (void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // toggle the disclosure button state
    self.disclosureButton.selected = !self.disclosureButton.selected;
    
    // if this was a user action, send the delegate the appropriate message
    if (userAction) {
        if (self.disclosureButton.selected) {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [self.delegate sectionHeaderView:self sectionOpened:self.section];
            }
        }
    }
}

@end