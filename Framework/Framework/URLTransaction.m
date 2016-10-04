//
//  URLTransaction.m
//  OAuth2
//
//  Created by Dan Kalinin on 01.04.16.
//  Copyright © 2016 Dan. All rights reserved.
//

#import "URLTransaction.h"
#import <objc/runtime.h>

NSString *const HTTPErrorDomain = @"HTTPErrorDomain";










@interface NSURLRequest (URLTransactionAssociations)

@property NSOperationQueue *queue;
@property NSManagedObjectContext *moc;
@property id info;

@property NSData *data;
@property NSHTTPURLResponse *response;
@property NSError *error;

@property (copy) URLRequestHandler success;
@property (copy) URLRequestHandler failure;
@property (copy) URLRequestHandler completion;

@property URLTransaction *transaction;
@property NSURLSessionDataTask *task;

@end



@implementation NSURLRequest (URLTransaction)

- (instancetype)queue:(NSOperationQueue *)queue {
    self.queue = queue;
    return self;
}

- (instancetype)moc:(NSManagedObjectContext *)moc {
    self.moc = moc;
    return self;
}

- (instancetype)info:(id)info {
    self.info = info;
    return self;
}

- (instancetype)success:(URLRequestHandler)success {
    self.success = success;
    return self;
}

- (instancetype)failure:(URLRequestHandler)failure {
    self.failure = failure;
    return self;
}

- (instancetype)completion:(URLRequestHandler)completion {
    self.completion = completion;
    return self;
}

- (void)resume {
    self.transaction = [[[URLTransaction new] queue:self.queue] addRequest:self];
    [self.transaction resume];
}

- (void)cancel {
    [self.transaction cancel];
}

#pragma mark - Accessors

static NSMutableDictionary *_baseComponents = nil;

+ (NSMutableDictionary<NSString *, NSURLComponents *> *)baseComponents {
    if (_baseComponents == nil) {
        _baseComponents = [NSMutableDictionary dictionary];
    }
    return _baseComponents;
}

- (void)setQueue:(NSOperationQueue *)queue {
    objc_setAssociatedObject(self, @selector(queue), queue, OBJC_ASSOCIATION_RETAIN);
}

- (NSOperationQueue *)queue {
    return objc_getAssociatedObject(self, @selector(queue));
}

- (void)setMoc:(NSManagedObjectContext *)moc {
    objc_setAssociatedObject(self, @selector(moc), moc, OBJC_ASSOCIATION_RETAIN);
}

- (NSManagedObjectContext *)moc {
    return objc_getAssociatedObject(self, @selector(moc));
}

- (void)setInfo:(id)info {
    objc_setAssociatedObject(self, @selector(info), info, OBJC_ASSOCIATION_RETAIN);
}

- (id)info {
    return objc_getAssociatedObject(self, @selector(info));
}

- (void)setData:(NSData *)data {
    objc_setAssociatedObject(self, @selector(data), data, OBJC_ASSOCIATION_RETAIN);
}

- (NSData *)data {
    return objc_getAssociatedObject(self, @selector(data));
}

- (void)setResponse:(NSHTTPURLResponse *)response {
    objc_setAssociatedObject(self, @selector(response), response, OBJC_ASSOCIATION_RETAIN);
}

- (NSHTTPURLResponse *)response {
    return objc_getAssociatedObject(self, @selector(response));
}

- (void)setError:(NSError *)error {
    objc_setAssociatedObject(self, @selector(error), error, OBJC_ASSOCIATION_RETAIN);
}

- (NSError *)error {
    return objc_getAssociatedObject(self, @selector(error));
}

- (void)setSuccess:(URLRequestHandler)success {
    objc_setAssociatedObject(self, @selector(success), success, OBJC_ASSOCIATION_COPY);
}

- (URLRequestHandler)success {
    return objc_getAssociatedObject(self, @selector(success));
}

- (void)setFailure:(URLRequestHandler)failure {
    objc_setAssociatedObject(self, @selector(failure), failure, OBJC_ASSOCIATION_COPY);
}

- (URLRequestHandler)failure {
    return objc_getAssociatedObject(self, @selector(failure));
}

- (void)setCompletion:(URLRequestHandler)completion {
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY);
}

- (URLRequestHandler)completion {
    return objc_getAssociatedObject(self, @selector(completion));
}

- (void)setTransaction:(URLTransaction *)transaction {
    objc_setAssociatedObject(self, @selector(transaction), transaction, OBJC_ASSOCIATION_RETAIN);
}

