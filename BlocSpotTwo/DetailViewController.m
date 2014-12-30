//
//  DetailViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 27/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "DetailViewController.h"
#import "CategoryViewController.h"

#import <CoreData/CoreData.h>

@interface DetailViewController () <MKMapViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem* saveButton;

@property (nonatomic, strong) NSMutableDictionary *dictionaryForSegue;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) MKMapItem *currentLocation;
@property (nonatomic, strong) MKMapItem *destinationLocation;
@property (nonatomic, strong) MKRoute *currentRoute;
@property (nonatomic, strong) MKPolyline *routeOverlay;


@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getDirections];
    
    self.detailMapView.delegate = self;
    
    self.title = self.titleTextLabelString;
    self.titleTextLabel.text = self.titleTextLabelString;
   
    if (self.phoneTextLabel.length == 0) {
        self.phoneButton.enabled = NO;
    } else
    {
        self.phoneButton.enabled = YES;
        [self.phoneButton setBackgroundImage:[UIImage imageNamed:@"phonebutton"] forState:UIControlStateNormal];
    }
    
    if (self.uRLLabel.length == 0) {
        self.urlButton.enabled = NO;
    } else
    {
        self.urlButton.enabled = YES;
        [self.urlButton setBackgroundImage:[UIImage imageNamed:@"domainbutton"] forState:UIControlStateNormal];
    }
    
    
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(segueToSaveView:)];
    self.saveButton.enabled = YES;
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
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
    
    [self createDictionaryForSegue];
}

-(IBAction)callPhone:(id)sender
{
    NSString *phoneString = [NSString stringWithFormat:@"telprompt://%@", self.phoneTextLabel];
    
    if (self.phoneTextLabel.length == 0) {
        NSLog(@"No phone number");
    } else
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:phoneString]];
    }
}

-(IBAction)visitWebsite:(id)sender
{
    if (self.uRLLabel == 0) {
        NSLog(@"No website address");
    } else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.uRLLabel]];
    }
}

-(void)segueToSaveView:(id)sender
{
    [self performSegueWithIdentifier:@"showSaveView" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createDictionaryForSegue
{
    self.dictionaryForSegue = [[NSMutableDictionary alloc]initWithObjectsAndKeys:self.titleTextLabelString, @"Title", self.phoneTextLabel, @"Phone", self.uRLLabel, @"URLString", @(self.detailLatitude), @"Latitude", @(self.detailLongitude), @"Longitude", nil];
}

-(void)getDirections
{

    CLLocationCoordinate2D destinationCoordinates = CLLocationCoordinate2DMake(self.detailLatitude, self.detailLongitude);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc]initWithCoordinate:destinationCoordinates addressDictionary:nil];
    
    self.destinationLocation = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    self.currentLocation = [MKMapItem mapItemForCurrentLocation];
    
    //Direction request
    
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc]init];
    
    [directionsRequest setSource:self.currentLocation];
    [directionsRequest setDestination:self.destinationLocation];
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:directionsRequest];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"There was an error getting the directions");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Unable to determine directions" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        } else
        {
        
        self.currentRoute = [response.routes firstObject];
        
        [self plotRouteOnMap:self.currentRoute];
        }
    }];
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"Delegate working");
    }
}

-(void)plotRouteOnMap:(MKRoute *)route
{
    if (self.routeOverlay) {
        [self.detailMapView removeOverlay:self.routeOverlay];
    }
    
    self.routeOverlay = route.polyline;
    
    [self.detailMapView addOverlay:self.routeOverlay];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithPolyline:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    return renderer;
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocation *resultLocation = [[CLLocation alloc]initWithLatitude:self.detailLatitude longitude:self.detailLongitude];
    
    CLLocationDistance meters = [userLocation.location distanceFromLocation:resultLocation];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(((self.detailLatitude + userLocation.location.coordinate.latitude)/2), ((self.detailLongitude + userLocation.location.coordinate.longitude)/2));
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, meters, meters);
    
    [self.detailMapView setRegion:region animated:YES];
}


/*
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.descriptionText = textField.text;
    [self updateDictionaryReadyForSegue];
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showSaveView"])
    {
       CategoryViewController * destinationCategoryViewController = (CategoryViewController*)[segue destinationViewController];
        destinationCategoryViewController.receivedDictionaryFromDetailView = self.dictionaryForSegue;
        destinationCategoryViewController.managedObjectContext = self.managedObjectContext;
    }
 
}



@end
