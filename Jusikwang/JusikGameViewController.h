//
//  JusikGameViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JusikStatusBarController;
@class JusikStockMarket;
@class JusikPlayer;
@interface JusikGameViewController : UIViewController {
    BOOL _showingMenu;
}
// Cores
@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, retain) JusikPlayer *player;

// View Controllers
@property (nonatomic, retain) JusikStatusBarController *statusBarController;

// Outlets
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UIView *statusBarMenuView;

- (void)showMenu: (id)sender;

@end
