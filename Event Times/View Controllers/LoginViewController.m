//
//  LoginViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

- (IBAction)onLoginPress:(id)sender;
- (IBAction)onSignUpPress:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onSignUpPress:(id)sender {
    [self performSegueWithIdentifier:@"signUpSegue" sender:nil];
}

- (IBAction)onLoginPress:(id)sender {
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
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
