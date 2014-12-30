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
        
        [self.record setValue:newCategory forKey:@"name"];
        [self.record setValue:[NSDate date] forKey:@"createdAt"];
        [self.record setValue:self.buttonColour forKey:@"colour"];
        
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            
            NSManagedObjectID *recordID = [self.record objectID];
            
            NSURL *url = [recordID URIRepresentation];
            
            self.urlObjectIDToBePassed = url;
            
            //[self dismissViewControllerAnimated:YES completion:nil];
            [self performSegueWithIdentifier:@"backToEditDetails" sender:self];
            
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
     editColourVC.rememberOriginalURL = self.rememberOriginalURL;
     editColourVC.detailText = self.detailText;
     editColourVC.name = self.name;
     editColourVC.category = self.category;

 } else if ([segue.identifier isEqualToString:@"backToEditDetails"])
 {
     EditPOIViewController *editPOIVC = (EditPOIViewController *)[segue destinationViewController];
     editPOIVC.managedObjectContext = self.managedObjectContext;
     editPOIVC.urlForObjectID = self.rememberOriginalURL;
     editPOIVC.detailText = self.detailText;
     editPOIVC.name = self.name;
     editPOIVC.category = self.category;
 }
}


@end
