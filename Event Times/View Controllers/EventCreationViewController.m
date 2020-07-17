//
//  EventCreationViewController.m
//  Event Times
//
//  Created by David Lara on 7/16/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "EventCreationViewController.h"
#import "Event.h"
#import "LocationSearchViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static NSString *activityCell = @"activityCell";
static NSString *addActivityCellId = @"addActivityCell";
static NSString *dateCellId = @"dateCell";
static NSString *datePickerId = @"datePicker";
static NSString *locationCellId = @"locationCell";
static NSString *textFieldCellId = @"textFieldCell";

#pragma mark -

@interface EventCreationViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *activitiesArray;
@property (strong, nonatomic) NSArray *detailsArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;

@end

#pragma mark -

@implementation EventCreationViewController

/**
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager.delegate = self;
    [self.locationManager requestLocation];
    CLLocation *userLocation = [self.locationManager location];
    if (userLocation == nil) {
        userLocation = [[CLLocation alloc] initWithLatitude:37.4530 longitude:-122.1817];
    }
    MKPlacemark *userPlacemark = [[MKPlacemark alloc] initWithCoordinate:userLocation.coordinate];
    
    self.eventTableView.delegate = self;
    self.eventTableView.dataSource = self;
    
    
    NSMutableDictionary *eventName = [@{@"title" : @"Event Name", @"text" : @""} mutableCopy];
    NSMutableDictionary *location = [@{@"title" : @"Location", @"location" : userPlacemark} mutableCopy];
    NSMutableDictionary *startDate = [@{@"title" : @"Start Date", @"date" : [NSDate date]} mutableCopy];
    NSMutableDictionary *endDate = [@{@"title" : @"End Date", @"date" : [NSDate date]} mutableCopy];
    self.detailsArray = @[eventName, startDate, endDate, location];
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    
}



#pragma mark - Utilities

- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath {
    BOOL hasDate = NO;
    
    if (indexPath.section == 0 && [self.detailsArray[indexPath.row] valueForKey:@"date"] != nil) {
        hasDate = YES;
    }
    
    return hasDate;
}

- (BOOL)indexPathHasDatePicker:(NSIndexPath *)indexPath {
    return self.datePickerIndexPath != nil && self.datePickerIndexPath.row == indexPath.row;
}

- (BOOL)indexPathHasLocation:(NSIndexPath *)indexPath {
    BOOL hasLocation = NO;
    
    if (indexPath.section == 0 && [self.detailsArray[indexPath.row] valueForKey:@"location"] != nil) {
        hasLocation = YES;
    }
    
    return hasLocation;
}

- (BOOL)indexPathHasString:(NSIndexPath *)indexPath {
    BOOL hasString = NO;
    
    if (indexPath.section == 0 && [self.detailsArray[indexPath.row] valueForKey:@"text"] != nil) {
        hasString = YES;
    }
    
    return hasString;
}

- (NSString *)cellIdForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"";
    
    if ([self indexPathHasDate:indexPath]) {
        cellId = dateCellId;
    }
    
    if ([self indexPathHasString:indexPath]) {
        cellId = textFieldCellId;
    }
    
    if ([self indexPathHasLocation:indexPath]) {
        cellId = locationCellId;
    }
    
    if ([self indexPathHasDatePicker:indexPath]) {
        cellId = datePickerId;
    }
    
    return cellId;
}

- (void)updateDatePicker {
    if (self.datePickerIndexPath != nil) {
        UITableViewCell *datePickerCell = [self.eventTableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *datePicker = (UIDatePicker *)[datePickerCell viewWithTag:100];
        if (datePicker != nil) {
            NSDictionary *dateObject = self.detailsArray[self.datePickerIndexPath.row - 1];
            [datePicker setDate:[dateObject valueForKey:@"date"] animated:NO];
        }
        
        
    }
}


#pragma mark - Navigation

/**
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

/**
 */
