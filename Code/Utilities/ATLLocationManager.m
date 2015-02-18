//
//  ATLLocationManager.m
//  Pods
//
//  Created by Kevin Coleman on 2/16/15.
//
//

#import "ATLLocationManager.h"

@interface ATLLocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation ATLLocationManager

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (BOOL)locationServicesEnabled
{
    if (![CLLocationManager locationServicesEnabled]) {
        return NO;
    }
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return NO;
        default:
            break;
    }
    return YES;
}

- (void)updateLocation
{
    if ([self respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self requestWhenInUseAuthorization];
    }
    [self startUpdatingLocation];
}

- (void)displayLocationEnablementAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Access Required"
                                                        message:@"To share your location, enable location services for this app in the Privacy section of the Settings app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
     [alertView show];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self stopUpdatingLocation];
}

@end
