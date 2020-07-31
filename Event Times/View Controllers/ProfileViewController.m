//
//  ProfileViewController.m
//  Event Times
//
//  Created by David Lara on 7/15/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "ProfileViewController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"

@import Parse;

#pragma mark -

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;

- (IBAction)onLogoutPress:(id)sender;

@end

#pragma mark -

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *photoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoTap:)];
    [self.profileImageView addGestureRecognizer:photoTapRecognizer];
    [self.profileImageView setUserInteractionEnabled:YES];
    
    [self displayUserDetails];
    
}

#pragma mark - Utilities

/**
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

/**
 */
- (void)saveProfileImage:(UIImage *)image {
    UIImage *resizedPhoto = [self resizeImage:image withSize:CGSizeMake(1000.0, 1000.0)];
    NSData *imageData = UIImagePNGRepresentation(resizedPhoto);
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
    
    [PFUser.currentUser setObject:imageFile forKey:@"profileImage"];
    [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (succeded) {
            self.profileImageView.file = imageFile;
            [self.profileImageView loadInBackground];
        }
    }];
}

#pragma mark - UIImagePickerControllerDelegate

/**
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    [self saveProfileImage:editedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Actions

/**
 */
- (IBAction)onPhotoTap:(UITapGestureRecognizer *)tapGestureRecognizer {
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

@end
