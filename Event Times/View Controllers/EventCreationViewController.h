//
//  EventCreationViewController.h
//  Event Times
//
//  Created by David Lara on 7/16/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, Details) {
    EventName,
    StartDate,
    EndDate,
    Location,
    Info,
    Tags
};

@interface EventCreationViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
