//
//  JusikPlayerInfoViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlidingTabsControl.h"

@class JusikPlayer;
@interface JusikPlayerInfoViewController : UIViewController <SlidingTabsControlDelegate>

// Core
@property (nonatomic, retain) JusikPlayer *player;

// UI
@property (nonatomic, retain) IBOutlet SlidingTabsControl *tab;
@property (nonatomic, retain) IBOutlet UIView *contentView;

@property (nonatomic, retain) IBOutlet UIView *statView;
@property (nonatomic, retain) IBOutlet UILabel *statPlayerName;
@property (nonatomic, retain) IBOutlet UILabel *statAssetText;
@property (nonatomic, retain) IBOutlet UILabel *statIntelligenceText;
@property (nonatomic, retain) IBOutlet UILabel *statReliabilityText;
@property (nonatomic, retain) IBOutlet UILabel *statFatigabilityText;

@property (nonatomic, retain) IBOutlet UIView *newsHistoryView;

- (void)updateStat;

@end
