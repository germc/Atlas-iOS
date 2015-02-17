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

/**
 @abstract Returns a boolean value indicating whether location services are enabled for the application.
 @discussion If location services are not enabled, an alert with instructions on enabling will be shown.
 */
- (BOOL)locationServicesEnabled;

/**
 @abstract Updates the location of the receiver by starting and immediately stopping location updates.
 */
- (void)updateLocation;

@end
