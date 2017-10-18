//
//  URLTransaction.m
//  OAuth2
//
//  Created by Dan Kalinin on 01.04.16.
//  Copyright © 2016 Dan. All rights reserved.
//

#import "URLTransaction.h"
#import <objc/runtime.h>
#import <Helpers/Helpers.h>

NSErrorDomain const HTTPErrorDomain = @"HTTPErrorDomain";

HTTPMethod const HTTPMethodOptions = @"OPTIONS";
HTTPMethod const HTTPMethodGet = @"GET";
HTTPMethod const HTTPMethodHead = @"HEAD";
HTTPMethod const HTTPMethodPost = @"POST";
HTTPMethod const HTTPMethodPut = @"PUT";
HTTPMethod const HTTPMethodPatch = @"PATCH";
HTTPMethod const HTTPMethodDelete = @"DELETE";
HTTPMethod const HTTPMethodTrace = @"TRACE";
HTTPMethod const HTTPMethodConnect = @"CONNECT";

HTTPHeaderField const HTTPHeaderFieldAccept = @"Accept";
HTTPHeaderField const HTTPHeaderFieldAuthorization = @"Authorization";
HTTPHeaderField const HTTPHeaderFieldContentType = @"Content-Type";
HTTPHeaderField const HTTPHeaderFieldIfModifiedSince = @"If-Modified-Since";
HTTPHeaderField const HTTPHeaderFieldLastModified = @"Last-Modified";
HTTPHeaderField const HTTPHeaderFieldDate = @"Date";

MediaType const MediaTypeApplicationForm = @"application/x-www-form-urlencoded";
MediaType const MediaTypeApplicationJSON = @"application/json";










@interface NSURLRequest (URLTransactionSelectors)

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

@property NSDateFormatter *dateFormatter;
@property NSMutableDictionary<NSNumber *, JSONSchema *> *JSONSchemas;

@end



@implementation NSURLRequest (URLTransaction)

+ (void)load {
    SEL original = @selector(initWithURL:cachePolicy:timeoutInterval:);
    SEL swizzled = @selector(initSwizzledWithURL_URLTransaction_NSURLRequest:cachePolicy:timeoutInterval:);
    [self swizzleInstanceMethod:original with:swizzled];
}

