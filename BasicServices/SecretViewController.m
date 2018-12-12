//
//  SecretViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 10/25/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "SecretViewController.h"

#import "UIFont+CommonValues.h"

#import "AppDelegate.h"

//------------- PARAMETERS

#define k_BarrelShotV       500
#define k_BarrelAngularV    1.05*M_PI
#define k_G                 1000

typedef enum {
    
    stateWaiting,
    statePlaying,
    stateGameOver
    
} GameState;

typedef enum {
    
    barrelNormal,
    barrelThreeState,
    barrelHot
    
} BarrelType;

//------------- GENERIC ENTITIES

@interface Entity : NSObject

@property(nonatomic, strong) UIImageView *view;
@property(nonatomic) float velX;
@property(nonatomic) float velY;
@property(nonatomic) float velAlpha;
@property(nonatomic) float applyGravity;

- (void)update:(float)dt;

@end

@implementation Entity

- (void)update:(float)dt {
    
    if(self.applyGravity) {
        self.velY += k_G * dt;
    }
    
    CGAffineTransform transform = CGAffineTransformRotate(self.view.transform, self.velAlpha*dt);
    self.view.transform = transform;
    
    self.view.center = CGPointMake(self.view.center.x + self.velX*dt, self.view.center.y + self.velY*dt);
}

@end

//------------- BARRELS

@interface Barrel : Entity

@property(nonatomic) BarrelType type;
@property(nonatomic) CGPoint endPoint1;
@property(nonatomic) CGPoint endPoint2;
@property(nonatomic) CGPoint nextPoint;
@property(nonatomic) float angle1;
@property(nonatomic) float angle2;
@property(nonatomic) BOOL active;

@property(nonatomic) float strength;
@property(nonatomic) BOOL applyGravityToPlayer;
@property(nonatomic) BOOL shouldAutoFire;

@end

@implementation Barrel

