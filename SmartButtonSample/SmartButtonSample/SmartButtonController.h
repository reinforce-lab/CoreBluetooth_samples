//
//  SmartButtonController.h
//  KeyFobSample
//
//  Created by akihiro uehara on 2013/01/17.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartButtonController : NSObject

@property (nonatomic, readonly) BOOL isBTPoweredOn;
@property (nonatomic, readonly) BOOL isScanning;
@property (nonatomic, readonly) BOOL isConnected;

@property (nonatomic, readonly) int  deviceRSSI;
@property (nonatomic, readonly) int  batteryLevel;

@property (nonatomic, readonly) BOOL isSwitch1Pushed;
@property (nonatomic, readonly) BOOL isSwitch2Pushed;

-(void)startScanning;
-(void)stopScanning;

-(void)disconnect;
@end
