//
//  URLRequest+Hotels.h
//  URLTransaction
//
//  Created by Dan Kalinin on 04.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "URLRequest.h"



@interface URLRequest (Hotels)

+ (instancetype)getHotels;
+ (instancetype)getImage:(NSString *)ID;
+ (instancetype)getReview:(NSString *)ID;

- (NSArray<Hotel *> *)mapHotels;
- (UIImage *)mapImage;
- (Review *)mapReview;

@end
