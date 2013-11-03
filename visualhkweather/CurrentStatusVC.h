//
//  CurrentStatusVC.h
//  visualhkweather
//
//  Created by Siu LO on 12年5月23日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
@interface CurrentStatusVC : UIViewController <UITableViewDelegate, UITableViewDataSource> {
        GADBannerView *bannerView_;
}

-(void) reloadData;


@end
