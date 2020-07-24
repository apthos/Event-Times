//
//  EventCreationViewController.h
//  Event Times
//
//  Created by David Lara on 7/16/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, Details) {
    Name,
    StartDate,
    EndDate,
    Location,
    Info,
    Tags
};

@interface EventCreationViewController : UIViewController

@property (strong, nonatomic) Event *event;

@end

NS_ASSUME_NONNULL_END
