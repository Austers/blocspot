//
//  ListCategoryViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 22/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "ListCategoryViewController.h"
#import "ListTabBarViewController.h"
#import "ListCategoryPOITVC.h"
#import "SavedDetailViewController.h"
#import "CustomCategoryView.h"
#import "CustomCategoryTVC.h"
#import "DistanceCalculator.h"

#import <CoreData/CoreData.h>

@interface ListCategoryViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CustomCategoryDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *selection;

@property (nonatomic, strong) UILabel *categoryLabel;

@property (nonatomic, strong) NSString *selectedCategoryName;

@end

@implementation ListCategoryViewController



- (void)viewDidLoad {
    [super viewDidLoad];
 
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reorderTable:) name:@"CategorySelected" object:nil];
    
    // set delegate
    self.categoryView.delegate = self;
    
    // set position to 0
    
    self.categoryviewConstraintRightPosition.constant = 0;
    
    ListTabBarViewController *tabController = (ListTabBarViewController *)self.tabBarController;
    self.managedObjectContext = tabController.managedObjectContext;
    
    [self fetchData];
}


-(void)fetchData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"PointOfInterest"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"hasCategory.name" ascending:NO]]];
    
    
    if (self.selectedCategoryName == nil) {
        NSLog(@"No name");
        
    } else
        
    {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"hasCategory.name", self.selectedCategoryName];
        [fetchRequest setPredicate:predicate];
        
    }
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }

}



-(void)changeConstraints
{
    [self viewDidLoad];
}

-(void)didSelectCategory:(NSString *)categoryName
{
    NSLog(@"Row selected is %@", categoryName);
    self.selectedCategoryName = categoryName;
    self.categoryviewConstraintRightPosition.constant = -self.categoryView.frame.size.width;
    [self fetchData];
    [self.mainTableview reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return [[self.fetchedResultsController sections]count];
}


-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.mainTableview beginUpdates];
}


-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.mainTableview endUpdates];
}


-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.mainTableview insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.mainTableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(ListCategoryPOITVC *)[self.mainTableview cellForRowAtIndexPath:indexPath]atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.mainTableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.mainTableview insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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

-(void)configureCell:(ListCategoryPOITVC *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSNumber *longNMN = (NSNumber *)[record valueForKey:@"longitude"];
    double longitude = [longNMN doubleValue];
    NSNumber *latNSN = (NSNumber *)[record valueForKey:@"latitude"];
    double latitude = [latNSN doubleValue];
    
    CLLocationCoordinate2D savedLocation = CLLocationCoordinate2DMake(latitude, longitude);
    
    DistanceCalculator *calculator = [[DistanceCalculator alloc]init];
    
    cell.distanceLabel.text = [calculator determineDistanceFromCurrentLocation:savedLocation];
    
    [cell.pointOfInterestLabel setText:[record valueForKey:@"name"]];
    
    NSString *categoryName = [[record valueForKey:@"hasCategory"]valueForKey:@"name"];
    NSString *categoryLetter = [categoryName substringToIndex:1];
    categoryLetter = [categoryLetter uppercaseString];
    
    UIView * categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    categoryView.backgroundColor = [[record valueForKey:@"hasCategory"]valueForKey:@"colour"];
    
    UIView *whiteBorder = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    whiteBorder.backgroundColor = [UIColor whiteColor];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.categoryLabel.text = categoryLetter;
    self.categoryLabel.backgroundColor = [UIColor grayColor];
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.font = [UIFont systemFontOfSize:20];
    
    [whiteBorder addSubview:self.categoryLabel];
    [categoryView addSubview:whiteBorder];
    
    whiteBorder.center = CGPointMake(categoryView.frame.size.width / 2, categoryView.frame.size.height / 2);
    self.categoryLabel.center = CGPointMake(whiteBorder.frame.size.width / 2, whiteBorder.frame.size.height / 2);
    
    cell.accessoryView = categoryView;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        ListCategoryPOITVC *cell = (ListCategoryPOITVC *)[tableView dequeueReusableCellWithIdentifier:@"listCategoryCell" forIndexPath:indexPath];
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
}


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


@end