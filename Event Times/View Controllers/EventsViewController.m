//
//  EventsViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "EventsViewController.h"
#import "EventCell.h"
#import "Event.h"

#import "EventCreationViewController.h"

@interface EventsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *events;

@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;

@end

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.eventsTableView.delegate = self;
    self.eventsTableView.dataSource = self;
    
    [self fetchEvents];
    
}

#pragma mark - Parse

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
    EventCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"eventCell"];
    
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
    
    [self performSegueWithIdentifier:@"eventEdit" sender:cell];
    
    [self.eventsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"eventEdit"]) {
        EventCell *cell = (EventCell *)sender;
        NSIndexPath *indexPath = [self.eventsTableView indexPathForCell:cell];
        if (indexPath.row != 0) {
            UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
            EventCreationViewController *controller = (EventCreationViewController *) navigationController.topViewController;
            
            Event *event = self.events[indexPath.row];
            controller.event = event;
        }
    }
}

- (IBAction)unwindToEvents:(UIStoryboardSegue *)sender {
    
}

@end
