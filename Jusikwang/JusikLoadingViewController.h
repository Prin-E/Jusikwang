//
//  JusikLoadingViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JusikStockMarket;
@class JusikPlayer;
@class JusikGameViewController;
@interface JusikLoadingViewController : UIViewController

@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, retain) JusikPlayer *player;

// UI
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;


// Load
- (BOOL)load;

@end

extern NSString *const JusikLoadingViewLoadDidCompleteNotification;