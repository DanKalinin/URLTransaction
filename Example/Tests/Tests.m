//
//  AppTests.m
//  AppTests
//
//  Created by Dan Kalinin on 03.08.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>



@interface URLRequestTests : XCTestCase {
@private
    int a;
    int b;
    
    NSString *first;
    NSString *last;
}

@end



@implementation URLRequestTests

- (void)setUp {
    [super setUp];
    
    a = 20;
    b = 5;
    
    first = @"John";
    last = @"Taylor";
}

- (void)tearDown {
    a = b = 0;
    
    first = last = nil;
    
    [super tearDown];
}

- (void)testAddition {
    XCTAssertEqual(a + b, 25, @"Addition failed");
}

- (void)testSubtraction {
    XCTAssertEqual(a - b, 15, @"Subtraction failed");
}

- (void)testDivision {
    XCTAssertEqual(a / b, 4, @"Division failed");
}

- (void)testMultiplication {
    XCTAssertEqual(a * b, 100, @"Multiplication failed");
}

- (void)testName {
    XCTAssertNotNil(first, @"Empty first name");
    XCTAssertNotNil(last, @"Empty last name");
}

- (void)testNameIsJohn {
    XCTAssertEqualObjects(first, @"John", @"Name is not John");
}

@end
