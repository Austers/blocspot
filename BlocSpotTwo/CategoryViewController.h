//
//  CategoryViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 3/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *receivedDictionaryFromDetailView;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@property (nonatomic, strong) IBOutlet UITextField *detailTextField;
@property (nonatomic, strong) IBOutlet UISwitch *geoSwitch;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
