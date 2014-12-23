//
//  DataSource.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 25/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SearchViewController.h"

@protocol DataSourceDelegate <NSObject>

@optional

-(void)finishedSearch:(NSArray *)resultsOfSearch;

@end

@interface DataSource : NSObject

-(instancetype) initWithSearchString:(NSString*)searchString Region:(MKCoordinateRegion)region Delegate:(id<DataSourceDelegate>)delegate;

@property (nonatomic, strong) NSString *searchingString;
@property (nonatomic) MKCoordinateRegion searchingRegion;
@property (nonatomic, weak) id<DataSourceDelegate> delegate;

//Last search properties
@property (nonatomic, strong, readonly) NSArray *lastSearchResults;
@property (nonatomic, strong, readonly) NSArray *lastSearchAnnotations;

//Search history properties
@property (nonatomic, strong, readonly) NSArray *searchHistory;

//Saved spots
@property (nonatomic, strong, readonly) NSArray *savedSpots;


-(void) performSearchForText;

@end

