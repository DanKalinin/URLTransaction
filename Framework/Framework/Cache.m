//
//  Cache.m
//  Framework
//
//  Created by Dan Kalinin on 1/12/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import "Cache.h"
#import "URLTransaction.h"










@interface NSData (URLTransactionSelectors)

@property (class, readonly) NSString *cachePath;

@end



@implementation NSData (URLTransaction)

static NSString *_cachePath = nil;

+ (NSString *)cachePath {
    if (_cachePath) return _cachePath;
    
    NSURL *URL = NSFileManager.defaultManager.userCachesDirectoryURL;
    NSString *dir = NSStringFromClass(URLTransaction.class);
    URL = [URL URLByAppendingPathComponent:dir];
    _cachePath = URL.path;
    return _cachePath;
}

+ (void)dataWithContentsOfURL:(NSURL *)URL completion:(DataBlock)completion {
    
    NSString *name = [URL.absoluteString digest:DigestMD5].string;
    NSString *path = [self.cachePath stringByAppendingPathComponent:name];
    
    NSFileManager *fm = NSFileManager.defaultManager;
    NSDictionary *attributes = [fm attributesOfItemAtPath:path error:nil];
    NSDate *date;
    if (attributes) {
        date = [attributes fileModificationDate];
    } else {
        date = [NSDate distantPast];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [request setDate:date forHTTPHeaderField:HTTPHeaderFieldIfModifiedSince];
    [request completion:^(NSURLRequest *request) {
        
        NSData *data;
        
        if (request.data.length > 0) {
            NSDate *date = [request.response dateForHTTPHeaderField:HTTPHeaderFieldLastModified];
            
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            attributes[NSFileModificationDate] = date;
            
            [fm createDirectoryAtPath:self.cachePath withIntermediateDirectories:YES attributes:nil error:nil];
            [fm createFileAtPath:path contents:request.data attributes:attributes];
            
            data = request.data;
        } else {
            data = [NSData dataWithContentsOfFile:path];
        }
        
        [self invokeHandler:completion data:data];
        
    }];
    [request resume];
}

@end










@implementation UIImage (URLTransaction)

+ (void)imageWithContentsOfURL:(NSURL *)URL completion:(ImageBlock)completion {
    [NSData dataWithContentsOfURL:URL completion:^(NSData *data) {
        UIImage *image = [UIImage imageWithData:data];
        [self invokeHandler:completion image:image];
    }];
}

@end
