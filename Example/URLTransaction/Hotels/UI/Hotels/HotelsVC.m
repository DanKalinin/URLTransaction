//
//  HotelsVC.m
//  URLTransaction
//
//  Created by Dan Kalinin on 04.10.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "HotelsVC.h"
#import "HotelCell.h"
#import "HotelVC.h"
#import "URLTransaction.h"
#import "MBProgressHUD.h"



@interface HotelsVC ()

@property NSArray<Hotel *> *hotels;
@property BOOL firstLoad;

@end



@implementation HotelsVC

#pragma mark - View controller

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.tableView.backgroundView HUD:1].mode = MBProgressHUDModeText;
    [self.tableView.backgroundView HUD:1].labelText = @"Cannot load hotels";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 8.0, 0.0);
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.frame];
    label.text = @"Pull to refresh";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    self.tableView.backgroundView = label;
    self.tableView.backgroundView.hidden = YES;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(loadHotels) forControlEvents:UIControlEventValueChanged];
    
    self.firstLoad = YES;
    [[self.tableView.backgroundView HUD:0] show:YES];
    [self loadHotels];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(HotelCell *)cell {
    HotelVC *vc = segue.destinationViewController;
    vc.hotel = cell.hotel;
}

#pragma mark - Actions

- (void)loadHotels {
    [[URLRequest getHotels] sendWithSuccess:^(URLRequest *request) {
        self.hotels = [request mapHotels];
        [self.tableView reloadData];
        self.tableView.backgroundView.hidden = YES;
    } failure:^(URLRequest *request) {
        [[self.tableView.backgroundView HUD:1] show:YES];
        [[self.tableView.backgroundView HUD:1] hide:YES afterDelay:1.0];
        self.tableView.backgroundView.hidden = NO;
    } completion:^(URLRequest *request) {
        if (self.firstLoad) {
            [[self.tableView.backgroundView HUD:0] hide:YES];
            self.firstLoad = NO;
        } else {
            [self.refreshControl endRefreshing];
        }
    } queue:dispatch_get_main_queue()];
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hotels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HotelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Hotel Cell"];
    cell.tag = indexPath.row;
    cell.hotel = self.hotels[indexPath.row];
    return cell;
}

@end
