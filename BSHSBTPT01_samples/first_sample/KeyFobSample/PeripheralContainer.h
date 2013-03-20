//
//  PeripheralContainer.h
//  KeyFobSample
//
//  Created by akihiro uehara on 2013/03/21.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// CBPeripheralは、接続後にRSSIが取れる。 接続しない状態では、発見時のRSSIを覚えておくしかない。そのためコンテナを使う。
@interface PeripheralContainer : NSObject
@property (nonatomic) NSNumber *RSSI;
@property (nonatomic) CBPeripheral *peripheral;

+(BOOL)contains:(NSSet *)containers peripheral:(CBPeripheral *)peripheral;
+(NSSet *)union:(NSSet *)a b:(NSSet *)b;

@end
