//
//  EditExistingViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 15/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "EditExistingViewController.h"
#import "EditColourVC.h"
#import "EditPOIViewController.h"

@interface EditExistingViewController ()

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;

@property (nonatomic, strong) NSManagedObject *fetchedObject;

@end

@implementation EditExistingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
    self.navigationItem.leftBarButtonItem = self.cancelButton;

    self.editText.text = self.passedText;

    self.colourButton.backgroundColor = self.buttonColour;
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PointOfInterest" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSaved" ascending:YES]]];
    
    NSManagedObjectID *recordID = [[self.managedObjectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:self.urlObjectID];
    
    self.fetchedObject = [self.managedObjectContext objectWithID:recordID];
    
   // self.editText.text = (NSString *)[self.fetchedObject valueForKey:@"name"];
   // self.colourButton.backgroundColor = (UIColor *)[self.fetchedObject valueForKey:@"colour"];

}


-(void)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)saveButtonPressed:(id)sender
{
    NSString *newCategory = self.editText.text;
    
    if (newCategory && newCategory.length) {
       // NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
       // NSManagedObject *record = [[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
       // [self.fetchedObject setValue:newCategory forKey:@"name"];
        [self.fetchedObject setValue:[NSDate date] forKey:@"createdAt"];
        [self.fetchedObject setValue:self.buttonColour forKey:@"colour"];
        [self.fetchedObject setValue:self.editText.text forKey:@"name"];
        
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            
           // NSManagedObjectID *recordID = [self.record objectID];
            
           // NSURL *url = [recordID URIRepresentation];
            
            //self.urlObjectIDToBePassed = url;
            
            [self dismissViewControllerAnimated:YES completion:nil];
            //[self performSegueWithIdentifier:@"backToEditDetails" sender:self];
            
        } else
        {
            if (error) {
                
                NSLog(@"Unable to save record.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
            
            [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Your category could not be saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
        
        
    } else
    {
        [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Your category needs a name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 
 if ([segue.identifier isEqualToString:@"showColourSelector"])
 {
     EditColourVC *editColourVC = (EditColourVC *)[segue destinationViewController];
     editColourVC.managedObjectContext = self.managedObjectContext;
     editColourVC.categoryNameTemp = self.editText.text;
     editColourVC.urlObjectID = self.urlObjectID;
    // editColourVC.detailText = self.detailText;
    // editColourVC.name = self.name;
    // editColourVC.category = self.category;

 }
}


@end
