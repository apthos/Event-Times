//
//  Placemark.h
//  Event Times
//
//  Created by David Lara on 7/14/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Placemark : PFObject<PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *country;


@end

NS_ASSUME_NONNULL_END
