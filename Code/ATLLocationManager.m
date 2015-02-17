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

- (void)startLocationServices
{
    if ([self respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self requestWhenInUseAuthorization];
    }
    [self startUpdatingLocation];
    [self stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (BOOL)locationServicesEnabled
{
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Required"
                                                            message:@"To share your location, enable location services in the Privacy section of the Settings app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Access Required"
                                                                message:@"To share your location, enable location services for this app in the Privacy section of the Settings app."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
            return NO;
            
        default:
            break;
    }
    return YES;
}

@end
