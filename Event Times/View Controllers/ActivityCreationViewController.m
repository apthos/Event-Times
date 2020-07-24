//
//  ActivityCreationViewController.m
//  Event Times
//
//  Created by David Lara on 7/24/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "ActivityCreationViewController.h"
#import "EventCreationViewController.h"
#import "LocationSearchViewController.h"
#import "Activity.h"
#import "DetailData.h"
#import "TextInputCell.h"
#import "DateCell.h"
#import "LocationCell.h"
#import "DatePickerCell.h"
#import "ActivityCell.h"
#import <MapKit/MapKit.h>

static NSString *activityCellId = @"activityCell";
static NSString *addActivityCellId = @"addActivityCell";
static NSString *dateCellId = @"dateCell";
static NSString *datePickerId = @"datePicker";
static NSString *locationCellId = @"locationCell";
static NSString *textInputCellId = @"textInputCell";
static NSString *basicCellId = @"basicCell";

#pragma mark -

@interface ActivityCreationViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *detailsArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UITableView *activityTableView;

- (IBAction)onCreatePress:(id)sender;
- (IBAction)onCancelPress:(id)sender;

@end

#pragma mark -

@implementation ActivityCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager.delegate = self;
    [self.locationManager requestLocation];
    CLLocation *userLocation = [self.locationManager location];
    if (userLocation == nil) {
        userLocation = [[CLLocation alloc] initWithLatitude:37.4530 longitude:-122.1817];
    }
    MKPlacemark *userPlacemark = [[MKPlacemark alloc] initWithCoordinate:userLocation.coordinate];

    self.activity = [Activity new];
    self.activity.startDate = [NSDate date];
    self.activity.endDate = [NSDate date];
    Placemark *newPlacemark = [Placemark new];
    [newPlacemark setWithPlacemark:userPlacemark];
    self.activity.location = newPlacemark;
    
    self.detailsArray = [self createActivityDataArray];
    
    self.activityTableView.delegate = self;
    self.activityTableView.dataSource = self;
    
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
        UITableViewCell *datePickerCell = [self.activityTableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *datePicker = (UIDatePicker *)[datePickerCell viewWithTag:99];
        if (datePicker != nil) {
            DetailData *dateData = self.detailsArray[self.datePickerIndexPath.row - 1];
            NSDate *date = dateData.data;
            [datePicker setDate:date animated:NO];
        }
    }
    
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    if ([self indexPathHasDatePicker:indexPath]) {
        DatePickerCell *datePickerCell = [self.activityTableView dequeueReusableCellWithIdentifier:datePickerId];
        cell = datePickerCell;
    }
    else {
        NSInteger arrayRow = indexPath.row;
        if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row < indexPath.row) {
            arrayRow--;
        }
        
        DetailData *detailData = self.detailsArray[arrayRow];
        
        switch(arrayRow) {
            case Name: {
                TextInputCell *eventNameCell = [self.activityTableView dequeueReusableCellWithIdentifier:textInputCellId];
                eventNameCell.placeholder = @"Event Name";
                if (detailData.data != nil) {
                    eventNameCell.textView.text = detailData.data;
                }
                cell = eventNameCell;
                break;
            }
            case StartDate: {
                DateCell *startDateCell = [self.activityTableView dequeueReusableCellWithIdentifier:dateCellId];
                startDateCell.textLabel.text = @"Start Date";
                NSDate *date = detailData.data;
                startDateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
                cell = startDateCell;
                break;
            }
            case EndDate: {
                DateCell *endDateCell = [self.activityTableView dequeueReusableCellWithIdentifier:dateCellId];
                endDateCell.textLabel.text = @"End Date";
                NSDate *date = detailData.data;
                endDateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
                cell = endDateCell;
                break;
            }
            case Location: {
                LocationCell *locationCell = [self.activityTableView dequeueReusableCellWithIdentifier:locationCellId];
                Placemark *placemark = detailData.data;
                locationCell.detailTextLabel.text = placemark.name;
                cell = locationCell;
                break;
            }
            case Info: {
                TextInputCell *infoCell = [self.activityTableView dequeueReusableCellWithIdentifier:textInputCellId];
                infoCell.placeholder = @"Info";
                if (detailData.data != nil) {
                    infoCell.textView.text = detailData.data;
                }
                cell = infoCell;
                break;
            }
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.datePickerIndexPath != nil) ? self.detailsArray.count + 1 : self.detailsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([self indexPathHasDatePicker:indexPath]) ? 216 : self.activityTableView.rowHeight;
}

