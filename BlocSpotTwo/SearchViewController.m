
//
//  SearchViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 24/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"
#import "SavedDetailViewController.h"

#import <CoreData/CoreData.h>

@interface SearchViewController () <DataSourceDelegate, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *searchResultTitles;
@property (strong, nonatomic) NSMutableArray *searchResultURL;
@property (strong, nonatomic) NSMutableArray *searchResultDistances;
@property (strong, nonatomic) NSMutableArray *searchResultPhoneNumbers;
@property (strong, nonatomic) NSMutableArray *searchResultLatitudes;
@property (strong, nonatomic) NSMutableArray *searchResultLongitudes;
@property (strong, nonatomic) NSArray *resultDictionaries;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSIndexPath *selection;


@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Search";
    
}


// Tableview setup

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Saved locations", @"Saved location header");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Search results", @"Search result header");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0)
    {
        NSArray *sections = [self.fetchedResultsController sections];
        id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        
        return [sectionInfo numberOfObjects];
    }
    else{
        return self.resultDictionaries.count;;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedCell"];
        
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [cell.textLabel setText:[record valueForKey:@"name"]];
        cell.detailTextLabel.text = @"";
        
        return cell;
    
         }
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
        
        cell.textLabel.text = [self.searchResultTitles objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.searchResultDistances objectAtIndex:indexPath.row];
        
        return cell;
    }
   
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailView"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
        DetailViewController *detailVC = segue.destinationViewController;
        
        detailVC.managedObjectContext = self.managedObjectContext;
    
        NSString *titleText = [self.searchResultTitles objectAtIndex:indexPath.row];
        NSString *uRLText = [self.searchResultURL objectAtIndex:indexPath.row];
        NSString *phoneText = [self.searchResultPhoneNumbers objectAtIndex:indexPath.row];
        NSNumber *latitude = [self.searchResultLatitudes objectAtIndex:indexPath.row];
        NSNumber *longitude = [self.searchResultLongitudes objectAtIndex:indexPath.row];
        
        detailVC.titleTextLabelString = titleText;
        detailVC.uRLLabel = uRLText;
        detailVC.phoneTextLabel = phoneText;
        detailVC.detailLatitude = [latitude doubleValue];
        detailVC.detailLongitude = [longitude doubleValue];
    
    } else if ([segue.identifier isEqualToString:@"savedDetailView"])
    {
        
        SavedDetailViewController *savedVC = segue.destinationViewController;
        savedVC.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSLog(@"%@", [record valueForKey:@"name"]);
        
        savedVC.passedName = [record valueForKey:@"name"];
        
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    self.searchString = searchBar.text;
    
    NSLog(@"%@", self.searchString);
    
    DataSource* source =[[DataSource alloc] initWithSearchString:self.searchString Region:self.currentRegion Delegate:self];
    [source performSearchForText];
    
    [self fetchPOI];

}


- (void) finishedSearch:(NSArray *)resultsOfSearch
{
    NSArray * results = resultsOfSearch;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"distance" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [results sortedArrayUsingDescriptors:sortDescriptors];
    
    self.resultDictionaries = [NSMutableArray arrayWithArray:sortedArray];
    
    [self generateTitleArray];
    [self generateUrlStringArray];
    [self generateDistanceFromCurrentLocation];
    [self generatePhoneArray];
    [self generateCoordinateData];
    
    [self.tableView reloadData];
}

-(void) generateCoordinateData
{
    NSMutableArray *longitudes = [[NSMutableArray alloc]init];
    NSMutableArray *latitudes = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        [longitudes addObject:[dict objectForKey:@"long"]];
        [latitudes addObject:[dict objectForKey:@"lat"]];
    }
    
    self.searchResultLongitudes = longitudes;
    self.searchResultLatitudes = latitudes;
}

-(void) generateTitleArray
{
    NSMutableArray *titles = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        [titles addObject:[dict objectForKey:@"name"]];
    }
    
    self.searchResultTitles = titles;
}

-(void) generateUrlStringArray
{
    NSMutableArray *URLs = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        [URLs addObject:[dict objectForKey:@"urlString"]];
    }
    
    self.searchResultURL = URLs;
}

-(void) generatePhoneArray
{
    NSMutableArray *phone = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        [phone addObject:[dict objectForKey:@"phone"]];
    }
    
    self.searchResultPhoneNumbers = phone;
}

-(void) generateDistanceFromCurrentLocation
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in self.resultDictionaries) {
        NSNumber *latitude = [dict objectForKey:@"lat"];
        NSNumber *longitude = [dict objectForKey:@"long"];
        
        double LatitudeD = [latitude doubleValue];
        double LongitudeD = [longitude doubleValue];

        CLLocation *location = [[CLLocation alloc]initWithLatitude:LatitudeD longitude:LongitudeD];
        
        CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.currentRegion.center.latitude longitude:self.currentRegion.center.longitude];
        
        CLLocationDistance distance = [location distanceFromLocation:currentLocation];
        
        int distanceInt = (int)distance;
        
        NSString *distanceString = [NSString stringWithFormat:@"%dm", distanceInt];
        
        [distanceArray addObject:distanceString];
        
    }
    self.searchResultDistances = distanceArray;
}

-(void)fetchPOI
{
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PointOfInterest" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSaved" ascending:YES]]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"name", self.searchString];
    [request setPredicate:predicate];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
   // NSManagedObject *fetchedPOI = [[self.fetchedResultsController fetchedObjects]objectAtIndex:0];
    
   // self.name = (NSString *)[fetchedPOI valueForKey:@"name"];
    // self.url = (NSString *)[fetchedPOI valueForKey:@"url"];
    // self.phone = (NSString *)[fetchedPOI valueForKey:@"phone"];
    // self.descriptionText = (NSString *)[fetchedPOI valueForKey:@"customDescription"];
    
    
  //  NSNumber *longNMN = (NSNumber *)[fetchedPOI valueForKey:@"longitude"];
  //  self.longitude = [longNMN doubleValue];
   // NSNumber *latNSN = (NSNumber *)[fetchedPOI valueForKey:@"latitude"];
   // self.latitude = [latNSN doubleValue];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
