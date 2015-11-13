//
//  NoReviewsCell.m
//  URLTransaction
//
//  Created by Dan Kalinin on 09.11.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "NoReviewsCell.h"



@interface NoReviewsCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblNoReviews;
@property (weak, nonatomic) IBOutlet UILabel *lblPullToRefresh;

@end



@implementation NoReviewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.contentView HUD:0].color = [UIColor clearColor];
    [self.contentView HUD:0].activityIndicatorColor = [UIColor grayColor];
}

#pragma mark - Accessors

- (void)setText:(NSString *)text {
    _text = text;
    self.lblNoReviews.text = text;
}

- (void)setRefreshing:(BOOL)refreshing {
    _refreshing = refreshing;
    
    self.lblNoReviews.hidden = refreshing;
    self.lblPullToRefresh.hidden = refreshing;
    
    if (refreshing) {
        [[self.contentView HUD:0] show:YES];
    } else {
        [[self.contentView HUD:0] hide:YES];
    }
}

@end
