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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
        self.navigationController.navigationBar.hidden = NO;
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
    userLocation = [[CLLocation alloc] initWithLatitude:41.888305 longitude:-87.633891];
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
            [_tableView reloadData];
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
    NSLog(@"RESULT: %@", res);
    [_tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
{
    tableBeers = beers;
    [_tableView reloadData];
    [searchBar resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate
//
//- (void)locationManager:(CLLocationManager *)manager
//	didUpdateToLocation:(CLLocation *)newLocation
//		   fromLocation:(CLLocation *)oldLocation __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_6, __MAC_NA, __IPHONE_2_0, __IPHONE_6_0)
//{
//    userLocation = newLocation;
//}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *beerBars = [[tableBeers objectAtIndex:indexPath.row] objectForKey:@"bars"];
    
    NSMutableArray *listOfBars = [[NSMutableArray alloc] init];
    for (NSString *b in beerBars) {
        for (PFObject *obj in bars) {
            if ([b isEqualToString:obj[@"name"]])
                [listOfBars addObject:obj];
        }
    }
    
    [self performSegueWithIdentifier:@"goToBars" sender:listOfBars];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BarsViewController *bC = (BarsViewController *)segue.destinationViewController;
    [bC setBars:(NSMutableArray *)sender];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableBeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *obj;
    
    obj = [tableBeers objectAtIndex:indexPath.row];
    
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
    userLocation = [[CLLocation alloc] initWithLatitude:41.888305 longitude:-87.633891];
    CLLocationDistance min = DBL_MAX;
    
    for (PFObject *o in list) {
        NSNumber *lat = o[@"latitude"];
        NSNumber *lon = o[@"longitude"];
        CLLocation *venLoc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
        CLLocationDistance dist = [userLocation distanceFromLocation:venLoc];
        dist = [self convertToMilesFromMeters:dist];
        min = MIN(min, dist);
    }
    
    return [NSString stringWithFormat:@"Closest Venue: %.2f mi", min];
}

-(UITableViewCell *)setupBeerCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Beers"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *topBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    [topBar setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:topBar];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 240, 20)];
    [name setTextColor:[UIColor brownColor]];
    [name setTextAlignment:NSTextAlignmentCenter];
    name.tag = BEER_NAME;
    [cell.contentView addSubview:name];
    
    UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(60, 40, 200, 20)];
    distance.tag = BEER_DISTANCE;
    [distance setFont:[UIFont systemFontOfSize:12]];
    [distance setTextColor:[UIColor lightGrayColor]];
    [distance setTextAlignment:NSTextAlignmentCenter];
    [cell.contentView addSubview:distance];
    
    return cell;
}

- (double)convertToMilesFromMeters: (double)distance
{
    return (distance / 1609.344);
}



@end
