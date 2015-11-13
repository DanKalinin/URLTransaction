//
//  ReviewCell.m
//  URLTransaction
//
//  Created by Dan Kalinin on 09.11.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "ReviewCell.h"



@interface ReviewCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblUser;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblRating;
@property (weak, nonatomic) IBOutlet UIView *vPros;
@property (weak, nonatomic) IBOutlet UILabel *lblPros;
@property (weak, nonatomic) IBOutlet UIView *vCons;
@property (weak, nonatomic) IBOutlet UILabel *lblCons;
@property BOOL configured;

@end



@implementation ReviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.vPros.layer.cornerRadius = 0.5 * self.vPros.frame.size.height;
    self.vCons.layer.cornerRadius = 0.5 * self.vCons.frame.size.height;
}

- (void)setReview:(Review *)review {
    _review = review;
    self.lblUser.text = review.user;
    
    NSDateFormatter *fm = [NSDateFormatter new];
    fm.dateFormat = @"dd/MM/yyyy";
    self.lblDate.text = [fm stringFromDate:self.review.date];
    
    self.lblRating.text = [NSString stringWithFormat:@"%i", review.rating];
    self.lblPros.text = review.pros;
    self.lblCons.text = review.cons;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.configured) {
        [self.contentView setNeedsLayout];
        [self.contentView layoutIfNeeded];
        self.configured = YES;
    }
}

@end
