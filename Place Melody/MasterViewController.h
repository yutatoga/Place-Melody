//
//  MasterViewController.h
//  Place Melody
//
//  Created by  on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreLocation/CoreLocation.h>

#import "SimpleAnnotation.h"
@interface MasterViewController : UIViewController<MPMediaPickerControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>{
    //map
    IBOutlet MKMapView *myMapView;
    CLLocationManager *myLocationManager;
    IBOutlet UILabel *labelLatitude;
    IBOutlet UILabel *labelLongitude;
    IBOutlet UILabel *labelTappedLatitude;
    IBOutlet UILabel *labelTappedLongitude;
    IBOutlet UIImageView *compassImg;
    IBOutlet UIView *viewMapBack;
    //ipod
    MPMusicPlayerController *player;
}
-(IBAction) addPin;
-(IBAction) showMediaPicker;

@end
