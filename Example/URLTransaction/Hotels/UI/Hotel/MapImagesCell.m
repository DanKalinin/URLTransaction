//
//  MapImagesCell.m
//  URLTransaction
//
//  Created by Dan Kalinin on 07.11.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapImagesCell.h"



@interface MapImagesCell () <UIScrollViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property NSMutableArray<UIImageView *> *imageViews;
@property BOOL configured;

@end



@implementation MapImagesCell

- (void)refresh {
    [self loadImage:self.currentPage];
    [self centerMap:self.showMap];
}

#pragma mark - Accessors

- (NSInteger)currentPage {
    return self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
}

- (void)setShowMap:(BOOL)showMap {
    _showMap = showMap;
    
    self.scrollView.hidden = showMap;
    self.pageControl.hidden = showMap;
    self.mapView.hidden = !showMap;
    
    if (showMap) {
        [self centerMap:NO];
    }
}

#pragma mark - Scroll view

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = self.currentPage;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.hotel.images.count > 1) {
        NSInteger currentPage = self.currentPage;
        if (currentPage == 0) {
            [self loadImage:1];
        } else if (currentPage == self.hotel.images.count - 1) {
            [self loadImage:self.hotel.images.count - 2];
        } else {
            [self loadImage:currentPage - 1];
            [self loadImage:currentPage + 1];
        }
    }
}

#pragma mark - Map view

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        NSString *ID = @"Annotation view identifier";
        MKAnnotationView *av = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
        if (av) {
            av.annotation = annotation;
        } else {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ID];
            av.image = [UIImage imageNamed:@"Annotation"];
        }
        return av;
    } else {
        return nil;
    }
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.configured) {
        [self.contentView setNeedsLayout];
        [self.contentView layoutIfNeeded];
        
        self.scrollView.contentSize = CGSizeMake(self.hotel.images.count * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        self.pageControl.numberOfPages = self.hotel.images.count;
        self.imageViews = [NSMutableArray array];
        for (NSInteger page = 0; page < self.hotel.images.count; page++) {
            
            CGRect frame = CGRectMake(page * self.scrollView.frame.size.width, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.image = self.hotel.images[page].image;
            [self.scrollView addSubview:imageView];
            [self.imageViews addObject:imageView];
            
            [imageView HUD:1].mode = MBProgressHUDModeText;
            [imageView HUD:1].labelText = @"Cannot load image";
        }
        
        if (!self.hotel.images.firstObject.image) {
            [self loadImage:0];
        }
        
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = self.hotel.location.coordinate;
        [self.mapView addAnnotation:annotation];
        [self centerMap:YES];
        
        self.configured = YES;
    }
}

#pragma mark - Helpers

- (void)loadImage:(NSInteger)page {
    
    if (self.hotel.images[page].image) return;

    __weak UIImageView *iv = self.imageViews[page];
    [[iv HUD:1] hide:NO];
    [[iv HUD:0] show:NO];

    [[URLRequest getImage:self.hotel.images[page].ID] sendWithSuccess:^(URLRequest *request) {

        self.hotel.images[page].image = [request mapImage];
        iv.image = self.hotel.images[page].image;

    } failure:^(URLRequest *request) {

        [[iv HUD:1] show:NO];

    } completion:^(URLRequest *request) {

        [[iv HUD:0] hide:NO];

    } queue:dispatch_get_main_queue()];
}

- (void)centerMap:(BOOL)animated {
    MKCoordinateRegion region = MKCoordinateRegionMake(self.hotel.location.coordinate, MKCoordinateSpanMake(0.005, 0.005));
    [self.mapView setRegion:region animated:animated];
}

@end
