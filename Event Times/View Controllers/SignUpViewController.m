//
//  SignUpViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

#pragma mark -

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)onSignUpPress:(id)sender;
- (IBAction)onScreenTap:(id)sender;

@end

#pragma mark -

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Parse

/** Creates a new user in the Parse database using the user input from text fields.
 */
- (void)registerUser {
    PFUser *newUser = [PFUser new];
    
    newUser.username = self.usernameField.text;
    newUser.email = self.emailField.text;
    newUser.password = self.passwordField.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self performSegueWithIdentifier:@"unwindToLogin" sender:nil];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
            
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error During Signup" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [errorAlert addAction:okAction];
            
            [self presentViewController:errorAlert animated:YES completion:nil];
        }
    }];
    
}

#pragma mark - Actions

/** User chose to end editing by tapping on the background view.
 
 @param sender The UITapGestureRecognizer attached to the background view.
 */
- (IBAction)onScreenTap:(id)sender {
    [self.view endEditing:YES];

}

/** User chose to sign up with the provided information by pressing the "Sign Up" button.
 
 @param sender The "Sign Up" UIButton.
 */
- (IBAction)onSignUpPress:(id)sender {
    if ([self.usernameField.text isEqualToString:@""] || [self.emailField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""]) {
        UIAlertController *emptyFieldAlert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"Missing username, email or password." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [emptyFieldAlert addAction:okAction];
        
        [self presentViewController:emptyFieldAlert animated:YES completion:nil];    }
    else {
        [self registerUser];
    }
    
}

#pragma mark - Navigation

/** Unwinds to the login view controller.
 
 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue {
    
}

@end
