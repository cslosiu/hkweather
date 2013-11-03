//
//  NewsViewController.m
//  visualhkweather
//
//  Created by Siu LO on 12年6月14日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//
// change
// 2013/10/22, change to load RSS as Twitter api changed to 1.1

#import <QuartzCore/QuartzCore.h>
#import "NewsViewController.h"
#import "NewsWebViewController.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

const int CELL_FONT_SIZE = 18;

#pragma mark - util

- (float) getCellHeightFor:(NSString*)text {
    UIFont *cellFont = [UIFont systemFontOfSize:CELL_FONT_SIZE];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
    return labelSize.height + 30.0f; // for top/bottom margin 
}

- (void) loadUpdatesDo {
    if (xmlparser != nil) {
        xmlparser = nil;
    }

    NSLog(@"init XML parser for loading RSS.");
    withinItemTag = NO;
    xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://rss.weather.gov.hk/rss/whatsnew_uc.xml"]];
    xmlparser.delegate = self;
    
    [xmlparser parse];
}

- (void) loadUpdates {
    [self performSelectorInBackground:@selector(loadUpdatesDo) withObject:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - view life cycle

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

    /////////////
    
    UIBarButtonItem *loadbtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadUpdates)];
    self.navigationItem.leftBarButtonItem = loadbtn;
    
    [self.navigationItem setTitle:@"最新消息"];
    [self loadUpdates];
    
    /*
    opQueue = [[NSOperationQueue alloc] init];
    [opQueue setMaxConcurrentOperationCount:2];
    
    NSInvocationOperation *opBasic =[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadUpdates) object:nil];
    [opQueue addOperation:opBasic];
    NSLog(@"added operation.");
     */

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

-(void) stopNetworkIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - xml parser functions

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    xmlpaths = [[NSMutableArray alloc] initWithCapacity:20];
    xmltext = [[NSMutableString alloc] initWithString:@""];
    tweets = [[NSMutableArray alloc] initWithCapacity:20];
}

-(void) parserDidEndDocument:(NSXMLParser *)parser {
    [xmlpaths removeAllObjects];
    xmlpaths = nil;
    [self performSelectorOnMainThread:@selector(stopNetworkIndicator) withObject:nil waitUntilDone:NO];
    UITableView *tv = (UITableView*) self.view;
    [tv reloadData];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    [xmlpaths addObject:elementName];
    [xmltext setString:@""];
   // NSLog(@"parse start element %@ %@",elementName,[attributeDict description]);
    
    if ([elementName isEqualToString:@"item"]) {
        withinItemTag = YES;
        tmpTweet = [HKOTweet new];
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    if (tmpTweet != nil) {
        if ([elementName isEqualToString:@"item"]) {
            withinItemTag = NO;
            [tweets addObject:tmpTweet];
            //tmpTweet = nil;
        }
        else if ([elementName isEqualToString:@"link"]) {
            tmpTweet.url = [xmltext copy];
            
        }
        else if ([elementName isEqualToString:@"description"] && withinItemTag) {
            //[tmpTweet removeURLFromText];
            tmpTweet.text = [xmltext copy];
        }
    }
    // pop the path record.
    [xmlpaths removeLastObject];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [xmltext appendString:string];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"ERROR: %@", [parseError description]);
}

#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showWeb"]) {
        NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
        HKOTweet *tw = [tweets objectAtIndex:ip.row];
        NewsWebViewController *c = [segue destinationViewController];
        //[c.navigationItem setTitle:tw.url];
        NSLog(@"URL: %@", tw.url);
        UIWebView *web = (UIWebView*) c.view;
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tw.url]]];
    }
    
}

#pragma mark - table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showWeb" sender:self];
}

#pragma mark - table data source
/*
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //if ([[cell.layer sublayers] count] < 2) {
        // set gradient
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = cell.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor]CGColor], (id)[[UIColor lightGrayColor]CGColor], nil];
        [cell.layer insertSublayer:gradient below:cell.backgroundView.layer];
    //}
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HKOTweet *tw = [tweets objectAtIndex:indexPath.row];
    float h = [self getCellHeightFor:tw.text];
    return h;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"tweetCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    HKOTweet *tw = [tweets objectAtIndex:indexPath.row];

    cell.backgroundColor = [UIColor whiteColor];

    // further customization
    cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    cell.textLabel.numberOfLines = 0;
    [cell.textLabel setText:tw.text];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
    
    [cell.detailTextLabel setText:tw.timediff];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
    
    if (tw.url != nil) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}



@end
