#import <CoreBluetooth/CoreBluetooth.h>

#define kDeviceName @"SomeDeviceName"

@interface CBCentral_skelton() <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *centralManager_;
}
@end

@implementation CBCentral_skelton

#pragma mark Constructor
-(id)init {
    self = [super init];
    if(self) {
        // 1. CBCentralManagerをインスタンスする
        centralManager_ = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma mark - Private methods
#pragma mark - Public methods

#pragma mark CBCentralManagerDelegate
// required
// 起動時に電源On/Off、BLEが使えるかが通知されるので、アプリ側はこれを見て動かす
// Bluetoothの電源On/Offが変更されたら、ここに通知される
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {            
    switch ([centralManager_ state]) {
        case CBCentralManagerStatePoweredOff:
            // Bluetoothの電源がOffのとき、iOSが、ONが必要なメッセージと設定画面に飛ぶダイアログを、アプリ起動時に自動表示してくれる
            break;
        case CBCentralManagerStatePoweredOn:
            break;
            
        case CBCentralManagerStateResetting:
            break;
            
        case CBCentralManagerStateUnauthorized:
            // Tell user the app is not allowed
            break;
            
        case CBCentralManagerStateUnknown:
            // Bad news, let's wait for another event
            break;
            
        case CBCentralManagerStateUnsupported:
            // Bluetooth low energy is not supported for this device.
            break;
    }
}

// optional
/*
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals;
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals;
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
*/

#pragma mark CBPeripheralDelegate
//optional

/*
// Available from iOS6
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
*/

/*
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;
*/
@end
