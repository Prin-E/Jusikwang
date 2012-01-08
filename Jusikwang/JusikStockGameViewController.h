//
//  JusikStockGameViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JusikGameController.h"

@class JusikStockMarket;
@class JusikPlayer;
@interface JusikStockGameViewController : UIViewController <JusikGameController>

@property (nonatomic, retain) IBOutlet UIView *favoriteView;
@property (nonatomic, retain) IBOutlet UIView *newsView;
@property (nonatomic, retain) IBOutlet UIView *newsBackgroundView;

@property (nonatomic, retain) IBOutlet UIButton *favoriteShowButton;
@property (nonatomic, retain) IBOutlet UILabel *gameTimeText;

@property (nonatomic, retain) IBOutlet UIView *resultView;

@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, retain) JusikPlayer *player;

- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

- (IBAction)newsSkip: (id)sender;
- (IBAction)newsParticipateStockMarket: (id)sender;

- (IBAction)resultButtonAction:(id)sender;

- (IBAction)toggleShowingFavoriteView: (id)sender;
@end

extern NSString *const JusikStockGameViewGameDidStartNotification;
extern NSString *const JusikStockGameViewPeriodDidUpdateNotification;
extern NSString *const JusikStockGameViewGameDidStopNotification;