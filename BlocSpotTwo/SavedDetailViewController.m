//
//  SavedDetailViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 16/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "SavedDetailViewController.h"

#import <CoreData/CoreData.h>

#import "ListTabBarViewController.h"
#import "EditPOIViewController.h"

@interface SavedDetailViewController () <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *listButton;

//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *categoryUppercase;
@property (nonatomic, strong) UIColor *categoryBackgroundColour;

@property (nonatomic, strong) MKMapItem *currentLocation;
@property (nonatomic, strong) MKMapItem *destinationLocation;
@property (nonatomic, strong) MKRoute *currentRoute;
@property (nonatomic, strong) MKPolyline *routeOverlay;
@property (nonatomic, getter=isON) BOOL on;

@end

@implementation SavedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    self.listButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"listbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(listButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = self.listButton;
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    [self fetchPOI];
    
    self.Title.text = self.name;
    
    if (self.phone.length == 0) {
        self.phoneButton.enabled = NO;
    } else
    {
        self.phoneButton.enabled = YES;
        [self.phoneButton setBackgroundImage:[UIImage imageNamed:@"phonebutton"] forState:UIControlStateNormal];
    }

    if (self.url.length == 0) {
        self.urlButton.enabled = NO;
    } else
    {
        self.urlButton.enabled = YES;
        [self.urlButton setBackgroundImage:[UIImage imageNamed:@"domainbutton"] forState:UIControlStateNormal];
    }
    
    self.categoryLabel.text = self.category;
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.descriptionTextLabel.text = self.descriptionText;
    self.categoryBackground.backgroundColor = self.categoryBackgroundColour;
    
}

-(IBAction)callPhone:(id)sender
{
    NSString *phoneString = [NSString stringWithFormat:@"telprompt://%@", self.phone];
    
    if (self.phone.length == 0) {
        NSLog(@"No phone number");
    } else
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:phoneString]];
    }
}

-(IBAction)visitWebsite:(id)sender
{
    if (self.url == 0) {
        NSLog(@"No website address");
    } else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    }
}

-(void)editButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"showEditView" sender:self];
}

-(void)listButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"showTabVC" sender:self];
}


-(void)fetchPOI
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PointOfInterest" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSaved" ascending:YES]]];
    
    NSManagedObjectID *recordID = [[self.managedObjectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:self.urlForObjectID];
    
    NSManagedObject *fetchedPOI = [self.managedObjectContext objectWithID:recordID];

    
    self.name = (NSString *)[fetchedPOI valueForKey:@"name"];
    self.url = (NSString *)[fetchedPOI valueForKey:@"url"];
    self.phone = (NSString *)[fetchedPOI valueForKey:@"phone"];
    self.descriptionText = (NSString *)[fetchedPOI valueForKey:@"customDescription"];
    self.category = (NSString *)[[fetchedPOI valueForKey:@"hasCategory"]valueForKey:@"name"];
    self.categoryUppercase = [self.category uppercaseString];
    self.categoryBackgroundColour = (UIColor *)[[fetchedPOI valueForKey:@"hasCategory"]valueForKey:@"colour"];
    
    
    NSNumber *longNMN = (NSNumber *)[fetchedPOI valueForKey:@"longitude"];
    self.longitude = [longNMN doubleValue];
    NSNumber *latNSN = (NSNumber *)[fetchedPOI valueForKey:@"latitude"];
    self.latitude = [latNSN doubleValue];
    
    [self getDirections];
    
}


-(void)getDirections
{
    
    CLLocationCoordinate2D destinationCoordinates = CLLocationCoordinate2DMake(self.latitude, self.longitude);
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
    CLLocation *resultLocation = [[CLLocation alloc]initWithLatitude:self.latitude longitude:self.longitude];
    
    CLLocationDistance meters = [userLocation.location distanceFromLocation:resultLocation];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(((self.latitude + userLocation.location.coordinate.latitude)/2), ((self.longitude + userLocation.location.coordinate.longitude)/2));
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, meters, meters);
    
    [self.detailMapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showTabVC"])
    {
        ListTabBarViewController * tabVC = (ListTabBarViewController*)[segue destinationViewController];
        tabVC.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"showEditView"])
    {
        EditPOIViewController *editVC = (EditPOIViewController *)[segue destinationViewController];
        editVC.managedObjectContext = self.managedObjectContext;
        editVC.urlForObjectID = self.urlForObjectID;
        editVC.detailText = self.descriptionText;
        editVC.name = self.name;
        editVC.category = self.category;
    }
    
}


@end
