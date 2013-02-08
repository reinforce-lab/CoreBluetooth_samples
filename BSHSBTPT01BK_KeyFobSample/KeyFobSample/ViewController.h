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

@property (weak, nonatomic) IBOutlet UILabel *RSSITextLabel;
@property (weak, nonatomic) IBOutlet UILabel *SwitchTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *SwitchStatusTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *BatteryTextLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *RSSIProgressBar;
@property (weak, nonatomic) IBOutlet UIProgressView *BatteryProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *RSSIValueTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *BatteryValueTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *BatteryPercentTextLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ScanActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *ScanButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *AleartModeSegmentedButtons;
@property (weak, nonatomic) IBOutlet UISegmentedControl *LinkLossSegmentedButtons;
@property (weak, nonatomic) IBOutlet UISwitch *notifyByPhoneCallSwitch;

@property (weak, nonatomic) KeyFobController *keyfob;

- (IBAction)scanButtonTouchUpInside:(id)sender;
- (IBAction)linkLossLevelValueChanged:(id)sender;
- (IBAction)immediateAlertValueChanged:(id)sender;
- (IBAction)notifyPhoneCallSwitchValueChanged:(id)sender;

@end
