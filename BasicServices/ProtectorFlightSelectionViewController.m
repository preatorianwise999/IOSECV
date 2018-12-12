//
//  ProtectorFlightSelectionViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/7/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "ProtectorFlightSelectionViewController.h"

#import "Flight.h"
#import "CompensationService.h"

#import "ProtectorFlightTableViewCell.h"

#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"

static NSString *cellIdentifier = @"ProtectorFlightCell";

@interface ProtectorFlightSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end

@implementation ProtectorFlightSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"ProtectorFlightTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CGRect popupRect = self.popupView.bounds;
    UIImage *bg = [UIImage drawRoundRectWithWidth:popupRect.size.width height:popupRect.size.height radius:popupRect.size.height/20.0 thickness:0 fillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.95] borderColor:[UIColor clearColor]];
    self.popupView.backgroundColor = [UIColor colorWithPatternImage:bg];
    self.popupView.clipsToBounds = YES;
    
    self.icon.image = [self.icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.icon.tintColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapInView)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
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

- (void)showAnimated {
    
    [self.tableView reloadData];
    
    self.view.hidden = NO;
    
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.popupView.alpha = 0;
    
    [UIView animateWithDuration:.4 animations:^{
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
    }];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate protectorFlightSelected:self.flights[indexPath.row]];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.flights.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProtectorFlightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Flight *info = self.flights[indexPath.row];
    
    // labels
    cell.flightNameLb.text = info.flightName;
    NSDate *date = info.departureDate;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = NSLocalizedString(@"flight_date_format", @"Date Format");
    cell.flightDateLb.text = [df stringFromDate:date];
    
    // icons
    
    UIColor *gray = [UIColor colorWithWhite:.6 alpha:1.0];
    UIColor *blue = [UIColor appDarkColorWithOpacity:1.0];
    
    cell.iconFood.image = [cell.iconFood.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.iconFood.tintColor = (info.foodServices.count > 0) ? blue : gray;
    
    cell.iconTransport.image = [cell.iconTransport.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.iconTransport.tintColor = (info.travelServices.count > 0) ? blue : gray;
    
    cell.iconHotel.image = [cell.iconHotel.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.iconHotel.tintColor = (info.hotelServices.count > 0) ? blue : gray;
    
    cell.iconCompensation.image = [cell.iconCompensation.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.iconCompensation.tintColor = gray;
    cell.servicesLabel.text = @"";
    cell.cashLabel.text = @"";
    cell.upgLabel.text = @"";
    
    CompensationService *compensation = info.compensationServices.anyObject;
    if(compensation != nil) {
        
        BOOL includeCompensation = (compensation && ([compensation.cashAmount doubleValue] > 0 || [compensation.servicesAmount doubleValue] > 0 || [compensation.upgrade boolValue]));
        
        if(includeCompensation) {
            
            cell.iconCompensation.tintColor = blue;
            
            cell.servicesLabel.text = [compensation.servicesAmount stringByAppendingString:@" USD"];
            cell.cashLabel.text = [compensation.cashAmount stringByAppendingString:@" USD"];
            cell.upgLabel.text = [compensation.upgrade boolValue] ? @"UPG" : @"NO UPG";
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

@end
