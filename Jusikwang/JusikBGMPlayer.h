//
//  JusikBGMPlayer.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 8..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JusikBGMPlayer : NSObject

@property (nonatomic) double volume;

+ (JusikBGMPlayer *)sharedPlayer;

- (NSArray *)musics;

- (void)loadMusic: (NSString *)musicName;
- (void)playMusic: (NSString *)musicName;

@end

extern NSString *const JusikBGMMusicMainMenu;
extern NSString *const JusikBGMMusicHappyEnding;
extern NSString *const JusikBGMMusicActivity;
extern NSString *const JusikBGMMusicNormalEnding;
extern NSString *const JusikBGMMusicBadEnding;