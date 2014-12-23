//
//  ListDateAddedViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 22/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "ListDateAddedViewController.h"
#import "ListTabBarViewController.h"
#import "ListDatePOITVC.h"
#import "SavedDetailViewController.h"

#import <CoreData/CoreData.h>

@interface ListDateAddedViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *selection;

@property (nonatomic, strong) UILabel *categoryLabel;

@end

@implementation ListDateAddedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ListTabBarViewController *tabController = (ListTabBarViewController *)self.tabBarController;
    self.managedObjectContext = tabController.managedObjectContext;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"PointOfInterest"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSaved" ascending:NO]]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections]count];
}


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
            [self configureCell:(ListDatePOITVC *)[self.tableView cellForRowAtIndexPath:indexPath]atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

-(void)configureCell:(ListDatePOITVC *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.pointOfInterestLabel setText:[record valueForKey:@"name"]];
   
    NSString *categoryName = [[record valueForKey:@"hasCategory"]valueForKey:@"name"];
    NSString *categoryLetter = [categoryName substringToIndex:1];
    categoryLetter = [categoryLetter uppercaseString];
    
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.categoryLabel.text = categoryLetter;
    self.categoryLabel.backgroundColor = [[record valueForKey:@"hasCategory"]valueForKey:@"colour"];
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.font = [UIFont systemFontOfSize:24];
    
    
    cell.accessoryView = self.categoryLabel;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListDatePOITVC *cell = (ListDatePOITVC *)[tableView dequeueReusableCellWithIdentifier:@"dateListCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"savedDetailView"])
    {
        
        SavedDetailViewController *savedVC = segue.destinationViewController;
        savedVC.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSManagedObjectID *recordID = [record objectID];
        
        NSURL *url = [recordID URIRepresentation];
        
        NSLog(@"%@", [record valueForKey:@"name"]);
        
        savedVC.urlForObjectID = url;
        
    }
    
}


@end