/**
 */
- (void)displayDatePicker:(NSIndexPath *)indexPath {
    [self.activityTableView beginUpdates];
    
    BOOL datePickerBelow = NO;
    
    if (self.datePickerIndexPath != nil) {
        datePickerBelow = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL clickedSameCell = self.datePickerIndexPath.row - 1 == indexPath.row;
      
    if (self.datePickerIndexPath != nil) {
        [self.activityTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    
    if (!clickedSameCell) {
        NSInteger rowBefore = (datePickerBelow ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathBefore = [NSIndexPath indexPathForRow:rowBefore inSection:0];
        
        [self.activityTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPathBefore.row + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathBefore.row + 1 inSection:0];
    }
    
    [self.activityTableView endUpdates];
    
    [self updateDatePicker];
    
}

- (NSArray<DetailData *> *)createActivityDataArray {
    DetailData *name = [DetailData new];
    name.data = self.activity.name;
    name.detailType = Name;
    
    DetailData *startDate = [DetailData new];
    startDate.data = self.activity.startDate;
    startDate.detailType = StartDate;
    
    DetailData *endDate = [DetailData new];
    endDate.data = self.activity.endDate;
    endDate.detailType = EndDate;
    
    DetailData *location = [DetailData new];
    location.data = self.activity.location;
    location.detailType = Location;
    
    DetailData *info = [DetailData new];
    info.data = self.activity.info;
    info.detailType = Info;
    
    NSArray *tableData = @[name, startDate, endDate, location, info];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Actions

/**
 */
- (IBAction)changedDate:(id)sender {
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
    DateCell *cell = [self.activityTableView cellForRowAtIndexPath:dateCellIndexPath];
    UIDatePicker *datePicker = sender;
    
    DetailData *date = self.detailsArray[dateCellIndexPath.row];
    date.data = datePicker.date;
    
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
    
}

/**
 */
- (IBAction)onCancelPress:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromActivityCreation" sender:self];
    
}

/**
 */
- (IBAction)onCreatePress:(id)sender {
    for (DetailData *detailData in self.detailsArray) {
        switch (detailData.detailType) {
            case Name: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:Name inSection:0];
                TextInputCell *textInputCell = [self.activityTableView cellForRowAtIndexPath:indexPath];
                self.activity.name = textInputCell.textView.text;
                break;
            }
            case StartDate: {
                self.activity.startDate = detailData.data;
                break;
            }
            case EndDate: {
                self.activity.endDate = detailData.data;
                break;
            }
            case Location: {
                self.activity.location = detailData.data;
                break;
            }
            case Info: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:Info inSection:0];
                TextInputCell *textInputCell = [self.activityTableView cellForRowAtIndexPath:indexPath];
                self.activity.info = textInputCell.textView.text;
                break;
            }
            case Tags: {
                break;
            }
        }
    }
    
    [self performSegueWithIdentifier:@"unwindFromActivityCreation" sender:self];
    
}

#pragma mark - Navigation

/**
 */
- (IBAction)unwindFromActivityCreation:(UIStoryboardSegue *)unwindSegue {
    
}

/**
 */
- (IBAction)unwindFromLocation:(UIStoryboardSegue *)unwindSegue {
    LocationSearchViewController *sender = unwindSegue.sourceViewController;
    MKMapItem *mapItem = sender.mapItem;
    
    Placemark *newLocation = [Placemark new];
    [newLocation setWithPlacemark:mapItem.placemark];
    
    DetailData *location = self.detailsArray[Location];
    location.data = newLocation;
    
    NSIndexPath *locationIndexPath = [NSIndexPath indexPathForRow:Location inSection:0];
    UITableViewCell *locationCell = [self.activityTableView cellForRowAtIndexPath:locationIndexPath];
    locationCell.detailTextLabel.text = newLocation.name;
    
}

@end
