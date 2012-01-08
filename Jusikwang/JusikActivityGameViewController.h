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
@interface JusikActivityGameViewController : UIViewController <JusikGameController>

@property (nonatomic, retain) JusikPlayer *player;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

@end

extern NSString *const JusikActivityGameViewGameDidStartNotification;
extern NSString *const JusikActivityGameViewGameDidStopNotification;