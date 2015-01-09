//
//  DistanceCalculator.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 2/01/2015.
//  Copyright (c) 2015 Bloc.io. All rights reserved.
//

#import "DistanceCalculator.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DistanceCalculator ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) double currentLatitude;
@property (nonatomic, assign) double currentLongitude;

@end

@implementation DistanceCalculator

-(instancetype)init
{
    if (self = [super init]) {
        CLLocationManager *locationManager = [[CLLocationManager alloc]init];
        self.currentLatitude = locationManager.location.coordinate.latitude;
        self.currentLongitude = locationManager.location.coordinate.longitude;
    }
    return self;
}

-(NSString *)determineDistanceFromCurrentLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *distance = [[NSString alloc]init];
    
    //MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.currentLatitude longitude:self.currentLongitude];
    
    CLLocation *savedLocationCoordinate = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    CLLocationDistance meters = [currentLocation distanceFromLocation:savedLocationCoordinate];
    
    MKDistanceFormatter *distanceFormatter = [[MKDistanceFormatter alloc]init];
    
    distance = [distanceFormatter stringFromDistance:meters];
    
    return distance;
}

-(CLLocation *)determineClosestLocationFromArrayOfLocations:(NSArray *)arrayOfLocations
{
  
    NSMutableArray *locationsByDistance = [[NSMutableArray alloc]init];
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.currentLatitude longitude:self.currentLongitude];
    
    for (CLLocation *location in arrayOfLocations) {
        
        CLLocationDistance meters = [currentLocation distanceFromLocation:location];
        
        NSNumber *distance = [NSNumber numberWithDouble:meters];
        
        NSDictionary *locationAndAssociatedCurrentDistance = [[NSDictionary alloc]initWithObjectsAndKeys:distance, @"distance", location, @"location", nil];
        
        [locationsByDistance addObject:locationAndAssociatedCurrentDistance];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray = [locationsByDistance sortedArrayUsingDescriptors:sortDescriptors];
    
    locationsByDistance = [NSMutableArray arrayWithArray:sortedArray];
    
    NSDictionary *closestLocationDictionary = [locationsByDistance objectAtIndex:0];
    
    CLLocation *closestLocation = [closestLocationDictionary valueForKey:@"location"];
    
    return closestLocation;
}



@end