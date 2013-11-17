//
//  InitialViewController.m
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#import "InitialViewController.h"
#import "BarsViewController.h"

@interface InitialViewController ()
{
    NSString *type;
}

@end

@implementation InitialViewController
{
    
}

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
    self.title = @"Tapped In";
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)gotToBars:(id)sender {
    type = @"Bars";
}

- (IBAction)goToBeers:(id)sender {
    type = @"Beers";
}

@end
