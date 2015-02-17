//
//  ATLLocationManager.h
//  Pods
//
//  Created by Kevin Coleman on 2/16/15.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h> 

@interface ATLLocationManager : CLLocationManager

- (BOOL)locationServicesEnabled;

- (void)startLocationServices;

@end
