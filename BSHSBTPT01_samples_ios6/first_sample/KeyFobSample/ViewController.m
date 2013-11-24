//
//  ViewController.m
//  KeyFobSample
//
//  Created by akihiro uehara on 2013/01/15.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import "ViewController.h"
#import "KeyFobController.h"
#import "AppDelegate.h"

@implementation ViewController
#pragma mark - ViewController life cycle
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.keyfob addObserver:self forKeyPath:@"peripheral" options:NSKeyValueObservingOptionNew context:(__bridge void *)(self)];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.keyfob addObserver:self forKeyPath:@"isBTPoweredOn"  options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [self.keyfob addObserver:self forKeyPath:@"isConnected"    options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    [self.keyfob addObserver:self forKeyPath:@"linkLossAlertLevel" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [self.keyfob addObserver:self forKeyPath:@"deviceRSSI" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [self.keyfob addObserver:self forKeyPath:@"txPower" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [self.keyfob addObserver:self forKeyPath:@"batteryLevel" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    [self.keyfob addObserver:self forKeyPath:@"isSwitchPushed" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    // 初期値
    self.keyfob.shouldNotifyPhoneCall = self.notifyByPhoneCallSwitch.on;
    
    // 初期表示
    [self updateViewStatus];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.keyfob removeObserver:self forKeyPath:@"peripheral"];
    
    [self.keyfob removeObserver:self forKeyPath:@"isBTPoweredOn"];
    [self.keyfob removeObserver:self forKeyPath:@"isConnected"];
    
    [self.keyfob removeObserver:self forKeyPath:@"linkLossAlertLevel"];
    [self.keyfob removeObserver:self forKeyPath:@"deviceRSSI"];
    [self.keyfob removeObserver:self forKeyPath:@"txPower"];
    [self.keyfob removeObserver:self forKeyPath:@"batteryLevel"];

    [self.keyfob removeObserver:self forKeyPath:@"isSwitchPushed"];
    
    [self.keyfob disconnect];
}

#pragma mark - Private methods
-(void)updateViewStatus {
    // 電波強度の表示更新
    self.RSSIProgressBar.progress   = self.keyfob.isConnected ? (self.keyfob.deviceRSSI + 100.0) / 100.0 : 0;
    self.RSSIValueTextLabel.text    = [NSString stringWithFormat:@"%d", self.keyfob.deviceRSSI];

    // バッテリレベルの表示更新
    self.BatteryProgressBar.progress= self.keyfob.isConnected ?  self.keyfob.batteryLevel / 100.0 : 0;
    self.BatteryValueTextLabel.text = [NSString stringWithFormat:@"%d", self.keyfob.batteryLevel];
    
    // セグメントボタンの有効/無効設定
    self.AleartModeSegmentedButtons.enabled = self.keyfob.isConnected;
    if(! self.keyfob.isConnected) self.AleartModeSegmentedButtons.selectedSegmentIndex = 0;
    
    self.LinkLossSegmentedButtons.enabled = self.keyfob.isConnected;
    self.LinkLossSegmentedButtons.selectedSegmentIndex = self.keyfob.linkLossAlertLevel;
    
    // スイッチ表示ボタン
    self.SwitchStatusTextLabel.text = self.keyfob.isSwitchPushed ? @"ON" : @"OFF";
}

#pragma mark - Event handlers
- (IBAction)linkLossLevelValueChanged:(id)sender {
    UISegmentedControl *seg = sender;
    [self.keyfob setLinkLossAlert:seg.selectedSegmentIndex];
}

- (IBAction)immediateAlertValueChanged:(id)sender {
    UISegmentedControl *seg = sender;
    [self.keyfob alert:seg.selectedSegmentIndex];
}

- (IBAction)notifyPhoneCallSwitchValueChanged:(id)sender {
    self.keyfob.shouldNotifyPhoneCall = self.notifyByPhoneCallSwitch.on;
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)self) {
        if([keyPath isEqualToString:@"peripheral"] && self.keyfob.peripheral == nil) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self updateViewStatus];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
