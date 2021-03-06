//
//  EventCreationViewController.m
//  Event Times
//
//  Created by David Lara on 7/16/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "EventCreationViewController.h"
#import "ActivityCreationViewController.h"
#import "LocationSearchViewController.h"
#import "TagsViewController.h"
#import "Event.h"
#import "Activity.h"
#import "DetailData.h"
#import "TextInputCell.h"
#import "DateCell.h"
#import "LocationCell.h"
#import "DatePickerCell.h"
#import "ActivityCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <MaterialComponents/MaterialActivityIndicator.h>

static NSString *activityCellId = @"activityCell";
static NSString *addActivityCellId = @"addActivityCell";
static NSString *dateCellId = @"dateCell";
static NSString *datePickerId = @"datePicker";
static NSString *locationCellId = @"locationCell";
static NSString *textInputCellId = @"textInputCell";
static NSString *basicCellId = @"basicCell";

#pragma mark -

@interface EventCreationViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *activitiesArray;
@property (strong, nonatomic) NSArray *detailsArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSIndexPath *editedActivityIndexPath;
@property (strong, nonatomic) MDCActivityIndicator *activityIndicator;

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;

@end

#pragma mark -

@implementation EventCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureActivityIndicator];
    [self configureLayoutConstraints];
    
    self.locationManager.delegate = self;
    [self.locationManager requestLocation];
    CLLocation *userLocation = [self.locationManager location];
    if (userLocation == nil) {
        userLocation = [[CLLocation alloc] initWithLatitude:37.4530 longitude:-122.1817];
    }
    MKPlacemark *userPlacemark = [[MKPlacemark alloc] initWithCoordinate:userLocation.coordinate];

    
    if (self.event == nil) {
        self.event = [Event new];
        self.event.startDate = [NSDate date];
        self.event.endDate = [NSDate date];
        Placemark *newPlacemark = [Placemark new];
        [newPlacemark setWithPlacemark:userPlacemark];
        self.event.location = newPlacemark;
        
        self.activitiesArray = [@[] mutableCopy];
    }
    else {
        [self fetchActivitiesForEvent];
    }

    self.detailsArray = [self createEventDataArray];

    
    self.eventTableView.delegate = self;
    self.eventTableView.dataSource = self;
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    
}

#pragma mark - UI Setup

/** Configure MDCActivityIndicator and add to view.
 */
- (void)configureActivityIndicator {
    self.activityIndicator = [MDCActivityIndicator new];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.cycleColors = @[UIColor.blackColor];
    [self.activityIndicator sizeToFit];
    [self.view addSubview:self.activityIndicator];
    
}

/** Configure Auto Layout constraints for the view.
 */
