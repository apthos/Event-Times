//
//  EventCreationViewController.m
//  Event Times
//
//  Created by David Lara on 7/16/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "EventCreationViewController.h"
#import "LocationSearchViewController.h"
#import "TagsViewController.h"
#import "Event.h"
#import "Activity.h"
#import "EventData.h"
#import "TextInputCell.h"
#import "DateCell.h"
#import "LocationCell.h"
#import "DatePickerCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static NSString *activityCellId = @"activityCell";
static NSString *addActivityCellId = @"addActivityCell";
static NSString *dateCellId = @"dateCell";
static NSString *datePickerId = @"datePicker";
static NSString *locationCellId = @"locationCell";
static NSString *textInputCellId = @"textInputCell";
static NSString *basicCellId = @"basicCell";

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
    if (self.activitiesArray == nil) {
        self.activitiesArray = [@[] mutableCopy];
    }
    
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
- (BOOL)indexPathHasDatePicker:(NSIndexPath *)indexPath {
    return self.datePickerIndexPath != nil && self.datePickerIndexPath.row == indexPath.row;
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
    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.section == 0) {
        if ([self indexPathHasDatePicker:indexPath]) {
            DatePickerCell *datePickerCell = [self.eventTableView dequeueReusableCellWithIdentifier:datePickerId];
            cell = datePickerCell;
        }
        else {
            NSInteger arrayRow = indexPath.row;
            if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row < indexPath.row) {
                arrayRow--;
            }
            
            EventData *eventData = self.detailsArray[arrayRow];
            
            switch(arrayRow) {
                case EventName: {
                    TextInputCell *eventNameCell = [self.eventTableView dequeueReusableCellWithIdentifier:textInputCellId];
                    eventNameCell.placeholder = @"Event Name";
                    cell = eventNameCell;
                    break;
                }
                case StartDate: {
                    DateCell *startDateCell = [self.eventTableView dequeueReusableCellWithIdentifier:dateCellId];
                    startDateCell.textLabel.text = @"Start Date";
                    NSDate *date = eventData.data;
                    startDateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
                    cell = startDateCell;
                    break;
                }
                case EndDate: {
                    DateCell *endDateCell = [self.eventTableView dequeueReusableCellWithIdentifier:dateCellId];
                    endDateCell.textLabel.text = @"End Date";
                    NSDate *date = eventData.data;
                    endDateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
                    cell = endDateCell;
                    break;
                }
                case Location: {
                    LocationCell *locationCell = [self.eventTableView dequeueReusableCellWithIdentifier:locationCellId];
                    Placemark *placemark = eventData.data;
                    locationCell.detailTextLabel.text = placemark.name;
                    cell = locationCell;
                    break;
                }
                case Info: {
                    TextInputCell *infoCell = [self.eventTableView dequeueReusableCellWithIdentifier:textInputCellId];
                    infoCell.placeholder = @"Info";
                    cell = infoCell;
                    break;
                }
                case Tags: {
                    UITableViewCell *tagsCell = [self.eventTableView dequeueReusableCellWithIdentifier:basicCellId];
                    tagsCell.textLabel.text = @"Tags";
                    tagsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell = tagsCell;
                    break;
                }
            }
        }
    }
    else {
        if (indexPath.row == 0) {
            cell = [self.eventTableView dequeueReusableCellWithIdentifier:addActivityCellId];
        }
        else {
            Activity *activity = self.activitiesArray[indexPath.row - 1];
            
            cell.textLabel.text = activity.name;
        }
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
        return self.activitiesArray.count + 1;
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

/**
 */
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Details" : @"Activities";
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
    
    EventData *tags = [EventData new];
    info.data = self.event.tags;
    info.detailType = Tags;
    
    NSArray *tableData = @[name, startDate, endDate, location, info, tags];
    return tableData;
}

#pragma mark - UITableViewDelegate

/**
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.reuseIdentifier isEqualToString:dateCellId]) {
        [self displayDatePicker:indexPath];
    }
    else if ([cell.reuseIdentifier isEqualToString:locationCellId]) {
        [self performSegueWithIdentifier:@"locationSegue" sender:nil];
    }
    else if ([cell.reuseIdentifier isEqualToString:basicCellId]) {
        [self performSegueWithIdentifier:@"tagsSegue" sender:nil];
    }
    else if ([cell.reuseIdentifier isEqualToString:addActivityCellId]) {
        
    }
    else if ([cell.reuseIdentifier isEqualToString:activityCellId]) {
        
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
    else if ([unwindSegue.sourceViewController isKindOfClass:[TagsViewController class]]) {
        TagsViewController *sender = unwindSegue.sourceViewController;
        
        EventData *tags = self.detailsArray[Tags];
        tags.data = sender.selectedTags;
    }
    
}

@end
