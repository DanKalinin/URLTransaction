//
//  Hotel.m
//  URLTransaction
//
//  Created by Dan Kalinin on 04.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "Hotel.h"



@implementation Hotel

@end



@implementation Hotel (Helpers)

- (float)avgRating {
    NSNumber *avgRating = [self valueForKeyPath:@"reviews.@avg.rating"];
    return avgRating.floatValue;
}

- (NSArray<Review *> *)loadedReviews {
    return [self.reviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user != nil"]];
}

@end
