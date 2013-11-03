//
//  NewsViewController.h
//  visualhkweather
//
//  Created by Siu LO on 12年6月14日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKOTweet.h"
#import "GADBannerView.h"
#define MY_BANNER_UNIT_ID @"a1526e7fe345df8"

@interface NewsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate> {
    
    NSMutableArray *xmlpaths; // during xml parsing
    NSXMLParser *xmlparser;
    NSMutableString *xmltext; // node content
    NSOperationQueue *opQueue;
    
    BOOL matchTimestamp;
    BOOL matchText;

    BOOL withinItemTag;
    HKOTweet *tmpTweet;
    NSMutableArray *tweets;
    
    GADBannerView *bannerView_;

}

@end
