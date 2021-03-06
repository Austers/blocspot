//
//  CustomCategoryTVController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 24/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "CustomCategoryTVController.h"
#import "ListTabBarViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#include "ListCategoryViewController.h"

@interface CustomCategoryTVController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CustomCategoryTVController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Category"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCategoryCell"];
    
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.textLabel setText:[record valueForKey:@"name"]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [record valueForKey:@"colour"];
    return cell;
}

/*
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
 if ([segue.identifier isEqualToString:@"savedDetailView"])
 {
 
 SavedDetailViewController *savedVC = segue.destinationViewController;
 savedVC.managedObjectContext = self.managedObjectContext;
 
 NSIndexPath *indexPath = [self.mainTableview indexPathForSelectedRow];
 
 NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
 
 NSManagedObjectID *recordID = [record objectID];
 
 NSURL *url = [recordID URIRepresentation];
 
 NSLog(@"%@", [record valueForKey:@"name"]);
 
 savedVC.urlForObjectID = url;
 
 }
 
 }
 */

@end

