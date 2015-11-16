# URLTransaction

[![CI Status](http://img.shields.io/travis/DanKalinin/URLTransaction.svg?style=flat)](https://travis-ci.org/DanKalinin/URLTransaction)
[![Version](https://img.shields.io/cocoapods/v/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)
[![License](https://img.shields.io/cocoapods/l/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)
[![Platform](https://img.shields.io/cocoapods/p/URLTransaction.svg?style=flat)](http://cocoapods.org/pods/URLTransaction)

Simple, but powerful iOS networking framework.

## Description

URLTransaction library provides a convenient API to send single HTTP requests, group them into transactions and send them asynchronously. If one request in transaction fails - entire transaction fails.

**Features:**
* Convenient `Get-Map` pattern to construct requests using factory methods which allows to hold initialization and response mapping code in single class.
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
2. Lazy loading.
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

Next we should to prepare REST API requests and their responses mapping logic. This logic can be inplemented in single `URLRequest` category using Get-Map pattern.

```objectivec
@implementation URLRequest (Hotels)

+ (NSURLComponents *)baseComponents {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"http";
    components.host = @"my.hotels.com";
    return components;
}

#pragma mark - Get

+ (instancetype)getHotels {
    NSURLComponents *components = self.baseComponents;
    components.path = @"/hotels";
    
    URLRequest *request = [URLRequest requestWithURL:components.URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

+ (instancetype)getImage:(NSString *)ID {
    NSURLComponents *components = self.baseComponents;
    components.path = [NSString stringWithFormat:@"/image/%@", ID];
    
    URLRequest *request = [URLRequest requestWithURL:components.URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Accept"];
    return request;
}

+ (instancetype)getReview:(NSString *)ID {
    NSURLComponents *components = self.baseComponents;
    components.path = [NSString stringWithFormat:@"/review/%@", ID];
    
    URLRequest *request = [URLRequest requestWithURL:components.URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

#pragma mark - Map

- (NSArray<Hotel *> *)mapHotels {
    NSMutableArray *hotels = [NSMutableArray array];
    NSArray *objects = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    for (NSDictionary *object in objects) {
        Hotel *hotel = [Hotel new];
        hotel.ID = [object[@"id"] intValue];
        hotel.stars = [object[@"stars"] intValue];
        hotel.name = object[@"name"];
        hotel.price = [object[@"price"] floatValue];
        
        CLLocationDegrees latitude = [object[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [object[@"longitude"] doubleValue];
        hotel.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        NSMutableArray *images = [NSMutableArray array];
        for (NSString *ID in object[@"images"]) {
            Image *image = [Image new];
            image.ID = ID;
            [images addObject:image];
        }
        hotel.images = images;
        
        NSMutableArray *reviews = [NSMutableArray array];
        for (NSString *ID in object[@"reviews"]) {
            Review *review = [Review new];
            review.ID = ID;
            [reviews addObject:review];
        }
        hotel.reviews = reviews;
        
        [hotels addObject:hotel];
    }
    return hotels;
}

- (UIImage *)mapImage {
    return [UIImage imageWithData:self.data];
}

- (Review *)mapReview {
    Review *review = [Review new];
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    if (object) {
        review.ID = object[@"id"];
        review.user = object[@"user"];
        review.date = [NSDate dateWithTimeIntervalSince1970:[object[@"date"] doubleValue]];
        review.pros = object[@"pros"];
        review.cons = object[@"cons"];
        review.rating = [object[@"rating"] intValue];
    }
    return review;
}

@end
```

### Sending requests

Finally we should to perform neccessary requests, map responses to model objects and display results in UI.

* Hotels
```objectivec
// Show activity indicator

[[URLRequest getHotels] sendWithSuccess:^(URLRequest *request) {  // try
   self.hotels = [request mapHotels];
   // Reload table view, update UI
} failure:^(URLRequest *request) {                                // catch
   // Display error message
} completion:^(URLRequest *request) {                             // finally
   // Hide activity indicator
} queue:dispatch_get_main_queue()];
```

* First image
```objectivec
// Show activity indicator

[[URLRequest getImage:hotel.images.firstObject.ID] sendWithSuccess:^(URLRequest *request) {
   hotel.images.firstObject.image = [request mapImage];
   // Put image to table view cell
} failure:^(URLRequest *request) {
   // Display error placeholder
} completion:^(URLRequest *request) {
   // Hide activity indicator
} queue:dispatch_get_main_queue()];
```

* Reviews
```objectivec

// Show activity indicator

NSMutableArray *reviews = [NSMutableArray array];

for (Review *review in hotel.reviews) {
   [[URLRequest getReview:review.ID] addToTransaction:@10 success:^(URLRequest *request) {   // Add all review requests into transaction with ID 10. Transaction ID is used to retrieve it for later execution. Numeric or string values can be specified.
      [reviews addObject:[request mapReview]];                                               // Map every incomming response to review model object and add it to mutable array
   } failure:nil completion:nil];
}

[[URLTransaction transaction:@10] sendWithSuccess:^(URLTransaction *transaction) {           // Retrieve transaction by ID and execute it
   // Success block is called when all requests in tranction are completed successfully
   hotel.reviews = reviews;                                                                  // Assign mapped reviews to hotel object
   NSNumber *avgRating = [hotel valueForKeyPath:@"reviews.@avg.rating"];                     // Calculate average hotel rating
   // Put average rating value to table view cell
} failure:^(URLTransaction *transaction) {
   // Failure block is called when at least one request in transaction is failed
   // Display error placeholder
} completion:^(URLTransaction *transaction) {
   // Hide activity indicator
} queue:dispatch_get_main_queue()];
```

## Demo application

`pod try URLTransaction`

This project illustrates the steps described above and can be used as foundation to implement your applications based on `URLTransaction` library.

[![](https://dl.dropboxusercontent.com/s/1kh0tdoz44iwg6b/1.png)](https://dl.dropboxusercontent.com/s/xhllb2wsl8qscp9/1.png)
[![](https://dl.dropboxusercontent.com/s/ehtrzim4ovawamo/2.png)](https://dl.dropboxusercontent.com/s/inxfu2k36ld550b/2.png)
[![](https://dl.dropboxusercontent.com/s/nx7efr7dkxh27fw/3.png)](https://dl.dropboxusercontent.com/s/wid1ukuevw2b586/3.png)
[![](https://dl.dropboxusercontent.com/s/xefhxo2kfwp44d5/5.png)](https://dl.dropboxusercontent.com/s/95pu32h8ivdldx1/5.png)
[![](https://dl.dropboxusercontent.com/s/khivcargm88e7rs/6.png)](https://dl.dropboxusercontent.com/s/1gymrdokl55iowh/6.png)
[![](https://dl.dropboxusercontent.com/s/vizmh54wd4psmvh/7.png)](https://dl.dropboxusercontent.com/s/3vxinzr75x05v8v/7.png)

## Requirements

Library:
* iOS 7 and later
* ARC

Demo application:
* iOS 8 and later
* ARC

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
