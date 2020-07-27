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

#pragma mark - PFSubclassing

+ (nonnull NSString *)parseClassName {
    return @"Activity";
}

@end
