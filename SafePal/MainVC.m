//
//  ViewController.m
//  SafePal
//
//  Created by Laurent Rivard on 11/2/13.
//  Copyright (c) 2013 Rivard.Laurent. All rights reserved.
//

#import "mainVC.h"
#import "AFNetworking.h"
//#import "AFHTTPRequestOperationManager.h"
#import <CoreLocation/CoreLocation.h>


#define METERS_PER_MILE 1609.344

@interface MainVC ()
@property BOOL isNightTime, _isOnWifi;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSArray *crimeCategories;
@property CLLocationCoordinate2D userLoc;
@property (strong, nonatomic) NSDictionary *crimeDic;
@end

@implementation MainVC
@synthesize mapView=_mapView;
@synthesize locationManager=_locationManager;
@synthesize location=_location;
@synthesize isNightTime=_isNightTime, _isOnWifi=_isOnWifi;
@synthesize  timer=_timer;
@synthesize zipCode=_zipCode;
@synthesize crimeCategories=_crimeCategories;
@synthesize userLoc=_userLoc;
@synthesize crimeDic=_crimeDic;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// setting night time to false to start out
    _isNightTime = NO;
    _isOnWifi = NO;

    _crimeCategories = [[NSArray alloc] initWithObjects:@"Arrest", @"Arson", @"Assault", @"Burglary", @"Robbery", @"Shooting", @"Theft", @"Vandalism", @"Other", nil];
    

    
//    [_mapView setShowsUserLocation:YES];
    

    
    //initialize location manager
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    [_locationManager startUpdatingLocation];
    
    //tells the app to keep things running in background ??
    UIBackgroundTaskIdentifier bgTask =0;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
    
    
}
-(void) fireTimer: (NSTimer *) timer {

//    int hour = [self getHour];
    
    //check if it's nighttime --> run in background
//    if(hour >=20 || hour <= 4) {
        [_locationManager startUpdatingLocation];
        NSLog(@"updated location");
//    }
//
    
    
    //check what time it is
    //get location
    //query crimes
    //show marker on map if app is in foreground
    //
}
-(int) getHour {
    //need to check if it's night time (8PM-4AM)
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //24 hour clock
    NSLocale* formatterLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [formatter setLocale:formatterLocale];
    [formatter setDateFormat:@"HH"];
    NSString *hourStr = [formatter stringFromDate:now];
    NSLog(@"%@", hourStr);
    
    int hour = [hourStr intValue];
    
    return hour;
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    NSLog(@"location: %@", newLocation);
    
    CLLocationCoordinate2D mapLocation;
    mapLocation.latitude = newLocation.coordinate.latitude;
    mapLocation.longitude = newLocation.coordinate.longitude;
    
    _userLoc.latitude = newLocation.coordinate.latitude;
    _userLoc.longitude = newLocation.coordinate.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);

    MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:mapLocation];
	[geocoder setDelegate:self];
	[geocoder start];

    [_mapView setRegion:viewRegion animated:YES];
    
    //stop location manager
    [_locationManager stopUpdatingLocation];
    
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [err show];
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSLog(@"The geocoder has returned: %@", [placemark addressDictionary]);
    _zipCode = [[placemark addressDictionary] objectForKey:@"ZIP"];
    NSLog(@"zip: %@", _zipCode);
    
    [self getCrimeDataWithLatitude:_userLoc.latitude andLongitude:_userLoc.longitude andZipCode:22 andCity:@"lkajsdflkjasdf"];

}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ERROR UPDATING LOCATION: %@", [error localizedDescription]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getCrimeDataWithLatitude:(double) latitude andLongitude:(double) longitude andZipCode:(int) zipCode andCity:(NSString *) city {
    NSURL *url = [NSURL URLWithString:@"http://safepal.herokuapp.com/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSNumber *lat = [NSNumber numberWithDouble:latitude];
    NSNumber *lng = [NSNumber numberWithDouble:longitude];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            lat , @"lat",
                            lng, @"lon",
                            nil];
    [httpClient getPath:@"/api" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _crimeDic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//        NSLog(@"crime dic :%@:", _crimeDic);
        
        //if app is backgrounded just send notification
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            [self sendLocalNotification];
        }
        else if(state == UIApplicationStateActive) {
            [self showAnnotationsAndData];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}
-(void) showAnnotationsAndData {
    NSDictionary *crimes = [_crimeDic objectForKey:@"data"];
    
    for(NSDictionary *dic in crimes) {        
        MKPlacemark *mPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[dic objectForKey:@"lat"] doubleValue], [[dic objectForKey:@"lon"] doubleValue]) addressDictionary:nil];

        [_mapView addAnnotation:mPlacemark];
    }
}
//#pragma mark tableview delegate
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 5;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"CrimeDetailCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    // Configure the cell...
//    cell.textLabel.text = @"Hello there!";
//    
//    return cell;
//}
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Row pressed!!");
//}
-(void) sendLocalNotification {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.alertBody = @"DANGER";
    //    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"notification is scheduled");

}
@end
