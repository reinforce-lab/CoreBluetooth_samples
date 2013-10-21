//
//  CentralViewController.m
//  simpleBeacon
//
//  Created by uehara akihiro on 2013/10/21.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "CentralViewController.h"

@interface CentralViewController () {
    CBCentralManager *_centralManager;
}
@property (weak, nonatomic) IBOutlet UISwitch *centralSwitch;
@end

@implementation CentralViewController

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

//    _queue = dispatch_queue_create("cbCentralQueue", NULL);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	// Do any additional setup after loading the view.
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Event handler
- (IBAction)centralSwitchValueChanged:(id)sender {
    if (_centralManager.state != CBCentralManagerStatePoweredOn) {
        [self showAleart:@"Bleutoothの電源が入っていません"];
        self.centralSwitch.on = NO;
        return;
    }
    
    if(self.centralSwitch.on) {
        NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
        [_centralManager scanForPeripheralsWithServices:nil options:options];
    } else {
        [_centralManager stopScan];
    }
}
#pragma mark CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self writeLog:[NSString stringWithFormat:@"advertisementData:%@ RSSI:%@", advertisementData, RSSI]];
    });
}

@end
