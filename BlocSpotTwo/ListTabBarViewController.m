//
//  ListTabBarViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 19/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "ListTabBarViewController.h"

#import "MapViewController.h"

#import "SearchViewController.h"

#import "CustomCategoryTVController.h"
#import "ListCategoryViewController.h"

@interface ListTabBarViewController ()

@property (nonatomic, strong) UIBarButtonItem *mapButton;
@property (nonatomic, strong) UIBarButtonItem *searchButton;
@property (nonatomic, strong) UIPopoverController *popoverMenu;

@end

@implementation ListTabBarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.title = @"Saved destinations";
    
    self.mapButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"mapbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(mapButtonPressed:)];
    self.navigationItem.leftBarButtonItem = self.mapButton;
    
    self.searchButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.searchButton;

}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[ListCategoryViewController class]]) {
        [(ListCategoryViewController *) viewController changeConstraints];
        NSLog(@"Hit");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)mapButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"segueToMap" sender:self];
}

-(void)searchButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"segueToSearch" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueToMap"])
    {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        
        MapViewController * mapVC = (MapViewController*)[nc topViewController];
        mapVC.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"segueToSearch"])
    {
        SearchViewController *searchVC = (SearchViewController *)[segue destinationViewController];
        searchVC.managedObjectContext = self.managedObjectContext;
    }
}
@end
