//
//  MapImagesCell.h
//  URLTransaction
//
//  Created by Dan Kalinin on 07.11.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MapImagesCell : UITableViewCell

@property Hotel *hotel;
@property (nonatomic) BOOL showMap;
- (void)refresh;

@end
