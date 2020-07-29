//
//  EventDetailsViewController.m
//  Event Times
//
//  Created by David Lara on 7/28/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "ActivityDetailsViewController.h"
#import "DetailsCell.h"

@interface EventDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *activities;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagsLabel;
@property (strong, nonatomic) IBOutlet UITableView *activitiesTableView;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self displayDetails];
    
    self.activitiesTableView.delegate = self;
    self.activitiesTableView.dataSource = self;
    [self fetchActivitiesForEvent];
    
}

#pragma mark - Utilities

#pragma mark - Setup

/**
 */
- (void)displayDetails {
    self.nameLabel.text = self.event.name;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    
    NSString *dates = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:self.event.startDate], [dateFormatter stringFromDate:self.event.endDate]];
    self.dateLabel.text = dates;
    
    self.locationLabel.text = self.event.location.name;
    self.infoLabel.text = self.event.info;
    self.tagsLabel.text = [self.event.tags componentsJoinedByString:@","];
    
}

#pragma mark - Parse

/**
 */
- (void)fetchActivitiesForEvent {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query orderByDescending:@"createdAt"];
    [query includeKeys:@[@"name", @"startDate", @"endDate", @"location",  @"author", @"info", @"tags"]];
    [query whereKey:@"event" equalTo:self.event];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (activities != nil) {
            self.activities = (NSMutableArray *) activities;
            
            [self.activitiesTableView reloadData];
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DetailsCell *cell = [self.activitiesTableView dequeueReusableCellWithIdentifier:@"detailsCell"];
    
    Activity *activity = self.activities[indexPath.row];
    [cell setActivity:activity];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activities.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Activities";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"activitySegue" sender:cell];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"activitySegue"]) {
        DetailsCell *cell = (DetailsCell *)sender;
        NSIndexPath *indexPath = [self.activitiesTableView indexPathForCell:cell];
        
        ActivityDetailsViewController *controller = (ActivityDetailsViewController *) segue.destinationViewController;
        
        Activity *activity = self.activities[indexPath.row];
        controller.activity = activity;
    }

}

@end
