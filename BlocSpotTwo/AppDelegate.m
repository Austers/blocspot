//
//  AppDelegate.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 10/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"

#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMutableArray *regionArray;

@end

@implementation AppDelegate

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BlocSpot" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"BlocSpot.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"GiAyQRmBg8IvimdFQFdDBguF7hNaLAQh1Xkkz37H"
                  clientKey:@"FTMFzQAL1bhJykbh9cSJ9JHolTC5SFg0yKySSCfx"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    NSArray *dataTest = [self testForData];
    
    if ([dataTest count] == 0) {
        [self populateData];
        NSLog(@"%@", dataTest);
    }
    
    [self locationManagerSetup];
    [self fetchRegionData];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MapViewController *mapVC = (MapViewController *)navigationController.topViewController;
    mapVC.managedObjectContext = self.managedObjectContext;
    
       return YES;
}

-(void)locationManagerSetup
{
    
    if (![CLLocationManager locationServicesEnabled]) {
        return;
    }
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        
        self.locationManager.delegate = self;
        
        [self.locationManager startUpdatingLocation];
       // [self.locationManager stopUpdatingLocation];
        
    }
    
}

-(void)fetchRegionData
{
    self.regionArray = [[NSMutableArray alloc]init];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PointOfInterest" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSaved" ascending:YES]]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"geoAlert == 1"];
    [request setPredicate:predicate];

    NSError *error = nil;
    
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    for (NSManagedObject *object in array)
    {
        CLCircularRegion *region = (CLCircularRegion *)[object valueForKey:@"region"];
        
        [self.locationManager startMonitoringForRegion:region];
        [self.regionArray addObject:region];
    }
    
    NSLog(@"Region array contains: %@", self.regionArray);
}


-(NSArray *)testForData
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];

    NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    return fetchedResults;
}


-(void)populateData
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *record = [[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    
    
    [record setValue:@"Restaurant" forKey:@"name"];
    [record setValue:[NSDate date] forKey:@"createdAt"];
    
    UIColor *presetOne = [UIColor redColor];
    
    [record setValue:presetOne forKey:@"colour"];
    
    NSError *error = nil;
    
    if ([self.managedObjectContext save:&error]) {
        
        NSLog(@"Saved successfully");
        
    } else
    {
        if (error) {
            
            NSLog(@"Unable to save record.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        
    }

}

-(void)saveManagedObjectContext
{
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        if (error) {
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Have entered %@",region);
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (notification == nil)
        return;
    notification.alertBody = [NSString stringWithFormat:@"Detected entering region"];
    notification.alertAction = @"Congratulate yourself";
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication]presentLocalNotificationNow:notification];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Have left %@",region);
   
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (notification == nil)
        return;
    notification.alertBody = [NSString stringWithFormat:@"Detected exiting region"];
    notification.alertAction = @"Congratulate yourself";
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication]presentLocalNotificationNow:notification];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  
    [self saveManagedObjectContext];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [self saveManagedObjectContext];
    
}

@end