- (void)configureLayoutConstraints {
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray new];
    
    //Activity Indicator Constraints
    NSLayoutConstraint *centerXIndicatorConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    [constraints addObject:centerXIndicatorConstraint];
    
    NSLayoutConstraint *centerYIndicatorConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
    [constraints addObject:centerYIndicatorConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark - Utilities

/** Determines whether index path corresponds to the date picker's index path.
 
 @param indexPath The indexPath to check if it has a date picker.
 */
- (BOOL)indexPathHasDatePicker:(NSIndexPath *)indexPath {
    return self.datePickerIndexPath != nil && self.datePickerIndexPath.row == indexPath.row;
}

/** Updates the date picker with the date of the cell above it.
 */
- (void)updateDatePicker {
    if (self.datePickerIndexPath != nil) {
        UITableViewCell *datePickerCell = [self.eventTableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *datePicker = (UIDatePicker *)[datePickerCell viewWithTag:99];
        if (datePicker != nil) {
            DetailData *dateData = self.detailsArray[self.datePickerIndexPath.row - 1];
            NSDate *date = dateData.data;
            [datePicker setDate:date animated:NO];
        }
    }
    
}

#pragma mark - Parse

/** Saves Activity objects from the activities array to the Parse database.
 */
- (void)saveActivities {
    for (Activity *activity in self.activitiesArray) {
        activity.event = self.event;
        
        [activity saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
            if (succeded) {
                
            }
            else {
                //TODO: IMPLEMENT ERROR HANDLING
            }
        }];
    }
    
    [self.activityIndicator stopAnimating];
    
}

/** Fetch activities corresponding to the event being edited from the Parse database.
 */
- (void)fetchActivitiesForEvent {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query orderByDescending:@"createdAt"];
    [query includeKeys:@[@"name", @"startDate", @"endDate", @"location",  @"author", @"info", @"tags"]];
    [query whereKey:@"event" equalTo:self.event];
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:1];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (activities != nil) {
            self.activitiesArray = (NSMutableArray *) activities;
            
            [self.eventTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

#pragma mark - UITableViewDataSource

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
            
            DetailData *detailData = self.detailsArray[arrayRow];
            
            switch(detailData.detailType) {
                case Name: {
                    TextInputCell *eventNameCell = [self.eventTableView dequeueReusableCellWithIdentifier:textInputCellId];
                    eventNameCell.placeholder = @"Event Name";
                    if (detailData.data != nil) {
                        eventNameCell.textView.text = detailData.data;
                    }
                    cell = eventNameCell;
                    break;
                }
                case StartDate: {
                    DateCell *startDateCell = [self.eventTableView dequeueReusableCellWithIdentifier:dateCellId];
                    startDateCell.textLabel.text = @"Start Date";
                    NSDate *date = detailData.data;
                    startDateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
                    cell = startDateCell;
                    break;
                }
                case EndDate: {
                    DateCell *endDateCell = [self.eventTableView dequeueReusableCellWithIdentifier:dateCellId];
                    endDateCell.textLabel.text = @"End Date";
                    NSDate *date = detailData.data;
                    endDateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
                    cell = endDateCell;
                    break;
                }
                case Location: {
                    LocationCell *locationCell = [self.eventTableView dequeueReusableCellWithIdentifier:locationCellId];
                    Placemark *placemark = detailData.data;
                    locationCell.detailTextLabel.text = placemark.name;
                    cell = locationCell;
                    break;
                }
                case Info: {
                    TextInputCell *infoCell = [self.eventTableView dequeueReusableCellWithIdentifier:textInputCellId];
                    infoCell.placeholder = @"Info";
                    if (detailData.data != nil) {
                        infoCell.textView.text = detailData.data;
                    }
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
            
            ActivityCell *activityCell = [self.eventTableView dequeueReusableCellWithIdentifier:activityCellId];
            activityCell.textLabel.text = activity.name;
            
            cell = activityCell;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return (self.datePickerIndexPath != nil) ? self.detailsArray.count + 1 : self.detailsArray.count;
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

/** Display date picker below the given index path.
 
 @param indexPath The index path to display the date picker under.
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

/** Returns an array containing DetailData objects corresponding to the event details.
 */
- (NSArray<DetailData *> *)createEventDataArray {
    DetailData *name = [DetailData new];
    name.data = self.event.name;
    name.detailType = Name;
    
    DetailData *startDate = [DetailData new];
    startDate.data = self.event.startDate;
    startDate.detailType = StartDate;
    
    DetailData *endDate = [DetailData new];
    endDate.data = self.event.endDate;
    endDate.detailType = EndDate;
    
    DetailData *location = [DetailData new];
    location.data = self.event.location;
    location.detailType = Location;
    
    DetailData *info = [DetailData new];
    info.data = self.event.info;
    info.detailType = Info;
    
    DetailData *tags = [DetailData new];
    tags.data = self.event.tags;
    tags.detailType = Tags;
    
    NSArray *tableData = @[name, startDate, endDate, location, info, tags];
    return tableData;
}


#pragma mark - UITableViewDelegate

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
    else if ([cell.reuseIdentifier isEqualToString:addActivityCellId] || [cell.reuseIdentifier isEqualToString:activityCellId]) {
        [self performSegueWithIdentifier:@"activityCreationSegue" sender:cell];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Actions

/** User changed the date in the UIDatePicker.
 
 @param sender The UIDatePicker attached to the DatePickerCell.
 */
- (IBAction)changedDate:(id)sender {
    NSIndexPath *dateCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
    DateCell *cell = [self.eventTableView cellForRowAtIndexPath:dateCellIndexPath];
    UIDatePicker *datePicker = sender;
    
    DetailData *date = self.detailsArray[dateCellIndexPath.row];
    date.data = datePicker.date;
    
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
    
}

/** User chose to create/edit the event by pressing the "Save" button.
 
 @param sender The "Save" UIButton.
 */
- (IBAction)onCreatePress:(id)sender {
    [self.activityIndicator startAnimating];
    
    self.event.author = [PFUser currentUser];
    
    for (DetailData *detailData in self.detailsArray) {
        
        switch (detailData.detailType) {
            case Name: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:Name inSection:0];
                TextInputCell *textInputCell = [self.eventTableView cellForRowAtIndexPath:indexPath];
                self.event.name = textInputCell.textView.text;
                break;
            }
            case StartDate: {
                self.event.startDate = detailData.data;
                break;
            }
            case EndDate: {
                self.event.endDate = detailData.data;
                break;
            }
            case Location: {
                self.event.location = detailData.data;
                break;
            }
            case Info: {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:Info inSection:0];
                TextInputCell *textInputCell = [self.eventTableView cellForRowAtIndexPath:indexPath];
                self.event.info = textInputCell.textView.text;
                break;
            }
            case Tags: {
                self.event.tags = detailData.data;
                break;
            }
        }
    }

    [self.event saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (succeded) {
            [self saveActivities];
            [self performSegueWithIdentifier:@"unwindToEvents" sender:nil];
        }
        else {
            //TODO: IMPLEMENT ERROR HANDLING
        }
    }];

}

/** User chose to remove activity by pressing the "X" button on the activity's corresponding cell.
 
 @param sender The "X" UIButton.
 */
- (IBAction)onRemovePress:(id)sender {
    CGPoint buttonPoint = [sender convertPoint:CGPointZero toView:self.eventTableView];
    NSIndexPath *buttonIndexPath = [self.eventTableView indexPathForRowAtPoint:buttonPoint];
    
    Activity *removedActivity = self.activitiesArray[buttonIndexPath.row - 1];
    [self.activitiesArray removeObject:removedActivity];
    
    [self.eventTableView beginUpdates];
    
    [self.eventTableView deleteRowsAtIndexPaths:@[buttonIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.eventTableView endUpdates];
    
}

- (IBAction)onTapGesture:(id)sender {
    [self.view endEditing:YES];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"tagsSegue"]) {
        if (self.event.tags != nil) {
            UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
            TagsViewController *controller = (TagsViewController *) navigationController.topViewController;
            
            controller.selectedTags = [[NSSet setWithArray:self.event.tags] mutableCopy];
        }
    }
    else if ([[segue identifier] isEqualToString:@"activityCreationSegue"]) {
        ActivityCell *cell = (ActivityCell *)sender;
        NSIndexPath *indexPath = [self.eventTableView indexPathForCell:cell];
        if (indexPath.row != 0) {
            self.editedActivityIndexPath = indexPath;
            
            UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
            ActivityCreationViewController *controller = (ActivityCreationViewController *) navigationController.topViewController;
            
            Activity *activity = self.activitiesArray[indexPath.row - 1];
            controller.activity = activity;
        }
    }
    
}

