//
//  ListTabBarViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 19/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTabBarViewController : UITabBarController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
