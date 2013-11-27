//
//  baseViewController.h
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/20.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface baseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

- (IBAction)clearButtonTouchUpInside:(id)sender;

-(void)writeLog:(NSString *)log;
-(void)clearLog;
-(void)showAleart:(NSString *)message;
@end
