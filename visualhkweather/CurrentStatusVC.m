//
//  CurrentStatusVC.m
//  visualhkweather
//
//  Created by Siu LO on 12年5月23日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CurrentStatusVC.h"
#import "CurrentStatus.h"

#define MY_BANNER_UNIT_ID @"a1526e7fe345df8"

@interface CurrentStatusVC ()

@end

@implementation CurrentStatusVC

// section id
const int SECTION_UPDATE = 0;
const int SECTION_WARNING = 1;
const int SECTION_BASIC = 2;
const int SECTION_REPORT = 3;
const int FONT_SIZE = 24;
const int REPORT_FONT_SIZE = 16;

#pragma mark - util

- (NSString*) getTemperatureDesc:(int)temp {
    NSString *d;
    if (temp <= 7) d = @"嚴寒";
    else if ((8 <= temp) && (temp <= 12)) d = @"寒冷";
    else if ((13 <= temp) && (temp <= 17)) d = @"清涼";
    else if ((18 <= temp) && (temp <= 22)) d = @"和暖";
    else if ((23 <= temp) && (temp <= 27)) d = @"溫暖";
    else if ((28 <= temp) && (temp <= 32)) d = @"炎熱";
    else if (33 <= temp)  d = @"酷熱";
    return d;
}

- (NSString*) getHumidityDesc:(int)reading {
    NSString *d;
    if (reading <= 40) d = @"非常乾燥";
    else if ((41 <= reading) && (reading <= 70)) d = @"乾燥";
    else if ((85 <= reading) && (reading <= 95)) d = @"潮濕";
    else if (96 <= reading)  d = @"非常潮濕";
    else d = @""; // no special words
    return d;
}

#pragma mark - life cycle


-(void) reloadData {
    NSLog(@"VC reloadData called");
    // call back function
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UITableView *t = (UITableView*) self.view;
    [t reloadData];
}

-(void) loadDataDo {
    [[CurrentStatus sharedCurrentStatus] loadFromNetwork];
}

-(void) loadData {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelectorInBackground:@selector(loadDataDo) withObject:nil];
}

-(void) viewWillAppear:(BOOL)animated {
    [CurrentStatus sharedCurrentStatus].callbackViewController = self;
    NSLog(@"callback set");
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad unit ID.
    bannerView_.adUnitID = MY_BANNER_UNIT_ID;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
    
    UITableView *view = (UITableView*) self.view;
    view.tableHeaderView = bannerView_;
    
    // other controls
    self.navigationItem.title = @"現時天氣";
    
    UIBarButtonItem *r = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
    self.navigationItem.leftBarButtonItem = r;
    
    [self loadData];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SECTION_UPDATE:
            break;
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section  {
    switch (section) {
        case SECTION_WARNING: 
            if ([[CurrentStatus sharedCurrentStatus] getWarningCount] > 0)
                return @"天氣警告";
            else {
                return nil;
            }
            break;
        case SECTION_BASIC:
            return @"概況";
            break;
        case SECTION_REPORT: 
            return @"本港天氣預告";
            break;
        default:
            return nil;
    }
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {    
}
 */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_REPORT) {
        NSString *cellText = [[CurrentStatus sharedCurrentStatus] getReportText];
        UIFont *cellFont = [UIFont systemFontOfSize:REPORT_FONT_SIZE];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
        float BUFFER = 80;
        return labelSize.height + BUFFER; 
    }
    else {
        return FONT_SIZE * 1.2 + 10.0; // default
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // when data is not yet ready, return default empty cell.
    if ([[CurrentStatus sharedCurrentStatus] getUpdateTime] == nil) {
        return cell;
    }
    
    // Set up the cell...
    NSString *label;
    NSString *value = nil;
    UIImage *icon = nil;
    
    //int margin = 0;
    
    switch (indexPath.section) {
        case SECTION_UPDATE: {
            cell.backgroundColor = [UIColor clearColor];
            // only 1 row.
            label = @"";
            value = [[CurrentStatus sharedCurrentStatus] getUpdateTime];
        }
            break;
        case SECTION_WARNING: {
            cell.backgroundColor = [UIColor yellowColor];
            NSArray *ws = [[CurrentStatus sharedCurrentStatus] getWarnings];
            WeatherWarning *w = [ws objectAtIndex:indexPath.row];
            icon = [[CurrentStatus sharedCurrentStatus] getIconFor:w.iconURL];
            label = w.name;
            value = nil;
            //margin = 5;
        }
            break;
        case SECTION_BASIC:
        {
            cell.backgroundColor = [UIColor clearColor];
            switch (indexPath.row) {
                case 0: {
                    NSString *tr = [[CurrentStatus sharedCurrentStatus] getTemperatureReading];
                    int t = [tr intValue];
                    label = @"氣溫";
                    value = [NSString stringWithFormat:@"%@℃ %@", tr, [self getTemperatureDesc:t]];
                }// temperature 
                             break;
                    
                case 1: {
                    NSString *hr = [[CurrentStatus sharedCurrentStatus] getHumidityReading];
                    int h = [hr intValue];
                    label = @"濕度";
                    value = [NSString stringWithFormat:@"%@%% %@", hr, [self getHumidityDesc:h] ];
                }// humi
                    break;
                case 2: // api
                    label = @"污染";
                    value = [[CurrentStatus sharedCurrentStatus] getApiGeneral];
                    break;
                case 3: // api
                    label = @"路邊";
                    value = [[CurrentStatus sharedCurrentStatus] getApiRoadside];
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_REPORT: {
            cell.backgroundColor = [UIColor clearColor];
            
            // one row only
            icon = [[CurrentStatus sharedCurrentStatus] getCurrentIcon];
            cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            cell.textLabel.numberOfLines = 0;
            value = nil;
            label = [[CurrentStatus sharedCurrentStatus] getReportText];
        }
            break;
        default:
            break;
    }
    [cell.textLabel setText:label];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    if (indexPath.section == SECTION_REPORT)
        cell.textLabel.font = [UIFont systemFontOfSize:REPORT_FONT_SIZE];
    else
        cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    
    [cell.detailTextLabel setText:value];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    
    // icon can be null
    [cell.imageView setImage:icon];
    if (icon) {
        CALayer * l = [cell.imageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:6.0];
    }
    
    /*
    if (margin > 0) {
        CGRect imageViewFrame = cell.imageView.frame;
        imageViewFrame.origin.x += margin;
        cell.imageView.frame = imageViewFrame;
    }
     */
    return cell;    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // sections: warning, basic, report text
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case SECTION_UPDATE:
            return 1;
        case SECTION_WARNING:
            rows = [[CurrentStatus sharedCurrentStatus] getWarningCount] ;
            break;
        case SECTION_BASIC: 
            rows = 4;
            break;
        case SECTION_REPORT: 
            rows = 1;
            break;
        default:
            break;
    }
    return rows;
}

#pragma mark - UITableViewDelegate methods




@end
