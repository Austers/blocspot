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
#import "ListTabBarViewController.h"

#import <CoreData/CoreData.h>

@interface EditPOIViewController () <NSFetchedResultsControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) NSString *categorySelection;
@property (nonatomic, strong) UIBarButtonItem *savePoiButton;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObject *fetchedObject;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSURL *urlObjectIDToBePassed;

@end

@implementation EditPOIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Edit details";
    self.detailTextField.text= self.detailText;
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PointOfInterest" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSaved" ascending:YES]]];
    
    NSManagedObjectID *recordID = [[self.managedObjectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:self.urlForObjectID];
    
    self.fetchedObject = [self.managedObjectContext objectWithID:recordID];

    [self fetchPOIData];
}


-(void)fetchPOIData
{
    self.name = (NSString *)[self.fetchedObject valueForKey:@"name"];
    self.detailText = (NSString *)[self.fetchedObject valueForKey:@"customDescription"];
    self.geoSwitch.on = [[self.fetchedObject valueForKey:@"geoAlert"]boolValue];
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
    
    NSUInteger pickerRow = [self determineLocationOfCategoryForDisplay];
    
    [self.picker selectRow:pickerRow inComponent:0 animated:YES];
    
}

//

-(NSUInteger)determineLocationOfCategoryForDisplay
{
    NSMutableArray *categoryStringArray = [[NSMutableArray alloc]init];
    
    for (NSManagedObject *object in [[self fetchedResultsController]fetchedObjects]) {
        NSString *title = (NSString *)[object valueForKey:@"name"];
        
        [categoryStringArray addObject:title];
    }
    
    NSLog(@"%@", categoryStringArray);
    NSLog(@"Category name = %@", self.category);
    
    NSUInteger pickerRow = [categoryStringArray indexOfObject:self.category];

    return pickerRow;
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
    
    NSAttributedString *categoryName = [[NSAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:textColour}];
    
    return categoryName;
}


//Button methods


-(IBAction)Save:(id)sender
{
    NSManagedObject *selectedCategory = [[self.fetchedResultsController fetchedObjects]objectAtIndex:[self.picker selectedRowInComponent:0]];
    
    self.categorySelection = (NSString *)[selectedCategory valueForKey:@"name"];
    
    NSLog(@"%@, %@", self.categorySelection, self.receivedDictionaryFromDetailView);
    
    [self changePOIData];
    
}

-(IBAction)delete:(id)sender
{
    [[[UIAlertView alloc]initWithTitle:@"Delete record" message:@"Are you sure you wish to delete this record?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        NSLog(@"Triggering");
        
        [self.managedObjectContext deleteObject:self.fetchedObject];
        
        NSError *error = nil;
        
        if ([self.fetchedObject.self.managedObjectContext save:&error]) {
            
            [self performSegueWithIdentifier:@"segueAfterDeleting" sender:self];
            
        } else
        {
            
            if (error) {
                
                NSLog(@"Unable to delete record.");
                NSLog(@"%@, %@", error, error.localizedDescription);
                
            }
        }
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.detailText = self.detailTextField.text;
    return YES;
}

-(void)changePOIData
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
         [self.fetchedObject setValue:description forKey:@"customDescription"];
 
         self.dateCreated = [NSDate date];
 
         [self.fetchedObject setValue:self.dateCreated forKey:@"dateSaved"];
         [self.fetchedObject setValue:self.name forKey:@"name"];
         [self.fetchedObject setValue:[NSNumber numberWithBool:self.geoSwitch.isOn] forKey:@"geoAlert"];
 
         [self.fetchedObject setValue:[[self.fetchedResultsController fetchedObjects]objectAtIndex:[self.picker selectedRowInComponent:0]] forKey:@"hasCategory"];
 
         NSManagedObjectID *recordID = [self.fetchedObject objectID];
 
         NSURL *url = [recordID URIRepresentation];
 
         self.urlObjectIDToBePassed = url;
 
         
         NSError *error = nil;
 
         if ([self.managedObjectContext save:&error]) {
             
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
        
        destinationVC.urlForObjectID = self.urlObjectIDToBePassed;
        destinationVC.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"segueAfterDeleting"])
    {
        ListTabBarViewController * tabVC = (ListTabBarViewController*)[segue destinationViewController];
        tabVC.managedObjectContext = self.managedObjectContext;
    }
    
}

@end