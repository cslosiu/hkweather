//
//  LandscapeViewController.m
//  visualhkweather
//
//  Created by Siu LO on 11年12月15日.
//  Copyright (c) 2011年 City University Of Hong Kong. All rights reserved.
//

#import "LandscapeViewController.h"
#import "ImageHolderVC.h"

@implementation LandscapeViewController
@synthesize scrollView, pageControl, viewControllers;

int kNumberOfPages = 0;  // init in ViewDidLoad()


#pragma mark - networking

// load a single image
-(void) loadImageOperation:(NSString*)urls {
    NSLog(@"loading %@", urls);
    NSURL *url = [NSURL URLWithString:urls];
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    [loadedImages setObject:img forKey:urls];
}


#pragma mark - life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // build the URLs
    imageURLStrings = [NSArray arrayWithObjects:
                       @"http://www.hko.gov.hk/wxinfo/ts/temp/tempchk.png", // temperature
                       @"http://www.hko.gov.hk/wxinfo/ts/temp/humidchk.png", // humidity
                       @"http://www.hko.gov.hk/wxinfo/ts/temp/maxichk.png",  // max temperature
                       @"http://www.hko.gov.hk/wxinfo/ts/temp/minichk.png",  // min temperature
                       @"http://www.hko.gov.hk/wxinfo/ts/grass/grasschk.png", // grass temperature
                       @"http://www.hko.gov.hk/wxinfo/ts/vis/vischk.png",     // visibility
                       nil];
    
    kNumberOfPages = [imageURLStrings count];
    
    // network loading
    if (opqueue == nil) {
        opqueue = [[NSOperationQueue alloc] init];
        [opqueue setMaxConcurrentOperationCount:kNumberOfPages];
        loadedImages  = [[NSMutableDictionary alloc] initWithCapacity:kNumberOfPages];
    }
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageOperation:) object:[imageURLStrings objectAtIndex:i]];
        [opqueue addOperation:op];
    }
    
    [opqueue waitUntilAllOperationsAreFinished];
    NSLog(@"all images loaded");
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    pageControl.hidden = NO;
    
    /*
    for (int i=0; i<kNumberOfPages; i++){
        [self loadScrollViewWithPage:i];
    }
     */
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        [self performSegueWithIdentifier:@"SegueToMain" sender:self];
    }
    
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
   // return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - scroll view delegates

- (void)loadScrollViewWithPage:(int)page {
    
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
    
    ImageHolderVC *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *) controller == [NSNull null]) {
        //controller = [[ImageHolderVC alloc] initWithImageURL:[imageURLStrings objectAtIndex:page]];
        UIImage *img = [loadedImages objectForKey:[imageURLStrings objectAtIndex:page]];
        controller = [[ImageHolderVC alloc] initWithImage:img];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    if (nil == controller.view.superview) {
        CGRect frame = controller.view.frame; //scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (pageControlUsed) {
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    pageControlUsed = YES;
    NSLog(@"changePage. now at page %d", page);
}

@end
