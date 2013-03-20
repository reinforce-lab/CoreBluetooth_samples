//
//  KeyFobController.h
//  KeyFobSample
//
//  Created by akihiro uehara on 2013/01/17.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    NoAlert    = 0,
    MidAlert   = 1,
    HighAlert = 2,
} AlertType;

@interface KeyFobController : NSObject

@property (nonatomic, readonly) BOOL isBTPoweredOn;
@property (nonatomic, readonly) BOOL isScanning;
@property (nonatomic, readonly) BOOL isConnected;

@property (nonatomic, readonly) AlertType linkLossAlertLevel;

@property (nonatomic, readonly) int  deviceRSSI;
@property (nonatomic, readonly) int  txPower;

@property (nonatomic, readonly) int  batteryLevel;
@property (nonatomic, readonly) BOOL isSwitchPushed;

@property (nonatomic) BOOL shouldNotifyPhoneCall;

-(void)startScanning;
-(void)stopScanning;

-(void)alert:(AlertType)value;
-(void)setLinkLossAlert:(AlertType)value;

-(void)disconnect;
@end
