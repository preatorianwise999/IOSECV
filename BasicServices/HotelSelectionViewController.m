//
//  HotelSelectionViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 11/7/15.
//  Copyright © 2015 Diego Cathalifaud. All rights reserved.
//

#import "HotelSelectionViewController.h"

#import "HotelTableViewCell.h"

#import "UIImage+Shapes.h"
#import "UIColor+CommonValues.h"
#import "HotelService.h"
#import "Provider.h"
#import "HotelData.h"
#import "UIFont+CommonValues.h"

static NSString *cellIdentifier = @"HotelCell";

@interface HotelSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) NSArray *hotels;

@end

@implementation HotelSelectionViewController

- (void)loadDataWithServices:(NSSet*)hotelServices {
    
    NSMutableDictionary *hotelsByName = [[NSMutableDictionary alloc] init];
    
    for(HotelService *hs in hotelServices) {
        HotelData *data = hotelsByName[hs.provider.name];
        if(!data) {
            data = [[HotelData alloc] init];
            data.hotelName = hs.provider.name;
            hotelsByName[data.hotelName] = data;
        }
        
        if([hs.subCode isEqualToString:kStrSingleRoom]) {
            data.nSingle = hs.roomAvailibility.intValue;
        }
        else if([hs.subCode isEqualToString:kStrDoubleRoom]) {
            data.nDouble = hs.roomAvailibility.intValue;
        }
    }
    
    self.hotels = [hotelsByName.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"numberOfBeds" ascending:NO]]];
    
    self.heightConstraint.constant = MIN(500, 60*(self.hotels.count + 1) + 110);
    [self.view layoutIfNeeded];
    
    CGRect popupRect = self.popupView.bounds;
    UIImage *bg = [UIImage drawRoundRectWithWidth:popupRect.size.width height:popupRect.size.height radius:popupRect.size.height/25.0 thickness:0 fillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.95] borderColor:[UIColor clearColor]];
    self.popupView.backgroundColor = [UIColor colorWithPatternImage:bg];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"HotelTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

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
    }];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == self.hotels.count) {
        [self.delegate hotelSelected:@"-"];
    }
    else {
        [self.delegate hotelSelected:((HotelData*)self.hotels[indexPath.row]).hotelName];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.hotels.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HotelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(indexPath.row == self.hotels.count) {
        cell.hotelNameLb.text = NSLocalizedString(@"service_no_hotel", @"No Hotel");
        cell.singleRoomLb.hidden = YES;
        cell.doubleRoomLb.hidden = YES;
    }
    
    else {
        
        HotelData *data = self.hotels[indexPath.row];
        cell.hotelNameLb.text = data.hotelName;
        cell.singleRoomLb.text = @(data.nSingle).stringValue;
        cell.doubleRoomLb.text = @(data.nDouble).stringValue;
        cell.singleRoomLb.hidden = NO;
        cell.doubleRoomLb.hidden = NO;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 24)];
    header.backgroundColor = [UIColor colorWithWhite:.9 alpha:.9];
    
    UILabel *sgLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 24)];
    sgLb.center = CGPointMake(332, 12);
    sgLb.textAlignment = NSTextAlignmentCenter;
    sgLb.text = @"Single";
    sgLb.font = [UIFont robotoWithSize:16];
    sgLb.textColor = [UIColor blackColor];
    [header addSubview:sgLb];
    
    UILabel *dbLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 24)];
    dbLb.center = CGPointMake(402, 12);
    dbLb.textAlignment = NSTextAlignmentCenter;
    dbLb.text = @"Double";
    dbLb.font = [UIFont robotoWithSize:16];
    dbLb.textColor = [UIColor blackColor];
    [header addSubview:dbLb];
    
    return header;
}

@end
