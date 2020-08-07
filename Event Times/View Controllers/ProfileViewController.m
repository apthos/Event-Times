//
//  ProfileViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "EventDetailsViewController.h"
#import "EventCreationViewController.h"
#import "SceneDelegate.h"
#import "DetailsCell.h"
#import "Event.h"
#import <MaterialComponents/MaterialActivityIndicator.h>

@import Parse;

#pragma mark -

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) MDCActivityIndicator *activityIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;

- (IBAction)onLogoutPress:(id)sender;

@end

#pragma mark -

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureActivityIndicator];
    [self configureLayoutConstraints];
    
    UITapGestureRecognizer *photoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoTap:)];
    [self.profileImageView addGestureRecognizer:photoTapRecognizer];
    [self.profileImageView setUserInteractionEnabled:YES];
    
    [self displayUserDetails];
    
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

/** Begins refreshing the content.
 */
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchEvents];
}

/** Resizes the given UIImage to the given CGSize.
 
 @param image The UIImage to resize.
 @param size The CGSize of the new UIImage.
 */
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Setup

/** Displays the current user's information.
 */
- (void)displayUserDetails {
    self.usernameLabel.text = PFUser.currentUser.username;
    self.emailLabel.text = PFUser.currentUser.email;
    
    PFFileObject *imageFile = [PFUser.currentUser objectForKey:@"profileImage"];
    
    if (imageFile != nil) {
        self.profileImageView.file = imageFile;
        [self.profileImageView loadInBackground];
    }
    
}

#pragma mark - Parse

/** Deletes the given event from the database and reloads the table view.
 
 @param event The Event to delete.
 */
- (void)deleteEvent:(Event *)event {
    [self.activityIndicator startAnimating];
    
    [event deleteInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        [self.activityIndicator stopAnimating];
        
        if (succeded) {
            [self fetchEvents];
        }
    }];
}

/** Fetch users' events from the Parse database.
*/
- (void)fetchEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"author" equalTo:PFUser.currentUser];
    [query orderByDescending:@"createdAt"];
    [query includeKeys:@[@"name", @"startDate", @"endDate", @"location",  @"author", @"info", @"tags"]];
    query.limit = 20;
    
    [self.refreshControl endRefreshing];
    [self.activityIndicator startAnimating];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        [self.activityIndicator stopAnimating];
        
        if (events != nil) {
            self.events = (NSMutableArray *) events;
            
            [self.eventsTableView reloadData];
            
        }
        else {
            //TODO: IMPLEMENT ERROR HANDLING
        }
    }];
    
}

/** Saves the given UIImage in the database as the profile picture for the current user.
 
 @param image The UIImage to upload to database.
 */
- (void)saveProfileImage:(UIImage *)image {
    UIImage *resizedPhoto = [self resizeImage:image withSize:CGSizeMake(1000.0, 1000.0)];
    NSData *imageData = UIImagePNGRepresentation(resizedPhoto);
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
    
    [self.activityIndicator startAnimating];
    
    [PFUser.currentUser setObject:imageFile forKey:@"profileImage"];
    [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        [self.activityIndicator stopAnimating];
        
        if (succeded) {
            self.profileImageView.file = imageFile;
            [self.profileImageView loadInBackground];
        }
    }];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    [self saveProfileImage:editedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"My Events";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"detailSegue" sender:cell];
    
    [self.eventsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

/** User chose to manage an event by long pressing on the UITableViewCell representing the event.
 
 @param gestureRecognizer The UILongPressGestureRecognizer that was interacted with.
 */
- (IBAction)onCellHold:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint pointHeld = [gestureRecognizer locationInView:self.eventsTableView];
        
        NSIndexPath *indexPath = [self.eventsTableView indexPathForRowAtPoint:pointHeld];
        if (indexPath != nil) {
            DetailsCell *cell = [self.eventsTableView cellForRowAtIndexPath:indexPath];
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Manage Event" message:cell.event.name preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self performSegueWithIdentifier:@"eventCreationSegue" sender:cell];
            }];
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                [self deleteEvent:cell.event];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
            
            [actionSheet addAction:editAction];
            [actionSheet addAction:deleteAction];
            [actionSheet addAction:cancelAction];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        }
    }

}

/** User chose to edit the profile picture by tapping on the profile picture UIImageView.
 
 @param gestureRecognizer The UITapGestureRecognizer that was interacted with.
 */
- (IBAction)onPhotoTap:(UITapGestureRecognizer *)gestureRecognizer {
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

/** User chose to logout by pressing the "Logout" button.

@param sender The "Logout" UIButton
*/
- (IBAction)onLogoutPress:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error During Logout" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [errorAlert addAction:okAction];
            
            [self presentViewController:errorAlert animated:YES completion:nil];
        }
        else {
            SceneDelegate *sceneDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            
            sceneDelegate.window.rootViewController = loginViewController;
        }
    }];
    
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
    else if ([[segue identifier] isEqualToString:@"eventCreationSegue"]) {
        DetailsCell *cell = (DetailsCell *)sender;
        NSIndexPath *indexPath = [self.eventsTableView indexPathForCell:cell];
        
        UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
        EventCreationViewController *controller = (EventCreationViewController *) navigationController.topViewController;
        
        Event *event = self.events[indexPath.row];
        controller.event = event;
    }
    
}

@end
