//
//  EditColourVC.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 30/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "EditColourVC.h"
#import "ColorCollectionViewCell.h"
#import "EditExistingViewController.h"

@interface EditColourVC () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *colourArray;
@property (nonatomic, assign) NSUInteger selectedItem;

@end

@implementation EditColourVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.colourArray = [[NSArray alloc]initWithObjects:[UIColor darkGrayColor],[UIColor lightGrayColor],[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor cyanColor],[UIColor yellowColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor],[UIColor brownColor], nil];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colourArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColorCollectionViewCell *cell = (ColorCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"colourCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [self.colourArray objectAtIndex:indexPath.row];
    
    return cell;
}

/*
 
 -(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
 
 self.selectedItem = indexPath.row;
 
 [self performSegueWithIdentifier:@"colourSelected" sender:self];
 
 }
 
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSArray *colourSelectionArray = [self.colourCollectionView indexPathsForSelectedItems];
    
    NSIndexPath *colourIndex = [colourSelectionArray objectAtIndex:0];
    
    NSUInteger colourRow = colourIndex.row;
    
    EditExistingViewController *editExistingVC = (EditExistingViewController *)[segue destinationViewController];
    editExistingVC.managedObjectContext = self.managedObjectContext;
    
    editExistingVC.passedText = self.categoryNameTemp;
    
    editExistingVC.buttonColour = [self.colourArray objectAtIndex:colourRow];
    
}

@end