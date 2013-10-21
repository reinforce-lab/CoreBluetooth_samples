//
//  CentralViewController.h
//  simpleBeacon
//
//  Created by uehara akihiro on 2013/10/21.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;
#import "baseViewController.h"

@interface CentralViewController : baseViewController<CBCentralManagerDelegate>
@end
