//
//  Activity.m
//  Event Times
//
//  Created by David Lara on 7/14/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "Activity.h"

@implementation Activity

@dynamic author;
@dynamic name;
@dynamic startDate;
@dynamic endDate;
@dynamic info;
@dynamic location;
@dynamic participants;
@dynamic event;

- (instancetype)initWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate info:(NSString *)info location:(Placemark *)location event:(Event *)event {
    self = [super init];
    if (self) {
        self.author = [PFUser currentUser];
        self.name = name;
        self.startDate = startDate;
        self.endDate = endDate;
        self.info = info;
        self.location = location;
        self.event = event;
        
    }
    
    return self;
}

+ (nonnull NSString *)parseClassName {
    return @"Activity";
}

@end
