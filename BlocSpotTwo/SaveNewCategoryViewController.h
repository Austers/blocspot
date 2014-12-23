//
//  SaveNewCategoryViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 14/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaveNewCategoryViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextField *categoryText;

@property (nonatomic, strong) IBOutlet UIButton *colourButton;

@property (nonatomic, strong) UIColor *buttonColour;

@end
