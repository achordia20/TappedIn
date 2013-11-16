//
//  Venues.h
//  TappedIn
//
//  Created by Abhinav Chordia on 11/16/13.
//  Copyright (c) 2013 Abhinav Chordia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Venues : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *venueId;
@property (strong, nonatomic) NSString *type; // Bar or Brewery or Anything Else
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSString *address;

@end
