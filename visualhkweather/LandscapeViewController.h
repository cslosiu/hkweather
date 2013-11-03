//
//  LandscapeViewController.h
//  visualhkweather
//
//  Created by Siu LO on 11年12月15日.
//  Copyright (c) 2011年 City University Of Hong Kong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandscapeViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    BOOL pageControlUsed;

    // holds the URLs for each weather map images loaded to the scroll views.
    NSArray *imageURLStrings;
    
    // async loading
    NSOperationQueue *opqueue;
    NSMutableDictionary *loadedImages; 
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;

- (IBAction)changePage:(id)sender;

- (void)loadScrollViewWithPage:(int)page ;

@end
