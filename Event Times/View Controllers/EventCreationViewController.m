//
//  EventCreationViewController.m
//  Event Times
//
//  Created by David Lara on 7/16/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "EventCreationViewController.h"
#import "LocationSearchViewController.h"
#import "Event.h"
#import "EventData.h"
#import "TextInputCell.h"
#import "DateCell.h"
#import "LocationCell.h"
#import "DatePickerCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static NSString *activityCell = @"activityCell";
static NSString *addActivityCellId = @"addActivityCell";
static NSString *dateCellId = @"dateCell";
static NSString *datePickerId = @"datePicker";
static NSString *locationCellId = @"locationCell";
static NSString *textInputCellId = @"textInputCell";

#pragma mark -

@interface EventCreationViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) Event *event;

@property (strong, nonatomic) NSMutableArray *activitiesArray;
@property (strong, nonatomic) NSArray *detailsArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
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

    self.event = [Event new];
    self.event.startDate = [NSDate date];
    self.event.endDate = [NSDate date];
    Placemark *newPlacemark = [Placemark new];
    [newPlacemark setWithPlacemark:userPlacemark];
    self.event.location = newPlacemark;
    
    self.detailsArray = [self createEventDataArray];
    
    self.eventTableView.delegate = self;
    self.eventTableView.dataSource = self;
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    
}


#pragma mark - Utilities

/**
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath {
    BOOL hasDate = NO;
    
    if (indexPath.section == 0 && (indexPath.row == StartDate || indexPath.row == EndDate)) {
        hasDate = YES;
    }
    
    return hasDate;
}

/**
 */
- (BOOL)indexPathHasDatePicker:(NSIndexPath *)indexPath {
    return self.datePickerIndexPath != nil && self.datePickerIndexPath.row == indexPath.row;
}

/**
 */
- (BOOL)indexPathHasLocation:(NSIndexPath *)indexPath {
    BOOL hasLocation = NO;
    
    if (indexPath.section == 0 && indexPath.row == Location) {
        hasLocation = YES;
    }
    
    return hasLocation;
}

/**
 */
- (BOOL)indexPathHasString:(NSIndexPath *)indexPath {
    BOOL hasString = NO;
    
    if (indexPath.section == 0 && (indexPath.row == EventName || indexPath.row == Info)) {
        hasString = YES;
    }
    
    return hasString;
}

/**
 */
- (NSString *)cellIdForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"";
    
    if ([self indexPathHasDate:indexPath]) {
        cellId = dateCellId;
    }
    
    if ([self indexPathHasString:indexPath]) {
        cellId = textInputCellId;
    }
    
    if ([self indexPathHasLocation:indexPath]) {
        cellId = locationCellId;
    }
    
    if ([self indexPathHasDatePicker:indexPath]) {
        cellId = datePickerId;
    }
    
    return cellId;
}

/**
 */
- (void)updateDatePicker {
    if (self.datePickerIndexPath != nil) {
        UITableViewCell *datePickerCell = [self.eventTableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *datePicker = (UIDatePicker *)[datePickerCell viewWithTag:99];
        if (datePicker != nil) {
            EventData *eventData = self.detailsArray[self.datePickerIndexPath.row - 1];
            NSDate *date = eventData.data;
            [datePicker setDate:date animated:NO];
        }
    }
    
}

#pragma mark - UITableViewDataSource

/**
 */
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row == indexPath.row) {
            DatePickerCell *cell = [self.eventTableView dequeueReusableCellWithIdentifier:datePickerId];
            return cell;
        }
        else {
            NSInteger arrayRow = indexPath.row;
            if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row < indexPath.row) {
                arrayRow--;
            }
            
            EventData *eventData = self.detailsArray[arrayRow];
            
            switch(arrayRow) {
                case EventName: {
                    TextInputCell *cell = [self.eventTableView dequeueReusableCellWithIdentifier:textInputCellId];
                    cell.placeholder = @"Event Name";
                    return cell;
                }
                case StartDate: {
                    DateCell *cell = [self.eventTableView dequeueReusableCellWithIdentifier:dateCellId];
                    cell.textLabel.text = @"Start Date";
                    NSDate *date = eventData.data;
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
                    return cell;
                }
                case EndDate: {
                    DateCell *cell = [self.eventTableView dequeueReusableCellWithIdentifier:dateCellId];
                    cell.textLabel.text = @"End Date";
                    NSDate *date = eventData.data;
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
                    return cell;
                }
                case Location: {
                    LocationCell *cell = [self.eventTableView dequeueReusableCellWithIdentifier:locationCellId];
                    Placemark *placemark = eventData.data;
                    cell.detailTextLabel.text = placemark.name;
                    return cell;
                }
                case Info: {
                    TextInputCell *cell = [self.eventTableView dequeueReusableCellWithIdentifier:textInputCellId];
                    cell.placeholder = @"Info";
                    return cell;
                }
            }
        }
        
        UITableViewCell *cell = [UITableViewCell new];
        return cell;
    }
    else {
        //TODO: IMPLEMENT ACTIVITY CELLS IN SECTION 1
        UITableViewCell *cell = [self.eventTableView dequeueReusableCellWithIdentifier:@""];
        return cell;
    }
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

- (NSArray<EventData *> *)createEventDataArray {
    EventData *name = [EventData new];
    name.data = self.event.name;
    name.detailType = EventName;
    
    EventData *startDate = [EventData new];
    startDate.data = self.event.startDate;
    startDate.detailType = StartDate;
    
    EventData *endDate = [EventData new];
    endDate.data = self.event.endDate;
    endDate.detailType = EndDate;
    
    EventData *location = [EventData new];
    location.data = self.event.location;
    location.detailType = Location;
    
    EventData *info = [EventData new];
    info.data = self.event.info;
    info.detailType = Info;
    
    NSArray *tableData = @[name, startDate, endDate, location, info];
    return tableData;
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

/**
 */
- (IBAction)changedDate:(id)sender {
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
    DateCell *cell = [self.eventTableView cellForRowAtIndexPath:dateCellIndexPath];
    UIDatePicker *datePicker = sender;
    
    EventData *date = self.detailsArray[dateCellIndexPath.row];
    date.data = datePicker.date;
    
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
    
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
        
        Placemark *newLocation = [Placemark new];
        [newLocation setWithPlacemark:mapItem.placemark];
        
        EventData *location = self.detailsArray[Location];
        location.data = newLocation;
        
        NSIndexPath *locationIndexPath = [NSIndexPath indexPathForRow:Location inSection:0];
        UITableViewCell *locationCell = [self.eventTableView cellForRowAtIndexPath:locationIndexPath];
        locationCell.detailTextLabel.text = newLocation.name;
    }
    
}

@end
