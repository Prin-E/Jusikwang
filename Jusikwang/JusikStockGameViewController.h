//
//  JusikStockGameViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JusikStockMarket;
@class JusikPlayer;
@interface JusikStockGameViewController : UIViewController

@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, retain) JusikPlayer *player;

- (void)play;

- (void)openMarket;
- (void)closeMarket;

- (IBAction)newsSkip: (id)sender;
- (IBAction)newsParticipateStockMarket: (id)sender;
@end
