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

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"will appear");
    /*
    NSLog(@"root view will show");
    if (pinDropBool) {
        pinDropBool = false;
        NSString *hoge = [NSString stringWithString:@"hoge"];
        [myMapView addAnnotation:
         [[SimpleAnnotation alloc]initWithLocationCoordinate:CLLocationCoordinate2DMake(myMapView.centerCoordinate.latitude , myMapView.centerCoordinate.longitude)
                                                       title:[[player nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle]
                                                    subtitle:[[player nowPlayingItem] valueForProperty:MPMediaItemPropertyAlbumTitle]]];
    }
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
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
    region.center.latitude = myLocationManager.location.coordinate.latitude;
    region.center.longitude = myLocationManager.location.coordinate.longitude;
    [myMapView setRegion:region animated:YES];
    
    //ipod
    player = [MPMusicPlayerController iPodMusicPlayer];
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
    
    //avoid go backing to current pos frequently
    //region.center.latitude = newLocation.coordinate.latitude;
    //region.center.longitude = newLocation.coordinate.longitude;
    
    
    //*should be fix******************************************************************************************************
    //region.span.latitudeDelta = 0.01;
    //region.span.longitudeDelta = 0.01;
    region.span.latitudeDelta = myMapView.region.span.latitudeDelta;
    region.span.longitudeDelta = myMapView.region.span.longitudeDelta;
    NSLog(@"Delta LAT:%f LON :%f", myMapView.region.span.latitudeDelta, myMapView.region.span.longitudeDelta);
    [myMapView setRegion:region animated:YES];
    
    //if user's location is within 200m, play pin's music
    CLLocation *currentLoc = myLocationManager.location;
    NSSet *visiblePins = [NSSet setWithSet:[myMapView annotationsInMapRect:myMapView.visibleMapRect] ];
    NSArray *visiblePinsArray = [NSArray arrayWithArray:[visiblePins allObjects]];    
    //check the nearest pin
    int nearestPinIndex = 0;
    NSLog(@"here is ok : visiblePins count is: %i", visiblePins.count);
    if (visiblePins.count != 0) {
        if (visiblePins.count > 1) {        
            for (int i= 0; i < visiblePins.count-1; i++) {
                if ([currentLoc distanceFromLocation:[ [CLLocation alloc] 
                                                      initWithLatitude:[[visiblePinsArray objectAtIndex:i] coordinate].latitude 
                                                      longitude:[[visiblePinsArray objectAtIndex:i] coordinate].longitude
                                                      ]] 
                    >
                    [currentLoc distanceFromLocation:[ [CLLocation alloc] 
                                                      initWithLatitude:[[visiblePinsArray objectAtIndex:i+1] coordinate].latitude 
                                                      longitude:[[visiblePinsArray objectAtIndex:i+1] coordinate].longitude
                                                      ]]) {
                    //if dist[i]<dist[i+1]
                    //save nearest pin's index
                    nearestPinIndex = i+1;
                }
            }
        }
        NSLog(@"nearest index: %d", nearestPinIndex);
        if ([currentLoc distanceFromLocation:[ [CLLocation alloc] 
                                              initWithLatitude:[[visiblePinsArray objectAtIndex:nearestPinIndex] coordinate].latitude 
                                              longitude:[[visiblePinsArray objectAtIndex:nearestPinIndex] coordinate].longitude
                                              ]] < 200) {
            NSLog(@"PLAY THE PLACE MELODY");
            //[player play];
            //search song 
            MPMediaQuery* query = [MPMediaQuery songsQuery];
            NSMutableArray *collections = [[NSMutableArray alloc] initWithCapacity:1];
            //below row user tapped 
            
            //for (int i=0; i<query.items.count; i++) {
            MPMediaPropertyPredicate* pred;
            pred = [MPMediaPropertyPredicate predicateWithValue:[[[[visiblePinsArray objectAtIndex:nearestPinIndex] mediaDictArray]  objectAtIndex:0] objectForKey:@"Title"]
                                                    forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonEqualTo
                    ];
            [query addFilterPredicate:pred];
            [collections addObjectsFromArray:query.items];
            [query  removeFilterPredicate:pred];
            //}
            
            
            
            /*
             //above row user tappd (from the index 0)
             for (int i=0; i<indexPath.row; i++) {
             MPMediaPropertyPredicate* pred;
             pred = [MPMediaPropertyPredicate predicateWithValue:[annotationMediaTitle objectAtIndex:i] forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonEqualTo];
             [query addFilterPredicate:pred];
             [collections addObjectsFromArray:query.items];
             [query  removeFilterPredicate:pred];
             } 
             */
            
            NSLog(@"collections:%@", [collections description]);
            MPMediaItemCollection *finalCollection = [MPMediaItemCollection collectionWithItems:collections];
            [player setQueueWithItemCollection:finalCollection];
            if (player.playbackState != MPMusicPlaybackStatePlaying) {
                [player play];
            }else {
                if ([[player nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle] != [[[visiblePinsArray objectAtIndex:nearestPinIndex] mediaDictArray]  objectAtIndex:0]) {
                    [player play];
                }
            }
        }
    }
    //here is timing for playing
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
    //UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    UIImage *image = [UIImage imageNamed:@"37-circle-x@2x.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width/2.5, image.size.height/2.5);
    button.frame = frame;   // match the button's size with the image size
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    //[button addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = button;
    NSLog(@"PIN DROPPED-----------------------------------------------------------------------------------------");
    return annotationView;
}




