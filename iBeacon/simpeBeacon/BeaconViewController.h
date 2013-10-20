//
//  BeaconViewController.h
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/19.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;
@import CoreLocation;
#import "baseViewController.h"

@interface BeaconViewController : baseViewController<CBPeripheralManagerDelegate>
@end
