//
//  EventCell.m
//  Event Times
//
//  Created by David Lara on 7/21/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "DetailsCell.h"
#import "Event.h"

@implementation DetailsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setters

- (void)setEvent:(Event *)event {
    _event = event;
    
    self.nameLabel.text = event.name;
    self.locationLabel.text = event.location.name;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    
    NSString *dates = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:event.startDate], [dateFormatter stringFromDate:event.endDate]];
    self.datesLabel.text = dates;
}

- (void)setActivity:(Activity *)activity {
    _activity = activity;
    
    self.nameLabel.text = activity.name;
    self.locationLabel.text = activity.location.name;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    
    NSString *dates = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:activity.startDate], [dateFormatter stringFromDate:activity.endDate]];
    self.datesLabel.text = dates;
}

@end
