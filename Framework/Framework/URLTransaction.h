//
//  URLTransaction.h
//  OAuth2
//
//  Created by Dan Kalinin on 01.04.16.
//  Copyright © 2016 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <JSONSchema/JSONSchema.h>

FOUNDATION_EXPORT double URLTransactionVersionNumber;
FOUNDATION_EXPORT const unsigned char URLTransactionVersionString[];

extern NSString *const HTTPErrorDomain;

extern NSString *const HTTPMethodGet;
extern NSString *const HTTPMethodPost;

extern NSString *const HTTPHeaderFieldAccept;
extern NSString *const HTTPHeaderFieldAuthorization;
extern NSString *const HTTPHeaderFieldContentType;
extern NSString *const HTTPHeaderFieldIfModifiedSince;
extern NSString *const HTTPHeaderFieldLastModified;
extern NSString *const HTTPHeaderFieldDate;

extern NSString *const MediaTypeApplicationForm;
extern NSString *const MediaTypeApplicationJSON;

typedef NS_ENUM(NSInteger, HTTPStatusCode) {
    HTTPStatusCodeOK = 200,
    
    HTTPStatusCodeNotModified = 304
};










@interface NSURLRequest (URLTransaction)

typedef void (^URLRequestHandler)(__kindof NSURLRequest *);

- (instancetype)queue:(NSOperationQueue *)queue;
- (instancetype)JSONSchema:(JSONSchema *)schema;
- (instancetype)moc:(NSManagedObjectContext *)moc;
- (instancetype)info:(id)info;
- (instancetype)success:(URLRequestHandler)success;
- (instancetype)failure:(URLRequestHandler)failure;
- (instancetype)completion:(URLRequestHandler)completion;

- (void)resume;
- (void)cancel;

@property (class, readonly) NSMutableDictionary<NSString *, NSURLComponents *> *baseComponents;
@property (readonly) NSOperationQueue *queue;
@property (readonly) JSONSchema *JSONSchema;
@property (readonly) NSManagedObjectContext *moc;
@property (readonly) id info;
@property (readonly) NSData *data;
@property (readonly) NSHTTPURLResponse *response;
@property (readonly) NSError *error;
@property (readonly) id json;

- (NSDate *)dateForHTTPHeaderField:(NSString *)field;

@end










@interface URLTransaction : NSObject

typedef void (^URLTransactionHandler)(URLTransaction *);

- (instancetype)queue:(NSOperationQueue *)queue;
- (instancetype)JSONSchema:(JSONSchema *)schema;
- (instancetype)moc:(NSManagedObjectContext *)moc;
- (instancetype)info:(id)info;
- (instancetype)addRequest:(NSURLRequest *)request;
- (instancetype)success:(URLTransactionHandler)success;
- (instancetype)failure:(URLTransactionHandler)failure;
- (instancetype)completion:(URLTransactionHandler)completion;

- (void)resume;
- (void)cancel;

@property (readonly) NSOperationQueue *queue;
@property (readonly) JSONSchema *JSONSchema;
@property (readonly) NSManagedObjectContext *moc;
@property (readonly) id info;
@property (readonly) NSArray *requests;
@property (readonly) NSError *error;

@end










@interface NSMutableURLRequest (URLTransaction)

- (void)setDate:(NSDate *)date forHTTPHeaderField:(NSString *)field;

@end










@interface NSHTTPURLResponse (URLTransaction)

- (NSDate *)dateForHTTPHeaderField:(NSString *)field;

@end
