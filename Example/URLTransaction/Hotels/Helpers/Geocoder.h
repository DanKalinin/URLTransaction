//
//  Geocoder.h
//  URLTransaction
//
//  Created by Dan Kalinin on 14.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>



@interface Geocoder : CLGeocoder

- (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(CLGeocodeCompletionHandler)completionHandler;

@end
