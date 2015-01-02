//
//  CustomAnnotation.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 27/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

-(id)initWithTitle:(NSString *)newTitle Subtitle:(NSString *)subTitle Location:(CLLocationCoordinate2D)location
{
    self = [super init];
    
    if (self) {
        _title = newTitle;
        _subtitle = subTitle;
        _coordinate = location;
    }
    
    return self;
}

-(MKAnnotationView *) annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"MyCustomAnnotation"];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    //Have category image
    annotationView.image = [UIImage imageNamed:@"blackpin"];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

/*
 MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
 annotation.coordinate = mapItem.placemark.coordinate;
 annotation.title = mapItem.name;
 annotation.subtitle = mapItem.placemark.addressDictionary[(NSString *)kABPersonAddressStreetKey];
 //annotation.phone = mapItem.phoneNumber;
 [annotationItems addObject:annotation];
 */

@end
