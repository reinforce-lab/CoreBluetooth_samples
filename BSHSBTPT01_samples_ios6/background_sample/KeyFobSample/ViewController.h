//
//  ViewController.h
//  KeyFobSample
//
//  Created by akihiro uehara on 2013/01/15.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyFobController.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ScanActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *ScanButton;

@property (weak, nonatomic) KeyFobController *keyfob;

- (IBAction)scanButtonTouchUpInside:(id)sender;

@end
