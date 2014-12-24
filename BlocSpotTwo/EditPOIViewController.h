//
//  EditPOIViewController.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 21/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPOIViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *receivedDictionaryFromDetailView;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@property (nonatomic, strong) IBOutlet UITextField *detailTextField;

@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSURL *urlForObjectID;

// @property (strong, nonatomic) IBOutlet UITextField *categoryTextField;

@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) NSString *name;

@end
