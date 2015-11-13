//
//  HotelVC.m
//  URLTransaction
//
//  Created by Dan Kalinin on 14.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "HotelVC.h"
#import "URLTransaction.h"
#import "MapImagesCell.h"
#import "HotelInfoCell.h"
#import "ReviewCell.h"
#import "NoReviewsCell.h"
#import "MBProgressHUD.h"



@interface HotelVC ()

@property (weak, nonatomic) IBOutlet UIButton *btnRating;
@property MapImagesCell *mapImagesCell;
@property HotelInfoCell *hotelInfoCell;
@property NoReviewsCell *noReviewsCell;

@end



@implementation HotelVC

#pragma mark - View controller

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.btnRating.bounds = CGRectMake(0.0, 0.0, 44.0, self.btnRating.bounds.size.height);
    self.btnRating.layer.cornerRadius = 3.0;
    [self.btnRating HUD:0].style = UIActivityIndicatorViewStyleWhite;
    [self.btnRating HUD:0].margin = self.btnRating.frame.size.width;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 8.0, 0.0);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64.0;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.mapImagesCell = [self.tableView dequeueReusableCellWithIdentifier:@"Map Images Cell"];
    self.mapImagesCell.hotel = self.hotel;
    
    self.hotelInfoCell = [self.tableView dequeueReusableCellWithIdentifier:@"Hotel Info Cell"];
    self.hotelInfoCell.hotel = self.hotel;
    
    self.noReviewsCell = [self.tableView dequeueReusableCellWithIdentifier:@"No Reviews Cell"];
    
    if (!self.hotel.images.firstObject.image) {
        [self.mapImagesCell refresh];
    }
    
    if (self.hotel.reviews.count) {
        if (self.hotel.loadedReviews.count) {
            [self setRating];
        } else {
            [self loadReviews];
        }
    } else {
        self.btnRating.hidden = YES;
    }
}

#pragma mark - Actions

- (IBAction)onSegmentChanged:(UISegmentedControl *)sender {
    self.mapImagesCell.showMap = sender.selectedSegmentIndex;
}

- (void)refresh {
    [self.mapImagesCell refresh];
    [self loadReviews];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else {
        if (self.hotel.reviews.count) {
            if (self.hotel.loadedReviews.count) {
                return self.hotel.reviews.count;
            } else {
                return 1;
            }
        } else {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.mapImagesCell;
    } else if (indexPath.section == 1) {
        return self.hotelInfoCell;
    } else {
        if (self.hotel.reviews.count) {
            if (self.hotel.loadedReviews.count) {
                ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Review Cell"];
                cell.review = self.hotel.reviews[indexPath.row];
                return cell;
            } else {
                self.noReviewsCell.text = @"Cannot load reviews";
                return self.noReviewsCell;
            }
        } else {
            self.noReviewsCell.text = @"No reviews";
            return self.noReviewsCell;
        }
    }
}

#pragma mark - Helpers

- (void)loadReviews {
    
    [self unsetRating];
    [[self.btnRating HUD:0] show:YES];
    self.noReviewsCell.refreshing = YES;
    
    for (Review *review in self.hotel.reviews) {
        [[URLRequest getReview:review.ID] addToTransaction:@10 success:nil failure:nil completion:nil];
    }
    
    [[URLTransaction transaction:@10] sendWithSuccess:^(URLTransaction *transaction) {
        NSMutableArray *reviews = [NSMutableArray array];
        for (URLRequest *request in transaction.requests) {
            [reviews addObject:[request mapReview]];
        }
        self.hotel.reviews = reviews;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self setRating];
    } failure:nil completion:^(URLTransaction *transaction) {
        [self.refreshControl endRefreshing];
        [[self.btnRating HUD:0] hide:YES];
        self.noReviewsCell.refreshing = NO;
    } queue:dispatch_get_main_queue()];
}

- (void)setRating {
    NSString *title = [NSString stringWithFormat:@"%.1f", self.hotel.avgRating];
    [self.btnRating setTitle:title forState:UIControlStateNormal];
}

- (void)unsetRating {
    [self.btnRating setTitle:nil forState:UIControlStateNormal];
}

@end
