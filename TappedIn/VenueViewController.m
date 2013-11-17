//
//  VenueViewController.m
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#import "VenueViewController.h"

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
    [_tableView setUserInteractionEnabled:YES];
    
    [self setupTableView];
	// Do any additional setup after loading the view.
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

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
{
    NSArray *beers  = [_venue objectForKey:@"beers"];
    return [beers count];
    return 0;
}
#define BEER_NAME 100
#define BEER_TAP 101

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Beer"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Beer"];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 200, 20)];
        name.tag = BEER_NAME;
        [cell.contentView addSubview:name];
        
        UIButton *tap = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(230, 10, 80, 35);
        tap.frame = frame;
        [tap setTitle:@"Tap" forState:UIControlStateNormal];
        [tap setTitle:@"Tap" forState:UIControlStateHighlighted];
        [tap addTarget:self action:@selector(tapDat:) forControlEvents:UIControlEventTouchUpInside];
        [tap setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tap setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        tap.tag = BEER_TAP;
        [cell.contentView addSubview:tap];
    }
    
    UILabel *name = (UILabel *)[cell viewWithTag:BEER_NAME];
    name.text = [[_venue objectForKey:@"beers"] objectAtIndex:indexPath.row];
    
    cell.tag = indexPath.row;
    
    return cell;
}

-(IBAction)tapDat:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [btn setTitle:@"Tapped" forState:UIControlStateNormal];
    [btn setTitle:@"Tapped" forState:UIControlStateHighlighted];
    [btn setTitle:@"Tapped" forState:UIControlStateDisabled];
}

@end
