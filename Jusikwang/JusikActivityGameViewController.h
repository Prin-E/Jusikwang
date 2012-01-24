//
//  JusikActivityGameViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 8..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JusikGameController.h"

@class JusikPlayer;
@class JusikDBManager;
@interface JusikActivityGameViewController : UIViewController <JusikGameController>

@property (nonatomic, retain) JusikPlayer *player;
@property (nonatomic, readonly) NSInteger activityCount;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, retain) JusikDBManager *db;

@property (nonatomic) NSUInteger visitComputerCount;
@property (nonatomic) NSUInteger visitChartCount;
@property (nonatomic) NSUInteger visitBookCount;
@property (nonatomic) NSUInteger visitBedCount;
@property (nonatomic) NSUInteger visitDoorCount;

@property (nonatomic) NSUInteger visitHeeseungCount;
@property (nonatomic) NSUInteger visitShopCount;
@property (nonatomic) NSUInteger visitStreetCount;
@property (nonatomic) NSUInteger visitParkCount;
@property (nonatomic) NSUInteger visitPoliceCount;

- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

@end

extern NSString *const JusikActivityGameViewGameDidStartNotification;
extern NSString *const JusikActivityGameViewGameDidStopNotification;