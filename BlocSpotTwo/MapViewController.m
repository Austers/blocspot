
//
//  MapViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 24/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "MapViewController.h"
#import "SearchViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CustomAnnotation.h"
#import <CoreData/CoreData.h>
#import "ListTabBarViewController.h"

@interface MapViewController () <CLLocationManagerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MapViewController

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // load an instance of your xib into a uiview
        
        // then add that ui view into self, i.e [self addSubview:some_view_name]
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Map";
    
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    NSLog(@" Managed Object Context is: %@", self.managedObjectContext);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"PointOfInterest"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSaved" ascending:YES]]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
     }
}

-(void) addAnnotationsTest
{
    CLLocationCoordinate2D testCoord = CLLocationCoordinate2DMake(40.704605000000001, -73.920426000000006);
    CustomAnnotation *test = [[CustomAnnotation alloc]initWithTitle:@"Tester Title" Subtitle:@"Tester Subtitle" Location:testCoord];
    
    [self.mapView addAnnotation:test];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
        
        {
            if([annotation isKindOfClass:[CustomAnnotation class]]) {
             
            CustomAnnotation *myLocation = (CustomAnnotation *)annotation;
            
            MKAnnotationView * annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"MyCustomAnnotation"];
            
            if (annotationView == nil)
            {
                annotationView = myLocation.annotationView;
            }
            else
            {
                annotationView.annotation = annotation;
            }
          //  annotationView.tag = annotationTag;
            return annotationView;
            }
            else
            {
                return nil;
            }
}

//Show annotation automatically


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D coord = self.mapView.userLocation.location.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 1000.0, 1000.0);
    
    [self.mapView setRegion:region animated:YES];
    
    [self addAnnotationsTest];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([segue.identifier isEqualToString:@"segueShowSearch"])
    {
        SearchViewController* destinationSearchViewController = (SearchViewController*)[segue destinationViewController];
        destinationSearchViewController.currentRegion = self.mapView.region;
        destinationSearchViewController.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"showListView"])
    {
        ListTabBarViewController *tabVC = (ListTabBarViewController *)[segue destinationViewController];
        tabVC.managedObjectContext = self.managedObjectContext;
    }
}


@end
