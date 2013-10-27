//
//  NPViewController.m
//  ANCS
//
//  Created by uehara akihiro on 2013/10/27.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "NPViewController.h"

#define DEVICE_NAME @"ANCSNP01"

@interface NPViewController () {
    CBPeripheralManager *_peripheralManager;
}
@property (weak, nonatomic) IBOutlet UIButton *startAdvertisingButton;
@end

@implementation NPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _startAdvertisingButton.enabled  = NO;
    _startAdvertisingButton.selected = NO;
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if([version hasPrefix:@"7" ]) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
}

#pragma mark CBperipheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if(peripheral.state == CBPeripheralManagerStatePoweredOn) {
        _startAdvertisingButton.enabled = YES;
    } else {
        if(_startAdvertisingButton.selected) {
            [_peripheralManager stopAdvertising];
        }
        _startAdvertisingButton.enabled  = NO;
        _startAdvertisingButton.selected = NO;
    }
}

- (IBAction)startAdvButtontouchUpInside:(id)sender {
    if(_startAdvertisingButton.selected) {
//        NSLog(@"stop advertising...");
        [_peripheralManager stopAdvertising];
        _startAdvertisingButton.selected = NO;
    } else {
//        NSLog(@"start advertising...");
        [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey : DEVICE_NAME}];
        _startAdvertisingButton.selected = YES;
    }
}
@end
