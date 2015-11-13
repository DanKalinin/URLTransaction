//
//  URLTransactionTests.m
//  URLTransactionTests
//
//  Created by DanKalinin on 11/13/2015.
//  Copyright (c) 2015 DanKalinin. All rights reserved.
//

@import XCTest;
#import "URLTransaction.h"
#import "URLRequest+Hotels.h"



@interface Tests : XCTestCase

@property NSArray<Hotel *> *hotels;

@end



@implementation Tests

- (void)setUp {
    [super setUp];
    
    XCTestExpectation *hotelsExpectation = [self expectationWithDescription:@"Hotels Expectation"];
    
    [[URLRequest getHotels] sendWithSuccess:^(URLRequest *request) {
        XCTAssertNil(request.error);
        XCTAssertEqual(200, request.response.statusCode);
        self.hotels = [request mapHotels];
        XCTAssertEqual(10, self.hotels.count);
    } failure:^(URLRequest *request) {
        XCTAssertNotNil(request.error);
        XCTAssertNotEqual(200, request.response.statusCode);
    } completion:^(URLRequest *request) {
        [hotelsExpectation fulfill];
    } queue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testRequest {
    if (self.hotels.count) {
        
        Image *image = self.hotels.firstObject.images.firstObject;
        XCTAssertNotNil(image);
        
        XCTestExpectation *imageExpectation = [self expectationWithDescription:@"Image Expectation"];
        
        [[URLRequest getImage:image.ID] sendWithSuccess:^(URLRequest *request) {
            XCTAssertNil(request.error);
            XCTAssertEqual(200, request.response.statusCode);
            UIImage *image = [request mapImage];
            XCTAssertNotNil(image);
            XCTAssertEqualWithAccuracy(404.0, image.size.width, 1.0);
            XCTAssertEqualWithAccuracy(500.0, image.size.height, 1.0);
        } failure:^(URLRequest *request) {
            XCTAssertNotNil(request.error);
            XCTAssertNotEqual(200, request.response.statusCode);
        } completion:^(URLRequest *request) {
            [imageExpectation fulfill];
        } queue:dispatch_get_main_queue()];
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }
}

- (void)testTransaction {
    if (self.hotels.count) {
        
        NSArray<Review *> *reviews = self.hotels.firstObject.reviews;
        XCTAssertGreaterThan(reviews.count, 0);
        
        XCTestExpectation *reviewsExpectation = [self expectationWithDescription:@"Reviews Expectation"];
        
        NSMutableArray<Review *> *loadedReviews = [NSMutableArray array];
        
        for (Review *review in reviews) {
            [[URLRequest getReview:review.ID] addToTransaction:@20 success:^(URLRequest *request) {
                XCTAssertNil(request.error);
                XCTAssertEqual(200, request.response.statusCode);
                [loadedReviews addObject:[request mapReview]];
            } failure:^(URLRequest *request) {
                XCTAssertNotNil(request.error);
                XCTAssertNotEqual(200, request.response.statusCode);
            } completion:nil];
        }
        
        [[URLTransaction transaction:@20] sendWithSuccess:^(URLTransaction *transaction) {
            XCTAssertNil(transaction.error);
            XCTAssertEqual(reviews.count, loadedReviews.count);
            XCTAssertEqualObjects(@"Marina", loadedReviews.firstObject.user);
        } failure:^(URLTransaction *transaction) {
            XCTAssertNotNil(transaction.error);
        } completion:^(URLTransaction *transaction) {
            [reviewsExpectation fulfill];
        } queue:dispatch_get_main_queue()];
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }
}

@end
