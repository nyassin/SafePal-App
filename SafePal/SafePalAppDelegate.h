//
//  AppDelegate.h
//  SafePal
//
//  Created by Laurent Rivard on 11/2/13.
//  Copyright (c) 2013 Rivard.Laurent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SafePalAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate,MKReverseGeocoderDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
