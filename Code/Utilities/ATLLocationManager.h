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
 */
- (BOOL)locationServicesEnabled;

/**
 @abstract Displays a `UIAlertView` with instructions on enabling location services for the application.
 */
- (void)displayLocationEnablementAlert;

@end
