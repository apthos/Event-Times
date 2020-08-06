//
//  SignUpViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import <MaterialComponents/MaterialTextFields.h>
#import <MaterialComponents/MaterialButtons.h>
#import <MaterialComponents/MaterialSnackbar.h>

#pragma mark -

@interface SignUpViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) MDCTextInputControllerFilled *usernameController;
@property (strong, nonatomic) MDCTextInputControllerFilled *emailController;
@property (strong, nonatomic) MDCTextInputControllerFilled *passwordController;
@property (strong, nonatomic) MDCTextField *usernameField;
@property (strong, nonatomic) MDCTextField *emailField;
@property (strong, nonatomic) MDCTextField *passwordField;
@property (strong, nonatomic) MDCButton *signUpButton;
@property (strong, nonatomic) MDCButton *backButton;

- (IBAction)onSignUpPress:(id)sender;
- (IBAction)onScreenTap:(id)sender;

@end

#pragma mark -

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureTitle];
    [self configureTextFields];
    [self configureButtons];
    [self configureLayoutConstraints];
}

#pragma mark - UI Setup

/** Configure MDCButtons and add to view.
 */
- (void)configureButtons {
    self.signUpButton = [[MDCButton alloc] initWithFrame:CGRectZero];
    self.signUpButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(onSignUpPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signUpButton];
    
    self.backButton = [[MDCButton alloc] initWithFrame:CGRectZero];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(onBackPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
}

/** Configure Auto Layout constraints for the view.
 */
- (void)configureLayoutConstraints {
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray new];
    
    //Title Label Constraints
    NSLayoutConstraint *topTitleConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:self.view.frame.size.height * 0.33];
    [constraints addObject:topTitleConstraint];
    
    NSLayoutConstraint *centerXTitleConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    [constraints addObject:centerXTitleConstraint];
    
    //Username Text Field Constraints
    NSLayoutConstraint *topUsernameConstraint = [NSLayoutConstraint constraintWithItem:self.usernameField  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:24];
    [constraints addObject:topUsernameConstraint];
    
    NSLayoutConstraint *centerXUsernameConstraint = [NSLayoutConstraint constraintWithItem:self.usernameField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    [constraints addObject:centerXUsernameConstraint];
    
    NSArray<NSLayoutConstraint *> *horizontalUsernameConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[username]-|" options:0 metrics:nil views:@{@"username" : self.usernameField}];
    [constraints addObjectsFromArray:horizontalUsernameConstraints];
    
    //Email Text Field Constraints
    NSLayoutConstraint *topEmailConstraint = [NSLayoutConstraint constraintWithItem:self.emailField  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.usernameField attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    [constraints addObject:topEmailConstraint];
    
    NSLayoutConstraint *centerXEmailConstraint = [NSLayoutConstraint constraintWithItem:self.emailField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    [constraints addObject:centerXEmailConstraint];
    
    NSArray<NSLayoutConstraint *> *horizontalEmailConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[email]-|" options:0 metrics:nil views:@{@"email" : self.emailField}];
    [constraints addObjectsFromArray:horizontalEmailConstraints];
    
    //Password Text Field Constraints
    NSLayoutConstraint *topPasswordConstraint = [NSLayoutConstraint constraintWithItem:self.passwordField  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.emailField attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    [constraints addObject:topPasswordConstraint];
    
    NSLayoutConstraint *centerXPasswordConstraint = [NSLayoutConstraint constraintWithItem:self.passwordField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    [constraints addObject:centerXPasswordConstraint];
    
    NSArray<NSLayoutConstraint *> *horizontalPasswordConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[password]-|" options:0 metrics:nil views:@{@"password" : self.passwordField}];
    [constraints addObjectsFromArray:horizontalPasswordConstraints];
    
    //Login/Sign Up Buttons Constraints
    NSLayoutConstraint *topLoginConstraint = [NSLayoutConstraint constraintWithItem:self.signUpButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordField attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    [constraints addObject:topLoginConstraint];
    
    NSLayoutConstraint *centerButtonsContraint = [NSLayoutConstraint constraintWithItem:self.signUpButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.backButton attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
    [constraints addObject:centerButtonsContraint];
    
    NSArray<NSLayoutConstraint *> *horizontalButtonConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[signup]-[back]-|" options:0 metrics:nil views:@{@"signup": self.signUpButton, @"back": self.backButton}];
    [constraints addObjectsFromArray:horizontalButtonConstraints];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

/** Configure MDCTextFields and add to view.
 */
- (void)configureTextFields {
    self.usernameField = [MDCTextField new];
    self.usernameField.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.usernameField];
    
    self.usernameController = [[MDCTextInputControllerFilled alloc] initWithTextInput:self.usernameField];
    self.usernameController.placeholderText = @"Username";
    
    self.emailField = [MDCTextField new];
    self.emailField.translatesAutoresizingMaskIntoConstraints = NO;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.emailField];
    
    self.emailController = [[MDCTextInputControllerFilled alloc] initWithTextInput:self.emailField];
    self.emailController.placeholderText = @"Email";
    
    self.passwordField = [MDCTextField new];
    self.passwordField.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.passwordField];
    
    self.passwordController = [[MDCTextInputControllerFilled alloc] initWithTextInput:self.passwordField];
    self.passwordController.placeholderText = @"Password";
    
}

/** Configure title UILabel and add to view.
 */
- (void)configureTitle {
    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIFont *titleFont = [UIFont fontWithName:@"Menlo-Regular" size:24];
    [self.titleLabel setFont:titleFont];
    self.titleLabel.text = @"Create An Account";
    [self.titleLabel sizeToFit];
    
    [self.view addSubview:self.titleLabel];
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

/** User chose to go back to the previous view controller by pressing the "Back" button.
 
 @param sender The "Back" MDCButton.
 */
- (IBAction)onBackPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** User chose to end editing by tapping on the background view.
 
 @param sender The UITapGestureRecognizer attached to the background view.
 */
- (IBAction)onScreenTap:(id)sender {
    [self.view endEditing:YES];

}

/** User chose to sign up with the provided information by pressing the "Sign Up" button.
 
 @param sender The "Sign Up" MDCButton.
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
