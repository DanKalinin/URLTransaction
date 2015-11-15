# URLTransaction

[![CI Status](http://img.shields.io/travis/DanKalinin/URLTransaction.svg?style=flat)](https://travis-ci.org/DanKalinin/URLTransaction)
[![Version](https://img.shields.io/cocoapods/v/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)
[![License](https://img.shields.io/cocoapods/l/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)
[![Platform](https://img.shields.io/cocoapods/p/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)

## Demo application

description

screenshots

pod try

### API

1. GET /hotels
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

2. GET /review/&lt;ID&gt;
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

3. GET /image/&lt;ID&gt;

## Description

![](https://www.dropbox.com/s/3y2c9nupbjdt3og/URLRequest.svg?raw=1)

## Usage

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
