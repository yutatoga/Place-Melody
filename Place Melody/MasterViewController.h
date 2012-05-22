//
//  MasterViewController.h
//  Place Melody
//
//  Created by  on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "SimpleAnnotation.h"
@interface MasterViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>{
    //map
    IBOutlet MKMapView *myMapView;
    CLLocationManager *myLocationManager;
    IBOutlet UILabel *labelLatitude;
    IBOutlet UILabel *labelLongitude;
    IBOutlet UILabel *labelTappedLatitude;
    IBOutlet UILabel *labelTappedLongitude;
    IBOutlet UIImageView *compassImg;
    IBOutlet UIView *viewMapBack;
}
-(IBAction) addPin;


@end
