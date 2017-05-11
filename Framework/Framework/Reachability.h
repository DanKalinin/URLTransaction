//
//  Reachability.h
//  Reachability
//
//  Created by Dan Kalinin on 1/9/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ReachabilityStatus) {
    ReachabilityStatusNone,
    ReachabilityStatusWiFi,
    ReachabilityStatusWWAN
};



@interface Reachability : NSObject

typedef void (^ReachabilityStatusHandler)(ReachabilityStatus status);

- (instancetype)initWithHost:(NSString *)host statusHandler:(ReachabilityStatusHandler)handler;

@property (readonly) ReachabilityStatus status;

@end
