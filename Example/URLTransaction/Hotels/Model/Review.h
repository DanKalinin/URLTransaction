//
//  Review.h
//  URLTransaction
//
//  Created by Dan Kalinin on 04.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Review : NSObject

@property NSString *ID;
@property NSString *user;
@property NSDate *date;
@property NSString *pros;
@property NSString *cons;
@property int rating;

@end
