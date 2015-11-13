//
//  NSURLRequest+CDHelpers.h
//  CookerDemo
//
//  Created by Dan Kalinin on 05.06.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class URLTransaction;



NS_ASSUME_NONNULL_BEGIN

@interface URLRequest : NSMutableURLRequest

typedef void (^URLRequestHandler)(__kindof URLRequest *);

@property (readonly) NSHTTPURLResponse *response;
@property (readonly) NSURLConnection *connection;
@property (readonly, nullable) NSError *error;
@property (readonly) NSMutableData *data;
@property (readonly) URLTransaction *transaction;
@property (nullable) id userInfo;
- (void)sendWithSuccess:(nullable URLRequestHandler)success failure:(nullable URLRequestHandler)failure completion:(nullable URLRequestHandler)completion queue:(nullable dispatch_queue_t)queue;
- (void)addToTransaction:(id)transactionID success:(nullable URLRequestHandler)success failure:(nullable URLRequestHandler)failure completion:(nullable URLRequestHandler)completion;

@end

NS_ASSUME_NONNULL_END
