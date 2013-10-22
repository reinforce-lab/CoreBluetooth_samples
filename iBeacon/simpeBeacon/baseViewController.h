//
//  baseViewController.h
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/20.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBeaconUUID  @"88a45c17-70c5-5d2c-88b9-8173c39d6750"
#define kIdentifier  @"com.reinforce-lab"
#define kPassBookURL @"https://pass.is/1B7fvaX1VrrZMqn"

@interface baseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *uuidTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

- (IBAction)clearButtonTouchUpInside:(id)sender;

-(void)writeLog:(NSString *)log;
-(void)showAleart:(NSString *)message;
@end
