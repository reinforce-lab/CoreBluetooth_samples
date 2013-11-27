//
//  NCViewController.m
//  ANCS
//
//  Created by uehara akihiro on 2013/10/27.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "NCViewController.h"

#define DEVICE_NAME @"ANCSNP01"

static NSString * const kAncsServiceUUID = @"7905F431-B5CE-4E99-A40F-4B1E122D00D0";

static NSString * const kNotificationSourceCharUUID = @"9FBF120D-6301-42D9-8C58-25E699A21DBD";
static NSString * const kControlPointCharUUID = @"69D1D8F3-45E1-49A8-9821-9BBDFDAAD9D9";
static NSString * const kDataSourceCharUUID = @"22EAC6E9-24D6-4BB5-BE44-B36ACE7C7BFB";

@interface NCViewController () {
    CBCentralManager *_centralManager;
    CBPeripheral *_peripheral;
    CBUUID *_ancsServiceUUID;
    CBUUID *_notificationSOurceCharUUID;
    CBUUID *_controlPointCharUUID;
    CBUUID *_dataSourceCharUUID;
    
    CBCharacteristic *_notificationSOurceChar;
    CBCharacteristic *_controlPointChar;
    CBCharacteristic *_dataSourceChar;
}
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation NCViewController

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
    
    _ancsServiceUUID = [CBUUID UUIDWithString:kAncsServiceUUID];
    
    _notificationSOurceCharUUID = [CBUUID UUIDWithString:kNotificationSourceCharUUID];
    _controlPointCharUUID       = [CBUUID UUIDWithString:kControlPointCharUUID];
    _dataSourceCharUUID         = [CBUUID UUIDWithString:kDataSourceCharUUID];
    
    self.activityIndicator.hidden = YES;
    self.connectButton.enabled  = NO;
    self.connectButton.selected = NO;
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if([version hasPrefix:@"6" ]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    } else {
        self.connectButton.enabled = NO;
        self.activityIndicator.hidden = YES;
    }
}
#pragma mark Event handler
- (IBAction)connectButtonTouchUpInside:(id)sender {
    if(self.connectButton.selected) {
        self.activityIndicator.hidden = YES;
        self.connectButton.selected   = NO;

        if(_peripheral != nil) {
            [_centralManager cancelPeripheralConnection:_peripheral];
            _peripheral = nil;
        }
    } else {
        if(self.activityIndicator.hidden) {
            [self writeLog:@"Start scanning..."];
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
            [_centralManager scanForPeripheralsWithServices:nil options:nil];
//            [_centralManager retrieveConnectedPeripheralsWithServices:@[_ancsServiceUUID]];
        } else {
            [self writeLog:@"Cancel scanning..."];
            self.activityIndicator.hidden = YES;
            [_centralManager stopScan];
        }
    }
}

#pragma mark CBCentralManagerDelegate
// required
// 起動時に電源On/Off、BLEが使えるかが通知されるので、アプリ側はこれを見て動かす
// Bluetoothの電源On/Offが変更されたら、ここに通知される
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self writeLog:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    if(_centralManager.state == CBCentralManagerStatePoweredOn) {
        self.connectButton.enabled = YES;
    } else {
        self.activityIndicator.hidden = YES;
        self.connectButton.enabled  = NO;
        self.connectButton.selected = NO;
        if(_peripheral != nil) {
            [_centralManager cancelPeripheralConnection:_peripheral];
            _peripheral = nil;
        }
    }
}

