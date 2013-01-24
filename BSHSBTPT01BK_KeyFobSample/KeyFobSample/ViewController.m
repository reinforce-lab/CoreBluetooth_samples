//
//  ViewController.m
//  KeyFobSample
//
//  Created by akihiro uehara on 2013/01/15.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import "ViewController.h"
#import "KeyFobController.h"

@interface ViewController () {
    KeyFobController *_keyfob;
}
@end

@implementation ViewController
#pragma mark - ViewController life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _keyfob = [[KeyFobController alloc] init];
    [_keyfob addObserver:self forKeyPath:@"isBTPoweredOn"  options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [_keyfob addObserver:self forKeyPath:@"isScanning"     options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [_keyfob addObserver:self forKeyPath:@"isConnected"    options:NSKeyValueObservingOptionNew context:(__bridge void *)self];

    [_keyfob addObserver:self forKeyPath:@"linkLossAlertLevel" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [_keyfob addObserver:self forKeyPath:@"deviceRSSI" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [_keyfob addObserver:self forKeyPath:@"txPower" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    [_keyfob addObserver:self forKeyPath:@"batteryLevel" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    [_keyfob addObserver:self forKeyPath:@"isSwitchPushed" options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 初期表示
    [self updateViewStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods
-(void)updateViewStatus {
    // 電波強度の表示更新
    self.RSSIProgressBar.progress   = _keyfob.isConnected ? (_keyfob.deviceRSSI + 100.0) / 100.0 : 0;
    self.RSSIValueTextLabel.text    = [NSString stringWithFormat:@"%d", _keyfob.deviceRSSI];

    // バッテリレベルの表示更新
    self.BatteryProgressBar.progress= _keyfob.isConnected ?  _keyfob.batteryLevel / 100.0 : 0;
    self.BatteryValueTextLabel.text = [NSString stringWithFormat:@"%d", _keyfob.batteryLevel];
    
    // スキャン/切断ボタンの表示を更新。未接続状態はScan、接続している状態(selected)のときは切断、を表示。
    self.ScanButton.enabled  = _keyfob.isBTPoweredOn;
    self.ScanButton.selected = _keyfob.isConnected;
    
    // スキャン状態を、インディケータに表示
    if(_keyfob.isScanning) {
        [self.ScanActivityIndicator startAnimating];
    } else {
        [self.ScanActivityIndicator stopAnimating];
    }
    
    // セグメントボタンの有効/無効設定
    self.AleartModeSegmentedButtons.enabled = _keyfob.isConnected;
    if(! _keyfob.isConnected) self.AleartModeSegmentedButtons.selectedSegmentIndex = 0;
    
    self.LinkLossSegmentedButtons.enabled = _keyfob.isConnected;
    self.LinkLossSegmentedButtons.selectedSegmentIndex = _keyfob.linkLossAlertLevel;
    
    // スイッチ表示ボタン
    self.SwitchStatusTextLabel.text = _keyfob.isSwitchPushed ? @"ON" : @"OFF";


}

#pragma mark - Event handlers
- (IBAction)scanButtonTouchUpInside:(id)sender {
    if(self.ScanButton.isSelected) {
        // 接続状態なので、切断する
        [_keyfob disconnect];
    } else {
        // スキャンを開始する
        [_keyfob startScanning];
    }
}

- (IBAction)linkLossLevelValueChanged:(id)sender {
    UISegmentedControl *seg = sender;
    [_keyfob setLinkLossAlert:seg.selectedSegmentIndex];
}

- (IBAction)immediateAlertValueChanged:(id)sender {
    UISegmentedControl *seg = sender;
    [_keyfob alert:seg.selectedSegmentIndex];
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