- (void)mapView:(MKMapView*)mapView 
 annotationView:(MKAnnotationView*)view 
calloutAccessoryControlTapped:(UIControl*)control
{
    [myMapView removeAnnotation:view.annotation];
}

- (IBAction)addPin{
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc]
     initWithMediaTypes: MPMediaTypeAnyAudio]; // 1
    [picker setDelegate: self]; // 2
    [picker setAllowsPickingMultipleItems: YES]; // 3
    picker.prompt =
    NSLocalizedString (@"Add songs to play",
                       "Prompt in media item picker");
    [self presentModalViewController: picker animated: YES]; // 4
    
    //debug
    CLLocation *currentLoc = myLocationManager.location;
    CLLocation *pinLoc = [[CLLocation alloc] initWithLatitude:myMapView.centerCoordinate.latitude longitude:myMapView.centerCoordinate.longitude];
    myDistLabel.text = [NSString stringWithFormat:@"Dist: %f meters" , [pinLoc distanceFromLocation:currentLoc]];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //update distance label
    NSLog(@"legion did changed");
    CLLocation *currentLoc = myLocationManager.location;
    CLLocation *pinLoc = [[CLLocation alloc] initWithLatitude:myMapView.centerCoordinate.latitude longitude:myMapView.centerCoordinate.longitude];
    double dist = [pinLoc distanceFromLocation:currentLoc];
    if (dist < 1000) {
        myDistLabel.text = [NSString stringWithFormat:@" Distance: %i m" , (int)dist];
    }else{
        myDistLabel.text = [NSString stringWithFormat:@" Distance: %0.3f km" , dist/1000];
    }    
}



#pragma mark -
#pragma mark picker
//picker----------------------------------------------------
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) collection {
    [self dismissModalViewControllerAnimated: YES];
    //[self updatePlayerQueueWithMediaCollection: collection];
    for(MPMediaItem *item in collection.items){;
        NSLog(@"title: %@", [item valueForProperty:MPMediaItemPropertyTitle]);
    };
    [player setQueueWithItemCollection:collection];
    //[player play];
       
       
    SimpleAnnotation *myAnnotation = [[SimpleAnnotation alloc]initWithLocationCoordinate:CLLocationCoordinate2DMake(myMapView.centerCoordinate.latitude , myMapView.centerCoordinate.longitude)
                                                                                   title:[[collection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle]
                                                                                subtitle:[[collection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyAlbumTitle]
                                      ];
    //set mediaDictArray
    NSMutableDictionary* pin = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                                   [[collection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle], @"Title", 
                                   [[collection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyArtist], @"Artist",
                                   [[collection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyAlbumTitle], @"Album",
                                   nil];
    [myAnnotation setMediaDictArray:[NSArray arrayWithObject:pin]];
    [myMapView addAnnotation:myAnnotation];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    [self dismissModalViewControllerAnimated: YES];
}

- (IBAction) showMediaPicker{
    
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc]
     initWithMediaTypes: MPMediaTypeAnyAudio]; // 1
    [picker setDelegate: self]; // 2
    [picker setAllowsPickingMultipleItems: YES]; // 3
    picker.prompt =
    NSLocalizedString (@"Add songs to play",
                       "Prompt in media item picker");
    [self presentModalViewController: picker animated: YES]; // 4
}

@end
