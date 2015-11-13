//
//  HotelInfoCell.m
//  URLTransaction
//
//  Created by Dan Kalinin on 08.11.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "HotelInfoCell.h"
#import "StarsView.h"



@interface HotelInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet StarsView *vStars;

@end



@implementation HotelInfoCell

- (void)setHotel:(Hotel *)hotel {
    _hotel = hotel;
    
    self.lblName.text = hotel.name;
    self.lblPrice.text = [NSString stringWithFormat:@"$%.f", hotel.price];
    self.vStars.stars = hotel.stars;
}

@end