- (instancetype)initSwizzledWithURL_URLTransaction_NSURLRequest:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    self = [self initSwizzledWithURL_URLTransaction_NSURLRequest:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
    if (self) {
        self.JSONSchemas = [NSMutableDictionary dictionary];
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
    if (_baseComponents) return _baseComponents;
    
    _baseComponents = [NSMutableDictionary dictionary];
    return _baseComponents;
}

- (void)setQueue:(NSOperationQueue *)queue {
    objc_setAssociatedObject(self, @selector(queue), queue, OBJC_ASSOCIATION_RETAIN);
}

- (NSOperationQueue *)queue {
    return objc_getAssociatedObject(self, @selector(queue));
}

- (void)setJSONSchemas:(NSMutableDictionary *)JSONSchemas {
    objc_setAssociatedObject(self, @selector(JSONSchemas), JSONSchemas, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableDictionary *)JSONSchemas {
    return objc_getAssociatedObject(self, @selector(JSONSchemas));
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

- (void)setDateFormatter:(NSDateFormatter *)dateFormatter {
    objc_setAssociatedObject(self, @selector(dateFormatter), dateFormatter, OBJC_ASSOCIATION_RETAIN);
}

- (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = objc_getAssociatedObject(self, @selector(dateFormatter));
    if (dateFormatter) return dateFormatter;
    
    self.dateFormatter = [NSDateFormatter fixedDateFormatterWithDateFormat:DateFormatRFC1123];
    return self.dateFormatter;
}

- (NSDate *)dateForHTTPHeaderField:(HTTPHeaderField)field {
    NSString *string = [self valueForHTTPHeaderField:field];
    NSDate *date = [self.dateFormatter dateFromString:string];
    return date;
}

- (void)setJSONSchema:(JSONSchema *)schema forStatusCode:(HTTPStatusCode)code {
    self.JSONSchemas[@(code)] = schema;
}

- (JSONSchema *)JSONSchemaForStatusCode:(HTTPStatusCode)code {
    JSONSchema *schema = self.JSONSchemas[@(code)];
    return schema;
}

#pragma mark - Helpers

- (void)invokeHandler:(URLRequestHandler)handler request:(NSURLRequest *)request {
    if (handler) {
        [self.queue addOperationWithBlock:^{
            handler(request);
        }];
    }
}

@end










@interface URLTransaction ()

@property NSOperationQueue *queue;
@property NSMutableDictionary<NSNumber *, JSONSchema *> *JSONSchemas;
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
        
        self.JSONSchemas = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)queue:(NSOperationQueue *)queue {
    self.queue = queue;
    return self;
}

- (instancetype)JSONSchema:(JSONSchema *)schema forStatusCode:(HTTPStatusCode)statusCode {
    self.JSONSchemas[@(statusCode)] = schema;
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
        
        request.task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (error) {
                if (([error.domain isEqualToString:NSURLErrorDomain]) && (error.code == NSURLErrorCancelled)) return;
                
                request.error = error;
                
                dispatch_group_leave(group);
                return;
            }
            
            request.data = data;
            request.response = (NSHTTPURLResponse *)response;
            
            NSInteger statusCode = request.response.statusCode;
            if (statusCode >= HTTPStatusCodeBadRequest) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[NSLocalizedDescriptionKey] = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
                userInfo[NSURLErrorKey] = request.URL;
                request.error = [NSError errorWithDomain:HTTPErrorDomain code:statusCode userInfo:userInfo];
                
                dispatch_group_leave(group);
                return;
            }
            
            JSONSchema *schema = request.JSONSchemas[@(statusCode)];
            if (!schema) {
                dispatch_group_leave(group);
                return;
            }
            
            NSOperationQueue *queue = [NSOperationQueue new];
            [queue addOperationWithBlock:^{
                NSError *error = nil;
                BOOL valid = [schema validateObject:request.data.json error:&error];
                if (!valid) {
                    request.error = error;
                }
                
                dispatch_group_leave(group);
            }];
            
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
                
                [request invokeHandler:request.failure request:request];
            } else {
                [request invokeHandler:request.success request:request];
            }
            [request invokeHandler:request.completion request:request];
        }
        
        // Transaction
        
        if (self.error) {
            [self invokeHandler:self.failure transaction:self];
        } else {
            [self invokeHandler:self.success transaction:self];
        }
        [self invokeHandler:self.completion transaction:self];
        
        [self cleanup];
    });
}

