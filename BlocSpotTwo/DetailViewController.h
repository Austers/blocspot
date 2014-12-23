//
//  DetailViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 27/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) NSString *titleTextLabelString;

@property (strong, nonatomic) IBOutlet UIButton *urlButton;
@property (strong, nonatomic) NSString *uRLLabel;

@property (nonatomic, strong) IBOutlet UIButton *phoneButton;
@property (strong, nonatomic) NSString *phoneTextLabel;

@property (strong, nonatomic) IBOutlet MKMapView *detailMapView;
@property (nonatomic) double detailLongitude;
@property (nonatomic) double detailLatitude;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
