//
//  ListTabBarViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 19/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCategoryTVController.h"

@interface ListTabBarViewController : UITabBarController <UITabBarControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) CustomCategoryTVController *categorySelector;

@end
