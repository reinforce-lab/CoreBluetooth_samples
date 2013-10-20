//
//  baseViewController.m
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/20.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "baseViewController.h"

@interface baseViewController () {
    NSMutableString   *_logText;
}

@end

@implementation baseViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    _logText = [[NSMutableString alloc] init];
    _logTextView.text = @"";
    
    _uuidTextLabel.text = kBeaconUUID;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Public methods
-(void)writeLog:(NSString *)log {
    NSLog(@"%@", log);
    [_logText appendFormat:@"%@\n", log];
    self.logTextView.text = _logText;
}
-(void)showAleart:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
#pragma mark Event handlers
- (IBAction)clearButtonTouchUpInside:(id)sender {
    _logText = [[NSMutableString alloc] init];
    _logTextView.text = @"";
}
@end

