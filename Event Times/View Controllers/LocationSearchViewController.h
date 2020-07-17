//
//  LocationSearchViewController.h
//  Event Times
//
//  Created by David Lara on 7/17/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationSearchViewController : UIViewController

@property (strong, nonatomic) MKMapItem *mapItem;

@end

NS_ASSUME_NONNULL_END
