//
//  EditExistingViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 15/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface EditExistingViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *editText;

@property (nonatomic, strong) IBOutlet UIButton *colourButton;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSManagedObject *record;

@property (nonatomic, strong) UIColor *buttonColour;
@property (nonatomic, strong) NSString *passedText;

@end
