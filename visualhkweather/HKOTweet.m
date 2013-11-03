//
//  HKOTweet.m
//  visualhkweather
//
//  Created by Siu LO on 12年6月19日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import "HKOTweet.h"

@implementation HKOTweet

@synthesize text,url,timediff,timediffDate;

-(id) init {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE' 'MMM' 'dd' 'HH':'mm':'ss' +0000 'yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"EEE M'月'd'日 'HH':'mm"];
    [outputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
    return self;
}

-(void) setupTimeDiff {
    assert(self.timediff!=nil);
    self.timediffDate = [dateFormatter dateFromString:self.timediff];
    self.timediff = [outputFormatter stringFromDate:self.timediffDate];
}

-(void) removeURLFromText {
    NSMutableString *s = [NSMutableString stringWithString:self.text];
    NSRange r = [s rangeOfString:@"http:"];
    if (r.location != NSNotFound) {
        r.length = [s length] - r.location;
        [s deleteCharactersInRange:r];
        self.text = [s copy];
    }
}

@end
