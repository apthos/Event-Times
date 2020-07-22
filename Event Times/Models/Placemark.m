//
//  Placemark.m
//  Event Times
//
//  Created by David Lara on 7/14/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "Placemark.h"
#import <MapKit/MapKit.h>

@implementation Placemark

@dynamic name;
@dynamic location;
@dynamic street;
@dynamic city;
@dynamic state;
@dynamic postalCode;
@dynamic country;

#pragma mark - Setters

- (void)setWithPlacemark:(MKPlacemark *)placemark {
    self.name = placemark.name;
    
    self.location = [[PFGeoPoint alloc] init];
    self.location.latitude = placemark.location.coordinate.latitude;
    self.location.longitude = placemark.location.coordinate.longitude;
    
    self.street = placemark.thoroughfare;
    self.city = placemark.locality;
    self.state = placemark.administrativeArea;
    self.postalCode = placemark.postalCode;
    self.country = placemark.country;
    
}

#pragma mark - PFSubclassing

+ (nonnull NSString *)parseClassName {
    return @"Placemark";
}

@end
