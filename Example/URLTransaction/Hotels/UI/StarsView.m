//
//  StarsView.m
//  URLTransaction
//
//  Created by Dan Kalinin on 04.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "StarsView.h"



@implementation StarsView

- (void)setStars:(NSUInteger)stars {
    _stars = stars;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat x = 0;
    UIColor *color;
    for (NSUInteger index = 0; index <= 5; index++) {
        if (index <= self.stars) {
            color = [UIColor colorWithRed:253.0/255 green:121.0/255 blue:26.0/255 alpha:1.0];
        } else {
            color = [UIColor blackColor];
        }
        
        UIBezierPath* starPath = [UIBezierPath bezierPath];
        [starPath moveToPoint:CGPointMake(x + 8.0, 0)];
        [starPath addLineToPoint:CGPointMake(x + 10.14, 5.06)];
        [starPath addLineToPoint:CGPointMake(x + 15.61, 5.53)];
        [starPath addLineToPoint:CGPointMake(x + 11.46, 9.12)];
        [starPath addLineToPoint:CGPointMake(x + 12.7, 14.47)];
        [starPath addLineToPoint:CGPointMake(x + 8.0, 11.64)];
        [starPath addLineToPoint:CGPointMake(x + 3.3, 14.47)];
        [starPath addLineToPoint:CGPointMake(x + 4.54, 9.12)];
        [starPath addLineToPoint:CGPointMake(x + 0.39, 5.53)];
        [starPath addLineToPoint:CGPointMake(x + 5.86, 5.06)];
        [starPath closePath];
        [color setFill];
        [starPath fill];
        
        x = 16.0 * index;
    }
}

@end
