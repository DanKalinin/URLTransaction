//
//  UIView+Hotels.m
//  URLTransaction
//
//  Created by Dan Kalinin on 07.11.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "UIView+Hotels.h"



@implementation UIView (Hotels)

- (MBProgressHUD *)HUD:(NSInteger)tag {
    MBProgressHUD *HUD = [[MBProgressHUD allHUDsForView:self] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag = %ld", (long)tag]].firstObject;
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self];
        HUD.tag = tag;
        [self addSubview:HUD];
    }
    return HUD;
}

@end
