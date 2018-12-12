//
//  LTMBaseViewController.m
//  BasicServices
//
//  Created by Diego Cathalifaud on 2/29/16.
//  Copyright © 2016 Diego Cathalifaud. All rights reserved.
//

#import "LTMBaseViewController.h"

#import "ActivityIndicatorView.h"
#import "Synchronizer.h"
#import "FlightsViewController.h"

@interface LTMBaseViewController () <SyncDelegate>

@property (nonatomic, strong) Synchronizer *sync;

@end

@implementation LTMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scanButtonPressed {
    
    //NSLog(@"SCAN");
}

- (void)syncButtonPressed {
    
    [[ActivityIndicatorView getSharedInstance] startActivityInView:self.view withMessage:NSLocalizedString(@"activity_sync", @"Sync")];
    
    self.sync = [[Synchronizer alloc] init];
    self.sync.delegate = self;
    self.sync.forcedSync = YES;
    [self.sync synchronizeModel];
}

- (void)logoutButtonPressed {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)popToFlightsViewController {
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[FlightsViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
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
