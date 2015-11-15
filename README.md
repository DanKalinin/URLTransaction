# URLTransaction

[![CI Status](http://img.shields.io/travis/DanKalinin/URLTransaction.svg?style=flat)](https://travis-ci.org/DanKalinin/URLTransaction)
[![Version](https://img.shields.io/cocoapods/v/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)
[![License](https://img.shields.io/cocoapods/l/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)
[![Platform](https://img.shields.io/cocoapods/p/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)

Simple, but powerful iOS networking framework.

## Description

URLTransaction library provides a convenient API to send single HTTP requests, group them into transactions and send them asynchronously. If one request in transaction fails - entire transaction fails.

**Features:**
* Convenient `Get-Map` pattern to construct request using factory methods which allows to hold initialization and response mapping code in single class.
* Requests can be sent immediately after creation or added into transaction for sending them asynchronously.
* Request and transaction objects have three completion blocks which allows to handle responses in `try-catch-finally` manner:
    * `success` - called when response HTTP status code is 200.
    * `failure` - called either when HTTP status code of response is other than 200, network problems occured or request timeout expired.
    * `completion` - called anyway to notify that request is completed. Can be used to hide activity indicator or clean some allocated resources.
* Every completion block receives the current request object itself as parameter, thus source request can be processed within block without capturing and creating an external weak request pointer.
* URLRequest has an `error` property which can be accessed in failure block to determine the failure reason.
* Possibility of specifying a dispatch queue where completion blocks should be executed. This is usefull when comletion blocks are used for mapping response to Core Data entities or for any other expensive operation.
* After completion of asynchronous transaction, request completion blocks will be called in the same order they were added into transaction. Finally, transaction completion blocks will be called. Request completion blocks can be used to map response body to Core Data entity. Transaction completion blocks can be used to establish relationships between mapped entities and save the context.

![](https://dl.dropboxusercontent.com/s/3y2c9nupbjdt3og/URLRequest.svg)

## Usage

### Problem

Consider, we develop an application showing reviews of hotels in different countries and have the following REST API:

* GET /hotels
```json
[
    {
        "id": 0,
        "stars": 3,
        "name": "Hotel Edison",
        "latitude": 40.759649,
        "longitude": -73.986130,
        "price": 363,
        "images": ["icc1ahyxdntbokw", "4hhdri604i8d1bl", "pcrgrkicohvef7j"],
        "reviews": ["s5q61xg82cqyyd5", "jv860jelyp01pb8", "92eo5x9dnaee762"]
    },
    {
        "id": 1,
        "stars": 4,
        "name": "Park Hotel Tokyo",
        "latitude": 35.663189,
        "longitude": 139.759555,
        "price": 287,
        "images": ["8jipxct9qbw67ru", "rw27z4nb35md3mi", "m4vfabpzfyj8yy3"],
        "reviews": ["euofdw2glov8se1", "0x9wc65h10cwv8n", "eou2rnq9ock03bm"]
    }
]
```

* GET /review/&lt;ID&gt;
```json
{
    "id": "y3oxlsdqma8w0dh",
    "user": "Jerzy",
    "date": 1423958400,
    "pros": "Forthcoming staff with decent English, great breakfasts, discreet service, clean room, nice relaxing view from the rooftop. Overall, hotel location in the neighborhood of Old Town whereas a bit off the beaches has many advantages.",
    "cons": "Not on the part of the hotel, but services by a collaborating tourist bureau could be better.",
    "rating": 8
}
```

* GET /image/&lt;ID&gt;

### Solution

All requests can be separated by execution time:

1. Primary loading.
   First we use `GET /hotels` request to populate the table view of master view controller with basic info about available hotels.
2. *Lazy loading.
   When basic hotel info is loaded we need to display the first image and average rating for all currently visible hotels. In order to do that we should to perform necessary requests passing the image and review IDs obtained from previous request. First image can be loaded by single `GET /image/<ID>` request. To calculate an average rating we should to load all hotel reviews using `GET /review/<ID>` request, but this is more difficult than making a single request. We should to perform them asynchronously and want to receive any notification when all responses are received. `URLTransaction` class gives this posibility to us.

### Model

First we should to create corresponding model objects:
* Hotel
```objectivec
@interface Hotel : NSObject

@property int ID;
@property float price;
@property int stars;
@property CLLocation *location;
@property NSString *name;
@property NSArray<Image *> *images;
@property NSArray<Review *> *reviews;

@end
```
* Review
```objectivec
@interface Review : NSObject

@property NSString *ID;
@property NSString *user;
@property NSDate *date;
@property NSString *pros;
@property NSString *cons;
@property int rating;

@end
```
* Image
```objectivec
@interface Image : NSObject

@property NSString *ID;
@property UIImage *image;

@end
```

### Get-Map pattern


## Demo application

description

screenshots

pod try








To run the example project, clone the repo, and run `pod install` from the Example directory first.

#### URLRequest

#### URLTransaction

```objective-c
@interface Department : NSObject

@property NSNumber *deptID;
@property NSString *name;
@property NSSet *employees;

@end
```

```objective-c
@interface Employee : NSObject

@property NSNumber *empID;
@property NSString *name;
@property NSDate *birthDay;

@end
```

```objective-c
@interface URLRequest (Company)

+ (instancetype)getDepartment:(NSNumber *)deptID;
+ (instancetype)getEmployee:(NSNumber *)empID;

- (Department *)mapDepartment;
- (Employee *)mapEmployee;

@end

@implementation URLRequest (Company)

#pragma mark - Build requests

+ (instancetype)getDepartment:(NSNumber *)deptID {
    
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"http";
    components.host = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Host"];       // Make sense to add your host to Info.plist
    components.path = [NSString stringWithFormat:@"/department/%i", deptID.intValue];
    
    URLRequest *request = [URLRequest requestWithURL:components.URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

+ (instancetype)getEmployee:(NSNumber *)empID {
    
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"http";
    components.host = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Host"];
    components.path = [NSString stringWithFormat:@"/employee/%i", empID.intValue];
    
    URLRequest *request = [URLRequest requestWithURL:components.URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

#pragma mark - Map responses

- (Department *)mapDepartment {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    if (json) {
        Department *department = [Department new];
        department.deptID = json[@"id"];
        department.name = json[@"name"];
        department.employees = json[@"employees"];
        return department;
    }
    return nil;
}

- (Employee *)mapEmployee {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    if (json) {
        Employee *employee = [Employee new];
        employee.empID = json[@"id"];
        employee.name = json[@"name"];
        employee.birthDay = [NSDate dateWithTimeIntervalSince1970:[json[@"dirthDay"] doubleValue]];
        return employee;
    }
    return nil;
}

@end
```

```objective-c
[[URLRequest getDepartment:@1] sendWithSuccess:^(URLRequest *request) {     // TRY:
    Department *department = [request mapDepartment];                       // Map response
                                                                            // Perform next request
    NSMutableSet *employees = [NSMutableSet set];
    
    for (NSNumber *empID in department.employees) {
        [[URLRequest getEmployee:empID] addToTransaction:@10 success:^(URLRequest *request) {   // Add to transaction with ID
            Employee *employee = [request mapEmployee];
            [employees addObject:employee];
        } failure:nil completion:nil];
    }
    
    [[URLTransaction transaction:@10] sendWithSuccess:^(URLTransaction *transaction) {          // Get transaction by ID & perform
        department.employees = employees;
    } failure:^(URLTransaction *transaction) {
        NSLog(@"Transaction failed - %@", transaction.error);
    } completion:^(URLTransaction *transaction) {
        // Hide activity indicator
    } queue:dispatch_get_main_queue()];
    
} failure:^(URLRequest *request) {                                          // CATCH:
    NSLog(@"Request failed - %@", request.error);                           // Process error
    
} completion:^(URLRequest *request) {                                       // FINALLY:
    // Hide activity indicator                                              // Perform cleanup
    
} queue:nil];
```

## Requirements

## Installation

URLTransaction is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "URLTransaction"
```

## Author

DanKalinin, daniil5511@gmail.com

## License

URLTransaction is available under the MIT license. See the LICENSE file for more info.
