//
//  URLTransaction.h
//  CookerDemo
//
//  Created by Dan Kalinin on 06.06.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLRequest.h"
extern NSString *const _Nonnull HTTPErrorDomain;



NS_ASSUME_NONNULL_BEGIN

@interface URLTransaction : NSObject

typedef void (^URLTransactionHandler)(__kindof URLTransaction *);

@property (readonly, nullable) NSError *error;
@property (readonly) id transactionID;
@property (readonly) NSMutableArray<__kindof URLRequest *> *requests;
@property (readonly) NSURLConnection *connection;
@property (readonly) NSOperationQueue *operationQueue;
@property (readonly) dispatch_group_t dispatchGroup;
@property (nullable) id userInfo;
+ (instancetype)transaction:(id)transactionID NS_SWIFT_NAME(init(id:));
- (void)sendWithSuccess:(nullable URLTransactionHandler)success failure:(nullable URLTransactionHandler)failure completion:(nullable URLTransactionHandler)completion queue:(nullable dispatch_queue_t)queue;

@end

NS_ASSUME_NONNULL_END
