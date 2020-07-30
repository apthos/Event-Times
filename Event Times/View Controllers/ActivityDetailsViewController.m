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

#pragma mark - Actions

/** User chose to join/leave the activity by pressing the "Join"/"Leave" button.

@param sender The "Join"/"Leave" UIButton.
  */
- (IBAction)onJoinPress:(id)sender {
    PFRelation *activityRelation = [self.activity relationForKey:@"participants"];
    PFRelation *userRelation = [PFUser.currentUser relationForKey:@"activities"];
    
    if (self.participant) {
        self.participant = NO;
        self.joinButton.title = @"Join";
        [activityRelation removeObject:PFUser.currentUser];
        [userRelation removeObject:self.activity];
    }
    else {
        self.participant = YES;
        self.joinButton.title = @"Leave";
        [activityRelation addObject:PFUser.currentUser];
        [userRelation addObject:self.activity];
    }
    
    [self.activity saveInBackground];
    [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
