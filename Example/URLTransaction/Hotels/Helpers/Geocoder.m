//
//  Geocoder.m
//  URLTransaction
//
//  Created by Dan Kalinin on 14.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "Geocoder.h"



@implementation Geocoder

+ (NSCache *)cache {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSCache new];
        cache.countLimit = 11;
    });
    return cache;
}

- (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(CLGeocodeCompletionHandler)completionHandler {
    NSArray *placemarks = [[self.class cache] objectForKey:location];
    if (placemarks) {
        completionHandler(placemarks, nil);
    } else {
        [super reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks) {
                [[self.class cache] setObject:placemarks forKey:location];
            }
            completionHandler(placemarks, error);
        }];
    }
}

@end
