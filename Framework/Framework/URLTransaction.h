//
//  URLTransaction.h
//  OAuth2
//
//  Created by Dan Kalinin on 01.04.16.
//  Copyright © 2016 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

FOUNDATION_EXPORT double URLTransactionVersionNumber;
FOUNDATION_EXPORT const unsigned char URLTransactionVersionString[];










@interface NSURLRequest (URLTransaction)

typedef void (^URLRequestHandler)(NSURLRequest *);

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

@end
