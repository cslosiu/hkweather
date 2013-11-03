//
//  SevenDayVC.h
//  visualhkweather
//
//  Created by Siu LO on 12年5月23日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#define MY_BANNER_UNIT_ID @"a1526e7fe345df8"

@interface SevenDayVC : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    GADBannerView *bannerView_;

    NSArray *severaldays;
}

@end
