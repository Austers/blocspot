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

@implementation CustomCategoryView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
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
        
        NSLog(@"this gets called");
        
        [self setup];
    }
    return self;
}

-(void)setup
{
    [[NSBundle mainBundle]loadNibNamed:@"CustomCategoryView" owner:self options:nil];
    [self addSubview:self.view];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections]count];
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(CustomCategoryTVC *)[self.tableView cellForRowAtIndexPath:indexPath]atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
     
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCategoryCell"];
   
    if (cell==nil) {
    
    UIViewController *temporaryController = [[UIViewController alloc]initWithNibName:@"CustomCategoryCell" bundle:nil];
    
    cell = (CustomCategoryTVC *)temporaryController.view;
    
    [self configureCell:cell atIndexPath:indexPath];
        
    }
    return cell;
}


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
 
    NSString *categoryName = [record valueForKey:@"name"];
    NSString *categoryLetter = [categoryName substringToIndex:1];
    categoryLetter = [categoryLetter uppercaseString];
    
  //  cell.categoryLabel.text = categoryLetter;
   // cell.categoryLabel.textColor = [UIColor whiteColor];
  //  cell.categoryLabel.textAlignment = NSTextAlignmentCenter;
    //cell.categoryLabel.font = [UIFont systemFontOfSize:24];
 
    cell.contentView.backgroundColor = [record valueForKey:@"colour"];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
/*
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCategoryTVC *cell = (CustomCategoryTVC *)[tableView dequeueReusableCellWithIdentifier:@"listCategoryCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
*/
@end
