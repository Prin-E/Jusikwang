//
//  JusikGameViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlidingTabsControl.h"

typedef enum {
    JusikGamePlayStateStock,
    JusikGamePlayStateActivity
} JusikGamePlayState;

@class JusikViewController;
@class JusikStatusBarController;
@class JusikPlayerInfoViewController;
@class JusikStockGameViewController;

@class JusikStockMarket;
@class JusikPlayer;
@interface JusikGameViewController : UIViewController

// Cores
@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, retain) JusikPlayer *player;

// View Controllers
@property (nonatomic, assign) JusikViewController *viewController;
@property (nonatomic, retain) JusikStatusBarController *statusBarController;
@property (nonatomic, retain) JusikPlayerInfoViewController *piViewController;

@property (nonatomic, retain) JusikStockGameViewController *stockGameController;

// Outlets
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UIView *statusBarMenuView;
@property (nonatomic, retain) IBOutlet UIView *menuView;

- (void)showMenu: (id)sender;

- (IBAction)exitGame:(id)sender;
@end
