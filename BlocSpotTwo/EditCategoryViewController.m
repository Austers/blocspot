//
//  EditCategoryViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 14/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "EditCategoryViewController.h"
#import <CoreData/CoreData.h>
#import "CategoryCellTableViewCell.h"
#import "SaveNewCategoryViewController.h"
#import "EditExistingViewController.h"

@interface EditCategoryViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *addButton;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *selection;

@end

@implementation EditCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Add details";
    
    self.addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(segueToAddCategoryView:)];
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Category"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }

    
}

//NSFetchResultController delegate protocols

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(CategoryCellTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

// UITableViewDelegate methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections]count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCellTableViewCell *cell = (CategoryCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(CategoryCellTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.categoryLabel setText:[record valueForKey:@"name"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   // [self setSelection:indexPath];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (record) {
            [self.fetchedResultsController.managedObjectContext deleteObject:record];
        }
    }
}



-(void)segueToAddCategoryView:(id)sender
{
    [self performSegueWithIdentifier:@"addNewCategoryView" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"addNewCategoryView"])
    {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
    
        SaveNewCategoryViewController * destinationCategoryViewController = (SaveNewCategoryViewController*)[nc topViewController];
        destinationCategoryViewController.managedObjectContext = self.managedObjectContext;
    }
    else if ([segue.identifier isEqualToString:@"editExistingCategory"])
    {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        
        EditExistingViewController *destinationVC = (EditExistingViewController *)[nc topViewController];
        
        destinationVC.managedObjectContext = self.managedObjectContext;
        
        self.selection = [self.tableView indexPathForSelectedRow];
        
        if (self.selection) {
            NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:self.selection];
            
            if (record) {
                destinationVC.passedText = [record valueForKey:@"name"];
                destinationVC.buttonColour = [record valueForKey:@"colour"];
                destinationVC.record = record;
                destinationVC.rememberOriginalURL = self.rememberOriginalURL;
                destinationVC.detailText = self.detailText;
                destinationVC.name = self.name;
                destinationVC.category = self.category;
            }

            //[self setSelection:nil];
        }
    }
}


@end
