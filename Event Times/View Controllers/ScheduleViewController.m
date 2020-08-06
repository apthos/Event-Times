//
//  ScheduleViewController.m
//  Event Times
//
//  Created by David Lara on 7/29/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ActivityDetailsViewController.h"
#import "Activity.h"
#import "DetailsCell.h"
#import <MaterialComponents/MaterialActivityIndicator.h>

#pragma mark -

@interface ScheduleViewController () <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSMutableArray *activities;
@property (strong, nonatomic) MDCActivityIndicator *activityIndicator;

@property (strong, nonatomic) IBOutlet UITableView *activitiesTableView;

@end

#pragma mark -

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureActivityIndicator];
    [self configureLayoutConstraints];
    
    self.activitiesTableView.delegate = self;
    self.activitiesTableView.dataSource = self;
    
    [self fetchActivities];
    
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

#pragma mark - Parse

/** Fetch activities for the current user from the Parse database.
*/
- (void)fetchActivities {
    PFRelation *activities = [PFUser.currentUser relationForKey:@"activities"];
    PFQuery *query = activities.query;
    [query orderByDescending:@"createdAt"];
    [query includeKeys:@[@"name", @"startDate", @"endDate", @"location",  @"author", @"info", @"tags"]];
    query.limit = 20;
    
    [self.activityIndicator startAnimating];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        [self.activityIndicator stopAnimating];
        
        if (activities != nil) {
            NSArray *sortedActivities = [activities sortedArrayUsingComparator:^NSComparisonResult(id activityOne, id activityTwo) {
                NSDate *dateOne = [(Activity *) activityOne startDate];
                NSDate *dateTwo = [(Activity *) activityTwo startDate];
                return [dateOne compare:dateTwo];
            }];
            self.activities = [sortedActivities mutableCopy];
            
            [self.activitiesTableView reloadData];
            
        } else {
            //TODO: IMPLEMENT ERROR HANDLING
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"detailSegue" sender:cell];
    
    [self.activitiesTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        ActivityDetailsViewController *controller = (ActivityDetailsViewController *) segue.destinationViewController;
        
        DetailsCell *cell = (DetailsCell *)sender;
        NSIndexPath *indexPath = [self.activitiesTableView indexPathForCell:cell];
        Activity *activity = self.activities[indexPath.row];
        
        controller.activity = activity;
    }
}

/** Unwinds from the activity details view controller and removes the activity if the user is no longer a participant.
 
 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindFromActivityDetails:(UIStoryboardSegue *)unwindSegue {
    
    ActivityDetailsViewController *sender = unwindSegue.sourceViewController;
    
    if (!sender.participant) {
        Activity *activity = sender.activity;
        
        [self.activities removeObject:activity];
        [self.activitiesTableView reloadData];
        
    }
    
}

@end
