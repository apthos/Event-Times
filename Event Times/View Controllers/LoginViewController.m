//
//  LoginViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <MaterialComponents/MaterialTextFields.h>
#import <MaterialComponents/MaterialButtons.h>
#import <MaterialComponents/MaterialSnackbar.h>
#import <MaterialComponents/MaterialActivityIndicator.h>

#pragma mark -

@interface LoginViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) MDCTextInputControllerFilled *usernameController;
@property (strong, nonatomic) MDCTextInputControllerFilled *passwordController;
@property (strong, nonatomic) MDCTextField *usernameField;
@property (strong, nonatomic) MDCTextField *passwordField;
@property (strong, nonatomic) MDCButton *loginButton;
@property (strong, nonatomic) MDCButton *signUpButton;
@property (strong, nonatomic) MDCActivityIndicator *activityIndicator;

- (IBAction)onLoginPress:(id)sender;
- (IBAction)onSignUpPress:(id)sender;
- (IBAction)onScreenTap:(id)sender;

@end

#pragma mark -

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTitle];
    [self configureTextFields];
    [self configureButtons];
    [self configureLayoutConstraints];
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

/** Configure MDCButtons and add to view.
 */
- (void)configureButtons {
    self.loginButton = [[MDCButton alloc] initWithFrame:CGRectZero];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(onLoginPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    self.signUpButton = [MDCButton new];
    self.signUpButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(onSignUpPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signUpButton];
    
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
    
    //Password Text Field Constraints
    NSLayoutConstraint *topPasswordConstraint = [NSLayoutConstraint constraintWithItem:self.passwordField  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.usernameField attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    [constraints addObject:topPasswordConstraint];
    
    NSLayoutConstraint *centerXPasswordConstraint = [NSLayoutConstraint constraintWithItem:self.passwordField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    [constraints addObject:centerXPasswordConstraint];
    
    NSArray<NSLayoutConstraint *> *horizontalPasswordConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[password]-|" options:0 metrics:nil views:@{@"password" : self.passwordField}];
    [constraints addObjectsFromArray:horizontalPasswordConstraints];
    
    //Login/Sign Up Buttons Constraints
    NSLayoutConstraint *topLoginConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordField attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
    [constraints addObject:topLoginConstraint];
    
    NSLayoutConstraint *centerButtonsContraint = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.signUpButton attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
    [constraints addObject:centerButtonsContraint];
    
    NSArray<NSLayoutConstraint *> *horizontalButtonConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[login]-[signup]-|" options:0 metrics:nil views:@{@"login": self.loginButton, @"signup": self.signUpButton}];
    [constraints addObjectsFromArray:horizontalButtonConstraints];
    
    //Activity Indicator Constraints
    NSLayoutConstraint *centerXIndicatorConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    [constraints addObject:centerXIndicatorConstraint];
    
    NSLayoutConstraint *centerYIndicatorConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
    [constraints addObject:centerYIndicatorConstraint];
    
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
    
    UIFont *titleFont = [UIFont fontWithName:@"Menlo-Regular" size:48];
    [self.titleLabel setFont:titleFont];
    self.titleLabel.text = @"Event Times";
    [self.titleLabel sizeToFit];
    
    [self.view addSubview:self.titleLabel];
}

#pragma mark - Parse

/** Logs user into the Parse database with the user input from text fields.
 */
- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [self.activityIndicator startAnimating];
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError * error) {
        [self.activityIndicator stopAnimating];
        
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
