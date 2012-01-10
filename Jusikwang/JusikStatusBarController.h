//
//  JusikStatusBarController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 1..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JusikStatusBarModeStockTime,
    JusikStatusBarModeActivity
} JusikStatusBarMode;

@class JusikStockMarket;
@class JusikPlayer;
@interface JusikStatusBarController : UIViewController

// 주식시장
@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, retain) JusikPlayer *player;

@property (nonatomic, copy) NSDate *date;

@property (nonatomic, readwrite) JusikStatusBarMode mode;

// 상태 뷰
@property (nonatomic, retain) IBOutlet UIView *statusContainerView;
@property (nonatomic, retain) IBOutlet UIButton *statusBarButton;

@property (nonatomic, assign) UIView *currentStatusView;
// 주식 상태 뷰들
@property (nonatomic, retain) IBOutlet UIView *stockTimeStatusView;

@property (nonatomic, retain) IBOutlet UILabel *stockTimeMoneyText;
@property (nonatomic, retain) IBOutlet UILabel *stockTimeKospiText;
@property (nonatomic, retain) IBOutlet UILabel *stockTimeDowText;
@property (nonatomic, retain) IBOutlet UILabel *stockTimeExchangeText;
@property (nonatomic, retain) IBOutlet UILabel *stockTimeDateText;

// 활동 상태 뷰들
@property (nonatomic, retain) IBOutlet UIView *activityTimeStatusView;

@property (nonatomic, retain) IBOutlet UILabel *activityTimeMoneyText;
@property (nonatomic, retain) IBOutlet UILabel *activityTimeIntelligenceText;
@property (nonatomic, retain) IBOutlet UILabel *activityTimeReliabilityText;
@property (nonatomic, retain) IBOutlet UILabel *activityTimeFatigabilityText;
@property (nonatomic, retain) IBOutlet UILabel *activityTimeDateText;

- (void)updateDate;
- (void)updateStatus;

@end
