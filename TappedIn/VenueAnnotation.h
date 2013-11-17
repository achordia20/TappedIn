//
//  VenueAnnotation.h
//  TappedIn
//
//  Created by Abhinav Chordia on 11/17/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#import <Foundation/Foundation.h>s
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface VenueAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString * title;
@property (nonatomic) NSInteger index;

@end
