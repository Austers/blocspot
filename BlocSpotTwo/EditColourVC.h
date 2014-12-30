//
//  EditColourVC.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 30/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface EditColourVC : UIViewController

@property (nonatomic, strong) IBOutlet UICollectionView *colourCollectionView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *categoryNameTemp;

@end
