//
//  SignaturePopupViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 4/12/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import "SignaturePopupViewController.h"

#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"

#define BRUSH_SIZE 2.0

@interface SignaturePopupViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;

@property (nonatomic) BOOL touchMoved;
@property (nonatomic) CGPoint previousPoint;

@end

@implementation SignaturePopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect popupRect = self.popupView.bounds;
    UIImage *bg = [UIImage drawRoundRectWithWidth:popupRect.size.width height:popupRect.size.height radius:popupRect.size.height/15.0 thickness:0 fillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.95] borderColor:[UIColor clearColor]];
    self.popupView.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    CGRect submitRect = self.submitButton.bounds;
    self.submitButton.backgroundColor = [UIColor clearColor];
    self.submitButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage drawRoundRectWithWidth:submitRect.size.width height:submitRect.size.height radius:submitRect.size.height/2 thickness:0 fillColor:[UIColor appDarkColorWithOpacity:1.0] borderColor:[UIColor clearColor]]];
    
    self.popupView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapInView)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    self.signatureImageView.layer.borderWidth = .5;
    self.signatureImageView.layer.borderColor = [UIColor lightGrayColor].CGColor ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(self.popupView.frame, [touch locationInView:self.view])) {
        return NO;
    }
    return YES;
}

- (void)tapInView {
    [self hideAnimated];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self.delegate signaturePopupClosedWithResult:self.signatureImageView.image];
    [self hideAnimated];
}

- (IBAction)clearButtonTapped:(id)sender {
    self.signatureImageView.image = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.touchMoved = NO;
    UITouch *touch = [touches anyObject];
    self.previousPoint = [touch locationInView:self.signatureImageView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.touchMoved = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.signatureImageView];
    
    UIGraphicsBeginImageContext(self.signatureImageView.bounds.size);
    [self.signatureImageView.image drawInRect:self.signatureImageView.bounds];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.previousPoint.x, self.previousPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), BRUSH_SIZE);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.signatureImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.signatureImageView setAlpha:1.0];
    UIGraphicsEndImageContext();
    
    self.previousPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(self.touchMoved == NO) {
        UIGraphicsBeginImageContext(self.signatureImageView.bounds.size);
        [self.signatureImageView.image drawInRect:self.signatureImageView.bounds];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), BRUSH_SIZE);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.previousPoint.x, self.previousPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.previousPoint.x, self.previousPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.signatureImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (void)showWithSignatureImage:(UIImage*)image {
    
    self.signatureImageView.image = image;
    
    self.view.hidden = NO;
    
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.popupView.alpha = 0;
    
    [UIView animateWithDuration:.2 animations:^{
        self.view.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:.4].CGColor;
        self.popupView.alpha = 1;
    }];
}

- (void)hideAnimated {
    
    [UIView animateWithDuration:.2 animations:^{
        self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.popupView.alpha = 0;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        self.signatureImageView.image = nil;
    }];
}


@end
