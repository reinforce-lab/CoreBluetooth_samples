//
//  PassbookViewController.m
//  simpleBeacon
//
//  Created by uehara akihiro on 2013/10/21.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "PassbookViewController.h"

@interface PassbookViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PassbookViewController

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
}

-(void)viewDidAppear:(BOOL)animated {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://pass.is/1B7fvaX1VrrZMqn"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
