//
//  ServicesTableViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 8/3/15.
//  Copyright (c) 2015 Diego Cathalifaud. All rights reserved.
//

#import "ServicesTableViewController.h"

#import "ServicesTableViewCell.h"

#import "UIFont+CommonValues.h"

#import "ModelHelper.h"
#import "Flight.h"
#import "FoodService.h"
#import "TravelService.h"
#import "HotelService.h"
#import "CompensationService.h"
#import "Provider.h"

#import "CheckoutInput.h"

#import "AppDelegate.h"

#define kHeightForSingleEntryCell   52
#define kHeightForDoubleEntryCell   82
#define kHeightForTripleEntryCell   125

#define kStrSingleRoom      @"SG"
#define kStrDoubleRoom      @"DB"

static NSString *cellIdentifier1 = @"ServiceCellSingleEntry";
static NSString *cellIdentifier2 = @"ServiceCellDoubleEntry";
static NSString *cellIdentifier3a = @"ServiceCellHotel";
static NSString *cellIdentifier3b = @"ServiceCellCompensation";

typedef enum {
    
    kProtectorFlightCell,
    kFoodServiceCell,
    kTransportServiceCell,
    kHotelServiceCell,
    kCompensationServiceCell
    
} CellType;

@interface ServicesTableViewController ()

@property(nonatomic, strong) Flight *flight;
@property(nonatomic, strong) Flight *protectorFlight;
@property(nonatomic, weak) UITableView *tableView;

@property(nonatomic, strong) NSArray *foodServicePassengerTypes;
@property(nonatomic, strong) NSDictionary *foodServiceTypes;
@property(nonatomic, strong) NSArray *transportServiceTypes;
@property(nonatomic, strong) NSDictionary *transportServiceProviders;
@property(nonatomic, strong) NSArray *hotelServiceProviders;
@property(nonatomic, strong) NSDictionary *hotelServiceAvailability;

@property(nonatomic, strong) ServicesTableViewCell *editedCell;
@property(nonatomic) CellType editingCellType;
@property(nonatomic) int editingBtnIndex;

@end

@implementation ServicesTableViewController

- (id)initWithTableView:(UITableView*)tableView andFlight:(Flight*)flight {
    
    if(self = [super init]) {
        
        self.flight = flight;
        self.protectorFlight = [flight defaultProtectorFlight];
        self.tableView = tableView;
        
        UINib *nib = [UINib nibWithNibName:@"ServicesTableViewCellSingle" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier1];
        nib = [UINib nibWithNibName:@"ServicesTableViewCellDouble" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier2];
        nib = [UINib nibWithNibName:@"ServicesTableViewCellHotel" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier3a];
        nib = [UINib nibWithNibName:@"ServicesTableViewCellCompensation" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier3b];
        
        self.editingBtnIndex = -1;
        
        self.input = [[CheckoutInput alloc] init];
        self.input.protectorFlight = self.protectorFlight;
        
        [self loadData];
    }
    
    return self;
}

- (void)setServiceSelectionView:(ServiceSelectionView *)serviceSelectionView {
    _serviceSelectionView = serviceSelectionView;
    self.serviceSelectionView.picker.delegate = self;
    self.serviceSelectionView.delegate = self;
}

- (void)setProtectorSelectionController:(ProtectorFlightSelectionViewController *)protectorSelectionController {
    _protectorSelectionController = protectorSelectionController;
    self.protectorSelectionController.delegate = self;
}

- (void)setHotelSelectionController:(HotelSelectionViewController *)hotelSelectionController {
    _hotelSelectionController = hotelSelectionController;
    self.hotelSelectionController.delegate = self;
    [self.hotelSelectionController loadDataWithServices:self.protectorFlight.hotelServices];
}

- (int)formHeight {
    
    int h = kHeightForSingleEntryCell;
    
    if(self.includeCompensationSection) h += kHeightForTripleEntryCell;
    if(self.includeFoodSection) h += kHeightForDoubleEntryCell;
    if(self.includeTransportSection) h += kHeightForDoubleEntryCell;
    if(self.includeHotelSection) h += kHeightForTripleEntryCell;
    
    return h;
}

