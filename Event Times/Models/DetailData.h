//
//  EventData.h
//  Event Times
//
//  Created by David Lara on 7/22/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCreationViewController.h"

NS_ASSUME_NONNULL_BEGIN


@interface DetailData : NSObject

@property (assign, nonatomic) Details detailType;
@property (strong, nonatomic) id data;

@end

NS_ASSUME_NONNULL_END
