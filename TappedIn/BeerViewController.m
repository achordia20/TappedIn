//
//  BeerViewController.m
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#define BEER_NAME 100
#define BEER_DISTANCE 105

#import "BeerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BarsViewController.h"

@interface BeerViewController ()<UISearchBarDelegate, CLLocationManagerDelegate,
                                    UITableViewDataSource, UITableViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    
    NSMutableArray *beers;
    NSMutableArray *bars;
    
    NSMutableArray *tableBeers;
}

@end

@implementation BeerViewController

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
    [super viewWillAppear:animated];
    self.title = @"Beers";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupLocationServices];
    [self setupSearchBar];
    [self setupTableView];
    [self loadData];
}

-(void)setupTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

-(void)setupLocationServices
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
    [locationManager setDesiredAccuracy:10.0];
    userLocation = locationManager.location;
}

-(void)setupSearchBar
{
    [_searchbar setDelegate:self];
}

-(void)loadData
{
    [self loadBeers];
    [self loadBars];
}

-(void)loadBeers
{
    NSLog(@"Loading Beers");
    PFQuery *query = [PFQuery queryWithClassName:@"Beers"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            beers = [objects mutableCopy];
            tableBeers = beers;
            [_tableView reloadData];
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
        } else
            NSLog(@"ERROR: %@", error.description);
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchBar.text];
    NSLog(@"pred: %@", predicate.debugDescription);
    NSArray *res = [beers filteredArrayUsingPredicate:predicate];
    tableBeers = res;
    [_tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_6, __MAC_NA, __IPHONE_2_0, __IPHONE_6_0)
{
    userLocation = newLocation;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if ([_type isEqualToString:@"Bars"]) {
//        [[[self parentViewController] parentViewController] performSegueWithIdentifier:@"goToVenue" sender:[_bars objectAtIndex:indexPath.row]];
//    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableBeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *obj;
    
    obj = [beers objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"Beers"];
    
    if (!cell) {
        cell = [self setupBeerCell];
    }
    

    UILabel *name = (UILabel *)[cell viewWithTag:BEER_NAME];
    name.text = obj[@"name"];
    
    UILabel *distance  = (UILabel *)[cell viewWithTag:BEER_DISTANCE];
    distance.text = [self getNearestBarFromList:obj[@"bars"]];
    return  cell;
}

-(NSString *)getNearestBarFromList: (NSArray *)barsForBeers
{
    if ([barsForBeers count] == 0)
        return @"NA";
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSString *b in barsForBeers) {
        for (PFObject *ba in bars) {
            if ([b isEqualToString:ba[@"name"]])
                [list addObject:ba];
        }
    }
    
    return [self calculateNearestBarFromList:list];
}

-(NSString *)calculateNearestBarFromList: (NSArray *)list
{
    CLLocationDistance min = DBL_MAX;
    for (PFObject *o in list) {
        NSNumber *lat = o[@"latitude"];
        NSNumber *lon = o[@"longitude"];
        CLLocation *venLoc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
        CLLocationDistance dist = [userLocation distanceFromLocation:venLoc];
        dist = [self convertToMilesFromMeters:dist];
        min = MIN(min, dist);
        NSLog(@"min: %f", min);
    }
    
    return [NSString stringWithFormat:@"%.2f mi", min];
}

-(UITableViewCell *)setupBeerCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Beers"];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 240, 20)];
    name.tag = BEER_NAME;
    [cell.contentView addSubview:name];
    
    UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 120, 20)];
    distance.tag = BEER_DISTANCE;
    [distance setFont:[UIFont systemFontOfSize:12]];
    [cell.contentView addSubview:distance];
    
    return cell;
}

- (double)convertToMilesFromMeters: (double)distance
{
    return (distance / 1609.344);
}



@end
