//
//  NCViewController.h
//  ANCS
//
//  Created by uehara akihiro on 2013/10/27.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;
#import "baseViewController.h"

@interface NCViewController : baseViewController<CBCentralManagerDelegate, CBPeripheralDelegate>
@end
