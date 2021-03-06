//
//  EventsViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "EventsViewController.h"
#import "EventDetailsViewController.h"
#import "DetailsCell.h"
#import "Event.h"
#import <Parse/Parse.h>
#import <MaterialComponents/MaterialActivityIndicator.h>

#pragma mark -

@interface EventsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableSet *userTags;
@property (strong, nonatomic) NSMutableArray *recommendedEvents;
@property (strong, nonatomic) MDCActivityIndicator *activityIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;

@end

#pragma mark -

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureActivityIndicator];
    [self configureLayoutConstraints];
    
    self.eventsTableView.delegate = self;
    self.eventsTableView.dataSource = self;
    
    [self configureRefreshControl];
    [self fetchEvents];
    
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

/** Configure UIRefreshControl for the table view.
 */
- (void)configureRefreshControl {
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.eventsTableView addSubview:self.refreshControl];
    [self.eventsTableView sendSubviewToBack:self.refreshControl];
}

#pragma mark - Utilities

/** Returns the amount of overlapping tags between the given NSArray and the user's tags.
 
 @param tags The NSArray of NSString tags.
 */
- (NSNumber *)computeOverlap:(NSArray *)tags {
    int count = 0;
    
    for (NSString *tag in tags) {
        if ([self.userTags containsObject:tag]) {
            count += 1;
        }
    }
    
    return [NSNumber numberWithInt:count];
}

/** Begins refreshing the content.
 */
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchEvents];
}

#pragma mark - Parse

/** Fetch events from the Parse database.
*/
- (void)fetchEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query orderByDescending:@"createdAt"];
    [query includeKeys:@[@"name", @"startDate", @"endDate", @"location",  @"author", @"info", @"tags"]];
    query.limit = 20;
    
    [self.refreshControl endRefreshing];
    [self.activityIndicator startAnimating];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (events != nil) {
            self.events = (NSMutableArray *) events;
            
            [self fetchRecommendedEvents];
        } else {
            //TODO: IMPLEMENT ERROR HANDLING
            [self.activityIndicator stopAnimating];
        }
    }];
    
}

/** Fetch recommended events for the current user.
 */
- (void)fetchRecommendedEvents {
    PFRelation *userEvents = [PFUser.currentUser relationForKey:@"events"];
    PFQuery *query = [userEvents query];
    [query includeKeys:@[@"name", @"startDate", @"endDate", @"location", @"author", @"info", @"tags"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (error) {
            //TODO: IMPLEMENT ERROR HANDLING
        }
        else {
            self.userTags = [NSMutableSet new];
            for (Event *event in events) {
                for (NSString *tag in event.tags) {
                    [self.userTags addObject:tag];
            
                }
            }
            
            NSMutableArray *unjoinedEvents = [NSMutableArray new];
            for (Event *event in self.events) {
                if (![events containsObject:event]) {
                    [unjoinedEvents addObject:event];
                }
            }
            
            NSMutableArray *overlaps = [NSMutableArray arrayWithCapacity:unjoinedEvents.count];
            for (Event *event in unjoinedEvents) {
                [overlaps addObject:[self computeOverlap:event.tags]];
            }
            
            NSMutableArray *rankedEvents = [[unjoinedEvents sortedArrayUsingComparator:^NSComparisonResult(id event1, id event2) {
                NSUInteger index1 = [unjoinedEvents indexOfObject:event1];
                NSUInteger index2 = [unjoinedEvents indexOfObject:event2];
                NSNumber *overlap1 = [overlaps objectAtIndex:index1];
                NSNumber *overlap2 = [overlaps objectAtIndex:index2];
                
                return [overlap2 compare:overlap1];
            }] mutableCopy];
            
            if (rankedEvents.count > 3) {
                NSRange tail = NSMakeRange(3, rankedEvents.count - 3);
                [rankedEvents removeObjectsInRange:tail];
            }
            
            self.recommendedEvents = rankedEvents;
            
            [self.eventsTableView reloadData];
        }
        
        [self.activityIndicator stopAnimating];
    }];
    
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DetailsCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"detailsCell"];
    
    Event *event = (indexPath.section == 0) ? self.recommendedEvents[indexPath.row] : self.events[indexPath.row];
    [cell setEvent:event];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? self.recommendedEvents.count : self.events.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Recommended Events" : @"All Events";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"detailSegue" sender:cell];
    
    [self.eventsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        EventDetailsViewController *controller = (EventDetailsViewController *) segue.destinationViewController;
        
        DetailsCell *cell = (DetailsCell *)sender;
        controller.event = cell.event;
    }
}

/** Creates an unwind segue to this view controller.

@param unwindSegue The unwind segue called.
*/
- (IBAction)unwindToEvents:(UIStoryboardSegue *)unwindSegue {
    
}

@end
