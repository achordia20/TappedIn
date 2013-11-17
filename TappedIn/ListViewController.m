//
//  ListViewController.m
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//
#define BEER_NAME 100
#define VENUE_NAME 101
#define VENUE_TYPE 102
#define VENUE_DISTANCE 103
#define VENUE_BEERS_ON_TAP 104
#define BEER_DISTANCE 105


#import "ListViewController.h"
#import <Parse/Parse.h>
#import <float.h>

@interface ListViewController ()<UITableViewDataSource, UITableViewDelegate>


@end

@implementation ListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    _userLocation = [[CLLocation alloc] initWithLatitude:41.888305 longitude:-87.633891];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupTableView];
}

-(void)setupTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[self parentViewController] parentViewController] performSegueWithIdentifier:@"goToVenue" sender:[_bars objectAtIndex:indexPath.row]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_bars count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *obj;
    
    obj = [_bars objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"Bars"];
    
    if (!cell) {
        cell = [self setupBarCell];
    }
    

    UILabel *name = (UILabel *)[cell viewWithTag:VENUE_NAME];
    name.text = obj[@"name"];
    
    UILabel *type = (UILabel*)[cell viewWithTag:VENUE_TYPE];
    type.text = obj[@"type"];
    
    UILabel *distance = (UILabel *)[cell viewWithTag:VENUE_DISTANCE];
    NSNumber *lat = obj[@"latitude"];
    NSNumber *lon = obj[@"longitude"];
    CLLocation *venLoc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
    _userLocation = [[CLLocation alloc] initWithLatitude:41.888305 longitude:-87.633891];
    CLLocationDistance dist = [_userLocation distanceFromLocation:venLoc];
    dist = [self convertToMilesFromMeters:dist];
    distance.text = [NSString stringWithFormat:@"%.2f mi", dist];
    NSLog(@"setting dist: %f", dist);
    
    UILabel *onTap = (UILabel *)[cell viewWithTag:VENUE_BEERS_ON_TAP];
    onTap.text = [NSString stringWithFormat:@"%d", [obj[@"beers"] count]];
    
    return  cell;
}

-(UITableViewCell *)setupBarCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_type];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *topBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [topBar setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:topBar];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 240, 20)];
    [name setTextColor:[UIColor orangeColor]];
    name.tag = VENUE_NAME;
    [cell.contentView addSubview:name];
    
    UILabel *type = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 120, 20)];
    [type setFont:[UIFont systemFontOfSize:12]];
    [type setTextColor:[UIColor lightGrayColor]];
    type.tag = VENUE_TYPE;
    [cell.contentView addSubview:type];
    
    UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(130, 40, 60, 20)];
    [distance setFont:[UIFont systemFontOfSize:12]];
    [distance setTextColor:[UIColor lightGrayColor]];
    distance.tag = VENUE_DISTANCE;
    [cell.contentView addSubview:distance];
    
    UILabel *onTap = [[UILabel alloc] initWithFrame:CGRectMake(280, 30, 40, 20)];
    [onTap setFont:[UIFont systemFontOfSize:25]];
    onTap.tag = VENUE_BEERS_ON_TAP;
    [cell.contentView addSubview:onTap];
    
    return cell;

}

- (double)convertToMilesFromMeters: (double)distance
{
    return (distance / 1609.344);
}

@end
