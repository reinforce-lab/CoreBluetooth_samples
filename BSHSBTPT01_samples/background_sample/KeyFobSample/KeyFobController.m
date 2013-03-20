//
//  KeyFobController.m
//  KeyFobSample
//
//  Created by akihiro uehara on 2013/01/17.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import "KeyFobController.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#define kTargetDeviceName          @"BSHSBTPT01BK"

#define kImmediateAlertServiceUUID @"1802"
#define kLinkLossServiceUUID       @"1803"
#define kAlertLevelUUID            @"2A06"

#define kTxPowerLevelServiceUUID   @"1804"
#define kTxPowerLevelUUID          @"2A07"

#define kBatteryLevelServiceUUID   @"180F"
#define kBatteryLevelUUID          @"2A19"
#define kBatteryLevelSwitchUUID    @"2A1B"

@interface KeyFobController() <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *_centralManager;
    // CBCentralManagerはCBPeripheralをretainしないので、アプリ側で保持しなければならない
    CBPeripheral *_peripheral;
    NSTimer *_timer;
    
    CBCharacteristic *_linkLossCharacteristic;
    CBCharacteristic *_immediateAlertCharacteristic;
    CBCharacteristic *_txPowerCharacteristic;
    CBCharacteristic *_batteryLevelCharacteristics;
    CBCharacteristic *_batteryLevelSwitchCharacteristics;
    
    CBUUID *_linkLossServiceUUID;
    CBUUID *_immediateAlertServiceUUID;
    CBUUID *_alertLevelUUID;
    
    CBUUID *_txPowerServiceUUID;
    CBUUID *_txPowerUUID;
    
    CBUUID *_batteryLevelServiceUUID;
    CBUUID *_batteryLevelUUID;
    CBUUID *_batteryLevelSwitchUUID;
}
@property (nonatomic) BOOL isBTPoweredOn;
@property (nonatomic) BOOL isScanning;
@property (nonatomic) BOOL isConnected;

@property (nonatomic) AlertType linkLossAlertLevel;

@property (nonatomic) int  deviceRSSI;
@property (nonatomic) int  txPower;

@property (nonatomic) int  batteryLevel;
@property (nonatomic) BOOL isSwitchPushed;

@property (nonatomic)  CTCallCenter *callCenter;
@end

@implementation KeyFobController
@synthesize isBTPoweredOn;
@synthesize isScanning;
@synthesize isConnected;

@synthesize linkLossAlertLevel;

@synthesize deviceRSSI;
@synthesize txPower;

@synthesize batteryLevel;
@synthesize isSwitchPushed;

#pragma mark Core Telephony

#pragma mark Constructor
-(id)init {
    self = [super init];
    if(self) {
        // CBCentralManagerをインスタンスする
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

        // サービス名やCharacteristicを判別するための、UUIDはここで準備しておきます
        // デバイスのすべてのサービスとCharacteristicsを列挙して、
        // 必要になった時点でUUIDで検索をかけてもいいのですが、
        // ここでは必要なサービスとCharacteristicsのみを事前取得するようにします
        _linkLossServiceUUID       = [CBUUID UUIDWithString:kLinkLossServiceUUID];
        _immediateAlertServiceUUID = [CBUUID UUIDWithString:kImmediateAlertServiceUUID];
        _alertLevelUUID            = [CBUUID UUIDWithString:kAlertLevelUUID];

        _txPowerServiceUUID = [CBUUID UUIDWithString:kTxPowerLevelServiceUUID];
        _txPowerUUID        = [CBUUID UUIDWithString:kTxPowerLevelUUID];
  
        _batteryLevelServiceUUID = [CBUUID UUIDWithString:kBatteryLevelServiceUUID];
        _batteryLevelUUID        = [CBUUID UUIDWithString:kBatteryLevelUUID];
        _batteryLevelSwitchUUID  = [CBUUID UUIDWithString:kBatteryLevelSwitchUUID];
        
        // Setting up CoreTelephony
        self.callCenter = [[CTCallCenter alloc] init];
        __weak KeyFobController *weak_self = self;
        _callCenter.callEventHandler = ^(CTCall *inCTCall) {
            NSString *callState = inCTCall.callState;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Phone call event: %@", [weak_self.callCenter.currentCalls anyObject]);
                if(callState ==CTCallStateIncoming) {
                    [weak_self alert:HighAlert];
                } else {
                    [weak_self alert:NoAlert];
                }
            });
        };
    }
    return self;
}
-(void)dealloc {
    [self stopScanning];
    [self disconnect];
}
#pragma mark - Private methods
-(void)timerFired:(NSTimer *)timer {
    if(_peripheral != nil) {
        [_peripheral readRSSI];
    }
}

