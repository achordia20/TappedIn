//
//  VenueViewController.m
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#import "VenueViewController.h"
#import <Parse/Parse.h>

@interface VenueViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation VenueViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = [_venue objectForKey:@"name"];
    [self setAddress];
    [_tableView setUserInteractionEnabled:YES];
    
    [self setupTableView];
	// Do any additional setup after loading the view.
}

-(void)setAddress
{
    _addressLbl.text = [_venue objectForKey:@"address"];
}

-(void)setupTableView
{
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *beers  = [_venue objectForKey:@"beers"];
    return [beers count];
    return 0;
}
#define BEER_NAME 100
#define BEER_TAP 101
#define BEER_LAST_TAPPED 102

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Beer"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Beer"];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 20)];
        name.tag = BEER_NAME;
        [cell.contentView addSubview:name];
        
        UIButton *tap = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(230, 5, 80, 35);
        tap.frame = frame;
        [tap setTitle:@"Tap" forState:UIControlStateNormal];
        [tap setTitle:@"Tap" forState:UIControlStateHighlighted];
        [tap addTarget:self action:@selector(tapDat:) forControlEvents:UIControlEventTouchUpInside];
        [tap setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [tap setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        tap.tag = BEER_TAP;
        [cell.contentView addSubview:tap];
        
        UILabel *lastTap = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 200, 20)];
        lastTap.tag = BEER_LAST_TAPPED;
        [lastTap setTextColor:[UIColor lightGrayColor]];
        lastTap.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:lastTap];
        
        UILabel *botBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 20)];
        [botBar setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:botBar];
    }
    
    UILabel *name = (UILabel *)[cell viewWithTag:BEER_NAME];
    name.text = [[_venue objectForKey:@"beers"] objectAtIndex:indexPath.row];
    
    UILabel *lastTap = (UILabel *)[cell viewWithTag:BEER_LAST_TAPPED];
    lastTap.text = @"Last Tapped: 11/16";
    
    cell.tag = indexPath.row;
    
    return cell;
}

-(IBAction)tapDat:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [btn setTitle:@"Tapped" forState:UIControlStateNormal];
    [btn setTitle:@"Tapped" forState:UIControlStateHighlighted];
    [btn setTitle:@"Tapped" forState:UIControlStateDisabled];
    UITableViewCell *cell = (UITableViewCell *)[[[sender superview] superview] superview];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    UILabel *lastTap = (UILabel *)[cell viewWithTag:BEER_LAST_TAPPED];
    lastTap.text = [NSString stringWithFormat:@"Last Tapped: %d/%d", [components month], [components day]];
}

@end
