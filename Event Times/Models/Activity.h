//
//  Activity.h
//  Event Times
//
//  Created by David Lara on 7/14/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <Parse/Parse.h>
#import "Event.h"
#import "Placemark.h"

NS_ASSUME_NONNULL_BEGIN

@interface Activity : PFObject<PFSubclassing>

@property (strong, nonatomic) PFUser *author;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) Placemark *location;
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) PFRelation *participants;

@end

NS_ASSUME_NONNULL_END
