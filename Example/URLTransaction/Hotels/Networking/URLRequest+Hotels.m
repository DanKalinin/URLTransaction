//
//  URLRequest+Hotels.m
//  URLTransaction
//
//  Created by Dan Kalinin on 04.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "URLRequest+Hotels.h"



@implementation URLRequest (Hotels)

#pragma mark - Build requests

+ (NSURLComponents *)baseComponents {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"dl.dropboxusercontent.com";
    return components;
}

+ (instancetype)getHotels {
    NSURLComponents *components = self.baseComponents;
    components.path = @"/s/1ey7hh078iyhdoh/hotels.json";
    
    URLRequest *request = [URLRequest requestWithURL:components.URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

+ (instancetype)getImage:(NSString *)ID {
    NSURLComponents *components = self.baseComponents;
    components.path = [NSString stringWithFormat:@"/s/%@/image.jpg", ID];
    
    URLRequest *request = [URLRequest requestWithURL:components.URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Accept"];
    return request;
}

+ (instancetype)getReview:(NSString *)ID {
    NSURLComponents *components = self.baseComponents;
    components.path = [NSString stringWithFormat:@"/s/%@/review.json", ID];
    
    URLRequest *request = [URLRequest requestWithURL:components.URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

#pragma mark - Map responses

- (NSArray<Hotel *> *)mapHotels {
    NSMutableArray *hotels = [NSMutableArray array];
    NSArray *objects = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    for (NSDictionary *object in objects) {
        Hotel *hotel = [Hotel new];
        hotel.ID = [object[@"id"] intValue];
        hotel.stars = [object[@"stars"] intValue];
        hotel.name = object[@"name"];
        hotel.price = [object[@"price"] floatValue];
        
        CLLocationDegrees latitude = [object[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [object[@"longitude"] doubleValue];
        hotel.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        NSMutableArray *images = [NSMutableArray array];
        for (NSString *ID in object[@"images"]) {
            Image *image = [Image new];
            image.ID = ID;
            [images addObject:image];
        }
        hotel.images = images;
        
        NSMutableArray *reviews = [NSMutableArray array];
        for (NSString *ID in object[@"reviews"]) {
            Review *review = [Review new];
            review.ID = ID;
            [reviews addObject:review];
        }
        hotel.reviews = reviews;
        
        [hotels addObject:hotel];
    }
    return hotels;
}

- (UIImage *)mapImage {
    return [UIImage imageWithData:self.data];
}

- (Review *)mapReview {
    Review *review = [Review new];
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    if (object) {
        review.ID = object[@"id"];
        review.user = object[@"user"];
        review.date = [NSDate dateWithTimeIntervalSince1970:[object[@"date"] doubleValue]];
        review.pros = object[@"pros"];
        review.cons = object[@"cons"];
        review.rating = [object[@"rating"] intValue];
    }
    return review;
}

@end
