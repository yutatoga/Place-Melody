//
//  MasterViewController.m
//  Place Melody
//
//  Created by  on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    
    
    //map
    myLocationManager = [[CLLocationManager alloc] init];
    myLocationManager.delegate = self;
    myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    myLocationManager.distanceFilter = kCLHeadingFilterNone;
    [myLocationManager startUpdatingLocation];
    [myLocationManager startUpdatingHeading];
    myMapView.showsUserLocation = YES;
    myMapView.delegate = self;
    MKCoordinateRegion  region = myMapView.region;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    
    [myMapView setRegion:region animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    NSDate *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //NSDate *object = [_objects objectAtIndex:indexPath.row];
        //[[segue destinationViewController] setDetailItem:object];
    }
}


//programa added

#pragma mark -
#pragma mark map
//map----------------------------------------------------
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"NEW LOCATION!");
    labelLatitude.text = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    labelLongitude.text = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
    MKCoordinateRegion  region = myMapView.region;
    region.center.latitude = newLocation.coordinate.latitude;
    region.center.longitude = newLocation.coordinate.longitude;
    //*should be fix******************************************************************************************************
    //region.span.latitudeDelta = 0.01;
    //region.span.longitudeDelta = 0.01;
    region.span.latitudeDelta = myMapView.region.span.latitudeDelta;
    region.span.longitudeDelta = myMapView.region.span.longitudeDelta;
    NSLog(@"Delta LAT:%f LON :%f", myMapView.region.span.latitudeDelta, myMapView.region.span.longitudeDelta);
    
    [myMapView setRegion:region animated:YES];
}

#pragma mark -
#pragma mark annnotation
//ピンが落ちてくる処理。    [_mapView addAnnotation:annotation]が呼ばれると、このメソッドが自動的に呼ばれ、上からピンが落ちてくるアニメーションになる。

-(MKAnnotationView*)mapView:(MKMapView*) mapView viewForAnnotation:(id )annotation
{
    //for album
    //annotation
    if (annotation == mapView.userLocation) {
        return nil;
    }  
    
    MKPinAnnotationView *annotationView;  
    
    NSString* identifier = @"Pin"; 
    
    annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } 
    
    annotationView.animatesDrop = YES; //このプロパティでアニメーションドロップを設定
    annotationView.canShowCallout = YES; //このプロパティを設定してコールアウト（文字を表示する吹出し）を表示
    annotationView.annotation = annotation; //このメソッドで設定したアノテーションをannotationViewに再追加してreturnで返す
    UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //[button addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = button;
    NSLog(@"PIN DROPPED-----------------------------------------------------------------------------------------");
    return annotationView;
} 

- (IBAction)addPin{
    
    NSString *hoge = [NSString stringWithString:@"hoge"];
    [myMapView addAnnotation:
     [[SimpleAnnotation alloc]initWithLocationCoordinate:CLLocationCoordinate2DMake(myMapView.centerCoordinate.latitude , myMapView.centerCoordinate.longitude)
                                                    title:hoge
                                                 subtitle:hoge]];
    
    
}

@end
