//
//  CrimeBreakdownVC.m
//  SafePal
//
//  Created by Laurent Rivard on 11/2/13.
//  Copyright (c) 2013 Rivard.Laurent. All rights reserved.
//

#import "CrimeBreakdownVC.h"

#define METERS_PER_MILE 1609.344

@interface CrimeBreakdownVC ()

@end

@implementation CrimeBreakdownVC

@synthesize crimeData=_crimeData;
@synthesize userLocation=_userLocation;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"crime data :%@", _crimeData);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_crimeData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"crimeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    UIImageView *img = (UIImageView *) [cell viewWithTag:200];

    //type of crime
    UILabel *type = (UILabel *) [cell viewWithTag:201];
    type.text = [[_crimeData objectAtIndex:indexPath.row] objectForKey:@"type"];
    
    //date to format using yesterday, today...
    UILabel *date = (UILabel *) [cell viewWithTag:202];
    date.text = [[_crimeData objectAtIndex:indexPath.row] objectForKey:@"date"];
    
    CLLocationDegrees lat = [[[_crimeData objectAtIndex:indexPath.row] objectForKey:@"lat"] doubleValue];
    CLLocationDegrees lng = [[[_crimeData objectAtIndex:indexPath.row] objectForKey:@"lon"] doubleValue];
    //distance between user and crime
    CLLocation *crimeLoc = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    UILabel *dist = (UILabel *) [cell viewWithTag:203];
    dist.text = [self distanceBetween:crimeLoc];
    
    return cell;
}
-(NSString *) distanceBetween:(CLLocation *) crimeLocation {
    
    CLLocationDistance dist = [crimeLocation distanceFromLocation:_userLocation];
    double miles = dist / METERS_PER_MILE ;
    NSString* formattedNumber = [NSString stringWithFormat:@"%.01f", miles];
    NSString *distStr = [NSString stringWithFormat:@"%@ miles", formattedNumber];
    NSLog(@"distance : %@", distStr);
    return distStr;
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
-(IBAction)backBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
