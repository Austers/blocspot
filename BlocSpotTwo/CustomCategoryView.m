//
//  CustomCategoryView.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 24/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "CustomCategoryView.h"
#import "CustomCategoryTVC.h"
#import "AppDelegate.h"

@interface CustomCategoryView ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CustomCategoryView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setup];
    }
    return self;
}

-(void)setup
{
   UIView* viewLayer = [[NSBundle mainBundle] loadNibNamed:@"CustomCategoryView" owner:self options:nil][0];
   [self addSubview:viewLayer];
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Category"];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections]count];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *categoryName = [record valueForKey:@"name"];
    
    [self.delegate didSelectCategory:categoryName];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (record) {
            [self.fetchedResultsController.managedObjectContext deleteObject:record];
        }
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CustomCategoryTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCategoryCell"];
    
    if (!cell)
    {
        cell = [[CustomCategoryTVC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomCategoryCell"];
    }
    
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.textLabel setText:[record valueForKey:@"name"]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [record valueForKey:@"colour"];
    return cell;
}


@end