- (void)setupWithBarrelType:(BarrelType)type p1:(CGPoint)p1 p2:(CGPoint)p2 a1:(float)a1 a2:(float)a2 {
    
    self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_shutdown_barrel.png"]];
    ((UIImageView*)self.view).image = [((UIImageView*)self.view).image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.type = type;
    
    self.view.tintColor = [UIColor whiteColor];
    if(type == barrelHot) {
        self.view.tintColor = [UIColor redColor];
    }
    
    self.view.frame = CGRectMake(0, 0, 36, 36);
    
    self.endPoint1 = p1;
    self.endPoint2 = p2;
    self.angle1 = a1;
    self.angle2 = a2;
    
    self.view.center = p1;
    self.nextPoint = p2;
    CGAffineTransform transform = CGAffineTransformMakeRotation(a1);
    self.view.transform = transform;
    
    self.velAlpha = k_BarrelAngularV;
    
    if(type == barrelHot) {
        self.velAlpha = 0;
    }
    
    self.applyGravity = NO;
    self.applyGravityToPlayer = YES;
}

- (void)capturePlayer {
    
    self.active = YES;
    
    if(self.type == barrelNormal) {
        self.view.tintColor = [UIColor yellowColor];
    } else if(self.type == barrelHot) {
        float angle = atan2f(self.view.transform.b, self.view.transform.a);
        while(angle < 0) {
            angle += 2*M_PI;
        }
        
        float distToA1 = MIN(fabs(angle - self.angle1), fabs(angle - (self.angle1 + 2*M_PI)));
        float distToA2 = MIN(fabs(angle - self.angle2), fabs(angle - (self.angle2 + 2*M_PI)));
        
        if(distToA1 < distToA2) {
            self.velAlpha = k_BarrelAngularV;
        } else {
            self.velAlpha = -k_BarrelAngularV;
        }
    }
}

- (void)firePlayer {
    
    self.active = NO;
    self.shouldAutoFire = NO;
    
    if(self.type == barrelNormal) {
        self.view.tintColor = [UIColor whiteColor];
    } else if(self.type == barrelHot) {
        self.velAlpha = 0;
    }
}

- (void)update:(float)dt {
    
    if(CGPointEqualToPoint(self.endPoint1, self.endPoint2)) {
        self.velX = 0;
        self.velY = 0;
    } else {
        float directionAngle = atan2f(self.nextPoint.y - self.view.center.y, self.nextPoint.x - self.view.center.x);
        self.velX = 100*cos(directionAngle);
        self.velY = 100*sin(directionAngle);
    }
    
    if(self.angle1 == self.angle2) {
        self.velAlpha = 0;
    }
    
    CGFloat previousAngle = atan2f(self.view.transform.b, self.view.transform.a);
    BOOL goingClockwise = (self.velAlpha >= 0);
    
    [super update:dt];
    
    if(self.velX != 0 || self.velY != 0) {
        if(CGRectContainsPoint(self.view.frame, self.nextPoint)) {
            if(CGPointEqualToPoint(self.nextPoint, self.endPoint1)) {
                self.nextPoint = self.endPoint2;
            } else {
                self.nextPoint = self.endPoint1;
            }
        }
    }
    
    if(self.velAlpha != 0) {
        
        CGFloat newAngle = atan2f(self.view.transform.b, self.view.transform.a);
        
        while(newAngle < 0) {
            newAngle += 2*M_PI;
        }
        while(previousAngle < 0) {
            previousAngle += 2*M_PI;
        }
        
        if(self.angle1 < self.angle2) {
            if((newAngle < self.angle1 || newAngle > self.angle2) &&
               (previousAngle >= self.angle1 || previousAngle <= self.angle2)) {
                
                float distToA1 = MIN(fabs(newAngle - self.angle1), fabs(newAngle - (self.angle1 + 2*M_PI)));
                float distToA2 = MIN(fabs(newAngle - self.angle2), fabs(newAngle - (self.angle2 + 2*M_PI)));
                
                if(distToA1 < distToA2) {
                    self.velAlpha = k_BarrelAngularV;
                } else {
                    self.velAlpha = -k_BarrelAngularV;
                }
            }
        } else {
            if((newAngle < self.angle1 && newAngle > self.angle2) &&
               (previousAngle >= self.angle1 || previousAngle <= self.angle2)) {
                
                float distToA1 = MIN(fabs(newAngle - self.angle1), fabs(newAngle - (self.angle1 + 2*M_PI)));
                float distToA2 = MIN(fabs(newAngle - self.angle2), fabs(newAngle - (self.angle2 + 2*M_PI)));
                
                if(distToA1 < distToA2) {
                    self.velAlpha = k_BarrelAngularV;
                } else {
                    self.velAlpha = -k_BarrelAngularV;
                }
            }
        }
        
        if(self.type == barrelHot &&
           self.active &&
           (goingClockwise != self.velAlpha >= 0)) {
            
            self.shouldAutoFire = YES;
        }
    }
}

@end

//------------- GAME ENGINE

@interface SecretViewController()<UIGestureRecognizerDelegate>

@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, strong) Entity *player;
@property(nonatomic, strong) Entity *star;
@property(nonatomic, strong) NSArray *barrels;
@property(nonatomic, strong) UILabel *scoreLabel;
@property(nonatomic, strong) UIButton *restartButton;
@property(nonatomic) GameState state;
@property(nonatomic) int score;
@property(nonatomic) int indexOfActiveBarrel;
@property(nonatomic) int indexOfIgnoredBarrel;
@property(nonatomic) BOOL shouldRandomizeStar;

@end

@implementation SecretViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UILabel *creditLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 690, 395, 40)];
    creditLb.text = @"coded by @diego_cath";
    creditLb.font = [UIFont robotoWithSize:14];
    creditLb.textColor = [UIColor whiteColor];
    creditLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:creditLb];
    
    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 395, 40)];
    self.scoreLabel.text = @"score: 0";
    self.scoreLabel.font = [UIFont robotoWithSize:18];
    self.scoreLabel.textColor = [UIColor whiteColor];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.scoreLabel];
    
    self.restartButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 350, 195, 68)];
    [self.restartButton setTitle:@"Restart" forState:UIControlStateNormal];
    [self.restartButton addTarget:self action:@selector(begin) forControlEvents:UIControlEventTouchUpInside];
    self.restartButton.hidden = YES;
    [self.view addSubview:self.restartButton];
}

