//
//  ViewController.h
//  sunny
//
//  Created by dshen on 9/24/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <LoginController.h>

@class LoginController;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *sportsgamesArray;
    NSMutableArray *sportsgamesIdArray;
    IBOutlet UITableView *table1;
}

@property (retain, nonatomic) IBOutlet UITableView *table1;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSMutableArray *sportsgamesArray;
@property (nonatomic, retain) NSMutableArray *sportsgamesIdArray;
@property (nonatomic, strong) UISwitch *mySwitch;
@property (nonatomic, strong) UISwitch *mySwitch1;

//for a map view
@property (nonatomic, strong) MKMapView *myMapView;

//for getting my location
@property (nonatomic, strong) CLLocationManager *myLocationManager;

//for dropping pins on a map
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;

@end
