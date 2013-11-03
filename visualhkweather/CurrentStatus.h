//
//  CurrentStatus.h
//  visualhkweather
//
//  Created by Siu LO on 12年5月24日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherWarning.h"
#import "DayWeather.h"

@interface CurrentStatus : NSObject <NSXMLParserDelegate> {
    NSMutableArray *warnings; // see WeatherWarning class.
    NSMutableArray *severaldays; // see DayWeather class.
    
    NSMutableArray *xmlpaths; // during xml parsing
    NSXMLParser *xmlparser;
    NSMutableString *xmltext; // node content
    WeatherWarning *tmpWarning;
    DayWeather *tmpDayWeather; // element of 7-day forecast
    NSString *NXTag;            // record last reading type (N or X)
    
    // network stuff
    NSOperationQueue *opQueue;
    NSDate *lastUpdated;

    // value extracted
    NSString *temperature;
    NSString *humidity;
    NSString *forecastDescription;
    NSString *forecastIconURLString;    
    NSString *updateTimeString;
    NSDate *updateTime;
    
    // air pollution index
    NSString *apiGeneralValue;
    NSString *apiGeneralDescription;
    NSString *apiRoadValue;
    NSString *apiRoadDescription;
    
    // images. Key=URL, value=UIImage*
    NSMutableDictionary *icons;
    NSString *currentIconURL;
    
    
}

// set this to receive call back when data is loaded. the callback method
// must be '-(void) reloadData'.
@property (nonatomic, retain) UIViewController *callbackViewController;

// singleton class method
+ (CurrentStatus*) sharedCurrentStatus;

// update methods
- (void) loadFromNetwork;

// data retrieval methods
- (int) getWarningCount;
- (NSArray*) getWarnings;
- (NSString*) getTemperatureReading;
- (NSString*) getHumidityReading;
- (NSString*) getReportText;
- (NSString*) getApiGeneral;
- (NSString*) getApiRoadside;
- (NSString*) getUpdateTime;
- (UIImage*) getCurrentIcon;
- (UIImage*) getIconFor:(NSString*)urlkey;
- (NSArray*) getSeveralDays;
@end
