//
//  ViewController.h
//  SafePal
//
//  Created by Laurent Rivard on 11/2/13.
//  Copyright (c) 2013 Rivard.Laurent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainVC : UIViewController <CLLocationManagerDelegate, MKReverseGeocoderDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) IBOutlet UILabel *breakdownLabel;
@property (strong, nonatomic) IBOutlet UILabel *mostCommonCrimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *zipcodeAvgCrimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentLocationCrimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentAddressLabel;

@property (strong, nonatomic) IBOutlet UIView *breakdownView;


-(IBAction)panicBtnPressed:(id)sender;
-(IBAction)breakdownBtnPressed:(id)sender;

@end
