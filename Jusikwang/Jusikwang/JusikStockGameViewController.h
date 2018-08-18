//
//  JusikStockGameViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JusikGameController.h"
#import "JusikFavoriteStockView.h"

@class JusikStockMarket;
@class JusikPlayer;
@class JusikDBManager;
@class JusikFavoriteStockView;
@interface JusikStockGameViewController : UIViewController <JusikGameController, UITextFieldDelegate, JusikFavoriteStockViewDelegate>

@property (nonatomic, retain) IBOutlet JusikFavoriteStockView *favoriteView;
@property (nonatomic, retain) IBOutlet UIView *newsView;
@property (nonatomic, retain) IBOutlet UIView *newsBackgroundView;

@property (nonatomic, retain) IBOutlet UIButton *favoriteShowButton;
@property (nonatomic, retain) IBOutlet UILabel *gameTimeText;

@property (nonatomic, retain) IBOutlet UIView *worldMapView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UIView *resultView;

// stock info views
@property (nonatomic, retain) IBOutlet UIView *stockInfoView;
@property (nonatomic, retain) IBOutlet UILabel *stockInfoNameText;
@property (nonatomic, retain) IBOutlet UILabel *stockInfoPriceText;
@property (nonatomic, retain) IBOutlet UITextField *stockInfoCountText;
@property (nonatomic, retain) IBOutlet UILabel *stockInfoTypeText;
@property (nonatomic, retain) IBOutlet UILabel *stockInfoPurchasedText;
@property (nonatomic, retain) IBOutlet UIButton *stockInfoFavoriteAddButton;
@property (nonatomic, retain) IBOutlet UIButton *stockInfoFavoriteRemoveButton;

// market, player
@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, retain) JusikPlayer *player;

// date
@property (nonatomic, copy) NSDate *date;

// DB
@property (nonatomic, retain) JusikDBManager *db;

// game controller
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

// news
- (IBAction)newsSkip: (id)sender;
- (IBAction)newsParticipateStockMarket: (id)sender;

- (IBAction)resultButtonAction:(id)sender;

- (IBAction)toggleShowingFavoriteView: (id)sender;

- (IBAction)showStockInfo:(id)sender;
- (IBAction)hideStockInfo:(id)sender;

- (IBAction)buyStock:(id)sender;
- (IBAction)sellStock:(id)sender;

- (IBAction)addFavorite:(id)sender;
- (IBAction)removeFavorite:(id)sender;
@end

extern NSString *const JusikStockGameViewGameDidStartNotification;
extern NSString *const JusikStockGameViewPeriodDidUpdateNotification;
extern NSString *const JusikStockGameViewGameDidStopNotification;