/** Unwinds to the events view controller.

 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindToEvents:(UIStoryboardSegue *)unwindSegue {
    
}

/** Unwinds from the activity creation view controller and adds the created activity to the activities table.
 
 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindFromActivityCreation:(UIStoryboardSegue *)unwindSegue {
    ActivityCreationViewController *sender = unwindSegue.sourceViewController;
    if (sender.activity != nil) {
        if (sender.editingActivity) {
            [self.activitiesArray setObject:sender.activity atIndexedSubscript:self.editedActivityIndexPath.row - 1];
            
            [self.eventTableView reloadRowsAtIndexPaths:@[self.editedActivityIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            Activity *newActivity = sender.activity;
            
            [self.activitiesArray addObject:newActivity];
            
            [self.eventTableView beginUpdates];
            
            NSIndexPath *newActivityIndexPath = [NSIndexPath indexPathForRow:self.activitiesArray.count inSection:1];
            [self.eventTableView insertRowsAtIndexPaths:@[newActivityIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.eventTableView endUpdates];
        }
    }
    
}

/** Unwinds from the location view controller and sets the location of the event.
 
 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindFromLocation:(UIStoryboardSegue *)unwindSegue {
    LocationSearchViewController *sender = unwindSegue.sourceViewController;
    MKMapItem *mapItem = sender.mapItem;
    
    Placemark *newLocation = [Placemark new];
    [newLocation setWithPlacemark:mapItem.placemark];
    
    DetailData *location = self.detailsArray[Location];
    location.data = newLocation;
    
    NSIndexPath *locationIndexPath = [NSIndexPath indexPathForRow:Location inSection:0];

    [self.eventTableView reloadRowsAtIndexPaths:@[locationIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

/** Unwinds from the location view controller and sets the tags of the event.

@param unwindSegue The unwind segue called.
*/
- (IBAction)unwindFromTags:(UIStoryboardSegue *)unwindSegue {
    TagsViewController *sender = unwindSegue.sourceViewController;
    
    DetailData *tags = self.detailsArray[Tags];
    tags.data = [sender.selectedTags allObjects];
    
}

@end
