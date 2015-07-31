//
//  NSURLRequest+CDHelpers.m
//  CookerDemo
//
//  Created by Dan on 05.06.15.
//  Copyright (c) 2015 Алексей. All rights reserved.
//

#import "URLRequest.h"
#import "URLTransaction.h"



@interface URLRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

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
