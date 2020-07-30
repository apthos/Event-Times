//
//  ActivityDetailsViewController.h
//  Event Times
//
//  Created by David Lara on 7/29/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActivityDetailsViewController : UIViewController

@property (strong, nonatomic) Activity *activity;
@property (assign, nonatomic) BOOL participant;

@end

NS_ASSUME_NONNULL_END
