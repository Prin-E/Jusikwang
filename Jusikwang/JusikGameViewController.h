//
//  JusikGameViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JusikGameController.h"
#import "SlidingTabsControl.h"

typedef enum {
    JusikGamePlayStateStock,
    JusikGamePlayStateActivity
} JusikGamePlayState;

@class JusikViewController;
@class JusikStatusBarController;
@class JusikPlayerInfoViewController;
@class JusikStockGameViewController;
@class JusikActivityGameViewController;

@class JusikStockMarket;
@class JusikPlayer;
@interface JusikGameViewController : UIViewController <JusikGameController>

// Cores
@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, retain) JusikPlayer *player;

@property (nonatomic, readwrite) JusikGamePlayState gameState;

@property (nonatomic, copy) NSDate *date;
@property (nonatomic, readwrite) NSUInteger turn;

@property (nonatomic) BOOL showsTutorial;

// View Controllers
@property (nonatomic, assign) JusikViewController *viewController;
@property (nonatomic, retain) JusikStatusBarController *statusBarController;
@property (nonatomic, retain) JusikPlayerInfoViewController *piViewController;

@property (nonatomic, retain) JusikStockGameViewController *stockGameController;
@property (nonatomic, retain) JusikActivityGameViewController *activityGameController;

// Outlets
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UIView *statusBarMenuView;
@property (nonatomic, retain) IBOutlet UIView *menuView;

- (void)showMenu: (id)sender;

- (void)play;
- (void)pause;
- (void)pause;
- (void)stop;

- (void)nextDay;

- (void)showTutorial;

- (IBAction)exitGame:(id)sender;

- (void)stockGameDidStart: (NSNotification *)n;
- (void)stockGamePeriodDidUpdate: (NSNotification *)n;
- (void)stockGameDidEnd: (NSNotification *)n;

- (void)activityGameDidStart: (NSNotification *)n;
- (void)activityGameDidEnd: (NSNotification *)n;

@end
