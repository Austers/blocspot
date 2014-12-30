//
//  EditCategoryViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 14/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditCategoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSURL *rememberOriginalURL;

@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;

@end
