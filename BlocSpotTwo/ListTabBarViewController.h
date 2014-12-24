//
//  ListTabBarViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 19/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCategoryTVController.h"

@interface ListTabBarViewController : UITabBarController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet UITableView *categoryTableview;

@property (nonatomic, strong) CustomCategoryTVController *categorySelector;

@end
