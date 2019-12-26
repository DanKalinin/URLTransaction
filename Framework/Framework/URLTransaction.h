//
//  URLTransaction.h
//  OAuth2
//
//  Created by Dan Kalinin on 01.04.16.
//  Copyright © 2016 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double URLTransactionVersionNumber;
FOUNDATION_EXPORT const unsigned char URLTransactionVersionString[];

#import <Helpers/Helpers.h>
#import <JSONSchema/JSONSchema.h>

extern NSErrorDomain const HTTPErrorDomain;

typedef NSString * HTTPMethod NS_STRING_ENUM;
extern HTTPMethod const HTTPMethodOptions;
extern HTTPMethod const HTTPMethodGet;
extern HTTPMethod const HTTPMethodHead;
extern HTTPMethod const HTTPMethodPost;
extern HTTPMethod const HTTPMethodPut;
extern HTTPMethod const HTTPMethodPatch;
extern HTTPMethod const HTTPMethodDelete;
extern HTTPMethod const HTTPMethodTrace;
extern HTTPMethod const HTTPMethodConnect;

typedef NSString * HTTPHeaderField NS_STRING_ENUM;
extern HTTPHeaderField const HTTPHeaderFieldAccept;
extern HTTPHeaderField const HTTPHeaderFieldAuthorization;
extern HTTPHeaderField const HTTPHeaderFieldContentType;
extern HTTPHeaderField const HTTPHeaderFieldIfModifiedSince;
extern HTTPHeaderField const HTTPHeaderFieldLastModified;
extern HTTPHeaderField const HTTPHeaderFieldDate;
extern HTTPHeaderField const HTTPHeaderFieldHost;

typedef NSString * MediaType NS_STRING_ENUM;
extern MediaType const MediaTypeApplicationForm;
extern MediaType const MediaTypeApplicationJSON;

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
    HTTPStatusCodeMultiStatus = 207,
    HTTPStatusCodeAlreadyReported = 208,
    
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

- (instancetype)session:(NSURLSession *)session;
- (instancetype)queue:(NSOperationQueue *)queue;
- (instancetype)info:(id)info;
- (instancetype)blocking:(BOOL)blocking;
- (instancetype)success:(URLRequestHandler)success;
- (instancetype)failure:(URLRequestHandler)failure;
- (instancetype)completion:(URLRequestHandler)completion;

- (void)resume;
- (void)cancel;

@property (class, readonly) NSMutableDictionary<NSString *, NSURLComponents *> *baseComponents;
@property (readonly) NSOperationQueue *queue;
@property (readonly) id info;
@property (readonly) NSData *data;
@property (readonly) NSHTTPURLResponse *response;
@property (readonly) NSError *error;
@property (readonly) NSString *raw;

- (NSDate *)dateForHTTPHeaderField:(HTTPHeaderField)field;

- (void)setJSONSchema:(JSONSchema *)schema forStatusCode:(HTTPStatusCode)code;
- (JSONSchema *)JSONSchemaForStatusCode:(HTTPStatusCode)code;

@end










@interface URLTransaction : NSObject

typedef void (^URLTransactionHandler)(URLTransaction *);

- (instancetype)session:(NSURLSession *)session;
- (instancetype)queue:(NSOperationQueue *)queue;
- (instancetype)info:(id)info;
- (instancetype)blocking:(BOOL)blocking;
- (instancetype)addRequest:(NSURLRequest *)request;
- (instancetype)success:(URLTransactionHandler)success;
- (instancetype)failure:(URLTransactionHandler)failure;
- (instancetype)completion:(URLTransactionHandler)completion;

- (void)resume;
- (void)cancel;

@property (readonly) NSOperationQueue *queue;
@property (readonly) id info;
@property (readonly) NSArray *requests;
@property (readonly) NSError *error;

@property (weak, readonly) NSURLRequest *failedRequest;

- (void)setJSONSchema:(JSONSchema *)schema forStatusCode:(HTTPStatusCode)code;
- (JSONSchema *)JSONSchemaForStatusCode:(HTTPStatusCode)code;

@end










@interface BasicCredential : Credential

@property NSString *user;
@property NSString *password;

@end










@interface NSMutableURLRequest (URLTransaction)

- (void)setDate:(NSDate *)date forHTTPHeaderField:(HTTPHeaderField)field;
- (void)setCredential:(Credential *)credential forHTTPHeaderField:(HTTPHeaderField)field;

@end










@interface NSHTTPURLResponse (URLTransaction)

- (NSDate *)dateForHTTPHeaderField:(HTTPHeaderField)field;

@end










@interface NSObject (URLTransaction)

@property NSURLRequest *request;
@property URLTransaction *transaction;

@end
