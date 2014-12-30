//
//  SavedDetailViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 16/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SavedDetailViewController : UIViewController

@property (nonatomic, strong) NSDate *dateCreated;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UILabel *Title;
@property (nonatomic, strong) IBOutlet UIButton *urlButton;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionTextLabel;
@property (nonatomic, strong) IBOutlet UISwitch *visitedSwitch;

@property (nonatomic, strong) IBOutlet UIButton *phoneButton;

@property (nonatomic, strong) IBOutlet UIView *categoryBackground;

@property (nonatomic, strong) IBOutlet MKMapView *detailMapView;

@property (nonatomic, strong) NSString *passedName;
@property (nonatomic, strong) NSURL *urlForObjectID;

@end