- (void)cancel {
    NSArray *tasks = [self.requests valueForKey:@"task"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state = %i", (int)NSURLSessionTaskStateRunning];
    tasks = [tasks filteredArrayUsingPredicate:predicate];
    [tasks makeObjectsPerformSelector:@selector(cancel)];
}

- (void)setJSONSchema:(JSONSchema *)schema forStatusCode:(HTTPStatusCode)code {
    self.JSONSchemas[@(code)] = schema;
}

- (JSONSchema *)JSONSchemaForStatusCode:(HTTPStatusCode)code {
    JSONSchema *schema = self.JSONSchemas[@(code)];
    return schema;
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
        
        for (NSNumber *code in self.JSONSchemas.allKeys) {
            JSONSchema *schema = request.JSONSchemas[code];
            if (!schema) {
                request.JSONSchemas[code] = self.JSONSchemas[code];
            }
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

- (void)invokeHandler:(URLTransactionHandler)handler transaction:(URLTransaction *)transaction {
    if (handler) {
        [self.queue addOperationWithBlock:^{
            handler(transaction);
        }];
    }
}

@end










@interface BasicCredential ()

@end



@implementation BasicCredential

- (NSString *)debugDescription {
    NSString *type = @"Basic";
    
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", self.user, self.password];
    NSData *data = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    credentials = [data base64EncodedStringWithOptions:0];
    
    NSString *value = [NSString stringWithFormat:@"%@ %@", type, credentials];
    return value;
}

@end










@implementation NSMutableURLRequest (URLTransaction)

- (void)setDate:(NSDate *)date forHTTPHeaderField:(HTTPHeaderField)field {
    NSString *value = [self.dateFormatter stringFromDate:date];
    [self setValue:value forHTTPHeaderField:field];
}

- (void)setCredential:(Credential *)credential forHTTPHeaderField:(HTTPHeaderField)field {
    NSString *value = credential.debugDescription;
    [self setValue:value forHTTPHeaderField:field];
}

@end










@interface NSHTTPURLResponse (URLTransactionSelectors)

@property NSDateFormatter *dateFormatter1;
@property NSDateFormatter *dateFormatter2;
@property NSDateFormatter *dateFormatter3;

@end










@implementation NSHTTPURLResponse (URLTransaction)

- (void)setDateFormatter1:(NSDateFormatter *)dateFormatter1 {
    objc_setAssociatedObject(self, @selector(dateFormatter1), dateFormatter1, OBJC_ASSOCIATION_RETAIN);
}

- (NSDateFormatter *)dateFormatter1 {
    NSDateFormatter *dateFormatter = objc_getAssociatedObject(self, @selector(dateFormatter1));
    if (dateFormatter) return dateFormatter;
    
    self.dateFormatter1 = [NSDateFormatter fixedDateFormatterWithDateFormat:DateFormatRFC1123];
    return self.dateFormatter1;
}

- (void)setDateFormatter2:(NSDateFormatter *)dateFormatter2 {
    objc_setAssociatedObject(self, @selector(dateFormatter2), dateFormatter2, OBJC_ASSOCIATION_RETAIN);
}

- (NSDateFormatter *)dateFormatter2 {
    NSDateFormatter *dateFormatter = objc_getAssociatedObject(self, @selector(dateFormatter2));
    if (dateFormatter) return dateFormatter;
    
    self.dateFormatter2 = [NSDateFormatter fixedDateFormatterWithDateFormat:DateFormatRFC850];
    return self.dateFormatter2;
}

- (void)setDateFormatter3:(NSDateFormatter *)dateFormatter3 {
    objc_setAssociatedObject(self, @selector(dateFormatter3), dateFormatter3, OBJC_ASSOCIATION_RETAIN);
}

- (NSDateFormatter *)dateFormatter3 {
    NSDateFormatter *dateFormatter = objc_getAssociatedObject(self, @selector(dateFormatter3));
    if (dateFormatter) return dateFormatter;
    
    self.dateFormatter3 = [NSDateFormatter fixedDateFormatterWithDateFormat:DateFormatAsctime];
    return self.dateFormatter3;
}

- (NSDate *)dateForHTTPHeaderField:(HTTPHeaderField)field {
    NSString *string = self.allHeaderFields[field];
    NSDate *date = [self.dateFormatter1 dateFromString:string];
    if (date) return date;
    
    date = [self.dateFormatter2 dateFromString:string];
    if (date) return date;
    
    date = [self.dateFormatter3 dateFromString:string];
    return date;
}

@end










@implementation NSObject (URLTransaction)

- (void)setRequest:(NSURLRequest *)request {
    [self.request cancel];
    objc_setAssociatedObject(self, @selector(request), request, OBJC_ASSOCIATION_RETAIN);
}

- (NSURLRequest *)request {
    return objc_getAssociatedObject(self, @selector(request));
}

- (void)setTransaction:(URLTransaction *)transaction {
    [self.transaction cancel];
    objc_setAssociatedObject(self, @selector(transaction), transaction, OBJC_ASSOCIATION_RETAIN);
}

- (URLTransaction *)transaction {
    return objc_getAssociatedObject(self, @selector(transaction));
}

@end
