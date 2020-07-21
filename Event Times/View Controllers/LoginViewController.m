//
//  LoginViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

#pragma mark -

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)onLoginPress:(id)sender;
- (IBAction)onSignUpPress:(id)sender;
- (IBAction)onScreenTap:(id)sender;

@end

#pragma mark -

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Parse

/** Logs user into the Parse database with the user input from text fields.
 */
- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError * error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error During Login" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [errorAlert addAction:okAction];
            
            [self presentViewController:errorAlert animated:YES completion:nil];
        }
        else {
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
    
}

#pragma mark - Actions

/** User chose to login with the provided information by pressing the "Login" button.
 
 @param sender The "Login" UIButton
 */
- (IBAction)onLoginPress:(id)sender {
    if ([self.usernameField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""]) {
        UIAlertController *emptyFieldAlert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"Missing username or password." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [emptyFieldAlert addAction:okAction];
        
        [self presentViewController:emptyFieldAlert animated:YES completion:nil];
    }
    else {
        [self loginUser];
    }
    
}

/** User chose to end editing by tapping on the background view.
 
 @param sender The UITapGestureRecognizer attached to the background view.
 */
- (IBAction)onScreenTap:(id)sender {
    [self.view endEditing:YES];
    
}

/** User chose to head to the sign up view controller by pressing the "Sign Up" button.
 
 @param sender The "Sign Up" UIButton
 */
- (IBAction)onSignUpPress:(id)sender {
    [self performSegueWithIdentifier:@"signUpSegue" sender:nil];
    
}

#pragma mark - Navigation

/** Creates an unwind segue to this view controller.
 
 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue {
    
}

@end
