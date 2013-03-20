//
//  DeviceListViewController.m
//  KeyFobSample
//
//  Created by Akihiro Uehara on 2013/03/21.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import "DeviceListViewController.h"
#import "KeyFobController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface DeviceListViewController () {
    KeyFobController *_ctr;
}
@end

@implementation DeviceListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _ctr = app.keyfob;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // This will be called when returning from details screen;
    // update the table in case favorite status has changed.
//    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_ctr addObserver:self forKeyPath:@"containers" options:NSKeyValueObservingOptionNew context:(__bridge void *)(self)];
    //NSLog(@"%s %@", __func__, _ctr);
    //NSLog(@"Start scanning...");
    [_ctr startScanning];
}

-(void)viewWillDisappear:(BOOL)animated  {
    [super viewWillDisappear:animated];
    [_ctr removeObserver:self forKeyPath:@"containers"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_ctr.containers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PeripheralContainer *c = [_ctr.containers objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (RSSI:%@)", c.peripheral.name, c.RSSI];
    cell.detailTextLabel.text = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, c.peripheral.UUID);
//    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
#pragma mark - Storyboard segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id controller = segue.destinationViewController;
    if ([controller isKindOfClass:[ViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PeripheralContainer *c = [_ctr.containers objectAtIndex:indexPath.row];

        [_ctr connect:c];
        [_ctr stopScanning];
        
        ViewController *viewCtr = (ViewController *)controller;
        viewCtr.keyfob = _ctr;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)(self)) {
        [self.tableView reloadData];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
