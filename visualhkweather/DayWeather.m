//
//  DayWeather.m
//  visualhkweather
//
//  Created by Siu LO on 12年6月4日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import "DayWeather.h"

                           
@implementation DayWeather

@synthesize weekdayIndex,updateDatetime,humiMax,humiMin,tempMax,tempMin,weatherDesc,iconUrlString;

- (NSString*) getWeekdayString {
    NSArray *wknames = [NSArray arrayWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
    int w = [self.weekdayIndex intValue];
    if (0<=w && w<=6) {
        return [NSString stringWithFormat:@"%@", [wknames objectAtIndex:w]];
    }
    else {
        return [NSString stringWithFormat:@"第%d天", w];
    }
}

@end