-(void)disconnectIntrinsic {
    [self stopScanning];
    
    [_timer invalidate];
    _timer = nil;

    _peripheral                   = nil;
    _linkLossCharacteristic       = nil;
    _immediateAlertCharacteristic = nil;
    _txPowerCharacteristic        = nil;
    _batteryLevelCharacteristics  = nil;
    _batteryLevelSwitchCharacteristics = nil;
        
    self.isSwitchPushed = NO;
    self.txPower        = 0;
    self.deviceRSSI     = 0;
    self.batteryLevel   = 0;
    
    self.isScanning  = NO;
    self.isConnected = NO;
}

-(CBCharacteristic *)findCharacteristics:(NSArray *)cs uuid:(CBUUID *)uuid
{
    for (CBCharacteristic *c in cs) {
        //DLog(@"\tUUID:%@ value:%@ (uuid:%@)", c.UUID, c.value, uuid.data);
        if ([c.UUID.data isEqualToData:uuid.data]) {
            return c;
        }
    }
    return nil;
}

#pragma mark - Public methods
-(void)startScanning {
    if( !isBTPoweredOn || isScanning) return;
    
    // BLEデバイスのスキャン時には、検索対象とするサービスを指定することが推奨です
    NSArray *scanServices = [NSArray arrayWithObjects:_linkLossServiceUUID, _immediateAlertServiceUUID, nil];
    // スキャンにはオプションが指定できます。いまあるオプションは、ペリフェラルを見つけた時に重複して通知するか、の指定です。
    // 近接検出など、コネクションレスでデバイスの状態を取得する用途などでは、これをYESに設定します。デフォルトでNOです。
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                            forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    // デバイスのスキャン開始。iPhoneはアドバタイズメント・パケットの受信を開始します。
    // このスキャンは、明示的に停止しない限り、スキャンし続けます。このスキャンは、アドバタイズメント・パケットの(2.4GHzの)受信処理で、RF回路は電力を消費します。
    [_centralManager scanForPeripheralsWithServices:scanServices options:scanOptions];
    
    self.isScanning = YES;
}

-(void)stopScanning {
    if(!isScanning) return;
    
    [_centralManager stopScan];
    self.isScanning = NO;
}

-(void)alert:(AlertType)value {
    if(_immediateAlertCharacteristic == nil) return;

    uint8_t b[1];
    b[0] = value;
    NSData *d = [NSData dataWithBytes:b length:1];
    [_peripheral writeValue:d forCharacteristic:_immediateAlertCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

-(void)setLinkLossAlert:(AlertType)value {
    // もしもサービスに接続していないなら、処理は無効です
    if(_linkLossCharacteristic == nil) return;
    
    self.linkLossAlertLevel = value;
    
    uint8_t b[1];
    b[0] = value;
    NSData *d = [NSData dataWithBytes:b length:1];
    [_peripheral writeValue:d forCharacteristic:_linkLossCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)disconnect {
    // ペリフェラルが未接続なら、切断処理は不要です
    if(_peripheral == nil) return;
    
    // 切断処理をします。_peripheralをnilにするなどの、切断完了後処理は、
    // centralManager:didDisconnectPeripheral:error:
    // で行います。
    [_centralManager cancelPeripheralConnection:_peripheral];
}

#pragma mark CBCentralManagerDelegate

// required
// 起動時に電源On/Off、BLEが使えるかが通知されるので、アプリ側はこれを見て動かす
// Bluetoothの電源On/Offが変更されたら、ここに通知される
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch ([_centralManager state]) {
        case CBCentralManagerStatePoweredOff:
            // Bluetoothの電源がOffのとき、iOSが、ONが必要なメッセージと設定画面に飛ぶダイアログを、アプリ起動時に自動表示してくれる
            self.isBTPoweredOn = NO;
            self.isScanning    = NO;
            self.isConnected   = NO;
            break;
        case CBCentralManagerStatePoweredOn:
            self.isBTPoweredOn = YES;
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
 
 */
// デバイスの発見時処理を行います。
// スキャンで指定したサービスがあるデバイスのみが通知されますが、同じような機能を持った対象外の装置を発見するかもしれません。
// アドバタイズメント・パケットに含まれる情報は、advertisementDataから得られます。デバイス名などで判別します。
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // すでにperipheralを見つけているときは、接続処理をしません
    if(_peripheral != nil) return;

    // 同一機種が周囲に複数あるとき、自分がもっているものだけに接続するには、UUIDが同じかを判定します。
    // !!注意!! iOS6では、一度も接続したことがない装置のUUIDはnilになります。一度でも接続すればUUIDが取れます。ここでは、一度は接続したことがある前提でUUIDを比較しています。
    /*
    CBUUID *targetUUID = [CBUUID UUIDWithString:@"00000000-0000-0000-2F0C-F0289947EA35"];
    if(peripheral.UUID == nil || ! [[CBUUID UUIDWithCFUUID:peripheral.UUID].data isEqualToData:targetUUID.data]) return;
    */
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if(localName != nil && [localName isEqualToString:kTargetDeviceName] ) {

        NSLog(@"Adv: %@ %@", RSSI, peripheral);
        
        //ターゲットを発見、接続します
        //この時点でperipheralはcentral managerに保持されていません。少なくとも接続が完了するまでの間、peripheralをアプリ側で保持します。
        //接続処理はタイムアウトしません。接続に失敗すれば centralManager:didFailToConnectPeripheral:error: が呼ばれます。
        //接続処理を中止するには、peripheralを開放するか、明示的に cancelPeripheralConnection を呼び出します。
        /*
        _peripheral = peripheral;
        [central connectPeripheral:_peripheral options:nil];

        // スキャンを停止します
        [self stopScanning];
         */
    }
}

// 接続失敗
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self disconnectIntrinsic];
}

// 接続
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // サービスを探します
    _peripheral.delegate = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    self.isConnected = YES;
    
    [peripheral discoverServices:[NSArray arrayWithObjects:
                                  _linkLossServiceUUID,
                                  _immediateAlertServiceUUID,
                                  _txPowerServiceUUID,
                                  _batteryLevelServiceUUID,
                                  nil]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self disconnectIntrinsic];
}

