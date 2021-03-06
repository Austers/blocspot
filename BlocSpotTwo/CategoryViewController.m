
//
//  CategoryViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 3/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "CategoryViewController.h"

#import "EditCategoryViewController.h"
#import "SavedDetailViewController.h"

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface CategoryViewController () <NSFetchedResultsControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate>

@property (nonatomic,strong) NSString *categorySelection;
@property (nonatomic, strong) UIBarButtonItem *savePoiButton;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSURL *urlObjectIDToBePassed;

// properties to be stored to CoreData

@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, assign) CLLocationCoordinate2D poiLocation;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Enter details";
    
    [self extractDictionaryValues];
}


-(void)viewDidAppear:(BOOL)animated
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Category"];
    fetchRequest.propertiesToFetch = @[@"name", @"colour"];
    

    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    [self.picker reloadAllComponents];

}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[self fetchedResultsController]fetchedObjects]count];
}


-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSManagedObject *category = [[[self fetchedResultsController]fetchedObjects]objectAtIndex:row];
    
    NSString *title = (NSString *)[category valueForKey:@"name"];
    
    UIColor *textColour = (UIColor *)[category valueForKey:@"colour"];
    
    NSAttributedString *attString = [[NSAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:textColour}];
    
    return attString;
}

-(IBAction)Save:(id)sender
{
    NSManagedObject *selectedCategory = [[self.fetchedResultsController fetchedObjects]objectAtIndex:[self.picker selectedRowInComponent:0]];
    
    self.categorySelection = (NSString *)[selectedCategory valueForKey:@"name"];
    
    NSLog(@"%@, %@", self.categorySelection, self.receivedDictionaryFromDetailView);
    NSLog(@"The switch is %d",self.geoSwitch.isOn);
    
    [self commitPOIData];

}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.detailText = self.detailTextField.text;
    return YES;
}

-(void)commitPOIData
{
 
    NSString *description = self.detailTextField.text;
    
        if (!(description && description.length))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please enter a description" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"What is going on here?");
            
        }
        else
        {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"PointOfInterest" inManagedObjectContext:self.managedObjectContext];
            NSManagedObject *record = [[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
            
            NSNumber *latNSN = [NSNumber numberWithDouble:self.latitude];
            NSNumber *longNSN = [NSNumber numberWithDouble:self.longitude];
            
            [record setValue:description forKey:@"customDescription"];
            
            self.dateCreated = [NSDate date];
            
            [record setValue:self.dateCreated forKey:@"dateSaved"];
            [record setValue:self.name forKey:@"name"];
            [record setValue:self.phone forKey:@"phone"];
            [record setValue:self.url forKey:@"url"];
            [record setValue:latNSN forKey:@"latitude"];
            [record setValue:longNSN forKey:@"longitude"];
            [record setValue:[NSNumber numberWithBool:self.geoSwitch.isOn] forKey:@"geoAlert"];
            
            if (self.geoSwitch.isOn == YES) {
                self.poiLocation = CLLocationCoordinate2DMake(self.latitude, self.longitude);
                CLCircularRegion *regionToMonitor = [[CLCircularRegion alloc]initWithCenter:self.poiLocation radius:250.0 identifier:[[NSUUID UUID]UUIDString]];
                [record setValue:regionToMonitor forKey:@"region"];
            }
             
            [record setValue:[[self.fetchedResultsController fetchedObjects]objectAtIndex:[self.picker selectedRowInComponent:0]] forKey:@"hasCategory"];
            
            NSError *error = nil;
            
            
            if ([self.managedObjectContext save:&error]) {
                
                NSManagedObjectID *recordID = [record objectID];
                
                NSURL *url = [recordID URIRepresentation];
                
                self.urlObjectIDToBePassed = url;
                
                [self performSegueWithIdentifier:@"segueAfterSaving" sender:self];

            } else
            {
            
            if (error) {
                    
                    NSLog(@"Unable to save record.");
                    NSLog(@"%@, %@", error, error.localizedDescription);
                
            }
                
                [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Your Point Of Interest could not be saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            }
        }
}

-(void)extractDictionaryValues
{
    self.name = self.receivedDictionaryFromDetailView [@"Title"];
    self.phone = self.receivedDictionaryFromDetailView [@"Phone"];
    self.url = self.receivedDictionaryFromDetailView [@"URLString"];
    
    NSNumber *receivedLatitude = self.receivedDictionaryFromDetailView [@"Latitude"];
    self.latitude = [receivedLatitude doubleValue];
    NSNumber *receivedLongitude = self.receivedDictionaryFromDetailView [@"Longitude"];
    self.longitude = [receivedLongitude doubleValue];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"editCategory"])
    {
        EditCategoryViewController * destinationCategoryViewController = (EditCategoryViewController*)[segue destinationViewController];
        destinationCategoryViewController.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"segueAfterSaving"])
    {
        SavedDetailViewController *destinationVC = (SavedDetailViewController*)[segue destinationViewController];
        
        destinationVC.urlForObjectID = self.urlObjectIDToBePassed;
        destinationVC.managedObjectContext = self.managedObjectContext;
    }
    
}

@end
