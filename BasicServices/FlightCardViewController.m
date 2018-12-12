//
//  FlightCardViewController.m
//  Nimbus2
//
//  Created by 720368 on 7/7/15.
//  Copyright (c) 2015 TCS. All rights reserved.
//

#import "FlightCardViewController.h"

#import "UILabel+Ring.h"

#import "Flight.h"
#import "Cabin.h"

#import "ModelHelper.h"

#import "UIColor+CommonValues.h"

@interface FlightCardViewController ()

@property (weak, nonatomic) IBOutlet UILabel *flightLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *airportLabel;
@property (weak, nonatomic) IBOutlet UILabel *cabinLabel1;
@property (weak, nonatomic) IBOutlet UILabel *cabinLabel2;
@property (weak, nonatomic) IBOutlet UILabel *numLabel1;
@property (weak, nonatomic) IBOutlet UILabel *numLabel2;

@property (weak, nonatomic) IBOutlet UIView *background;


@end

@implementation FlightCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.flight) {
        return;
    }
    
    NSSet *cabins = self.flight.cabins;
    self.flightLabel.text = self.flight.flightName;
    NSDate *date = self.flight.departureDate;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = NSLocalizedString(@"flight_date_format", @"Date Format");
    self.dateLabel.text = [df stringFromDate:date];
    self.airportLabel.text = self.flight.departureAirport;
    
    Cabin *jc, *yc;
    
    for(Cabin *c in cabins) {
        if([c.name isEqualToString:@"J"]) {
            jc = c;
        }
        else if([c.name isEqualToString:@"Y"]) {
            yc = c;
        }
    }
    
    int jcCurrent = jc.currentValue.intValue;
    //            int jcMax = ((Cabin*)cabins[0]).capacity.intValue;
    int ycCurrent = yc.currentValue.intValue;
    //            int ycMax = ((Cabin*)cabins[1]).capacity.intValue;
    
    //            self.cabinLabel1.text = [NSString stringWithFormat:@"%@C", ((Cabin*)cabins[0]).name];
    //            self.cabinLabel2.text = [NSString stringWithFormat:@"%@C", ((Cabin*)cabins[1]).name];
    self.numLabel1.text = [NSString stringWithFormat:@"%d", jcCurrent];
    self.numLabel2.text = [NSString stringWithFormat:@"%d", ycCurrent];
    [self.numLabel1 drawRingWithProgressPercentage:.75 radius:35 ringColor:[UIColor whiteColor] progressColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.5]];
    [self.numLabel2 drawRingWithProgressPercentage:.75 radius:35 ringColor:[UIColor whiteColor] progressColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.5]];
    
    self.view.layer.allowsEdgeAntialiasing = YES;
    
    self.background.backgroundColor = [UIColor appLightColorWithOpacity:.6];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
