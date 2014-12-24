//
//  ListCategoryViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 22/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCategoryTVController.h"

@interface ListCategoryViewController : UIViewController

@property (nonatomic, strong) CustomCategoryTVController *customVC;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet UITableView *mainTableview;
//@property (nonatomic, weak) IBOutlet UITableView *popupTableview;

@property (nonatomic, strong) IBOutlet UIView *categoryView;

@end
