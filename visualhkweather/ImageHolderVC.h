//
//  ImageHolderVC.h
//  visualhkweather
//
//  Created by Siu LO on 12年5月22日.
//  Copyright (c) 2012年 City University Of Hong Kong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageHolderVC : UIViewController {
    IBOutlet UIImageView *imageView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    NSString *imageUrl;
    
    // for async download image
    NSOperationQueue *operationQueue;

}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;

- (id) initWithImage:(UIImage*) image;

//-(id) initWithImageURL:(NSString*)imageUrl;

@end
