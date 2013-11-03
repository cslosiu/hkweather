//
//  DayWeather.h
//  visualhkweather
//
//  Created by Siu LO on 12年6月4日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DayWeather : NSObject {
    
}

@property (nonatomic, retain) NSDate *updateDatetime;
@property (nonatomic, retain) NSString *weekdayIndex;
@property (nonatomic, retain) NSString *weatherDesc;
@property (nonatomic, retain) NSString *tempMin;
@property (nonatomic, retain) NSString *tempMax;
@property (nonatomic, retain) NSString *humiMin;
@property (nonatomic, retain) NSString *humiMax;
@property (nonatomic, retain) NSString *iconUrlString;


- (NSString*) getWeekdayString;


@end
