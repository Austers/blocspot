//
//  CustomCategoryView.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 24/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCategoryTVC.h"

#import <CoreData/CoreData.h>

@protocol CustomCategoryDelegate <NSObject>

-(void) didSelectCell:(NSIndexPath *)selectedIndexPath;

@end

@interface CustomCategoryView : UIView <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id<CustomCategoryDelegate> delegate;

@end
