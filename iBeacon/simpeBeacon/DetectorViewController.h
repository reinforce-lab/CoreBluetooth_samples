//
//  DetectorViewController.h
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/20.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
#import "baseViewController.h"

@interface DetectorViewController : baseViewController<CLLocationManagerDelegate>

@end
