
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
#import "SavedDetailViewController.h"
#import "DistanceCalculator.h"

@interface MapViewController () <CLLocationManagerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSURL *urlForObjectID;

@property (nonatomic, strong) CLLocation *closestLocation;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSMutableArray *locationsArray;

@end

@implementation MapViewController

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Map";
    
    self.mapView.delegate = self;
    
    self.locationsArray = [[NSMutableArray alloc]init];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
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



-(void) fetchDataAndCreateAnnotations
{
    NSMutableArray *annotations = [[NSMutableArray alloc]init];
    
    for (NSManagedObject *object in [[self fetchedResultsController]fetchedObjects])
    {
        NSNumber *longNMN = (NSNumber *)[object valueForKey:@"longitude"];
        double longitude = [longNMN doubleValue];
        NSNumber *latNSN = (NSNumber *)[object valueForKey:@"latitude"];
        double latitude = [latNSN doubleValue];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        NSString *title = (NSString *)[object valueForKey:@"name"];
        
        NSManagedObjectID *recordID = [object objectID];
        
        NSURL *url = [recordID URIRepresentation];
        
        CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithTitle:title Subtitle:nil Location:coordinate];
        annotation.urlForObjectID = url;
        
        [annotations addObject:annotation];
    }
    
    [self.mapView addAnnotations:annotations];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[CustomAnnotation class]])
    {
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CustomAnnotation* customView = (CustomAnnotation*)(view);
    self.urlForObjectID = customView.urlForObjectID;
    NSLog(@"Hit");
    [self performSegueWithIdentifier:@"savedDetailView" sender:self];
}

//- (void)mapView:(MKMapView *)mapView annotationView:(CustomAnnotation *)view calloutAccessoryControlTapped:(UIControl *)control {
//    // Go to edit view
//    self.urlForObjectID = view.urlForObjectID;
//    NSLog(@"Hit");
//    [self performSegueWithIdentifier:@"savedDetailView" sender:self];
//    
//}



-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    for (NSManagedObject *object in [[self fetchedResultsController]fetchedObjects])
    {
        NSNumber *longNMN = (NSNumber *)[object valueForKey:@"longitude"];
        double longitude = [longNMN doubleValue];
        NSNumber *latNSN = (NSNumber *)[object valueForKey:@"latitude"];
        double latitude = [latNSN doubleValue];
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
        [self.locationsArray addObject:location];
    }
    
    DistanceCalculator *calculator = [[DistanceCalculator alloc]init];
    
     self.closestLocation = [calculator determineClosestLocationFromArrayOfLocations:self.locationsArray];

    self.latitude = self.closestLocation.coordinate.latitude;
    self.longitude = self.closestLocation.coordinate.longitude;
    
    CLLocationDistance meters = [userLocation.location distanceFromLocation:self.closestLocation];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(((self.latitude + userLocation.location.coordinate.latitude)/2), ((self.longitude + userLocation.location.coordinate.longitude)/2));
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, meters, meters);
    
    [self.mapView setRegion:region animated:YES];
    [self fetchDataAndCreateAnnotations];

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
    } else if ([segue.identifier isEqualToString:@"savedDetailView"])
    {
        SavedDetailViewController *savedDetailVC = (SavedDetailViewController *)[segue destinationViewController];
        savedDetailVC.managedObjectContext = self.managedObjectContext;
        savedDetailVC.urlForObjectID = self.urlForObjectID;
    }
}


@end
