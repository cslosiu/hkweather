//
//  CurrentStatus.m
//  visualhkweather
//
//  Created by Siu LO on 12年5月24日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//
//  manages the last saved current status information.

#import "CurrentStatus.h"

static CurrentStatus *sharedInstance = nil;

@implementation CurrentStatus
@synthesize callbackViewController;

#pragma mark - util functions

- (BOOL) xpathMatch:(NSString*)path atNegative:(int)n {
    // test if the path at previous node matches the given node.
    // n=0 means the last one.
    if (n < [xmlpaths count]) {
        return ([[xmlpaths objectAtIndex:[xmlpaths count]-n-1] isEqualToString:path]);
    }
    else {
        return NO;
    }
}

- (void) opLoadIcon:(NSString*)urlstr {
    NSURL *url = [NSURL URLWithString:urlstr];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [UIImage imageWithData:data];
    [icons setObject:img forKey:urlstr];
}

- (void) loadIcons {
    // load weather icons in concurrent threads
    // before calling this method, fill the 'icons' dictionary with URLs as keys.
    NSEnumerator *keys = [icons keyEnumerator];
    NSString *url;
    while ( ( url = (NSString*)[keys nextObject] )) {
        NSInvocationOperation *opLoad =[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(opLoadIcon:) object:url];
        [opQueue addOperation:opLoad];
    }
}

#pragma mark - xml parser delegate functions

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    // for holding the xml path
    NSLog(@"start xml doc");
    warnings = [[NSMutableArray alloc] initWithCapacity:2];
    severaldays =[[NSMutableArray alloc] initWithCapacity:7];
    xmlpaths = [[NSMutableArray alloc] initWithCapacity:10];
    xmltext = [[NSMutableString alloc] initWithString:@""];
    icons = [[NSMutableDictionary alloc] initWithCapacity:8];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [xmlpaths removeAllObjects];
    xmlpaths = nil;
    lastUpdated = [NSDate date];
    [self loadIcons]; 
    NSLog(@"end xml doc");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    [xmlpaths addObject:elementName];
    [xmltext setString:@""];
    if ([elementName isEqualToString:@"WeatherWarning"]) {
        tmpWarning = [WeatherWarning new];
    }
    else if ([elementName isEqualToString:@"WeatherForecast"]) {
        if ([self xpathMatch:@"SeveralDaysWeatherForecast" atNegative:1]) {
            tmpDayWeather = [DayWeather new];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    // gathering attributes of one day-weather
    if (tmpDayWeather) {
        if ([elementName isEqualToString:@"StartTime"]) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'+08:00'"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
            tmpDayWeather.updateDatetime = [dateFormatter dateFromString:[xmltext copy]];
        }
        else if ([elementName isEqualToString:@"StartTimeWeekday"]) {
            tmpDayWeather.weekdayIndex = [xmltext copy];
        }
        else if ([elementName isEqualToString:@"WeatherDescription"]) {
            tmpDayWeather.weatherDesc = [xmltext copy];
        }
        else if ([elementName isEqualToString:@"URL"]) {
            tmpDayWeather.iconUrlString = [xmltext copy];
            [icons setObject:@"" forKey:[xmltext copy]];
        }
        else if ([elementName isEqualToString:@"Type"]) {
            NXTag = [xmltext copy];
        }
        else if ([elementName isEqualToString:@"Measure"]) {
            if ([self xpathMatch:@"TemperatureInformation" atNegative:2]) {
                if ([NXTag isEqualToString:@"N"])
                    tmpDayWeather.tempMin = [xmltext copy];
                else tmpDayWeather.tempMax = [xmltext copy];
            }
            else if ([self xpathMatch:@"RelativeHumidityInformation" atNegative:2]) {
                if ([NXTag isEqualToString:@"N"])
                    tmpDayWeather.humiMin = [xmltext copy];
                else tmpDayWeather.humiMax = [xmltext copy];
            }
        }
        else if ([elementName isEqualToString:@"WeatherForecast"]) {
            // 7 day parent element
            [severaldays addObject:tmpDayWeather];
            tmpDayWeather = nil;
        }
    } // tmpDayWeather
    else {
        
        if ([elementName isEqualToString:@"Measure"]) {
            if ([self xpathMatch:@"CurrentWeather" atNegative:4]) {
                if ([self xpathMatch:@"TemperatureInformation" atNegative:2]) {
                    temperature = [xmltext copy];
                }
                else if ([self xpathMatch:@"RelativeHumidityInformation" atNegative:2]) {
                    humidity = [xmltext copy];
                }
            }
        }
        else if ([elementName isEqualToString:@"Api"]) {
            if ([self xpathMatch:@"GeneralStation" atNegative:1]) {
                apiGeneralValue = [xmltext copy];
            }
            else if ([self xpathMatch:@"RoadsideStation" atNegative:1]) {
                apiRoadValue = [xmltext copy];
            }
        }
        else if ([elementName isEqualToString:@"Description"]) {
            if ([self xpathMatch:@"GeneralStation" atNegative:1]) {
                apiGeneralDescription = [xmltext copy];
            }
            else if ([self xpathMatch:@"RoadsideStation" atNegative:1]) {
                apiRoadDescription = [xmltext copy];
            }
        }
        else if ([elementName isEqualToString:@"WeatherDescription"]) {
            if ([self xpathMatch:@"LocalWeatherForecast" atNegative:2]) {
                forecastDescription = [xmltext copy];
            }
        }
        else if ([elementName isEqualToString:@"LastUpdateTime"]) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            //[dateFormatter setLocale:enUSPOSIXLocale];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'+08:00'"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
            // [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            updateTime = [dateFormatter dateFromString:[xmltext copy]];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            updateTimeString = [dateFormatter stringFromDate:updateTime];
        }
        else if ([elementName isEqualToString:@"URL"] && [self xpathMatch:@"WeatherIcon" atNegative:1]) {
            NSString *urlstr = [xmltext copy];
            [icons setObject:@"" forKey:urlstr];
            if ([self xpathMatch:@"LocalWeatherForecast" atNegative:3]) {
                currentIconURL = urlstr;
            }
            if (tmpWarning != nil) {
                tmpWarning.iconURL = urlstr;
            }
        }
        else if ([elementName isEqualToString:@"Name"]) {
            if (tmpWarning != nil) {
                tmpWarning.name = [xmltext copy];
            }
        }
        else if ([elementName isEqualToString:@"InForce"]) {
            if (tmpWarning != nil) {
                tmpWarning.inForce = [xmltext copy];
            }
        }
        else if ([elementName isEqualToString:@"WeatherWarning"]) {
            [warnings addObject:tmpWarning];
            tmpWarning = nil;
        }
        
    } // tmpDayWeather
    

    //[xmltext setString:nil];
    [xmlpaths removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [xmltext appendString:string];
}

