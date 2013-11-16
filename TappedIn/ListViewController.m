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


#import "ListViewController.h"
#import <Parse/Parse.h>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Type: %@, COUNT: %u", _type, [_beers count]);
    if ([_type isEqualToString:@"Beers"])
        return [_beers count];
    else if ([_type isEqualToString:@"Bars"])
        return [_bars count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *obj;
    
    if ([_type isEqualToString:@"Beers"]) {
        obj = [_beers objectAtIndex:indexPath.row];
    } else {
        obj = [_bars objectAtIndex:indexPath.row];
    }
    
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:_type];
    
    if (!cell) {
        NSLog(@"Cell Does Not Exist");
        if ([_type isEqualToString:@"Beers"]) {
            cell = [self setupBeerCell];
        } else {
            cell = [self setupBarCell];
        }
    }
    
    if ([_type isEqualToString:@"Beers"]) {
        UILabel *name = (UILabel *)[cell viewWithTag:BEER_NAME];
        name.text = obj[@"name"];
    } else {
        UILabel *name = (UILabel *)[cell viewWithTag:VENUE_NAME];
        name.text = obj[@"name"];
        
        UILabel *type = (UILabel*)[cell viewWithTag:VENUE_TYPE];
        type.text = obj[@"type"];
        
        UILabel *distance = (UILabel *)[cell viewWithTag:VENUE_DISTANCE];
        NSNumber *lat = obj[@"latitude"];
        NSNumber *lon = obj[@"longitude"];
        CLLocation *venLoc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
        CLLocationDistance dist = [_userLocation distanceFromLocation:venLoc];
        dist = [self convertToMilesFromMeters:dist];
        distance.text = [NSString stringWithFormat:@"%.2f mi", dist];
        NSLog(@"setting dist: %f", dist);
        
        UILabel *onTap = (UILabel *)[cell viewWithTag:VENUE_BEERS_ON_TAP];
        onTap.text = [NSString stringWithFormat:@"%@", obj[@"onTap"]];
    }
    return  cell;
}

-(UITableViewCell *)setupBarCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_type];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 240, 20)];
    name.tag = VENUE_NAME;
    [cell.contentView addSubview:name];
    
    UILabel *type = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 120, 20)];
    [type setFont:[UIFont systemFontOfSize:12]];
    type.tag = VENUE_TYPE;
    [cell.contentView addSubview:type];
    
    UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(130, 40, 60, 20)];
    [distance setFont:[UIFont systemFontOfSize:12]];
    distance.tag = VENUE_DISTANCE;
    [cell.contentView addSubview:distance];
    
    UILabel *onTap = [[UILabel alloc] initWithFrame:CGRectMake(250, 20, 60, 20)];
    onTap.tag = VENUE_BEERS_ON_TAP;
    [cell.contentView addSubview:onTap];
    
    return cell;

}

-(UITableViewCell *)setupBeerCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_type];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 280, 20)];
    name.tag = BEER_NAME;
    
    [cell.contentView addSubview:name];
    return cell;
}

- (double)convertToMilesFromMeters: (double)distance
{
    return (distance / 1609.344);
}

@end
