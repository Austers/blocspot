//
//  EditPOIViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 21/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "EditPOIViewController.h"

#import "EditCategoryViewController.h"
#import "SavedDetailViewController.h"

#import <CoreData/CoreData.h>

@interface EditPOIViewController () <NSFetchedResultsControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic,strong) NSString *categorySelection;
@property (nonatomic, strong) UIBarButtonItem *savePoiButton;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSDate *dateCreated;

@end

@implementation EditPOIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Edit details";
    self.detailTextField.text= self.detailText;
    
    [self fetchPOIData];
}


-(void)viewDidAppear:(BOOL)animated
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Category"];
    fetchRequest.propertiesToFetch = @[@"name"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    
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

-(void)fetchPOIData
{
    NSManagedObjectID *recordID = [[self.managedObjectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:self.urlForObjectID];
    NSManagedObject *record = [self.managedObjectContext objectWithID:recordID];
    
    self.name = (NSString *)[record valueForKey:@"name"];
    self.detailText = (NSString *)[record valueForKey:@"customDescription"];
    
    
}



-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[self fetchedResultsController]fetchedObjects]count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSManagedObject *category = [[[self fetchedResultsController]fetchedObjects]objectAtIndex:row];
    
    NSString *categoryName = (NSString *)[category valueForKey:@"name"];
    
    return categoryName;
}


//Button methods

-(IBAction)Save:(id)sender
{
    NSManagedObject *selectedCategory = [[self.fetchedResultsController fetchedObjects]objectAtIndex:[self.picker selectedRowInComponent:0]];
    
    self.categorySelection = (NSString *)[selectedCategory valueForKey:@"name"];
    
    NSLog(@"%@, %@", self.categorySelection, self.receivedDictionaryFromDetailView);
    
   // [self changePOIData];
    
}

-(IBAction)delete:(id)sender
{
    [[[UIAlertView alloc]initWithTitle:@"Delete record" message:@"Are you sure you wish to delete this record?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    
    // Delete record
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.detailText = self.detailTextField.text;
    return YES;
}
/*
-(void)changePOIData
{
    
    NSString *description = self.detailTextField.text;
    
    if (description && description.length) {
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
        
        [record setValue:[[self.fetchedResultsController fetchedObjects]objectAtIndex:[self.picker selectedRowInComponent:0]] forKey:@"hasCategory"];
        
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else
        {
            if (error) {
                
                NSLog(@"Unable to save record.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
            
            [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Your Point Of Interest could not be saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
        
        
    } else
    {
        [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please enter a description" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"editCategory"])
    {
        EditCategoryViewController * destinationCategoryViewController = (EditCategoryViewController*)[segue destinationViewController];
        destinationCategoryViewController.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"segueAfterSaving"])
    {
        SavedDetailViewController *destinationVC = (SavedDetailViewController*)[segue destinationViewController];
        destinationVC.passedName = self.name;
        destinationVC.managedObjectContext = self.managedObjectContext;
    }
    
}



@end