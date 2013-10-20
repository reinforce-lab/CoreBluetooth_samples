//
//  baseViewController.h
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/20.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBeaconUUID @"D8C48660-3422-476D-A44A-D92DF37D29A0"
#define kIdentifier @"com.reinforce-lab"

@interface baseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *uuidTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

- (IBAction)clearButtonTouchUpInside:(id)sender;

-(void)writeLog:(NSString *)log;
-(void)showAleart:(NSString *)message;
@end
