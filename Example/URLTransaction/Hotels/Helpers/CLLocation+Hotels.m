//
//  CLLocation+Hotels.m
//  URLTransaction
//
//  Created by Dan Kalinin on 14.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "CLLocation+Hotels.h"



@implementation CLLocation (Hotels)

- (BOOL)isEqual:(id)object {
    return [self distanceFromLocation:object] < 1.0;
}

@end
