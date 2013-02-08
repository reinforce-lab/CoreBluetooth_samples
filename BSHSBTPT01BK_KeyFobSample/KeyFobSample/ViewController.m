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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.keyfob = app.keyfob;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Do any additional setup after loading the view, typically from a nib.
    [self.keyfob addObserver:self forKeyPath:@"isBTPoweredOn"  options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [self.keyfob addObserver:self forKeyPath:@"isScanning"     options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
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
    // remove KVO
    [self.keyfob removeObserver:self forKeyPath:@"isBTPoweredOn"];
    [self.keyfob removeObserver:self forKeyPath:@"isScanning" ];
    [self.keyfob removeObserver:self forKeyPath:@"isConnected"];
    
    [self.keyfob removeObserver:self forKeyPath:@"linkLossAlertLevel"];
    [self.keyfob removeObserver:self forKeyPath:@"deviceRSSI"];
    [self.keyfob removeObserver:self forKeyPath:@"txPower"];
    [self.keyfob removeObserver:self forKeyPath:@"batteryLevel"];

    [self.keyfob removeObserver:self forKeyPath:@"isSwitchPushed"];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods
-(void)updateViewStatus {
    // 電波強度の表示更新
    self.RSSIProgressBar.progress   = self.keyfob.isConnected ? (self.keyfob.deviceRSSI + 100.0) / 100.0 : 0;
    self.RSSIValueTextLabel.text    = [NSString stringWithFormat:@"%d", self.keyfob.deviceRSSI];

    // バッテリレベルの表示更新
    self.BatteryProgressBar.progress= self.keyfob.isConnected ?  self.keyfob.batteryLevel / 100.0 : 0;
    self.BatteryValueTextLabel.text = [NSString stringWithFormat:@"%d", self.keyfob.batteryLevel];
    
    // スキャン/切断ボタンの表示を更新。未接続状態はScan、接続している状態(selected)のときは切断、を表示。
    self.ScanButton.enabled  = self.keyfob.isBTPoweredOn;
    self.ScanButton.selected = self.keyfob.isConnected;
    
    // スキャン状態を、インディケータに表示
    if(self.keyfob.isScanning) {
        self.ScanActivityIndicator.hidden = NO;
        [self.ScanActivityIndicator startAnimating];
    } else {
        self.ScanActivityIndicator.hidden = YES;
        [self.ScanActivityIndicator stopAnimating];
   }
    
    // セグメントボタンの有効/無効設定
    self.AleartModeSegmentedButtons.enabled = self.keyfob.isConnected;
    if(! self.keyfob.isConnected) self.AleartModeSegmentedButtons.selectedSegmentIndex = 0;
    
    self.LinkLossSegmentedButtons.enabled = self.keyfob.isConnected;
    self.LinkLossSegmentedButtons.selectedSegmentIndex = self.keyfob.linkLossAlertLevel;
    
    // スイッチ表示ボタン
    self.SwitchStatusTextLabel.text = self.keyfob.isSwitchPushed ? @"ON" : @"OFF";
}

#pragma mark - Event handlers
- (IBAction)scanButtonTouchUpInside:(id)sender {
    if(self.ScanButton.isSelected) {
        // 接続状態なので、切断する
        [self.keyfob disconnect];
    } else {
        // スキャンを開始する
        [self.keyfob startScanning];
    }
}

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
        [self updateViewStatus];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
