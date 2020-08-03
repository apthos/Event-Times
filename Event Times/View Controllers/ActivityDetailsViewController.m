//
//  ActivityDetailsViewController.m
//  Event Times
//
//  Created by David Lara on 7/29/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "ActivityDetailsViewController.h"

#pragma mark -

@interface ActivityDetailsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *joinButton;

- (IBAction)onJoinPress:(id)sender;

@end

#pragma mark -

@implementation ActivityDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self displayDetails];
    [self checkIfUserIsParticipant];
    
}
 
#pragma mark - Setup

/** Displays the details of the activity.
 */
- (void)displayDetails {
    self.nameLabel.text = self.activity.name;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeZone: [NSTimeZone systemTimeZone]];
    
    NSString *dates = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:self.activity.startDate], [dateFormatter stringFromDate:self.activity.endDate]];
    self.dateLabel.text = dates;
    
    self.locationLabel.text = self.activity.location.name;
    self.infoLabel.text = self.activity.info;
    
}

#pragma mark - Parse

/** Determines if the user is a participant of the displayed activity.
 */
- (void)checkIfUserIsParticipant {
    PFRelation *participants = self.activity.participants;
    PFQuery *query = [participants query];
    [query whereKey:@"objectId" equalTo:PFUser.currentUser.objectId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            self.participant = YES;
            self.joinButton.title = @"Leave";
        }
        else {
            self.participant = NO;
            self.joinButton.title = @"Join";
        }
    }];
    
}

/** Determines if the user is a participant of the given Event.
 */
- (void)checkIfUserAttendsEvent:(Event *)event {
    PFRelation *userActivities = [PFUser.currentUser relationForKey:@"activities"];
    PFQuery *query = [userActivities query];
    [query whereKey:@"event" equalTo:event];
    
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (error) {
            //TODO: IMPLEMENT ERROR HANDLING
        }
        else {
            if (count == 1) {
                [self addUserToEvent:event];
            }
            else  if (count == 0){
                [self removeUserFromEvent:event];
            }
        }
    }];
    
}

/** Adds the current user to the given Event in the database.
 */
- (void)addUserToEvent:(Event *)event {
    PFRelation *userEvents = [PFUser.currentUser relationForKey:@"events"];
    PFRelation *eventParticipants = [event relationForKey:@"participants"];
    
    [eventParticipants addObject:PFUser.currentUser];
    [userEvents addObject:event];
    
    [event saveInBackground];
    [PFUser.currentUser saveInBackground];
}

/** Removes the current user to the given Event in the database.
 */
- (void)removeUserFromEvent:(Event *)event {
    PFRelation *userEvents = [PFUser.currentUser relationForKey:@"events"];
    PFRelation *eventParticipants = [event relationForKey:@"participants"];
    
    [eventParticipants removeObject:PFUser.currentUser];
    [userEvents removeObject:event];
    
    [event saveInBackground];
    [PFUser.currentUser saveInBackground];
}

#pragma mark - Actions

/** User chose to join/leave the activity by pressing the "Join"/"Leave" button.

@param sender The "Join"/"Leave" UIButton.
  */
- (IBAction)onJoinPress:(id)sender {
    PFRelation *userActivities = [PFUser.currentUser relationForKey:@"activities"];
    PFRelation *activityParticipants = [self.activity relationForKey:@"participants"];
    
    if (self.participant) {
        self.participant = NO;
        self.joinButton.title = @"Join";
        [activityParticipants removeObject:PFUser.currentUser];
        [userActivities removeObject:self.activity];
        
    }
    else {
        self.participant = YES;
        self.joinButton.title = @"Leave";
        [activityParticipants addObject:PFUser.currentUser];
        [userActivities addObject:self.activity];
    }
    
    [self.activity saveInBackground];
    [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self checkIfUserAttendsEvent:self.activity.event];
        [self performSegueWithIdentifier:@"unwindFromActivityDetails" sender:nil];
    }];
    
}

#pragma mark - Navigation

/** Creates an unwind segue from this view controller.
 
 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindFromActivityDetails:(UIStoryboardSegue *)unwindSegue {
    
}

@end