// optional
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, peripherals]];
    
    _peripheral = [peripherals firstObject];
    [_peripheral discoverServices:@[_ancsServiceUUID]];
}
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, peripherals]];
    
    _peripheral = [peripherals firstObject];
    [_centralManager connectPeripheral:_peripheral options:nil];
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, peripheral]];
    
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if(localName != nil && [localName isEqualToString:DEVICE_NAME]) {
        _peripheral = peripheral;
        [_centralManager connectPeripheral:_peripheral options:nil];
        [_centralManager stopScan];
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, peripheral]];
    
    _peripheral.delegate = self;
    [_peripheral discoverServices:@[_ancsServiceUUID]];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, peripheral]];
    
    self.activityIndicator.hidden = YES;
    self.connectButton.enabled  = YES;
    self.connectButton.selected = NO;
    _peripheral = nil;
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, peripheral]];
    
    self.activityIndicator.hidden = YES;
    self.connectButton.enabled    = YES;
    self.connectButton.selected   = NO;
    _peripheral = nil;
}
#pragma mark Private method
-(NSString *)eventIDToString:(uint8_t)eventid {
    switch (eventid) {
        case 0: return @"EventIDNotificationAdded";
        case 1: return @"EventIDNotificationModified";
        case 2: return @"EventIDNotificationRemoved";
        default: return @"Reserved EventID values";
    }
}
-(NSString *)eventFlagToString:(uint8_t)eventflag {
    NSMutableString *s = [[NSMutableString alloc] init];
    if(eventflag & 0x01) {
        [s appendString:@"EventFlagSilent"];
    }
    if(eventflag & 0x02) {
        if([s length] > 0) {
            [s appendString:@"|"];
        }
        [s appendString:@"EventFlagImportant"];
    }
    if(eventflag & 0xfc) {
        if([s length] > 0) {
            [s appendString:@"|"];
        }
        [s appendString:@"Reserved EventFlags"];
    }
    return s;
}
-(NSString *)categoryIDToString:(uint8_t)categoryid {
    switch (categoryid) {
        case 0: return @"CategoryIDOther";
        case 1: return @"CategoryIDIncomingCall";
        case 2: return @"CategoryIDMissedCall";
        case 3: return @"CategoryIDVoicemail";
        case 4: return @"CategoryIDSocial";
        case 5: return @"CategoryIDSchedule";
        case 6: return @"CategoryIDEmail";
        case 7: return @"CategoryIDNews";
        case 8: return @"CategoryIDHealthAndFitness";
        case 9: return @"CategoryIDBusinessAndFinance";
        case 10: return @"CategoryIDLocation";
        case 11: return @"CategoryIDEntertainment";
        default: return @"Reserved CategoryID values";
    }
}
-(void)dumpNotificationSource:(NSData *)data {
    if([data length] != 8) {
        [self writeLog:[NSString stringWithFormat:@"Invalid data length: %d expected:8", [data length]]];
    } else {
        uint8_t buf[8];
        [data getBytes:buf];
        [self writeLog:[NSString stringWithFormat:@"EventID:%@ EventFlags:%@ CtegoryID:%@ CategoryCount:%d",
              [self eventIDToString:buf[0]],
              [self eventFlagToString:buf[1]],
              [self categoryIDToString:buf[2]],
              buf[3]]];
    }
}

#pragma mark CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, error]];
    
    [_peripheral
     discoverCharacteristics:@[_notificationSOurceCharUUID,
                               _controlPointCharUUID,
                               _dataSourceCharUUID]
     forService:[_peripheral.services firstObject]];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, service]];
    for(CBCharacteristic *c in service.characteristics) {
        if([c.UUID.data isEqualToData:_notificationSOurceCharUUID.data]) {
            _notificationSOurceChar = c;
            [_peripheral setNotifyValue:YES forCharacteristic:_notificationSOurceChar];
        } else if([c.UUID.data isEqualToData:_controlPointCharUUID.data]) {
            _controlPointChar = c;
        } else if([c.UUID.data isEqualToData:_dataSourceCharUUID.data]) {
            _dataSourceChar = c;
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, characteristic]];
    [self dumpNotificationSource:characteristic.value];
    /*
    if([characteristic.UUID.data isEqualToData:_notificationSOurceCharUUID.data]) {

    }*/
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, characteristic]];
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self writeLog:[NSString stringWithFormat:@"%s %@ value:%@", __PRETTY_FUNCTION__, characteristic, characteristic.value]];
    [self dumpNotificationSource:characteristic.value];
}
@end
