//
//  SavedDetailViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 16/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "SavedDetailViewController.h"

#import <CoreData/CoreData.h>

#import "ListTabBarViewController.h"

@interface SavedDetailViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *listButton;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) UIColor *categoryBackgroundColour;

@end

@implementation SavedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    self.listButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"listbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(listButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = self.listButton;
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    [self fetchPOI];
    
    self.Title.text = self.name;
    
    if (self.phone.length == 0) {
        self.phoneButton.enabled = NO;
    } else
    {
        self.phoneButton.enabled = YES;
        [self.phoneButton setBackgroundImage:[UIImage imageNamed:@"phonebutton"] forState:UIControlStateNormal];
    }

    if (self.url.length == 0) {
        self.urlButton.enabled = NO;
    } else
    {
        self.urlButton.enabled = YES;
        [self.urlButton setBackgroundImage:[UIImage imageNamed:@"domainbutton"] forState:UIControlStateNormal];
    }
    
    self.categoryLabel.text = self.category;
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.descriptionTextLabel.text = self.descriptionText;
    self.categoryBackground.backgroundColor = self.categoryBackgroundColour;
    
}

-(IBAction)callPhone:(id)sender
{
    NSString *phoneString = [NSString stringWithFormat:@"telprompt://%@", self.phone];
    
    if (self.phone.length == 0) {
        NSLog(@"No phone number");
    } else
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:phoneString]];
    }
}

-(IBAction)visitWebsite:(id)sender
{
    if (self.url == 0) {
        NSLog(@"No website address");
    } else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    }
}

-(void)editButtonPressed:(id)sender
{
    
}

-(void)listButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"showTabVC" sender:self];
}


-(void)fetchPOI
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PointOfInterest" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSaved" ascending:YES]]];
    
    NSManagedObjectID *recordID = [[self.managedObjectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:self.urlForObjectID];
    
    /*
    
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"name", self.passedName];
     [request setPredicate:predicate];
    
     self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
     [self.fetchedResultsController setDelegate:self];
    
     NSError *error = nil;
    
     [self.fetchedResultsController performFetch:&error];
    
     if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
     }
    
     NSManagedObject *fetchedPOI = [[self.fetchedResultsController fetchedObjects]objectAtIndex:0];
    
    */
    
    NSManagedObject *fetchedPOI = [self.managedObjectContext objectWithID:recordID];

    
    self.name = (NSString *)[fetchedPOI valueForKey:@"name"];
    self.url = (NSString *)[fetchedPOI valueForKey:@"url"];
    self.phone = (NSString *)[fetchedPOI valueForKey:@"phone"];
    self.descriptionText = (NSString *)[fetchedPOI valueForKey:@"customDescription"];
    self.category = (NSString *)[[fetchedPOI valueForKey:@"hasCategory"]valueForKey:@"name"];
    self.category = [self.category uppercaseString];
    self.categoryBackgroundColour = (UIColor *)[[fetchedPOI valueForKey:@"hasCategory"]valueForKey:@"colour"];
    
    
    NSNumber *longNMN = (NSNumber *)[fetchedPOI valueForKey:@"longitude"];
    self.longitude = [longNMN doubleValue];
    NSNumber *latNSN = (NSNumber *)[fetchedPOI valueForKey:@"latitude"];
    self.latitude = [latNSN doubleValue];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showTabVC"])
    {
        ListTabBarViewController * tabVC = (ListTabBarViewController*)[segue destinationViewController];
        tabVC.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"showEditVC"])
    {
        
    }
    
}


@end