- (void)loadData {
    
    CompensationService *compensation = self.protectorFlight.compensationServices.anyObject;
    
    self.includeCompensationSection = (compensation && ([compensation.cashAmount doubleValue] > 0 || [compensation.servicesAmount doubleValue] > 0 || [compensation.upgrade boolValue]));
    self.includeFoodSection = (self.protectorFlight.foodServices && self.protectorFlight.foodServices.count > 0);
    self.includeTransportSection = (self.protectorFlight.travelServices && self.protectorFlight.travelServices.count > 0);
    self.includeHotelSection = (self.protectorFlight.hotelServices && self.protectorFlight.hotelServices.count > 0);
    
    // food services
    
    NSMutableArray *regularMeals = [[NSMutableArray alloc] init];
    NSMutableArray *vipMeals = [[NSMutableArray alloc] init];
    
    NSSet *services = self.protectorFlight.foodServices;
    for(FoodService *f in services) {
        if([f.type compare:kStrRegular options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [regularMeals addObject:[f.details uppercaseString]];
        } else if([f.type compare:kStrHighValue options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [vipMeals addObject:[f.details uppercaseString]];
        }
    }
    
    NSMutableArray *paxTypes = [[NSMutableArray alloc] init];
    [paxTypes addObject:@"-"];
    if(vipMeals.count > 0) {
        [paxTypes addObject:kStrHighValue];
    }
    if(regularMeals.count > 0) {
        [paxTypes addObject:kStrRegular];
    }
    self.foodServicePassengerTypes = paxTypes;
    self.foodServiceTypes = @{kStrHighValue : vipMeals, kStrRegular : regularMeals};
    
    if(![self.foodServicePassengerTypes containsObject:self.input.passengerType]) {
        self.input.passengerType = nil;
        self.input.foodServiceName = nil;
    }
    if(![self.foodServiceTypes[self.input.passengerType] containsObject:self.input.foodServiceName]) {
        self.input.foodServiceName = nil;
    }
    
    // transport services
    
    NSMutableArray *options1 = [NSMutableArray arrayWithObject:@"-"];
    NSMutableDictionary *options2 = [[NSMutableDictionary alloc] init];
    services = [self.protectorFlight.travelServices copy];
    for(TravelService *s in services) {
        if(![options1 containsObject:s.details]) {
            [options1 addObject:s.details];
        }
        NSMutableArray *array = [NSMutableArray arrayWithArray:options2[s.details]];
        [array addObject:s.provider.name];
        options2[s.details] = array;
    }
    self.transportServiceTypes = options1;
    self.transportServiceProviders = options2;
    
    if(![self.transportServiceTypes containsObject:self.input.transportType]) {
        self.input.transportProvider = nil;
        self.input.transportType = nil;
    } else if(![self.transportServiceProviders[self.input.transportType] containsObject:self.input.transportProvider]) {
        self.input.transportProvider = nil;
    }
    
    // hotel services
    
    options1 = [NSMutableArray arrayWithObject:@"-"];
    options2 = [[NSMutableDictionary alloc] init];
    services = [self.protectorFlight.hotelServices copy];
    for(HotelService *s in services) {
        if(![options1 containsObject:s.provider.name]) {
            [options1 addObject:s.provider.name];
        }
        NSMutableDictionary *roomDict = [NSMutableDictionary dictionaryWithDictionary:options2[s.provider.name]];
        roomDict[s.subCode] = s.roomAvailibility;
        options2[s.provider.name] = roomDict;
    }
    self.hotelServiceProviders = options1;
    self.hotelServiceAvailability = options2;
    
    if(![self.hotelServiceProviders containsObject:self.input.hotelProvider]) {
        self.input.hotelProvider = nil;
        self.input.hotelSingleNumber = 0;
        self.input.hotelDoubleNumber = 0;
    }
    
    if(self.hotelSelectionController != nil) {
        [self.hotelSelectionController loadDataWithServices:self.protectorFlight.hotelServices];
    }
}

- (NSString*)getTitleForCellType:(CellType)cellType atIndex:(int)index {
    
    NSString *title;
    switch (cellType) {
        case kProtectorFlightCell: {
            if(index == 0) {
                title = NSLocalizedString(@"service_protector_flight_title", @"Protector Flight");
            }
        } break;
            
        case kFoodServiceCell: {
            if(index == 0) {
                title = NSLocalizedString(@"service_food_passenger_type", @"Passenger Type");
            } else {
                title = NSLocalizedString(@"service_food_service_type", @"Service Type");
            }
        } break;
            
        case kTransportServiceCell: {
            if(index == 0) {
                title = NSLocalizedString(@"service_transport_type", @"Transport Type");
            } else {
                title = NSLocalizedString(@"service_transport_provider", @"Provider");
            }
        } break;
            
        case kHotelServiceCell: {
            title = @"Hotel";
        } break;
            
        case kCompensationServiceCell: {
            if(index == 0) {
                title = NSLocalizedString(@"service_LATAM_services_title", @"LATAM services");
            } else if(index == 1) {
                title = NSLocalizedString(@"service_cash_title", @"Cash");
            } else if(index == 2) {
                title = @"UPG";
            }
        } break;
            
        default: {
            
        } break;
    }
    
    return title;
}

- (NSString*)getIconNameForCellType:(CellType)cellType {
    
    switch (cellType) {
        case kProtectorFlightCell: {
            return @"ic_protector.png";
        } break;
            
        case kFoodServiceCell: {
            return @"ic_restaurant.png";
        } break;
            
        case kTransportServiceCell: {
            return @"ic_transport.png";
        } break;
            
        case kHotelServiceCell: {
            return @"ic_hotel.png";
        } break;
            
        case kCompensationServiceCell: {
            return @"ic_compensation.png";
        } break;
            
        default: {
            
        } break;
    }
    
    return nil;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CellType cellType = [self cellTypeForIndex:(int)indexPath.row];
    
    switch (cellType) {
        case kProtectorFlightCell: {
            return kHeightForSingleEntryCell;
        } break;
            
        case kFoodServiceCell: {
            return kHeightForDoubleEntryCell;
        } break;
            
        case kTransportServiceCell: {
            return kHeightForDoubleEntryCell;
        } break;
            
        case kHotelServiceCell: {
            return kHeightForTripleEntryCell;
        } break;
            
        case kCompensationServiceCell: {
            return kHeightForTripleEntryCell;
        } break;
            
        default: {
            
        } break;
    }
    
    return 0;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int rows = 1;
    
    if(self.includeCompensationSection) rows ++;
    if(self.includeFoodSection) rows++;
    if(self.includeTransportSection) rows++;
    if(self.includeHotelSection) rows++;

    return rows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CellType cellType = [self cellTypeForIndex:(int)indexPath.row];
    
    ServicesTableViewCell *cell;
    UIColor *iconColor;
    
    if(cellType == kProtectorFlightCell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        
        cell.label1.text = [self getTitleForCellType:cellType atIndex:0];
        if([self.input.protectorFlight isEqual:self.flight] == NO) {
            iconColor = [UIColor whiteColor];
            cell.selectionLabel1.text = self.input.protectorFlight.flightName;
        } else {
            iconColor = [UIColor colorWithWhite:.6 alpha:1.0];
            cell.selectionLabel1.text = @"";
        }
   
    } else if(cellType == kFoodServiceCell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        
        cell.label1.text = [self getTitleForCellType:cellType atIndex:0];
        cell.selectionLabel1.text = self.input.passengerType;
        cell.label2.text = [self getTitleForCellType:cellType atIndex:1];
        cell.selectionLabel2.text = self.input.foodServiceName;
        if([self.input isFoodSelected]) {
            iconColor = [UIColor whiteColor];
        } else {
            iconColor = [UIColor colorWithWhite:.6 alpha:1.0];
        }
   
    } else if(cellType == kTransportServiceCell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        
        cell.label1.text = [self getTitleForCellType:cellType atIndex:0];
        cell.selectionLabel1.text = self.input.transportType;
        cell.label2.text = [self getTitleForCellType:cellType atIndex:1];
        cell.selectionLabel2.text = self.input.transportProvider;
        if([self.input isTransportSelected]) {
            iconColor = [UIColor whiteColor];
        } else {
            iconColor = [UIColor colorWithWhite:.6 alpha:1.0];
        }
    
    } else if(cellType == kHotelServiceCell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3a];
        
        cell.label1.text = [self getTitleForCellType:cellType atIndex:0];
        cell.selectionLabel1.text = self.input.hotelProvider;
        cell.label2.text = @"0";            // single max
        cell.selectionLabel2.text = @"0";   // single current
        cell.label3.text = @"0";            // double max
        cell.selectionLabel3.text = @"0";   // double current
        if([self.input isHotelSelected]) {
            iconColor = [UIColor whiteColor];
        } else {
            iconColor = [UIColor colorWithWhite:.6 alpha:1.0];
        }
  
    } else if(cellType == kCompensationServiceCell) {
       
        CompensationService *compensation = [self.protectorFlight.compensationServices anyObject];
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3b];
        
        cell.label1.text = [self getTitleForCellType:cellType atIndex:0];
        cell.label2.text = [self getTitleForCellType:cellType atIndex:1];
        cell.label3.text = [self getTitleForCellType:cellType atIndex:2];
        cell.selectionLabel1.text = compensation.servicesAmount;
        cell.selectionLabel2.text = compensation.cashAmount;
        cell.selectionLabel3.text = [compensation.upgrade boolValue] ? @"YES" : @"NO";
        cell.selectionSwitch.on = self.input.compensationSelected;
        [cell.selectionSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        if(self.input.compensationSelected) {
            iconColor = [UIColor whiteColor];
        } else {
            iconColor = [UIColor colorWithWhite:.6 alpha:1.0];
        }
    }
    
    // style
    
    cell.icon.image = [[UIImage imageNamed:[self getIconNameForCellType:cellType]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.icon.tintColor = iconColor;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.cellIndex = (int)indexPath.row;

    return cell;
}

- (CellType)cellTypeForIndex:(int)index {
    
    if(index >= 1 && !self.includeFoodSection) index++;
    if(index >= 2 && !self.includeTransportSection) index++;
    if(index >= 3 && !self.includeHotelSection) index++;
    
    switch (index) {
            
        case 0: {
            return kProtectorFlightCell;
        }
        case 1: {
            return kFoodServiceCell;
        }
        case 2: {
            return kTransportServiceCell;
        }
        case 3: {
            return kHotelServiceCell;
        }
        case 4: {
            return kCompensationServiceCell;
        }
        default: {
            return kFoodServiceCell;
        }
    }
}

#pragma mark ServiceSelectionDelegate methods

- (void)serviceSelected:(NSInteger)selectedItem {
    
    [self.serviceSelectionView hideAnimated];
    
    switch (self.editingCellType) {
        case kFoodServiceCell: {
            if(self.editingBtnIndex == 0) {
                self.input.passengerType = self.foodServicePassengerTypes[selectedItem];
                self.editedCell.selectionLabel1.text = [self.input.passengerType uppercaseString];
                if([self.input.passengerType isEqual:@"-"]) {
                    self.editedCell.selectionLabel1.text = @"";
                    self.editedCell.selectionLabel2.text = @"";
                    self.input.passengerType = nil;
                    self.input.foodServiceName = nil;
                } else if(![(NSArray*)self.foodServiceTypes[self.editedCell.selectionLabel1.text] containsObject:self.editedCell.selectionLabel2.text]) {
                    self.editedCell.selectionLabel2.text = @"";
                    self.input.foodServiceName = nil;
                }
            } else {
                NSArray *items = self.foodServiceTypes[self.input.passengerType];
                self.input.foodServiceName = items[selectedItem];
                self.editedCell.selectionLabel2.text = [self.input.foodServiceName uppercaseString];
            }
            
            // update icon
            if([self.input isFoodSelected]) {
                self.editedCell.icon.tintColor = [UIColor whiteColor];
            } else {
                self.editedCell.icon.tintColor = [UIColor colorWithWhite:.6 alpha:1.0];
            }
            
        } break;
        
        case kTransportServiceCell: {
            if(self.editingBtnIndex == 0) {
                self.input.transportType = self.transportServiceTypes[selectedItem];
                self.editedCell.selectionLabel1.text = [self.input.transportType uppercaseString];
                if([self.input.transportType isEqual:@"-"]) {
                    self.editedCell.selectionLabel1.text = @"";
                    self.editedCell.selectionLabel2.text = @"";
                    self.input.transportType = nil;
                    self.input.transportProvider = nil;
                } else if(![(NSArray*)self.transportServiceProviders[self.editedCell.selectionLabel1.text] containsObject:self.editedCell.selectionLabel2.text]) {
                    self.editedCell.selectionLabel2.text = @"";
                    self.input.transportProvider = nil;
                }
            } else {
                NSArray *items = self.transportServiceProviders[self.input.transportType];
                self.input.transportProvider = items[selectedItem];
                self.editedCell.selectionLabel2.text = [self.input.transportProvider uppercaseString];
            }
            
            // update icon
            if([self.input isTransportSelected]) {
                self.editedCell.icon.tintColor = [UIColor whiteColor];
            } else {
                self.editedCell.icon.tintColor = [UIColor colorWithWhite:.6 alpha:1.0];
            }
            
        } break;
        default: {
            
        } break;
    }
    
    self.editingBtnIndex = -1;
}

#pragma mark ProtectorFlightSelectionDelegate

- (void)protectorFlightSelected:(Flight *)flight {
    
    assert(flight != nil);
    
    self.protectorFlight = flight;
    self.input.protectorFlight = flight;
    self.editedCell.selectionLabel1.text = flight.flightName;
    
    if([flight isEqual:[self.flight defaultProtectorFlight]]) {
        self.editedCell.selectionLabel1.text = @"";
        self.editedCell.icon.tintColor = [UIColor colorWithWhite:.6 alpha:1.0];
    } else {
        self.editedCell.icon.tintColor = [UIColor whiteColor];
    }
    
    [self loadData];
    self.servicesHeightConstraint.constant = [self formHeight];
    [self.tableView.superview layoutIfNeeded];
    [self.tableView reloadData];
    [self.protectorSelectionController hideAnimated];
}

#pragma mark HotelSelectionDelegate

- (void)hotelSelected:(NSString *)hotelName {
    
    self.input.hotelProvider = hotelName;
    
    if(![[self.input.hotelProvider uppercaseString] isEqualToString:self.editedCell.selectionLabel1.text]) {
        
        self.editedCell.selectionLabel1.text = [self.input.hotelProvider uppercaseString];
        if([self.editedCell.selectionLabel1.text isEqual:@"-"]) {
            self.editedCell.selectionLabel1.text = @"";
            [self.editedCell setOptionsHidden:YES];
            self.input.hotelProvider = nil;
            self.input.hotelSingleNumber = 0;
            self.input.hotelDoubleNumber = 0;
        } else {
            NSDictionary *availabilities = self.hotelServiceAvailability[self.input.hotelProvider];
            self.editedCell.label2.text = [availabilities[kStrSingleRoom] stringValue];
            self.editedCell.label3.text = [availabilities[kStrDoubleRoom] stringValue];
            [self.editedCell setOptionsHidden:NO];
        }
        
        self.editedCell.selectionLabel2.text = @"0";
        self.editedCell.selectionLabel3.text = @"0";
        
        // update icon
        [self roomValueChanged:self.editedCell];
    }
    
    [self.hotelSelectionController hideAnimated];
}

#pragma mark ServiceCellDelegate methods

- (void)serviceCell:(ServicesTableViewCell*)cell didClickButton:(int)btnIndex {
    
    self.editedCell = cell;
    self.editingCellType = [self cellTypeForIndex:cell.cellIndex];
    self.editingBtnIndex = btnIndex;
    
    if(self.editingCellType == kFoodServiceCell || self.editingCellType == kTransportServiceCell) {
        
        NSInteger selectedIndex = 0;
        
        if(self.editingCellType == kFoodServiceCell) {
            if(btnIndex == 0) {
                selectedIndex = [self.foodServicePassengerTypes indexOfObject:self.input.passengerType];
            }
            else if(btnIndex == 1) {
                if(!self.input.passengerType) {
                    return;
                }
                selectedIndex = [self.foodServiceTypes[self.input.passengerType] indexOfObject:self.input.foodServiceName];
            }
        } else if(self.editingCellType == kTransportServiceCell) {
            if(btnIndex == 0) {
                selectedIndex = [self.transportServiceTypes indexOfObject:self.input.transportType];
            } else if(btnIndex == 1) {
                if(!self.input.transportType) {
                    return;
                }
                selectedIndex = [self.transportServiceProviders[self.input.transportType] indexOfObject:self.input.transportProvider];
            }
        }
        
        if(selectedIndex == NSNotFound) {
            selectedIndex = 0;
        }
        
        // populate selection popup
        self.serviceSelectionView.title.text = [self getTitleForCellType:self.editingCellType atIndex:btnIndex];
        UIImage *icon = [UIImage imageNamed:[self getIconNameForCellType:self.editingCellType]];
        icon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.serviceSelectionView.icon.image = icon;
        self.serviceSelectionView.icon.tintColor = [UIColor blackColor];
        [self.serviceSelectionView.picker selectRow:MAX(0, selectedIndex) inComponent:0 animated:NO];
        [self.serviceSelectionView.picker reloadAllComponents];
        
        // show selection popup animated
        [self.serviceSelectionView showAnimated];
    } else if(self.editingCellType == kProtectorFlightCell) {
        
        [self.protectorSelectionController showAnimated];
    } else if(self.editingCellType == kHotelServiceCell) {
        [self.hotelSelectionController showAnimated];
    }
}

- (void)roomValueChanged:(ServicesTableViewCell*)cell {
   
    cell.icon.tintColor = [UIColor colorWithWhite:.6 alpha:1.0];
    
    if(self.input.hotelProvider) {
        
        self.input.hotelSingleNumber = cell.selectionLabel2.text.intValue;
        self.input.hotelDoubleNumber = cell.selectionLabel3.text.intValue;
        if(self.input.hotelSingleNumber > 0 || self.input.hotelDoubleNumber > 0) {
            cell.icon.tintColor = [UIColor whiteColor];
        }
    }
}

- (void)switchValueChanged:(id)sender {
    
    UISwitch *selectionSwitch = (UISwitch*)sender;
    self.input.compensationSelected = selectionSwitch.isOn;
    
    id view = [selectionSwitch superview];
    while (view && [view isKindOfClass:[ServicesTableViewCell class]] == NO) {
        view = [view superview];
    }
    
    ServicesTableViewCell *cell = (ServicesTableViewCell*)view;
    cell.icon.tintColor = [UIColor colorWithWhite:.6 alpha:1.0];
    if(self.input.compensationSelected) {
        cell.icon.tintColor = [UIColor whiteColor];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (self.editingCellType) {
        case kFoodServiceCell: {
            if(self.editingBtnIndex == 0) {
                return self.foodServicePassengerTypes.count;
            } else {
                NSArray *foodTypes = self.foodServiceTypes[self.input.passengerType];
                return foodTypes.count;
            }
        } break;
        case kTransportServiceCell: {
            if(self.editingBtnIndex == 0) {
                return self.transportServiceTypes.count;
            } else {
                NSArray *transportProviders = self.transportServiceProviders[self.input.transportType];
                return transportProviders.count;
            }
        } break;
            
        default: {
            return 0;
        } break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    switch (self.editingCellType) {
        case kFoodServiceCell: {
            if(self.editingBtnIndex == 0) {
                return [self.foodServicePassengerTypes[row] uppercaseString];
            } else {
                NSArray *foodTypes = self.foodServiceTypes[self.input.passengerType];
                return [foodTypes[row] uppercaseString];
            }
        } break;
            
        case kTransportServiceCell: {
            if(self.editingBtnIndex == 0) {
                return [self.transportServiceTypes[row] uppercaseString];
            } else {
                NSArray *transportProviders = self.transportServiceProviders[self.input.transportType];
                return [transportProviders[row] uppercaseString];
            }
        } break;
            
        default:
            break;
    }
    
    return nil;
}

@end
