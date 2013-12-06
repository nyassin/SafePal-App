//
//  AppDelegate.m
//  SafePal
//
//  Created by Laurent Rivard on 11/2/13.
//  Copyright (c) 2013 Rivard.Laurent. All rights reserved.
//

#import "SafePalAppDelegate.h"
#import "AFNetworking.h"

@interface SafePalAppDelegate ()
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *reverseGeo;
@property CLLocationCoordinate2D userLoc;
@property (strong, nonatomic) NSString *zipCode;

@end
@implementation SafePalAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    NSLog(@"Recieved Notification %@",notif);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"did enter background called");
    [self.locationManager stopUpdatingLocation];
    
    UIApplication* app = [UIApplication sharedApplication];
    
    _bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
        NSLog(@"did enter background invalidated");
    }];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:180
                                                  target:_locationManager
                                                selector:@selector(getLocation)
                                                userInfo:nil
                                                 repeats:YES];
}
-(void) getLocation {
    NSLog(@"timer fired");
    [_locationManager startUpdatingLocation];
}
-(void) sendAlert {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.alertBody = @"Notif from app delegate.";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"hello");
}
-(void) getCrimeDataWithLatitude:(double) latitude andLongitude:(double) longitude andZipCode:(NSString *) zipCode andCity:(NSString *) city {
    NSURL *url = [NSURL URLWithString:@"http://safepal.herokuapp.com/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSNumber *lat = [NSNumber numberWithDouble:latitude];
    NSNumber *lng = [NSNumber numberWithDouble:longitude];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            lat , @"lat",
                            lng, @"lon",
                            nil];
    
    [httpClient getPath:@"/api" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *crimeDic = [[NSDictionary alloc] init];
        crimeDic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"crime dic: %@", crimeDic);
        BOOL dangerous = [[[crimeDic objectForKey:@"metadata"] objectForKey:@"sendAlert"] boolValue];
        
        if(dangerous)
            [self sendAlert];
        else
            NSLog(@"LOC: %@", params);


        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    NSLog(@"location updated in background");
    CLLocationCoordinate2D mapLocation;
    mapLocation.latitude = newLocation.coordinate.latitude;
    mapLocation.longitude = newLocation.coordinate.longitude;
    
    _userLoc.latitude = newLocation.coordinate.latitude;
    _userLoc.longitude = newLocation.coordinate.longitude;
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapLocation,METERS_PER_MILE,METERS_PER_MILE);
    
    MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:mapLocation];
	[geocoder setDelegate:self];
	[geocoder start];
    
    NSLog(@"new location from app delegate");
    
    //stop location updates
    [_locationManager stopUpdatingLocation];

    
}
- (void)updateCurrentLocationLabel {
    NSLog(@"updateCurrentLocationLabel called");
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:_userLoc.latitude longitude:_userLoc.longitude];
    
    if (!self.reverseGeo) {
        self.reverseGeo = [[CLGeocoder alloc] init];
    }
    
    [self.reverseGeo reverseGeocodeLocation:curLocation completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks firstObject];
        // self.locationString = [NSString stringWithFormat:@"%@, %@", [placemark name],[placemark locality]];
         
         //find zipcode and send it to API and get response back
         _zipCode = [[placemark addressDictionary] objectForKey:@"ZIP"];
         [self getCrimeDataWithLatitude:_userLoc.latitude andLongitude:_userLoc.longitude andZipCode:_zipCode andCity:@"doesntmatternow"];
     }];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    //  UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    //[err show];
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ERROR UPDATING LOCATION: %@", [error localizedDescription]);
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
