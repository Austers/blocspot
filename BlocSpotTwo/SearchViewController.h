//
//  SearchViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 24/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DataSource.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *searchString;
@property (nonatomic) MKCoordinateRegion currentRegion;
@property (nonatomic, strong) NSArray *cellTester;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
