//
//  URLTransaction.m
//  CookerDemo
//
//  Created by Dan Kalinin on 06.06.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "URLTransaction.h"
NSString *const HTTPErrorDomain = @"HTTPErrorDomain";



@interface URLTransaction ()

@property (copy) URLTransactionHandler success;
@property (copy) URLTransactionHandler failure;
@property (copy) URLTransactionHandler completion;

@end



@interface URLRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (copy) URLRequestHandler success;
@property (copy) URLRequestHandler failure;
@property (copy) URLRequestHandler completion;

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
        
        NSLog(@"%@ %@", request.HTTPMethod, request.URL.path);
    }
    
    static int transactions = 0;
    if (!transactions) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = self.requests.count;
    }
    transactions++;
    
    dispatch_group_notify(self.dispatchGroup, self.operationQueue.underlyingQueue, ^{
        
        transactions--;
        if (!transactions) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        
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



@implementation URLRequest

- (void)sendWithSuccess:(URLRequestHandler)success failure:(URLRequestHandler)failure completion:(URLRequestHandler)completion queue:(dispatch_queue_t)queue {
    id transactionID = @(self.hash);
    [self addToTransaction:transactionID success:success failure:failure completion:completion];
    [[URLTransaction transaction:transactionID] sendWithSuccess:nil failure:nil completion:nil queue:queue];
}

- (void)addToTransaction:(id)transactionID success:(URLRequestHandler)success failure:(URLRequestHandler)failure completion:(URLRequestHandler)completion {
    _data = nil;
    _error = nil;
    
    self.success = success;
    self.failure = failure;
    self.completion = completion;
    
    _transaction = [URLTransaction transaction:transactionID];
    [self.transaction.requests addObject:self];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _connection = connection;
    _error = error;
    dispatch_group_leave(self.transaction.dispatchGroup);
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    _response = response;
    if (response.statusCode != 200) {
        _error = [NSError errorWithDomain:HTTPErrorDomain code:response.statusCode userInfo:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.data) {
        [self.data appendData:data];
    } else {
        _data = [NSMutableData dataWithData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _connection = connection;
    dispatch_group_leave(self.transaction.dispatchGroup);
}

@end