- (void)viewDidAppear:(BOOL)animated {
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressStateChanged:)];
    gesture.minimumPressDuration = 0;
    gesture.delegate = self;
    [self.view.superview.superview addGestureRecognizer:gesture];
    
    [self setup];
}

#pragma mark - Setup Game Objects

- (void)setup {
    
    self.player = [Entity new];
    self.player.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_user_circle.png"]];
    self.player.velAlpha = 4*M_PI;
    self.player.view.frame = CGRectMake(0, 0, 30, 30);
    [self.view addSubview:self.player.view];
    self.player.view.hidden = YES;
    
    self.star = [Entity new];
    self.star.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star.png"]];
    self.star.velAlpha = M_PI_4;
    self.star.view.frame = CGRectMake(0, 0, 20, 20);
    [self.view addSubview:self.star.view];
    
    NSMutableArray *barrels = [NSMutableArray new];
    Barrel *b;
    CGPoint p1, p2;
    float a1, a2;
    
    // top barrel
    b = [Barrel new];
    p1 = CGPointMake(50, 80);
    p2 = CGPointMake(self.view.bounds.size.width - 100, 80);
    a1 = 3*M_PI_4;
    a2 = 5*M_PI_4;
    b.strength = 1.0;
    [b setupWithBarrelType:barrelNormal p1:p1 p2:p2 a1:a1 a2:a2];
    [barrels addObject:b];
    [self.view addSubview:b.view];
    
    // bot barrel
    b = [Barrel new];
    p1 = CGPointMake(100, self.view.bounds.size.height - 180);
    p2 = CGPointMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 180);
    a1 = 7*M_PI_4;
    a2 = M_PI_4;
    b.strength = 2.0;
    [b setupWithBarrelType:barrelNormal p1:p1 p2:p2 a1:a1 a2:a2];
    [barrels addObject:b];
    [self.view addSubview:b.view];
    
    // right barrel
    b = [Barrel new];
    p1 = CGPointMake(self.view.bounds.size.width - 40, 150);
    p2 = CGPointMake(self.view.bounds.size.width - 40, self.view.bounds.size.height - 360);
    a1 = 3*M_PI_2;
    a2 = 0;
    b.strength = 1.2;
    [b setupWithBarrelType:barrelNormal p1:p1 p2:p2 a1:a1 a2:a2];
    [barrels addObject:b];
    [self.view addSubview:b.view];
    
    // left barrel
    b = [Barrel new];
    p1 = CGPointMake(40, 100);
    p2 = CGPointMake(40, self.view.bounds.size.height - 320);
    a1 = .5*M_PI_4;
    a2 = 3*M_PI_4;
    b.strength = 1.2;
    [b setupWithBarrelType:barrelNormal p1:p1 p2:p2 a1:a1 a2:a2];
    [barrels addObject:b];
    [self.view addSubview:b.view];
    
    // left-down barrel
    b = [Barrel new];
    p1 = CGPointMake(40, self.view.bounds.size.height - 180);
    p2 = CGPointMake(40, self.view.bounds.size.height - 180);
    a1 = 0;
    a2 = M_PI_2;
    b.strength = .8;
    [b setupWithBarrelType:barrelHot p1:p1 p2:p2 a1:a1 a2:a2];
    b.applyGravityToPlayer = NO;
    [barrels addObject:b];
    [self.view addSubview:b.view];
    
    // right-down barrel
    b = [Barrel new];
    p1 = CGPointMake(self.view.bounds.size.width - 40, self.view.bounds.size.height - 280);
    p2 = CGPointMake(self.view.bounds.size.width - 40, self.view.bounds.size.height - 280);
    a1 = 3*M_PI_2;
    a2 = 0;
    b.strength = 1.8;
    [b setupWithBarrelType:barrelHot p1:p1 p2:p2 a1:a1 a2:a2];
    [barrels addObject:b];
    [self.view addSubview:b.view];
    
    self.barrels = barrels;
    
    [self begin];
}

