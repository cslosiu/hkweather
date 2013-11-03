//
//  SevenDayVC.m
//  visualhkweather
//
//  Created by Siu LO on 12年5月23日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SevenDayVC.h"
#import "CurrentStatus.h"
#define FONT_SIZE 16
#define MARGIN    80

@interface SevenDayVC ()

@end

@implementation SevenDayVC



#pragma mark - life cycles

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

    self.navigationItem.title = @"七天預告";
    severaldays = [[CurrentStatus sharedCurrentStatus] getSeveralDays];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    severaldays = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - data source functions

/*
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect rect = cell.imageView.frame;
    rect.origin.x = 10.0f;
    cell.imageView.frame = rect;
    cell.imageView.center = rect.origin;
    NSLog(@"row: %d, x: %f", indexPath.row, cell.imageView.frame.origin.x);
}
 */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayWeather *day = [severaldays objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont systemFontOfSize:FONT_SIZE];
    CGSize constraintSize = CGSizeMake(320.0f, MAXFLOAT);
    CGSize labelSize = [day.weatherDesc sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
    return labelSize.height + MARGIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"7DayCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    
    // data
    DayWeather *day = [severaldays objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    
    NSString *wk = [day getWeekdayString];
    NSString *t1 = day.tempMin;
    NSString *t2 = day.tempMax;
    NSString *h1 = day.humiMin;
    NSString *h2 = day.humiMax;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"M月d日"];
    NSString *dt = [fmt stringFromDate:day.updateDatetime];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ (%@) ", dt, wk]];
    NSString *detail = [NSString stringWithFormat:@"%@~%@℃   %@~%@%% \n%@",
                        t1, t2, h1, h2, day.weatherDesc];
    [cell.detailTextLabel setText:detail];
    
    UIImage *icon = [[CurrentStatus sharedCurrentStatus] getIconFor:day.iconUrlString];
    [cell.imageView setImage:icon];
    
    CALayer * l = [cell.imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:6.0];
    
    // further customize
    cell.textLabel.textColor = [UIColor purpleColor];
    cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                                            
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [severaldays count];
}

@end
