//
//  SaveNewCategoryViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 14/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "SaveNewCategoryViewController.h"

#import <CoreData/CoreData.h>

#import "CategoryViewController.h"
#import "ColourSelectViewController.h"

@interface SaveNewCategoryViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@end

@implementation SaveNewCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Add Category";
    
    self.saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveCategory:)];
    
    self.cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    
    if (self.buttonColour == nil) {
        self.buttonColour = [UIColor redColor];
        self.colourButton.backgroundColor = self.buttonColour;
    } else
    {
        self.colourButton.backgroundColor = self.buttonColour;
    }
    
    self.categoryText.text = self.passedText;
    
}

-(void) cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveCategory:(id)sender
{
    
    NSString *newCategory = self.categoryText.text;
    
    if (newCategory && newCategory.length) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
        NSManagedObject *record = [[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        
        [record setValue:newCategory forKey:@"name"];
        [record setValue:[NSDate date] forKey:@"createdAt"];
        [record setValue:self.buttonColour forKey:@"colour"];
    
       // [self performSegueWithIdentifier:@"backToEditDetails" sender:self];
        
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showColourSelector"])
    {
  
    ColourSelectViewController *colourSelectVC = (ColourSelectViewController *)[segue destinationViewController];
    colourSelectVC.managedObjectContext = self.managedObjectContext;
    colourSelectVC.categoryNameTemp = self.categoryText.text;
    }
    
    
    
}


@end
