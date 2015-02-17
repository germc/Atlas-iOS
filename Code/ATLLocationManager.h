//
//  ATLLocationManager.h
//  Pods
//
//  Created by Kevin Coleman on 2/16/15.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h> 

@class ATLLocationManager;

@protocol ATLLocationManagerDelegate <NSObject>

- (void)locationManager:(ATLLocationManager *)locationManager didUpdateLocation:(CLLocation *)location;

@end

@interface ATLLocationManager : NSObject

@property (nonatomic) id<ATLLocationManagerDelegate>delegate;

- (BOOL)locationServicesEnabled;

- (void)startLocationServices;

@end