- (void)begin {
    
    self.score = 0;
    self.scoreLabel.text = @"score: 0";
    
    self.player.view.center = CGPointMake(0, 0);
    self.player.view.hidden = YES;
    
    [self randomizeStarPosition];
    
    do {
        self.indexOfActiveBarrel = arc4random() % self.barrels.count;
    } while(((Barrel*)self.barrels[self.indexOfActiveBarrel]).type != barrelNormal);
    
    ((Barrel*)self.barrels[self.indexOfActiveBarrel]).view.tintColor = [UIColor yellowColor];
    
    self.restartButton.hidden = YES;
}

- (void)randomizeStarPosition {
    
    self.shouldRandomizeStar = NO;
    self.star.view.hidden = NO;
    
    CGPoint starCenter;
    starCenter.x = 60 + arc4random() % ((int)self.view.bounds.size.width - 120);
    starCenter.y = 100 + arc4random() % ((int)self.view.bounds.size.height - 300);
    self.star.view.center = starCenter;
    
    for(Entity *e in self.barrels) {
        if(CGRectIntersectsRect(e.view.frame, self.star.view.frame)) {
            [self randomizeStarPosition];
        }
    }
    
    if(CGRectIntersectsRect(self.player.view.frame, self.star.view.frame)) {
        [self randomizeStarPosition];
    }
}

#pragma mark - Updates

- (void)tick:(CADisplayLink *)link {
    
    float dt = link.duration * link.frameInterval;
    
    if(self.player.view.hidden == NO) {
        [self.player update:dt];
    }
    
    [self.star update:dt];
    
    for (int i = 0; i < self.barrels.count; i++) {
        
        Barrel *b = self.barrels[i];
        
        if(b.type == barrelHot && b.shouldAutoFire) {
            [self firePlayer];
        }
        
        [b update:dt];
        
        // check if player collided with barrel
        if(self.player.view.hidden == NO) {
            if(hypotf(self.player.view.center.x - b.view.center.x, self.player.view.center.y - b.view.center.y) < 40.0) {
                if(i != self.indexOfIgnoredBarrel) {
                    
                    [b capturePlayer];
                    
                    self.indexOfActiveBarrel = i;
                    self.player.view.hidden = YES;
                    
                    if(self.shouldRandomizeStar) {
                        [self randomizeStarPosition];
                    }
                }
            } else if(i == self.indexOfIgnoredBarrel) {
                self.indexOfIgnoredBarrel = -1;
            }
        }
    }
    
    // check if player caught star
    if(self.player.view.hidden == NO &&
       self.star.view.hidden == NO &&
       CGRectIntersectsRect(self.player.view.frame, self.star.view.frame)) {
        
        self.score++;
        self.scoreLabel.text = [NSString stringWithFormat:@"score: %d", self.score];
        self.star.view.hidden = YES;
        self.shouldRandomizeStar = YES;
    }
    
    // check if player lost
    if(self.restartButton.hidden &&
       self.player.view.frame.origin.y > self.view.frame.size.height) {
        
        self.restartButton.hidden = NO;
        
        if(self.shouldRandomizeStar) {
            [self randomizeStarPosition];
        }
    }
}

- (void)firePlayer {
    
    Barrel *b = self.barrels[self.indexOfActiveBarrel];
    
    [b firePlayer];
    
    self.player.view.center = b.view.center;
    self.player.view.hidden = NO;
    self.indexOfIgnoredBarrel = self.indexOfActiveBarrel;
    self.indexOfActiveBarrel = -1;
    
    float alpha = atan2f(b.view.transform.b, b.view.transform.a) - M_PI_2;
    self.player.velX = k_BarrelShotV * cos(alpha) * b.strength + b.velX;
    self.player.velY = k_BarrelShotV * sin(alpha) * b.strength + b.velY;
    self.player.applyGravity = b.applyGravityToPlayer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    UIView *view = touch.view;
    CGPoint loc = [touch locationInView:view];
    UIView *subview = [view hitTest:loc withEvent:nil];
    
    if([subview isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

- (void)longPressStateChanged:(UILongPressGestureRecognizer*)gesture {
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        if(self.indexOfActiveBarrel >= 0) {
            
            Barrel *b = self.barrels[self.indexOfActiveBarrel];
            
            if(b.type == barrelHot) {
                return;
            }
            
            [self firePlayer];
        }
    }
}

@end
