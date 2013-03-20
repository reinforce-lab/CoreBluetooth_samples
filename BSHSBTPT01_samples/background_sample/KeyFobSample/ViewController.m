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
        
    // 初期表示
    [self updateViewStatus];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // remove KVO
    [self.keyfob removeObserver:self forKeyPath:@"isBTPoweredOn"];
    [self.keyfob removeObserver:self forKeyPath:@"isScanning" ];
}

#pragma mark - Private methods
-(void)updateViewStatus {
    // スキャン/切断ボタンの表示を更新。未接続状態はScan、接続している状態(selected)のときは切断、を表示。
    self.ScanButton.enabled  = self.keyfob.isBTPoweredOn;
    self.ScanButton.selected = self.keyfob.isScanning;
    
    // スキャン状態を、インディケータに表示
    if(self.keyfob.isScanning) {
        self.ScanActivityIndicator.hidden = NO;
        [self.ScanActivityIndicator startAnimating];
    } else {
        self.ScanActivityIndicator.hidden = YES;
        [self.ScanActivityIndicator stopAnimating];
   }
    
}

#pragma mark - Event handlers
- (IBAction)scanButtonTouchUpInside:(id)sender {
    if(self.ScanButton.isSelected) {
        [self.keyfob stopScanning];
    } else {
        [self.keyfob startScanning];
    }
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
