//
//  CrimeBreakdownVC.h
//  SafePal
//
//  Created by Laurent Rivard on 11/2/13.
//  Copyright (c) 2013 Rivard.Laurent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CrimeBreakdownVC : UITableViewController
@property (strong, nonatomic) NSArray *crimeData;
@property CLLocation *userLocation;

-(IBAction)backBtn:(id)sender;
@end
