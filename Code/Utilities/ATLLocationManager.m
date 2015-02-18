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

- (void)displayLocationEnablementAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Access Required"
                                                        message:@"To share your location, enable location services for this app in the Privacy section of the Settings app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
     [alertView show];
    
}

@end
