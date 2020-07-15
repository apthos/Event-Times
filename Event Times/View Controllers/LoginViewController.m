//
//  LoginViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)onLoginPress:(id)sender;
- (IBAction)onSignUpPress:(id)sender;
- (IBAction)onScreenTap:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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

- (IBAction)onScreenTap:(id)sender {
    [self.view endEditing:YES];
    
}

- (IBAction)onSignUpPress:(id)sender {
    [self performSegueWithIdentifier:@"signUpSegue" sender:nil];
    
}

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

- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
