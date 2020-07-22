//
//  EventCell.m
//  Event Times
//
//  Created by David Lara on 7/21/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "EventCell.h"
#import "Event.h"

@implementation EventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEvent:(Event *)event {
    _event = event;
    
    self.nameLabel.text = event.name;
    self.locationLabel.text = event.location.name;
    
    NSString *dates = [NSString stringWithFormat:@"%@ - %@", event.startDate.description, event.endDate.description];
    self.datesLabel.text = dates;
}

@end