- (IBAction)unwindToEvents:(UIStoryboardSegue *)unwindSegue {
    
}

/**
 */
- (IBAction)unwindToEventCreation:(UIStoryboardSegue *)unwindSegue {
    if ([unwindSegue.sourceViewController isKindOfClass:[LocationSearchViewController class]]) {
        LocationSearchViewController *sender = unwindSegue.sourceViewController;
        MKMapItem *mapItem = sender.mapItem;
        NSInteger locationRow = 3;

        NSMutableDictionary *locationObject = self.detailsArray[locationRow];
        [locationObject setValue:mapItem forKey:@"location"];
        
        NSIndexPath *locationIndexPath = [NSIndexPath indexPathForRow:locationRow inSection:0];
        UITableViewCell *locationCell = [self.eventTableView cellForRowAtIndexPath:locationIndexPath];
        locationCell.detailTextLabel.text = mapItem.name;
    }
}

#pragma mark - UITableViewDataSource

/**
 */
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellId = [self cellIdForIndexPath:indexPath];
    UITableViewCell *cell = [self.eventTableView dequeueReusableCellWithIdentifier:cellId];
    
    if (indexPath.section == 0) {
        NSInteger arrayRow = indexPath.row;
        if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row <= indexPath.row) {
            arrayRow--;
        }
        
        NSDictionary *detailObject = self.detailsArray[arrayRow];
        
        if ([cellId isEqualToString:textFieldCellId]) {
            cell.textLabel.text = [detailObject valueForKey:@"title"];
            
        }
        else if ([cellId isEqualToString:locationCellId]) {
            cell.textLabel.text = [detailObject valueForKey:@"title"];
            cell.detailTextLabel.text = [[detailObject valueForKey:@"location"] name];
        }
        else if ([cellId isEqualToString:dateCellId]) {
            cell.textLabel.text = [detailObject valueForKey:@"title"];
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[detailObject valueForKey:@"date"]];
        }
    }
    else {
        //TODO: IMPLEMENT ACTIVITY CELLS IN SECTION 1
    }
    
    return cell;
}

/**
 */
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.datePickerIndexPath != nil) {
            return self.detailsArray.count + 1;
        }
        return self.detailsArray.count;
    }
    else {
        return self.activitiesArray.count;
    }
    
}

/**
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([self indexPathHasDatePicker:indexPath]) ? 216 : self.eventTableView.rowHeight;
}

/**
 */
- (void)displayDatePicker:(NSIndexPath *)indexPath {
    [self.eventTableView beginUpdates];
    
    BOOL datePickerBelow = NO;
    
    if (self.datePickerIndexPath != nil) {
        datePickerBelow = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL clickedSameCell = self.datePickerIndexPath.row - 1 == indexPath.row;
      
    if (self.datePickerIndexPath != nil) {
        [self.eventTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
        
    }
    
    if (!clickedSameCell) {
        NSInteger rowBefore = (datePickerBelow ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathBefore = [NSIndexPath indexPathForRow:rowBefore inSection:0];
        
        [self.eventTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPathBefore.row + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathBefore.row + 1 inSection:0];
        
    }
    
    [self.eventTableView endUpdates];
    
    [self updateDatePicker];
    
}

#pragma mark - UITableViewDelegate

/**
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == dateCellId) {
        [self displayDatePicker:indexPath];
    }
    else if (cell.reuseIdentifier == locationCellId) {
        [self performSegueWithIdentifier:@"locationSegue" sender:nil];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Actions

- (IBAction)changedDate:(id)sender {
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
    UITableViewCell *cell = [self.eventTableView cellForRowAtIndexPath:dateCellIndexPath];
    UIDatePicker *datePicker = sender;
    
    NSMutableDictionary *dateObject = self.detailsArray[dateCellIndexPath.row];
    [dateObject setValue:datePicker.date forKey:@"date"];
    
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
    
}


@end
