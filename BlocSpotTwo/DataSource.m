//
//  DataSource.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 25/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "DataSource.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import "MapViewController.h"

@interface DataSource ()

@property (nonatomic, strong) NSMutableArray *lastSearchResults;
@property (nonatomic, strong) NSMutableArray *lastResultAnnotations;
@property (nonatomic, strong) NSMutableArray *searchHistory;


@end

@implementation DataSource

-(instancetype) initWithSearchString:(NSString*)searchString Region:(MKCoordinateRegion)region Delegate:(id<DataSourceDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.searchingString = searchString;
        self.searchingRegion = region;
        self.delegate = delegate;
    }
 
    return self;
}

-(void) performSearchForText
{
    
    NSMutableArray *searchItems = [[NSMutableArray alloc]init];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = self.searchingString;
    request.region = self.searchingRegion;
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count == 0) {
            NSLog(@"No Matches");
            NSLog(@"%@", self.searchingString);
        } else
        {
            for (MKMapItem *mapItem in response.mapItems) {
                
                NSString *name = mapItem.name;
                NSString *phone = [[NSString alloc]init];
                NSURL *url = [[NSURL alloc]init];
                NSString *urlString = [[NSString alloc]init];
                
                if (mapItem.phoneNumber == nil) {
                    phone = @"";
                } else
                {
                    phone = mapItem.phoneNumber;
                }
                
                if (mapItem.url == nil) {
                    url = [NSURL URLWithString:@""];
                } else
                {
                    url = mapItem.url;
                }
                
                if (mapItem.url == nil) {
                    urlString = @"";
                } else
                {
                    urlString = [mapItem.url absoluteString];
                }
                
                //Determines distace from current location for each mapitem
                
                CLLocationCoordinate2D coordinate = mapItem.placemark.location.coordinate;
                CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
                CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.searchingRegion.center.latitude longitude:self.searchingRegion.center.longitude];
                CLLocationDistance itemDistanceFromCurrent = [location distanceFromLocation:currentLocation];
                
                //Creates a formatted dictionary for each set of mapitem data, to be passed to the relevant VC
                
                NSDictionary *mapItemStore = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"name", phone, @"phone", url, @"url", urlString, @"urlString", @(coordinate.latitude), @"lat", @(coordinate.longitude), @"long", @(itemDistanceFromCurrent), @"distance", nil];
                
                //Creates an array of the generated dictionaries
                
                [searchItems addObject:mapItemStore];
                
                self.lastSearchResults = searchItems;
              
            }
        }
        
        //Calls the delegate method on the delegate VC which passes across the array containing the dictionaries of formatted mapitem data
        
        [self.delegate finishedSearch:self.lastSearchResults];

    }];
    
}

@end
