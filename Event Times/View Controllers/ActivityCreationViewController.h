//
//  ActivityCreationViewController.h
//  Event Times
//
//  Created by David Lara on 7/24/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActivityCreationViewController : UIViewController

@property (strong, nonatomic) Activity *activity;
@property (assign, nonatomic) BOOL editingActivity;

@end

NS_ASSUME_NONNULL_END
