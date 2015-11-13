//
//  HotelCell.m
//  URLTransaction
//
//  Created by Dan Kalinin on 04.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "HotelCell.h"
#import "StarsView.h"
#import "URLTransaction.h"
#import "MBProgressHUD.h"
#import "Geocoder.h"



@interface HotelCell ()

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *ivFlag;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblRating;
@property (weak, nonatomic) IBOutlet StarsView *vStars;
@property (nonatomic) Geocoder *geocoder;

@end



@implementation HotelCell

#pragma mark - Cell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lblRating.layer.cornerRadius = 3.0;
    
    self.ivFlag.layer.cornerRadius = 3.0;
    self.ivFlag.layer.borderWidth = 1.0;
    self.ivFlag.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.ivImage HUD:0].margin = self.ivImage.frame.size.width;
    
    [self.lblRating HUD:0].style = UIActivityIndicatorViewStyleWhite;
    [self.lblRating HUD:0].margin = self.lblRating.frame.size.width;
    
    [self.ivFlag HUD:0].style = UIActivityIndicatorViewStyleWhite;
    [self.ivFlag HUD:0].margin = self.ivFlag.frame.size.width;
}

- (void)prepareForReuse {
    self.ivImage.image = nil;
    self.lblRating.text = nil;
    self.ivFlag.image = nil;
    self.lblLocation.text = nil;
    if (self.geocoder.geocoding) {
        [self.geocoder cancelGeocode];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.baseView.backgroundColor = [UIColor colorWithRed:0.0 green:100.0/255.0 blue:255.0 alpha:0.3];
    } else {
        self.baseView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    }
}

#pragma mark - Accessors

- (void)setHotel:(Hotel *)hotel {
    _hotel = hotel;
    
    self.lblName.text = hotel.name;
    self.lblPrice.text = [NSString stringWithFormat:@"$%.f", hotel.price];
    self.vStars.stars = hotel.stars;
    
    NSInteger tag = self.tag;
    
    // Image
    UIImage *image = hotel.images.firstObject.image;
    if (image) {
        self.ivImage.image = image;
    } else {
        [[self.ivImage HUD:0] show:YES];
        [[URLRequest getImage:hotel.images.firstObject.ID] sendWithSuccess:^(URLRequest *request) {
            if (self.tag == tag) {
                hotel.images.firstObject.image = [request mapImage];
                self.ivImage.image = hotel.images.firstObject.image;
            }
        } failure:nil completion:^(URLRequest *request) {
            if (self.tag == tag) {
                [[self.ivImage HUD:0] hide:YES];
            }
        } queue:dispatch_get_main_queue()];
    }
    
    // Average rating
    if (hotel.reviews.count) {
        self.lblRating.hidden = NO;
        if (hotel.loadedReviews.count) {
            self.lblRating.text = [NSString stringWithFormat:@"%.1f", hotel.avgRating];
        } else {
            [[self.lblRating HUD:0] show:YES];
            NSMutableArray *reviews = [NSMutableArray array];
            for (Review *review in hotel.reviews) {
                [[URLRequest getReview:review.ID] addToTransaction:@10 success:^(URLRequest *request) {
                    if (self.tag == tag) {
                        [reviews addObject:[request mapReview]];
                    }
                } failure:nil completion:nil];
            }
            [[URLTransaction transaction:@10] sendWithSuccess:^(URLTransaction *transaction) {
                if (self.tag == tag) {
                    hotel.reviews = reviews;
                    self.lblRating.text = [NSString stringWithFormat:@"%.1f", hotel.avgRating];
                }
            } failure:nil completion:^(URLTransaction *transaction) {
                if (self.tag == tag) {
                    [[self.lblRating HUD:0] hide:YES];
                }
            } queue:dispatch_get_main_queue()];
        }
    } else {
        self.lblRating.hidden = YES;
    }
    
    // Location
    CLPlacemark *placemark = hotel.placemark;
    if (placemark) {
        self.ivFlag.image = [UIImage imageNamed:placemark.ISOcountryCode];
        self.lblLocation.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.ISOcountryCode];
    } else {
        [[self.ivFlag HUD:0] show:YES];
        [self.geocoder reverseGeocodeLocation:hotel.location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (self.tag == tag) {
                CLPlacemark *placemark = placemarks.firstObject;
                if (placemark) {
                    hotel.placemark = placemark;
                    self.ivFlag.image = [UIImage imageNamed:placemark.ISOcountryCode];
                    self.lblLocation.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.ISOcountryCode];
                }
                [[self.ivFlag HUD:0] hide:YES];
            }
        }];
    }
}

- (Geocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [Geocoder new];
    }
    return _geocoder;
}

@end
