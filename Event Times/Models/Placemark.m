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

- (instancetype)initWithPlacemark:(MKPlacemark *)placemark {
    self = [super init];
    
    if (self) {
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
    
    return self;
}

+ (nonnull NSString *)parseClassName {
    return @"Placemark";
}

@end
