//
//  HKOTweet.h
//  visualhkweather
//
//  Created by Siu LO on 12年6月19日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKOTweet : NSObject {
    NSDateFormatter* dateFormatter ;
    NSDateFormatter* outputFormatter;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *timediff;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDate *timediffDate;


-(void) setupTimeDiff ;
-(void) removeURLFromText;

@end
