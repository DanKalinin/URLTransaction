//
//  Reachability.m
//  Reachability
//
//  Created by Dan Kalinin on 1/9/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

static void Callback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);



@interface Reachability ()

@property SCNetworkReachabilityRef target;
@property ReachabilityStatus status;

@property (copy) ReachabilityStatusHandler statusHandler;

@end



@implementation Reachability

- (instancetype)initWithHost:(NSString *)host statusHandler:(ReachabilityStatusHandler)handler {
    self = [super init];
    if (self) {
        if (!host) host = @"0.0.0.0";
        self.target = SCNetworkReachabilityCreateWithName(NULL, host.UTF8String);
        SCNetworkReachabilityScheduleWithRunLoop(self.target, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        SCNetworkReachabilityContext ctx;
        ctx.version = 0;
        ctx.info = (__bridge void *)(self);
        ctx.retain = NULL;
        ctx.release = NULL;
        ctx.copyDescription = NULL;
        SCNetworkReachabilitySetCallback(self.target, Callback, &ctx);
        
        SCNetworkReachabilityFlags flags;
        SCNetworkReachabilityGetFlags(self.target, &flags);
        self.status = [self statusForFlags:flags];
        self.statusHandler = handler;
        [self invokeHandler:handler status:self.status];
    }
    return self;
}

- (void)dealloc {
    SCNetworkReachabilitySetCallback(self.target, NULL, NULL);
    SCNetworkReachabilityUnscheduleFromRunLoop(self.target, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFRelease(self.target);
}

#pragma mark - Helpers

- (ReachabilityStatus)statusForFlags:(SCNetworkReachabilityFlags)flags {
    
    ReachabilityStatus status = ReachabilityStatusNone;
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsConnectionRequired) && !(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            status = ReachabilityStatusWWAN;
        } else {
            status = ReachabilityStatusWiFi;
        }
    }
    
    return status;
}

- (void)invokeHandler:(ReachabilityStatusHandler)handler status:(ReachabilityStatus)status {
    if (handler) {
        handler(status);
    }
}

@end



static void Callback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    Reachability *reachability = (__bridge Reachability *)info;
    ReachabilityStatus status = [reachability statusForFlags:flags];
    if (status != reachability.status) {
        reachability.status = status;
        [reachability invokeHandler:reachability.statusHandler status:status];
    }
}