#pragma mark - class related
- (id) init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            xmlparser = nil;
            opQueue = [[NSOperationQueue alloc] init];
            [opQueue setMaxConcurrentOperationCount:4];
        }
        return self;
    }
}

- (void) dealloc {
    NSLog(@"CurrentStatus dealloc");
    opQueue = nil;
}

- (id)copyWithZone:(NSZone *)zone {
    // for singleton
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    // for singleton. to prevent someone manually alloc.
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }    
    // fail the memory allocation if called in 2nd time
    return nil;
}

+ (CurrentStatus*) sharedCurrentStatus  {
    @synchronized (self) {
        if (sharedInstance == nil) {
            // do not use the returned value.
            // see +allocWithZone
            [[self alloc] init];
        }
    }
    return sharedInstance;
}

#pragma mark - regular methods

- (NSString*) getpath:(NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    return path;
}

- (void) loadURL:(NSURL*)url toFile:(NSString*)filename {
    // load content of a URL and save to local file.
    NSData *data = [NSData dataWithContentsOfURL:url];
    BOOL written = [data writeToFile:[self getpath:filename] atomically:YES];
    NSString *msg = [NSString stringWithFormat:@"Error writing %@",filename];
    NSAssert(written, @"Error writing %@", msg);
    NSLog(@"Written: %@ => %@",url,filename);
}

/*
- (void) loadWarningFile {
    [self loadURL:[NSURL URLWithString:@"http://rss.weather.gov.hk/rss/WeatherWarningSummaryv2_uc.xml"] toFile:@"w.xml"];
}
*/

- (void) loadBasicInfoFile {
    // loading chinese version
    
    // throw away the existing parser to ensure reload
    if (xmlparser != nil)
        xmlparser = nil;
    
    NSLog(@"init XML parser.");
    xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.gov.hk/tc/weather.data.xml"]] ;
    xmlparser.delegate = self;
    NSLog(@"parse start");
    [xmlparser parse];
}

- (void) loadFromNetwork {
    // this method should be executed in BACKGROUND thread.
    
    // load latest information from internet.
    //NSInvocationOperation *opW = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadWarningFile) object:nil];
    NSInvocationOperation *opBasic =[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadBasicInfoFile) object:nil];
    //[opQueue addOperation:opW];
    [opQueue addOperation:opBasic];
    NSLog(@"added operation.");

    [opQueue waitUntilAllOperationsAreFinished];
    
    // call back
    if (self.callbackViewController) {
        [self.callbackViewController performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (int) getWarningCount {
    return [warnings count];
}

- (NSArray*) getWarnings {
    return warnings;
}


- (NSString*) getTemperatureReading {
    return temperature;
}

- (NSString*) getHumidityReading {
    return humidity;
}

- (NSString*) getReportText {
    return forecastDescription;
}

- (NSString*) getApiGeneral {
    return [NSString stringWithFormat:@"%@ %@", apiGeneralValue, apiGeneralDescription];
}

- (NSString*) getApiRoadside {
    return [NSString stringWithFormat:@"%@ %@", apiRoadValue, apiRoadDescription];
}

- (NSString*) getUpdateTime {
    // the timestamp in the xml data
    return updateTimeString;
}

- (UIImage*) getCurrentIcon {
    return [icons objectForKey:currentIconURL];
}

- (UIImage*) getIconFor:(NSString*)urlkey {
    return [icons objectForKey:urlkey];
}

- (NSArray*) getSeveralDays {
    return severaldays;
}

@end
