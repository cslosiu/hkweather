//
//  ImageHolderVC.m
//  visualhkweather
//
//  Created by Siu LO on 12年5月22日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
// 
//  this view controller will be used as one page in the LandscapeViewController. 
// this holds one image showing a picture showing a measure in HK map.


#import "ImageHolderVC.h"

@implementation ImageHolderVC
@synthesize imageView, image;
@synthesize activityIndicator;

- (id) initWithImage:(UIImage*) a_image {
    self = [super initWithNibName:@"ImageHolderVC" bundle:[NSBundle mainBundle]];
    if (self) {
        self.image = a_image;
    }
    return self;
}

- (id) initWithImageURL:(NSString*)a_imageUrl {
    
    // creates the view controller with an image at the given URL.
    self = [super initWithNibName:@"ImageHolderVC" bundle:[NSBundle mainBundle]];
    if (self) {
        imageUrl = a_imageUrl;
    }
    return self;
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //activityIndicator.hidden = NO;
    //[activityIndicator startAnimating];
    
    // for async download image.
    /*
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] 
                                    initWithTarget:self 
                                    selector:@selector(loadImageFrom:) 
                                    object:url];
    
    [operationQueue addOperation:theOp];
     */
    [self.imageView setImage:self.image];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.imageView setImage:nil];
    self.imageView = nil;
    self.activityIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

/*
#pragma mark - NSoperation sync functions
- (void) stopActivity {
    //[activityIndicator stopAnimating];
    //activityIndicator.hidden = YES;
    [self.view setNeedsDisplay];
}

- (void) loadImageFrom:(NSURL*)url {
    NSLog(@"loading...");
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    [imageView setImage:image];
    
    NSLog(@"loadImageFrom complete: %@", url);
    [self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
    
}
 */

@end
