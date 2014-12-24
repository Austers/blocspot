//
//  CustomCategoryView.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 24/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface CustomCategoryView : UIView <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *view;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end