- (URLTransaction *)transaction {
    return objc_getAssociatedObject(self, @selector(transaction));
}

- (void)setTask:(NSURLSessionDataTask *)task {
    objc_setAssociatedObject(self, @selector(task), task, OBJC_ASSOCIATION_RETAIN);
}

- (NSURLSessionDataTask *)task {
    return objc_getAssociatedObject(self, @selector(task));
}

- (id)json {
    @try {
        id object = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
        return object;
    } @catch (NSException *exception) {
        return nil;
    }
}

#pragma mark - Helpers

- (void)invokeHandler:(URLRequestHandler)handler {
    if (handler) {
        [self.queue addOperationWithBlock:^{
            handler(self);
        }];
    }
}

@end










@interface URLTransaction ()

@property NSOperationQueue *queue;
@property NSManagedObjectContext *moc;
@property id info;

@property NSError *error;

@property (copy) URLTransactionHandler success;
@property (copy) URLTransactionHandler failure;
@property (copy) URLTransactionHandler completion;

@property NSOperationQueue *systemQueue;
@property NSMutableArray *mutableRequests;

@end



@implementation URLTransaction

- (instancetype)init {
    self = [super init];
    if (self) {
        self.systemQueue = [NSOperationQueue new];
        self.systemQueue.maxConcurrentOperationCount = 1;
        
        self.mutableRequests = [NSMutableArray array];
    }
    return self;
}

- (instancetype)queue:(NSOperationQueue *)queue {
    self.queue = queue;
    return self;
}

- (instancetype)moc:(NSManagedObjectContext *)moc {
    self.moc = moc;
    return self;
}

- (instancetype)info:(id)info {
    self.info = info;
    return self;
}

- (instancetype)addRequest:(NSURLRequest *)request {
    [self.mutableRequests addObject:request];
    return self;
}

- (instancetype)success:(URLTransactionHandler)success {
    self.success = success;
    return self;
}

- (instancetype)failure:(URLTransactionHandler)failure {
    self.failure = failure;
    return self;
}

- (instancetype)completion:(URLTransactionHandler)completion {
    self.completion = completion;
    return self;
}

- (NSArray *)requests {
    return self.mutableRequests;
}

- (void)resume {
    
    [self prepare];
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSURLRequest *request in self.requests) {
        
        dispatch_group_enter(group);
        
        request.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (error) {
                request.error = error;
            } else {
                request.data = data;
                request.response = (NSHTTPURLResponse *)response;
                
                NSInteger statusCode = request.response.statusCode;
                if (statusCode >= 400) {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    userInfo[NSLocalizedDescriptionKey] = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
                    userInfo[NSURLErrorKey] = request.URL;
                    request.error = [NSError errorWithDomain:HTTPErrorDomain code:statusCode userInfo:userInfo];
                }
            }
            
            dispatch_group_leave(group);
        }];
        
        [request.task resume];
        
        NSLog(@"%@ %@", request.HTTPMethod, request.URL.path);
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_notify(group, queue, ^{
        
        // Requests
        
        for (NSURLRequest *request in self.requests) {
            
            request.transaction = nil;
            
            if (request.error) {
                
                if (!self.error) {
                    self.error = request.error;
                }
                
                [request invokeHandler:request.failure];
            } else {
                [request invokeHandler:request.success];
            }
            [request invokeHandler:request.completion];
        }
        
        // Transaction
        
        if (self.error) {
            [self invokeHandler:self.failure];
        } else {
            [self invokeHandler:self.success];
        }
        [self invokeHandler:self.completion];
        
        [self cleanup];
    });
}

- (void)cancel {
    NSArray *tasks = [self.requests valueForKey:@"task"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state = %ld", (long)NSURLSessionTaskStateRunning];
    tasks = [tasks filteredArrayUsingPredicate:predicate];
    [tasks makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark - Helpers

- (void)prepare {
    
    // Transaction
    
    if (!self.queue) {
        self.queue = [NSOperationQueue mainQueue];
    }
    
    // Requests
    
    for (NSURLRequest *request in self.requests) {
        if (!request.queue) {
            request.queue = self.queue;
        }
        
        if (!request.moc && self.moc) {
            request.moc = self.moc;
        }
        
        if (!request.info && self.info) {
            request.info = self.info;
        }
    }
}

- (void)cleanup {
    
}

- (void)invokeHandler:(URLTransactionHandler)handler {
    if (handler) {
        [self.queue addOperationWithBlock:^{
            handler(self);
        }];
    }
}

@end
