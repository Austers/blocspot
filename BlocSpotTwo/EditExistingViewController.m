//
//  EditExistingViewController.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 15/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "EditExistingViewController.h"

@interface EditExistingViewController ()

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *saveButton;

@end

@implementation EditExistingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    
    if (self.record) {
        [self.editText setText:[self.record valueForKey:@"name"]];
    }
}


-(void)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)saveButtonPressed:(id)sender
{
    NSString *categoryName = self.editText.text;
    
    if (categoryName && categoryName.length) {
        [self.record setValue:categoryName forKey:@"name"];
        
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else
        {
            if (error) {
                NSLog(@"Unable to save record");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
            
            [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Your to-do could not be saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
        }
        
    } else
    {
        [[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Your to-do needs a name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
