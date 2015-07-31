//
//  NSURLRequest+CDHelpers.h
//  CookerDemo
//
//  Created by Dan on 05.06.15.
//  Copyright (c) 2015 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>
@class URLTransaction;
static NSString *HTTPErrorDomain = @"HTTPErrorDomain";



@interface URLRequest : NSMutableURLRequest

typedef void (^URLRequestHandler)(URLRequest *);

@property (readonly) NSHTTPURLResponse *response;
@property (readonly) NSURLConnection *connection;
@property (readonly) NSError *error;
@property (readonly) NSMutableData *data;

@property (readonly) URLTransaction *transaction;
@property (copy) URLRequestHandler success;
@property (copy) URLRequestHandler failure;
@property (copy) URLRequestHandler completion;
@property id userInfo;
- (void)sendWithSuccess:(URLRequestHandler)success failure:(URLRequestHandler)failure completion:(URLRequestHandler)completion queue:(dispatch_queue_t)queue;
- (void)addToTransaction:(id)transactionID success:(URLRequestHandler)success failure:(URLRequestHandler)failure completion:(URLRequestHandler)completion;

@end
