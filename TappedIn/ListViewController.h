//
//  ListViewController.h
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ListViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSMutableArray *beers;
@property (strong, nonatomic) NSMutableArray *bars;
@property (strong, nonatomic) CLLocation *userLocation;

@end
