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

#pragma mark -

@interface EventsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *events;

@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;

@end

#pragma mark -

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.eventsTableView.delegate = self;
    self.eventsTableView.dataSource = self;
    
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
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (events != nil) {
            self.events = (NSMutableArray *) events;
            
            [self.eventsTableView reloadData];
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DetailsCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"detailsCell"];
    
    Event *event = self.events[indexPath.row];
    [cell setEvent:event];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"detailSegue" sender:cell];
    
    [self.eventsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        EventDetailsViewController *controller = (EventDetailsViewController *) segue.destinationViewController;
        
        DetailsCell *cell = (DetailsCell *)sender;
        NSIndexPath *indexPath = [self.eventsTableView indexPathForCell:cell];
        Event *event = self.events[indexPath.row];
        
        controller.event = event;
    }
}

/** Creates an unwind segue to this view controller.

@param unwindSegue The unwind segue called.
*/
- (IBAction)unwindToEvents:(UIStoryboardSegue *)unwindSegue {
    
}

@end
