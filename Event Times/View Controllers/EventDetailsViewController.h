//
//  EventDetailsViewController.h
//  Event Times
//
//  Created by David Lara on 7/28/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventDetailsViewController : UIViewController

@property (strong, nonatomic) Event *event;

@end

NS_ASSUME_NONNULL_END
