//
//  URLTransaction.m
//  CookerDemo
//
//  Created by Dan Kalinin on 06.06.15.
//  Copyright (c) 2015 Алексей. All rights reserved.
//

#import "URLTransaction.h"
#import "URLRequest.h"



@interface URLTransaction ()

@end



@implementation URLTransaction

+ (instancetype)transaction:(id)transactionID {
    URLTransaction *transaction = [NSThread mainThread].threadDictionary[transactionID];
    if (!transaction) {
        transaction = [self new];
        [transaction setValue:transactionID forKey:@"transactionID"];
        [transaction setValue:[NSMutableArray array] forKey:@"requests"];
        [NSThread mainThread].threadDictionary[transactionID] = transaction;
    }
    return transaction;
}

- (void)sendWithSuccess:(URLTransactionHandler)success failure:(URLTransactionHandler)failure completion:(URLTransactionHandler)completion queue:(dispatch_queue_t)queue {
    [[NSThread mainThread].threadDictionary removeObjectForKey:self.transactionID];
    
    self.success = success;
    self.failure = failure;
    self.completion = completion;
    
    if (!queue) {
        queue = dispatch_queue_create([NSString stringWithFormat:@"%@.%@.%@", [NSBundle mainBundle].bundleIdentifier, NSStringFromClass([self class]), self.transactionID].lowercaseString.UTF8String, DISPATCH_QUEUE_SERIAL);
    }
    _operationQueue = [NSOperationQueue new];
    self.operationQueue.underlyingQueue = queue;
    
    _dispatchGroup = dispatch_group_create();
    for (URLRequest *request in self.requests) {
        dispatch_group_enter(self.dispatchGroup);
        
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:request startImmediately:NO];
        [self.connection setDelegateQueue:self.operationQueue];
        [self.connection start];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = self.requests.count;
    
    dispatch_group_notify(self.dispatchGroup, self.operationQueue.underlyingQueue, ^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        for (URLRequest *request in self.requests) {
            if (request.error) {
                !request.failure ? : request.failure(request);
            } else {
                !request.success ? : request.success(request);
            }
            !request.completion ? : request.completion(request);
        }
        
        if (self.error) {
            !self.failure ? : self.failure(self);
        } else {
            !self.success ? : self.success(self);
        }
        !self.completion ? : self.completion(self);
    });
}

- (NSError *)error {
    NSArray *errors = [self.requests valueForKey:@"error"];
    return [errors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != nil"]].firstObject;
}

@end
