//
//  URLTransaction.h
//  OAuth2
//
//  Created by Dan Kalinin on 01.04.16.
//  Copyright © 2016 Dan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <JSONSchema/JSONSchema.h>

FOUNDATION_EXPORT double URLTransactionVersionNumber;
FOUNDATION_EXPORT const unsigned char URLTransactionVersionString[];

#import <URLTransaction/Reachability.h>
#import <URLTransaction/Cache.h>

extern NSErrorDomain const HTTPErrorDomain;

extern NSString *const HTTPMethodOptions;
extern NSString *const HTTPMethodGet;
extern NSString *const HTTPMethodHead;
extern NSString *const HTTPMethodPost;
extern NSString *const HTTPMethodPut;
extern NSString *const HTTPMethodPatch;
extern NSString *const HTTPMethodDelete;
extern NSString *const HTTPMethodTrace;
extern NSString *const HTTPMethodConnect;

extern NSString *const HTTPHeaderFieldAccept;
extern NSString *const HTTPHeaderFieldAuthorization;
extern NSString *const HTTPHeaderFieldContentType;
extern NSString *const HTTPHeaderFieldIfModifiedSince;
extern NSString *const HTTPHeaderFieldLastModified;
extern NSString *const HTTPHeaderFieldDate;

extern NSString *const MediaTypeApplicationForm;
extern NSString *const MediaTypeApplicationJSON;

typedef NS_ENUM(NSInteger, HTTPStatusCode) {
    
    // Informational
    
    HTTPStatusCodeContinue = 100,
    HTTPStatusCodeSwitchingProtocols = 101,
    
    // Successful
    
    HTTPStatusCodeOK = 200,
    HTTPStatusCodeCreated = 201,
    HTTPStatusCodeAccepted = 202,
    HTTPStatusCodeNonAuthoritativeInformation = 203,
    HTTPStatusCodeNoContent = 204,
    HTTPStatusCodeResetContent = 205,
    HTTPStatusCodePartialContent = 206,
    
    // Redirection
    
    HTTPStatusCodeMultipleChoices = 300,
    HTTPStatusCodeMovedPermanently = 301,
    HTTPStatusCodeFound = 302,
    HTTPStatusCodeSeeOther = 303,
    HTTPStatusCodeNotModified = 304,
    HTTPStatusCodeUseProxy = 305,
    HTTPStatusCodeUnused = 306,
    HTTPStatusCodeTemporaryRedirect = 307,
    
    // Client error
    
    HTTPStatusCodeBadRequest = 400,
    HTTPStatusCodeUnathorized = 401,
    HTTPStatusCodePaymentRequired = 402,
    HTTPStatusCodeForbidden = 403,
    HTTPStatusCodeNotFound = 404,
    HTTPStatusCodeMethodNotAllowed = 405,
    HTTPStatusCodeNotAcceptable = 406,
    HTTPStatusCodeProxyAuthenticationRequired = 407,
    HTTPStatusCodeRequestTimeout = 408,
    HTTPStatusCodeConflict = 409,
    HTTPStatusCodeGone = 410,
    HTTPStatusCodeLengthRequired = 411,
    HTTPStatusCodePreconditionFailed = 412,
    HTTPStatusCodeRequestEntityTooLarge = 413,
    HTTPStatusCodeRequestURITooLong = 414,
    HTTPStatusCodeUnsupportedMediaType = 415,
    HTTPStatusCodeRequestRangeNotSatisfiable = 416,
    HTTPStatusCodeExpectationFailed = 417,
    
    // Server error
    
    HTTPStatusCodeInternalServerError = 500,
    HTTPStatusCodeNotImplemented = 501,
    HTTPStatusCodeBadGateway = 502,
    HTTPStatusCodeServiceUnavailable = 503,
    HTTPStatusCodeGatewayTimeout = 504,
    HTTPStatusCodeHTTPVersionNotSupported = 505
};










@interface NSURLRequest (URLTransaction)

typedef void (^URLRequestHandler)(__kindof NSURLRequest *);

- (instancetype)queue:(NSOperationQueue *)queue;
- (instancetype)moc:(NSManagedObjectContext *)moc;
- (instancetype)info:(id)info;
- (instancetype)success:(URLRequestHandler)success;
- (instancetype)failure:(URLRequestHandler)failure;
- (instancetype)completion:(URLRequestHandler)completion;

- (void)resume;
- (void)cancel;

@property (class, readonly) NSMutableDictionary<NSString *, NSURLComponents *> *baseComponents;
@property (readonly) NSOperationQueue *queue;
@property (readonly) NSManagedObjectContext *moc;
@property (readonly) id info;
@property (readonly) NSData *data;
@property (readonly) NSHTTPURLResponse *response;
@property (readonly) NSError *error;
@property (readonly) id json;
@property (readonly) UIImage *image;

- (NSDate *)dateForHTTPHeaderField:(NSString *)field;

- (void)setJSONSchema:(JSONSchema *)schema forStatusCode:(HTTPStatusCode)code;
- (JSONSchema *)JSONSchemaForStatusCode:(HTTPStatusCode)code;

@end










@interface URLTransaction : NSObject

typedef void (^URLTransactionHandler)(URLTransaction *);

- (instancetype)queue:(NSOperationQueue *)queue;
- (instancetype)moc:(NSManagedObjectContext *)moc;
- (instancetype)info:(id)info;
- (instancetype)addRequest:(NSURLRequest *)request;
- (instancetype)success:(URLTransactionHandler)success;
- (instancetype)failure:(URLTransactionHandler)failure;
- (instancetype)completion:(URLTransactionHandler)completion;

- (void)resume;
- (void)cancel;

@property (readonly) NSOperationQueue *queue;
@property (readonly) NSManagedObjectContext *moc;
@property (readonly) id info;
@property (readonly) NSArray *requests;
@property (readonly) NSError *error;

- (void)setJSONSchema:(JSONSchema *)schema forStatusCode:(HTTPStatusCode)code;
- (JSONSchema *)JSONSchemaForStatusCode:(HTTPStatusCode)code;

@end










@interface NSMutableURLRequest (URLTransaction)

- (void)setDate:(NSDate *)date forHTTPHeaderField:(NSString *)field;

@end










@interface NSHTTPURLResponse (URLTransaction)

- (NSDate *)dateForHTTPHeaderField:(NSString *)field;

@end
