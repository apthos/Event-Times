//
//  Event.m
//  Event Times
//
//  Created by David Lara on 7/14/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "Event.h"

#pragma mark -

@implementation Event

@dynamic author;
@dynamic name;
@dynamic startDate;
@dynamic endDate;
@dynamic info;
@dynamic location;
@dynamic tags;
@dynamic participants;

#pragma mark - NSObject

- (BOOL)isEqual:(Event *)otherEvent {
    return [self.objectId isEqual:otherEvent.objectId];
}

#pragma mark - PFSubclassing

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

@end
