# URLTransaction

[![CI Status](http://img.shields.io/travis/DanKalinin/URLTransaction.svg?style=flat)](https://travis-ci.org/DanKalinin/URLTransaction)
[![Version](https://img.shields.io/cocoapods/v/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)
[![License](https://img.shields.io/cocoapods/l/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)
[![Platform](https://img.shields.io/cocoapods/p/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)

## Description
![](https://www.dropbox.com/s/jhx6bruip81daa3/URLRequest%20.svg?dl=0&raw=1)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

#### URLRequest
![](https://www.dropbox.com/s/cosw9dw22smx3mi/URLRequest.png?dl=0)

#### URLTransaction
![](https://www.dropbox.com/s/mvffsqm18tmr0qf/URLTransaction.png?dl=0)

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
