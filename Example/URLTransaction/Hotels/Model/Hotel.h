//
//  Hotel.h
//  URLTransaction
//
//  Created by Dan Kalinin on 04.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



@interface Hotel : NSObject

@property int ID;
@property float price;
@property int stars;
@property CLLocation *location;
@property CLPlacemark *placemark;
@property NSString *name;
@property NSArray<Image *> *images;
@property NSArray<Review *> *reviews;

@end



@interface Hotel (Helpers)

@property (readonly) float avgRating;
@property (readonly) NSArray<Review *> *loadedReviews;

@end
