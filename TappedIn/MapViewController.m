//
//  MapViewController.m
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#import "MapViewController.h"
#import "VenueAnnotation.h"
#import <Parse/Parse.h>

@interface MapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *location;
}

@end

@implementation MapViewController

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
    _mapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    location = [[CLLocation alloc] initWithLatitude:41.874674 longitude:-87.636566];
    [self setRegionForMap];
    [self annotateMap];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate

- (void)setRegionForMap
{
    CLLocationCoordinate2D cityCoordinate = CLLocationCoordinate2DMake(41.888305, -87.633891);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.015f, 0.015f);
    MKCoordinateRegion region = MKCoordinateRegionMake(cityCoordinate, span);
    [self.mapView setRegion:region animated:YES];
}

-(void)annotateMap
{
    NSInteger bars = [_bars count];
    
    for (int i = 0; i < bars; i++) {
        PFObject *obj = [_bars objectAtIndex:i];
        NSNumber *lat = obj[@"latitude"];
        NSNumber *lon = obj[@"longitude"];
        NSString *venueName = obj[@"name"];
        
        MKCoordinateRegion venAnn = { {0.0, 0.0}, {0.0, 0.0} };
        venAnn.center.latitude = [lat doubleValue];
        venAnn.center.longitude = [lon doubleValue];
        VenueAnnotation *ann = [[VenueAnnotation alloc] init];
        ann.title = venueName;
        ann.coordinate = venAnn.center;
        ann.index = i;
        [self.mapView addAnnotation:ann];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[VenueAnnotation class]]) {
        VenueAnnotation *vAnnotation = annotation;
        
        MKAnnotationView *annView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"venuePin"];
        if (annView == nil) {
            annView = [[MKPinAnnotationView alloc] initWithAnnotation:vAnnotation reuseIdentifier:@"venuePins"];
        }
        
        [annView setCanShowCallout:YES];
        PFObject *venue = [_bars objectAtIndex:vAnnotation.index];
        NSString *count = [NSString stringWithFormat:@"%d", [venue[@"beers"] count]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, 22, 22)];
        [button setTitle:count forState:UIControlStateNormal];
        [button setTitle:count forState:UIControlStateSelected];
        [button addTarget:self action:@selector(goToVenueFromMap:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        button.tag = [(VenueAnnotation *)annotation index];
        [button setBackgroundColor:[UIColor grayColor]];
        
        annView.rightCalloutAccessoryView = button;
        UIImage *img = [UIImage imageNamed:@"map-small"];
        img = [MapViewController drawText:count inImage:img atPoint:CGPointMake(10, 0)];
        
        annView.image = img;
        
        return annView;
    }
    return nil;
}

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:40];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(IBAction)goToVenueFromMap:(id)sender
{
    [[[self parentViewController] parentViewController] performSegueWithIdentifier:@"goToVenue" sender:[_bars objectAtIndex:[(UIButton *)sender tag]]];
}

@end
