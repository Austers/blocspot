//
//  DistanceCalculator.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 2/01/2015.
//  Copyright (c) 2015 Bloc.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DistanceCalculator : NSObject

-(NSString *)determineDistanceFromCurrentLocation:(CLLocationCoordinate2D)coordinate;

-(CLLocation *)determineClosestLocationFromArrayOfLocations:(NSArray *)arrayOfLocations;

@end