#pragma mark CBPeripheralDelegate
//optional
//- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0);
//- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0);

//発見したサービスに対して、Characteristicsを探します
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // FIXME: エラー処理の実装
    for (CBService *service in peripheral.services) {
        if ([service.UUID.data isEqualToData:_linkLossServiceUUID.data]) {
            [peripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                 _alertLevelUUID,
                                                 nil]
                                     forService:service];
        } else if ([service.UUID.data isEqualToData:_immediateAlertServiceUUID.data]) {
            [peripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                 _alertLevelUUID,
                                                 nil]
                                     forService:service];
        } else if ([service.UUID.data isEqualToData:_txPowerServiceUUID.data]) {
            [peripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                 _txPowerUUID,
                                                 nil]
                                     forService:service];
        } else if ([service.UUID.data isEqualToData:_batteryLevelServiceUUID.data]) {
            [peripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                 _batteryLevelUUID,
                                                 _batteryLevelSwitchUUID,
                                                 nil]
                                     forService:service];
        } else {
            // unknown service...
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // FIXME: エラー処理の実装
    if ([service.UUID.data isEqualToData:_linkLossServiceUUID.data]) {
        _linkLossCharacteristic = [self findCharacteristics:service.characteristics uuid:_alertLevelUUID];
        [peripheral readValueForCharacteristic:_linkLossCharacteristic];
    } else if ([service.UUID.data isEqualToData:_immediateAlertServiceUUID.data]) {
        _immediateAlertCharacteristic = [self findCharacteristics:service.characteristics uuid:_alertLevelUUID];
    } else if ([service.UUID.data isEqualToData:_txPowerServiceUUID.data]) {
        _txPowerCharacteristic =[self findCharacteristics:service.characteristics uuid:_txPowerUUID];
        [peripheral readValueForCharacteristic:_txPowerCharacteristic];
    } else if ([service.UUID.data isEqualToData:_batteryLevelServiceUUID.data]) {
        _batteryLevelCharacteristics = [self findCharacteristics:service.characteristics uuid:_batteryLevelUUID];
        _batteryLevelSwitchCharacteristics = [self findCharacteristics:service.characteristics uuid:_batteryLevelSwitchUUID];
        
        [peripheral setNotifyValue:YES forCharacteristic:_batteryLevelSwitchCharacteristics];
        
        [peripheral readValueForCharacteristic:_batteryLevelCharacteristics];
        [peripheral readValueForCharacteristic:_batteryLevelSwitchCharacteristics];
    }
}
/*
 - (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
 - (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
 - (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
 - (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;
 - (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;
 */

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    self.deviceRSSI = [peripheral.RSSI integerValue];
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    uint8_t b;
    if(characteristic == _txPowerCharacteristic) {
        [characteristic.value getBytes:&b length:1];
        self.txPower = b;
    } else if(characteristic == _linkLossCharacteristic) {
        [characteristic.value getBytes:&b length:1];
        self.linkLossAlertLevel = b;
    } else if(characteristic == _batteryLevelCharacteristics) {
        [characteristic.value getBytes:&b length:1];
        self.batteryLevel = b;
    } else if(characteristic == _batteryLevelSwitchCharacteristics) {
        [characteristic.value getBytes:&b length:1];
        self.isSwitchPushed = (b == 0x01);
    }
}
@end
