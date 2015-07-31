//
//  URLTransaction.h
//  CookerDemo
//
//  Created by Dan Kalinin on 06.06.15.
//  Copyright (c) 2015 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>
@class URLRequest;



@interface URLTransaction : NSObject

typedef void (^URLTransactionHandler)(URLTransaction *);

@property (readonly) NSError *error;

@property (readonly) NSString *transactionID;
@property (readonly) NSMutableArray *requests;
@property (readonly) NSURLConnection *connection;
@property (readonly) NSOperationQueue *operationQueue;
@property (readonly) dispatch_group_t dispatchGroup;
@property (copy) URLTransactionHandler success;
@property (copy) URLTransactionHandler failure;
@property (copy) URLTransactionHandler completion;

+ (instancetype)transaction:(id)transactionID;
- (void)sendWithSuccess:(URLTransactionHandler)success failure:(URLTransactionHandler)failure completion:(URLTransactionHandler)completion queue:(dispatch_queue_t)queue;

@end
