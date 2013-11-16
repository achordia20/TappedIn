//
//  MainViewController.m
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#import "MainViewController.h"
#import "MapViewController.h"
#import "ListViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MainViewController ()<UISearchBarDelegate, CLLocationManagerDelegate>
{
    NSMutableArray *beers;
    NSMutableArray *bars;
    
    UITabBarController *tabBarController;
    MapViewController *mapViewController;
    ListViewController *listViewController;
    
    CLLocationManager *locationManager;
    CLLocation *userLocation;
}

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title =  self.type;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLocationServices];
    [self setupSearchBar];
    [self setupChildViewControllers];
    [self loadData];
}

-(void)setupLocationServices
{
    NSLog(@"setupLocationServices");
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
    [locationManager setDesiredAccuracy:10.0];
    userLocation = locationManager.location;
    listViewController.userLocation = userLocation;
    mapViewController.userLocation = userLocation;
}

-(void)setupSearchBar
{
    [_searchBar setDelegate:self];
}

-(void)setupChildViewControllers
{
    tabBarController = [self.childViewControllers objectAtIndex:0];
    listViewController = [[tabBarController childViewControllers] objectAtIndex:0];
    mapViewController = [[tabBarController childViewControllers] objectAtIndex:1];
    listViewController.type = _type;
    mapViewController.type = _type;
}

-(void)loadData
{
    if ([_type isEqualToString:@"Beers"]) {
        [self loadBeers];
    } else if ([_type isEqualToString:@"Bars"]) {
        [self loadBars];
    }
}

-(void)loadBeers
{
    NSLog(@"Loading Beers");
    PFQuery *query = [PFQuery queryWithClassName:@"Beers"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            beers = [objects mutableCopy];
            listViewController.beers = beers;
            mapViewController.beers = beers;
            [self reloadChildData];
        } else
            NSLog(@"ERROR: %@", error.description);
    }];
}

-(void)loadBars
{
    PFQuery *query = [PFQuery queryWithClassName:@"Bars"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            bars = [objects mutableCopy];
            listViewController.bars = bars;
            mapViewController.bars = bars;
            [self reloadChildData];
        } else
            NSLog(@"ERROR: %@", error.description);
    }];
}

-(void)reloadChildData
{
    if (tabBarController.selectedIndex == 0) {
        [listViewController.tableView reloadData];
    } else if (tabBarController.selectedIndex == 1) {
        [mapViewController.mapView reloadInputViews];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchBar.text];
    NSLog(@"pred: %@", predicate.debugDescription);
    if ([_type isEqualToString:@"Beers"]) {
        NSArray *res = [beers filteredArrayUsingPredicate:predicate];
        listViewController.beers = [res mutableCopy];
        mapViewController.beers = [res mutableCopy];;
        [self reloadChildData];
    } else if ([_type isEqualToString:@"Bars"]) {
        NSArray *res = [bars filteredArrayUsingPredicate:predicate];
        listViewController.bars = [res mutableCopy];
        mapViewController.bars = [res mutableCopy];
        [self reloadChildData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
{
    if ([_type isEqualToString:@"Beers"]) {
        listViewController.beers = beers;
        mapViewController.beers = beers;
        [self reloadChildData];
    } else if ([_type isEqualToString:@"Bars"]) {
        listViewController.bars = bars;
        mapViewController.bars = bars;
        [self reloadChildData];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_6, __MAC_NA, __IPHONE_2_0, __IPHONE_6_0)
{
    userLocation = newLocation;
    listViewController.userLocation = userLocation;
    mapViewController.userLocation = userLocation;
}


@end
