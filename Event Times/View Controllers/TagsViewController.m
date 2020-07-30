//
//  TagsViewController.m
//  Event Times
//
//  Created by David Lara on 7/23/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "TagsViewController.h"

#pragma mark -

@interface TagsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *tags;

@property (strong, nonatomic) IBOutlet UITableView *tagsTableView;

- (IBAction)onCancelPress:(id)sender;
- (IBAction)onDonePress:(id)sender;

@end

#pragma mark -

@implementation TagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tags = @[@"One",@"Two",@"Three"];
    
    if (self.selectedTags == nil) {
        self.selectedTags = [NSMutableSet new];
    }
    
    self.tagsTableView.delegate = self;
    self.tagsTableView.dataSource = self;
    
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tagsTableView dequeueReusableCellWithIdentifier:@"tagCell"];
    
    NSString *tag = self.tags[indexPath.row];
    cell.textLabel.text = tag;

    if ([self.selectedTags containsObject:tag]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tags.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tagsTableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedTags removeObject:cell.textLabel.text];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedTags addObject:cell.textLabel.text];
    }
    
    [self.tagsTableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Actions

/** User chose to cancel editing the tags of the event by "Cancel" UIButton.

@param sender The "Cancel" UIButton.
*/
- (IBAction)onCancelPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/** User chose to finish editing the tags of the event by "Done" UIButton.

@param sender The "Done" UIButton.
*/
- (IBAction)onDonePress:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromTags" sender:self];
    
}

#pragma mark - Navigation

/** Creates an unwind segue from this view controller.
 
 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindFromTags:(UIStoryboardSegue *)unwindSegue {
    
}


@end
