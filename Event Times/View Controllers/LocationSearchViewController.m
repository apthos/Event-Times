//
//  LocationSearchViewController.m
//  Event Times
//
//  Created by David Lara on 7/17/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "LocationSearchViewController.h"
#import <MapKit/MapKit.h>

#pragma mark -

@interface LocationSearchViewController () <CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKLocalSearchCompleter *localSearchCompleter;
@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) CLLocation *userLocation;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *locationsTableView;

@end

#pragma mark -

@implementation LocationSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestLocation];
    self.userLocation = [self.locationManager location];
    
    self.searchBar.delegate = self;
    
    self.locationsTableView.delegate = self;
    self.locationsTableView.dataSource = self;
    
}

#pragma mark - Search

/** Searches for locations based on the provided string. Places the obtained MKMapItems in the locations array.
 
 @param query The text to search for.
 */
- (void)searchFor:(NSString *)query {
    MKLocalSearchRequest *searchRequest = [MKLocalSearchRequest new];
    searchRequest.naturalLanguageQuery = query;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(10.0, 10.0);
    searchRequest.region = MKCoordinateRegionMake(self.userLocation.coordinate, span);
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response) {
            self.locations = response.mapItems;
            [self.locationsTableView reloadData];
        }
        else if (error) {
            //TODO: IMPLEMENT ERROR HANDLING
        }
    }];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocation *)location didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //TODO: IMPLEMENT ERROR HANDLING
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.searchBar.text != nil) {
        [self searchFor:self.searchBar.text];
    }
    else {
        self.locations = nil;
        [self.locationsTableView reloadData];
    }
    
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    MKMapItem *location = self.locations[indexPath.row];
    
    cell.textLabel.text = location.name;
    cell.detailTextLabel.text = [location.placemark locality];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.locationsTableView cellForRowAtIndexPath:indexPath] != nil) {
        self.mapItem = self.locations[indexPath.row];
        [self performSegueWithIdentifier:@"unwindToEventCreation" sender:self];
    }
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

/** Unwinds to the creation view controller.
 
 @param unwindSegue The unwind segue called.
 */
- (IBAction)unwindToEventCreation:(UIStoryboardSegue *)unwindSegue {
    
}


@end
